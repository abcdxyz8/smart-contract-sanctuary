// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./facades/HardCoreLike.sol";
import "./facades/FeeDistributorLike.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import './PriceOracle.sol';

contract LiquidVault is Ownable {

    event EthereumDeposited(
        address from,
        address to,
        uint256 amount,
        uint256 percentageAmount
    );

    /*
    * A user can hold multiple locked LP batches.
    * Each batch takes 30 days to incubate
    */
    event LPQueued(
        address holder,
        uint256 amount,
        uint256 eth,
        uint256 hardCore,
        uint256 timeStamp
    );

    event LPClaimed(
        address holder,
        uint256 amount,
        uint256 timestamp,
        uint256 exitfee
    );

    struct LPbatch {
        address holder;
        uint256 amount;
        uint256 timestamp;
    }

    struct liquidVaultConfig {
        address hardCore;
        IUniswapV2Router02 uniswapRouter;
        IUniswapV2Pair tokenPair;
        FeeDistributorLike feeDistributor;
        PriceOracle uniswapOracle;
        address weth;
        address payable ethReceiver;
        uint32 stakeDuration;
        uint8 donationShare; //0-100
        uint8 purchaseFee; //0-100
    }

    bool private locked;
    modifier lock {
        require(!locked, "HARDCORE: reentrancy violation");
        locked = true;
        _;
        locked = false;
    }

    liquidVaultConfig public config;
    //Front end can loop through this and inspect if enough time has passed
    mapping(address => LPbatch[]) public LockedLP;
    mapping(address => uint256) public queueCounter;

    function seed(
        uint32 duration,
        address hcore,
        address feeDistributor,
        address payable ethReceiver,
        uint8 donationShare, // LP Token
        uint8 purchaseFee, // ETH
        PriceOracle uniswapOracle
    ) public onlyOwner {
        config.hardCore = hcore;
        config.uniswapRouter = IUniswapV2Router02(
            HardCoreLike(hcore).uniswapRouter()
        );
        config.tokenPair = IUniswapV2Pair(
            HardCoreLike(hcore).tokenUniswapPair()
        );
        config.feeDistributor = FeeDistributorLike(feeDistributor);
        config.weth = config.uniswapRouter.WETH();
        config.uniswapOracle = uniswapOracle;
        setEthFeeAddress(ethReceiver);
        setParameters(duration, donationShare, purchaseFee);
    }

    function setOracleAddress(PriceOracle _uniswapOracle) external onlyOwner {
        require(address(_uniswapOracle) != address(0), 'Zero address not allowed');
        config.uniswapOracle = _uniswapOracle;
    }

    function setEthFeeAddress(address payable ethReceiver)
        public
        onlyOwner
    {
        require(
            ethReceiver != address(0),
            "LiquidVault: eth receiver is zero address"
        );

        config.ethReceiver = ethReceiver;
    }

    function setParameters(uint32 duration, uint8 donationShare, uint8 purchaseFee)
        public
        onlyOwner
    {
        require(
            donationShare <= 100,
            "HardCore: donation share % between 0 and 100"
        );
        require(
            purchaseFee <= 100,
            "HardCore: purchase fee share % between 0 and 100"
        );

        config.stakeDuration = duration * 1 days;
        config.donationShare = donationShare;
        config.purchaseFee = purchaseFee;
    }

    function purchaseLPFor(address beneficiary) public payable lock {
        config.feeDistributor.distributeFees();
        require(msg.value > 0, "HARDCORE: eth required to mint Hardcore LP");

        uint256 feeValue = config.purchaseFee * msg.value / 100;
        uint256 exchangeValue = msg.value - feeValue;

        (uint256 reserve1, uint256 reserve2, ) = config.tokenPair.getReserves();

        uint256 hardCoreRequired;

        if (address(config.hardCore) < address(config.weth)) {
            hardCoreRequired = config.uniswapRouter.quote(
                exchangeValue,
                reserve2,
                reserve1
            );
        } else {
            hardCoreRequired = config.uniswapRouter.quote(
                exchangeValue,
                reserve1,
                reserve2
            );
        }

        uint256 balance = HardCoreLike(config.hardCore).balanceOf(address(this));
        require(
            balance >= hardCoreRequired,
            "HARDCORE: insufficient HardCore in LiquidVault"
        );

        IWETH(config.weth).deposit{ value: exchangeValue }();
        address tokenPairAddress = address(config.tokenPair);
        IWETH(config.weth).transfer(tokenPairAddress, exchangeValue);
        HardCoreLike(config.hardCore).transfer(
            tokenPairAddress,
            hardCoreRequired
        );
        config.ethReceiver.transfer(feeValue);
        config.uniswapOracle.update();

        uint256 liquidityCreated = config.tokenPair.mint(address(this));

        LockedLP[beneficiary].push(
            LPbatch({
                holder: beneficiary,
                amount: liquidityCreated,
                timestamp: block.timestamp
            })
        );

        emit LPQueued(
            beneficiary,
            liquidityCreated,
            exchangeValue,
            hardCoreRequired,
            block.timestamp
        );

        emit EthereumDeposited(msg.sender, config.ethReceiver, exchangeValue, feeValue);
    }

    //send eth to match with HCORE tokens in LiquidVault
    function purchaseLP() public payable {
        purchaseLPFor(msg.sender);
    }

    //pops latest LP if older than period
    function claimLP() public {
        uint256 length = LockedLP[msg.sender].length;
        require(length > 0, "HARDCORE: No locked LP.");
        uint256 oldest = queueCounter[msg.sender];
        LPbatch memory batch = LockedLP[msg.sender][oldest];
        require(
            block.timestamp - batch.timestamp > config.stakeDuration,
            "HARDCORE: LP still locked."
        );
        oldest = LockedLP[msg.sender].length - 1 == oldest
            ? oldest
            : oldest + 1;
        queueCounter[msg.sender] = oldest;
        uint256 donation = (config.donationShare * batch.amount) / 100;
        emit LPClaimed(msg.sender, batch.amount, block.timestamp, donation);
        require(
            config.tokenPair.transfer(address(0), donation),
            "HardCore: donation transfer failed in LP claim."
        );
        require(
            config.tokenPair.transfer(batch.holder, batch.amount - donation),
            "HardCore: transfer failed in LP claim."
        );
    }

    function lockedLPLength(address holder) public view returns (uint256) {
        return LockedLP[holder].length;
    }

    function getLockedLP(address holder, uint256 position)
        public
        view
        returns (
            address,
            uint256,
            uint256
        )
    {
        LPbatch memory batch = LockedLP[holder][position];
        return (batch.holder, batch.amount, batch.timestamp);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '@uniswap/lib/contracts/libraries/FixedPoint.sol';
import '@uniswap/v2-periphery/contracts/libraries/UniswapV2OracleLibrary.sol';
import "./facades/ERC20Like.sol";


contract PriceOracle {
    using FixedPoint for *;
    IUniswapV2Pair public immutable pair;
    uint public immutable multiplier;
    uint private priceLast;
    uint public priceCumulativeLast;
    uint32 public blockTimestampLast;

    address public tokenA;
    address public tokenB;
    address public token0;

    constructor(IUniswapV2Pair _pair, address _tokenA, address _tokenB) public {
        pair = _pair;
        tokenA = _tokenA;
        tokenB = _tokenB;
        multiplier = uint(10)**(ERC20Like(_pair.token1()).decimals());
        (token0, ) = _tokenA < _tokenB
            ? (_tokenA, _tokenB)
            : (_tokenB, _tokenA);
        
        if(token0 == _tokenA) {
          priceCumulativeLast = _pair.price0CumulativeLast();
        } else {
          priceCumulativeLast = _pair.price1CumulativeLast();
        }
    }
    function update() public returns(uint) {
        uint112 reserve0;
        uint112 reserve1;
        (reserve0, reserve1, blockTimestampLast) = pair.getReserves();
        require(reserve0 != 0 && reserve1 != 0, 'PriceOracle: NO_RESERVES');

        uint _priceCumulative;
        (uint _price0Cumulative, uint _price1Cumulative, uint32 _blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(address(pair));
        if(token0 == tokenA) {
          _priceCumulative = _price0Cumulative;
        } else {
          _priceCumulative = _price1Cumulative;
        }
        uint _priceCumulativeLast = priceCumulativeLast;
        uint _blockTimestampLast = blockTimestampLast;
        uint _price;
        if (_blockTimestamp != _blockTimestampLast) {
            _price = FixedPoint.uq112x112(uint224((_priceCumulative - _priceCumulativeLast) /
                (_blockTimestamp - _blockTimestampLast))).mul(multiplier).decode144();
            priceLast = _price;
            priceCumulativeLast = _priceCumulative;
            blockTimestampLast = _blockTimestamp;
        } else {
            _price = priceLast;
        }
        return _price;
    }
    // note this will always return 0 before update has been called successfully for the first time.
    function consult() external view returns (uint) {
        uint _priceCumulative;

        (uint _price0Cumulative, uint _price1Cumulative, uint32 _blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(address(pair));

        if(token0 == tokenA) {
          _priceCumulative = _price0Cumulative;
        } else {
          _priceCumulative = _price1Cumulative;
        }
        uint _priceCumulativeLast = priceCumulativeLast;
        uint _blockTimestampLast = blockTimestampLast;
        // most recent price is already calculated.
        if (_blockTimestamp == _blockTimestampLast) {
            return priceLast;
        }
        return FixedPoint.uq112x112(uint224((_priceCumulative - _priceCumulativeLast) / 
            (_blockTimestamp - _blockTimestampLast))).mul(multiplier).decode144();
    }
    function updateAndConsult() external returns (uint) {
        return update();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.1;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract ERC20Like is IERC20 {
    function totalSupply() external view virtual override returns (uint256);

    function balanceOf(address account) external view virtual override returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        virtual
    override
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        virtual
    override
        returns (uint256);

    function approve(address spender, uint256 amount)
        external
        virtual
    override
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual override returns (bool);

    function name() public view virtual returns (string memory);

    function symbol() public view virtual returns (string memory);

    function decimals() public view virtual returns (uint8);

    function burn(uint256 value) public virtual;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

abstract contract FeeDistributorLike {
    function distributeFees() public virtual;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.1;
import "./ERC20Like.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

abstract contract HardCoreLike is ERC20Like {
    function uniswapRouter() public virtual returns (IUniswapV2Router02);

    function tokenUniswapPair() public virtual returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "../GSN/Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity >=0.4.0;

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))
library FixedPoint {
    // range: [0, 2**112 - 1]
    // resolution: 1 / 2**112
    struct uq112x112 {
        uint224 _x;
    }

    // range: [0, 2**144 - 1]
    // resolution: 1 / 2**112
    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 x) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(x) << RESOLUTION);
    }

    // encodes a uint144 as a UQ144x112
    function encode144(uint144 x) internal pure returns (uq144x112 memory) {
        return uq144x112(uint256(x) << RESOLUTION);
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {
        require(x != 0, 'FixedPoint: DIV_BY_ZERO');
        return uq112x112(self._x / uint224(x));
    }

    // multiply a UQ112x112 by a uint, returning a UQ144x112
    // reverts on overflow
    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {
        uint z;
        require(y == 0 || (z = uint(self._x) * y) / y == uint(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

    // returns a UQ112x112 which represents the ratio of the numerator to the denominator
    // equivalent to encode(numerator).div(denominator)
    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    // decode a UQ112x112 into a uint112 by truncating after the radix point
    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    // decode a UQ144x112 into a uint144 by truncating after the radix point
    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
    }
}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

pragma solidity >=0.5.0;

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '@uniswap/lib/contracts/libraries/FixedPoint.sol';

// library with helper methods for oracles that are concerned with computing average prices
library UniswapV2OracleLibrary {
    using FixedPoint for *;

    // helper function that returns the current block timestamp within the range of uint32, i.e. [0, 2**32 - 1]
    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2 ** 32);
    }

    // produces the cumulative price using counterfactuals to save gas and avoid a call to sync.
    function currentCumulativePrices(
        address pair
    ) internal view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {
        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();

        // if time has elapsed since the last update on the pair, mock the accumulated price values
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            // subtraction overflow is desired
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            // addition overflow is desired
            // counterfactual
            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            // counterfactual
            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}