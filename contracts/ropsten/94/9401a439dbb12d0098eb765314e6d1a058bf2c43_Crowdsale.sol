pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        // Gas optimization: this is cheaper than requiring &#39;a&#39; not being zero, but the
        // benefit is lost if &#39;b&#39; is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */ 
    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold

        return c;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    )
    internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    )
    internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    )
    internal {
        require(token.approve(spender, value));
    }
}

/**
 * @title Multiownable
 * @dev The Multiownable contract has many addresses as a owners, which can call a METHODS
 * but method will work only after enough amount of owners will sign the same
 * method with the same parameters
 */
contract Multiownable {

    // VARIABLES

    uint256 private ownersGeneration;
    uint256 private howManyOwnersDecide;
    address[] private owners;

    bytes32[] public allOperations;
    address private insideCallSender;
    uint256 private insideCallCount;
    address private superOwner;

    // Reverse lookup tables for owners and allOperations
    mapping(address => uint) private ownersIndices; // Starts from 1
    mapping(bytes32 => uint) private allOperationsIndicies;

    // Owners voting mask per operations
    mapping(bytes32 => uint256) private votesMaskByOperation;
    mapping(bytes32 => uint256) private votesCountByOperation;

    // EVENTS

    event OwnershipTransferred(address[] previousOwners, uint howManyOwnersDecide, address[] newOwners, uint newHowManyOwnersDecide);
    event OperationCreated(bytes32 operation, uint howMany, uint ownersCount, address proposer);
    event OperationUpvoted(bytes32 operation, uint votes, uint howMany, uint ownersCount, address upvoter);
    event OperationPerformed(bytes32 operation, uint howMany, uint ownersCount, address performer);
    event OperationDownvoted(bytes32 operation, uint votes, uint ownersCount, address downvoter);
    event OperationCancelled(bytes32 operation, address lastCanceller);

    // ACCESSORS

    function isOwner(address wallet) public constant returns(bool) {
        return ownersIndices[wallet] > 0;
    }

    function ownersCount() public constant returns(uint) {
        return owners.length;
    }

    function allOperationsCount() public constant returns(uint) {
        return allOperations.length;
    }

    // MODIFIERS

    /**
     * @dev Allows to perform method by any of the owners
     */
    modifier onlyAnyOwner {
        if (checkHowManyOwners(1)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = 1;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    /**
     * @dev Allows to perform method only after many owners call it with the same arguments
     */
    modifier onlyManyOwners {
        if (checkHowManyOwners(howManyOwnersDecide)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = howManyOwnersDecide;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    /**
     * @dev Allows to perform method only after all owners call it with the same arguments
     */
    modifier onlyAllOwners {
        if (checkHowManyOwners(owners.length)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = owners.length;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    /**
     * @dev Allows to perform method only after some owners call it with the same arguments
     */
    modifier onlySomeOwners(uint howMany) {
        require(howMany > 0, "onlySomeOwners: howMany argument is zero");
        require(howMany <= owners.length, "onlySomeOwners: howMany argument exceeds the number of owners");

        if (checkHowManyOwners(howMany)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = howMany;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    // CONSTRUCTOR

    constructor() public {
        owners.push(msg.sender);
        ownersIndices[msg.sender] = 1;
        howManyOwnersDecide = 1;
    }

    // INTERNAL METHODS

    /**
     * @dev onlyManyOwners modifier helper
     */
    function checkHowManyOwners(uint howMany) internal returns(bool) {
        if (insideCallSender == msg.sender) {
            require(howMany <= insideCallCount, "checkHowManyOwners: nested owners modifier check require more owners");
            return true;
        }

        uint ownerIndex = ownersIndices[msg.sender] - 1;
        require(ownerIndex < owners.length, "checkHowManyOwners: msg.sender is not an owner");
        bytes32 operation = keccak256(abi.encodePacked(msg.data, ownersGeneration));

        require((votesMaskByOperation[operation] & (2 ** ownerIndex)) == 0, "checkHowManyOwners: owner already voted for the operation");

        votesMaskByOperation[operation] |= (2 ** ownerIndex);
        uint operationVotesCount = votesCountByOperation[operation] + 1;
        votesCountByOperation[operation] = operationVotesCount;

        if (operationVotesCount == 1) {
            allOperationsIndicies[operation] = allOperations.length;
            allOperations.push(operation);
            emit OperationCreated(operation, howMany, owners.length, msg.sender);
        }
        emit OperationUpvoted(operation, operationVotesCount, howMany, owners.length, msg.sender);

        // If enough owners confirmed the same operation
        if (votesCountByOperation[operation] >= howMany) {
            if (howMany != 1 && votesMaskByOperation[operation] & (2 ** (ownersIndices[superOwner] - 1)) == 0) {
                return false;
            }

            deleteOperation(operation);
            emit OperationPerformed(operation, howMany, owners.length, msg.sender);
            return true;
        }

        return false;
    }

    /**
     * @dev Used to delete cancelled or performed operation
     * @param operation defines which operation to delete
     */
    function deleteOperation(bytes32 operation) internal {
        uint index = allOperationsIndicies[operation];
        if (index < allOperations.length - 1) { // Not last
            allOperations[index] = allOperations[allOperations.length - 1];
            allOperationsIndicies[allOperations[index]] = index;
        }
        allOperations.length--;

        delete votesMaskByOperation[operation];
        delete votesCountByOperation[operation];
        delete allOperationsIndicies[operation];
    }

    // PUBLIC METHODS

    /**
     * @dev Allows owners to change their mind by cancelling votesMaskByOperation operations
     * @param operation defines which operation to delete
     */
    function cancelPending(bytes32 operation) public onlyAnyOwner {
        uint ownerIndex = ownersIndices[msg.sender] - 1;
        require((votesMaskByOperation[operation] & (2 ** ownerIndex)) != 0, "cancelPending: operation not found for this user");
        votesMaskByOperation[operation] &= ~(2 ** ownerIndex);
        uint operationVotesCount = votesCountByOperation[operation] - 1;
        votesCountByOperation[operation] = operationVotesCount;
        emit OperationDownvoted(operation, operationVotesCount, owners.length, msg.sender);
        if (operationVotesCount == 0) {
            deleteOperation(operation);
            emit OperationCancelled(operation, msg.sender);
        }
    }

    /**
     * @dev Allows owners to change ownership
     * @param newOwners defines array of addresses of new owners
     * @param newHowManyOwnersDecide defines how many owners can decide
     */
    function transferOwnershipWithHowMany(address[] newOwners, address _superOwner, uint256 newHowManyOwnersDecide) public onlyManyOwners {
        require(newOwners.length > 0, "transferOwnershipWithHowMany: owners array is empty");
        require(_superOwner != address(0), "transferOwnershipWithHowMany: _superOwner address is not valid");
        require(newOwners.length <= 256, "transferOwnershipWithHowMany: owners count is greater then 256");
        require(newHowManyOwnersDecide > 0, "transferOwnershipWithHowMany: newHowManyOwnersDecide equal to 0");
        require(newHowManyOwnersDecide <= newOwners.length, "transferOwnershipWithHowMany: newHowManyOwnersDecide exceeds the number of owners");

        // Reset owners reverse lookup table
        for (uint j = 0; j < owners.length; j++) {
            delete ownersIndices[owners[j]];
        }

        superOwner = _superOwner;
        ownersIndices[superOwner] = 1;

        for (uint i = 0; i < newOwners.length; i++) {
            require(newOwners[i] != address(0), "transferOwnershipWithHowMany: owners array contains zero");
            require(ownersIndices[newOwners[i]] == 0, "transferOwnershipWithHowMany: owners array contains duplicates");
            ownersIndices[newOwners[i]] = i + 2;
        }

        emit OwnershipTransferred(owners, howManyOwnersDecide, newOwners, newHowManyOwnersDecide);

        owners = newOwners;
        owners.push(superOwner);
        howManyOwnersDecide = newHowManyOwnersDecide;
        allOperations.length = 0;
        ownersGeneration++;
    }

}

/**
 * @title EthPriceOraclize interface
 */
interface IEthPriceOraclize {
	function changeQueryDelay(uint256 newDelay) external;
	function getEthPrice() external view returns (uint256);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns(uint256);

    function balanceOf(address who) external view returns(uint256);

    function allowance(address owner, address spender)
    external view returns(uint256);

    function transfer(address to, uint256 value) external returns(bool);

    function approve(address spender, uint256 value)
    external returns(bool);

    function transferFrom(address from, address to, uint256 value)
    external returns(bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract IToken is IERC20 {
    function pause() external;
	function unpause() external;
    function addLockedAccount(address _account, uint256 amount, uint256 dateOfRelease) external;
}

/**
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 * See RBAC.sol for example usage.
 */
library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage _role, address _account)
    internal {
        _role.bearer[_account] = true;
    }

    /**
     * @dev remove an account&#39;s access to this role
     */
    function remove(Role storage _role, address _account)
    internal {
        _role.bearer[_account] = false;
    }

    /**
     * @dev check if an account has this role
     * // reverts
     */
    function check(Role storage _role, address _account)
    internal
    view {
        require(has(_role, _account), "Account is not whitelisted");
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage _role, address _account)
    internal
    view
    returns(bool) {
        return _role.bearer[_account];
    }
}

/**
 * @title RBAC (Role-Based Access Control)
 * @author Matt Condon (@Shrugs)
 * @dev Stores and provides setters and getters for roles and addresses.
 * Supports unlimited numbers of roles and addresses.
 * See //contracts/mocks/RBACMock.sol for an example of usage.
 * This RBAC method uses strings to key roles. It may be beneficial
 * for you to write your own implementation of this interface using Enums or similar.
 */
contract RBAC {
    using Roles for Roles.Role;

    mapping(string => Roles.Role) private roles;

    event RoleAdded(address indexed operator, string role);
    event RoleRemoved(address indexed operator, string role);

    /**
     * @dev reverts if addr does not have role
     * @param _operator address
     * @param _role the name of the role
     * // reverts
     */
    function checkRole(address _operator, string _role)
    public
    view {
        roles[_role].check(_operator);
    }

    /**
     * @dev determine if addr has role
     * @param _operator address
     * @param _role the name of the role
     * @return bool
     */
    function hasRole(address _operator, string _role)
    public
    view
    returns(bool) {
        return roles[_role].has(_operator);
    }

    /**
     * @dev add a role to an address
     * @param _operator address
     * @param _role the name of the role
     */
    function _addRole(address _operator, string _role)
    internal {
        roles[_role].add(_operator);
        emit RoleAdded(_operator, _role);
    }

    /**
     * @dev remove a role from an address
     * @param _operator address
     * @param _role the name of the role
     */
    function _removeRole(address _operator, string _role)
    internal {
        roles[_role].remove(_operator);
        emit RoleRemoved(_operator, _role);
    }

    /**
     * @dev modifier to scope access to a single role (uses msg.sender as addr)
     * @param _role the name of the role
     * // reverts
     */
    modifier onlyRole(string _role) {
        checkRole(msg.sender, _role);
        _;
    }
}

/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * This simplifies the implementation of "user permissions".
 */
contract Whitelist is RBAC, Multiownable {

    // Name of the whitelisted role.
    string private constant ROLE_WHITELISTED = "whitelist";

    // Backend based account role
    string private constant ROLE_BACKEND = "backend";

    /**
     * @dev Throws if operator is not whitelisted.
     * @param _operator address
     */
    modifier onlyIfWhitelisted(address _operator) {
        checkRole(_operator, ROLE_WHITELISTED);
        _;
    }

    /**
     * @dev Throws if operator not the backend address
     * @param _operator address
     */
    modifier onlyBackEnd(address _operator) {
        checkRole(_operator, ROLE_BACKEND);
        _;
    }

    /**
     * @dev add an address to the backend
     * @param _operator address
     * @return true if the address was added to the backend addresses, false if the address was already in the backend addresses
     */
    function addAddressToBackEnd(address _operator)
    public
    onlyAnyOwner
    {
        _addRole(_operator, ROLE_BACKEND);
    }

    /**
     * @dev remove an address from the backend addresses
     * @param _operator address
     * @return true if the address was removed from the backend,
     * false if the address wasn&#39;t in the backend in the first place
     */
    function removeAddressFromBackend(address _operator)
    public
    onlyAnyOwner
    {
        _removeRole(_operator, ROLE_BACKEND);
    }

    /**
     * @dev Determine if an account is backend address.
     * @return true if the account is backend, false otherwise.
     */
    function isBackend(address _operator)
    public
    view
    returns(bool) {
        return hasRole(_operator, ROLE_BACKEND);
    }

    /**
     * @dev Determine if an account is whitelisted.
     * @return true if the account is whitelisted, false otherwise.
     */
    function isWhitelisted(address _operator)
    public
    view
    returns(bool) {
        return hasRole(_operator, ROLE_WHITELISTED);
    }

    /**
     * @dev add an address to the whitelist
     * @param _operator address
     * @return true if the address was added to the whitelist, false if the address was already in the whitelist
     */
    function addAddressToWhitelist(address _operator)
    public
    onlyBackEnd(msg.sender) {
        _addRole(_operator, ROLE_WHITELISTED);
    }

    /**
     * @dev add addresses to the whitelist
     * @param _operators addresses
     * @return true if at least one address was added to the whitelist,
     * false if all addresses were already in the whitelist
     */
    function addAddressesToWhitelist(address[] _operators)
    public
    onlyBackEnd(msg.sender) {
        for (uint256 i = 0; i < _operators.length; i++) {
            addAddressToWhitelist(_operators[i]);
        }
    }

    /**
     * @dev remove an address from the whitelist
     * @param _operator address
     * @return true if the address was removed from the whitelist,
     * false if the address wasn&#39;t in the whitelist in the first place
     */
    function removeAddressFromWhitelist(address _operator)
    public
    onlyBackEnd(msg.sender) {
        _removeRole(_operator, ROLE_WHITELISTED);
    }

    /**
     * @dev remove addresses from the whitelist
     * @param _operators addresses
     * @return true if at least one address was removed from the whitelist,
     * false if all addresses weren&#39;t in the whitelist in the first place
     */
    function removeAddressesFromWhitelist(address[] _operators)
    public
    onlyBackEnd(msg.sender) {
        for (uint256 i = 0; i < _operators.length; i++) {
            removeAddressFromWhitelist(_operators[i]);
        }
    }

}

/**
 * @title Crowdsale
 * @dev The main smart contract, which responsible for token distribution and token management
 */
contract Crowdsale is Whitelist {
    using SafeMath for uint256;
    using SafeERC20 for IToken;

    IToken private _token;
    address private _wallet;

    IEthPriceOraclize private _oraclize;

    bool private _open = true;

    uint256 private _weiRaised;
    uint256 private _usdRaised;
    uint256 private _tokensSold;

    uint256 private _minLimitPrivateSale = 50000000;                        // $500.000,00
    uint256 private _minLimitPublicFirstSale = 25000000;                    // $250.000,00
    uint256 private _minLimitPublicSecondSale = 55;                         // $0,55

    uint256 private _teamTokens = 457142857 * 1 ether;
    uint256 private _advisorsTokens = 140000000 * 1 ether;
    uint256 private _foundationTokens = 637857143 * 1 ether;
    uint256 private _syndicateTokens = 10000000 * 1 ether;

    struct SaleStage {
        uint256 initialAmount;
        uint256 totalAmount;
        uint256 rate;
        bool finalized;
    }

    SaleStage private early;
    SaleStage private equity;
    SaleStage private privateSale;
    SaleStage private publicFirst;
    SaleStage private publicSecond;

    /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokensPurchased(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    /**
     * @dev Constructor
     */
    constructor(address token, address oraclize, address wallet, address backend) public {
        _token = IToken(token);
        _oraclize = IEthPriceOraclize(oraclize);
        _wallet = wallet;

        addAddressToBackEnd(backend);

        early = SaleStage(300000000 * 1 ether, 300000000 * 1 ether, 10, false);
        equity = SaleStage(571428571 * 1 ether, 571428571 * 1 ether, 35, false);
        privateSale = SaleStage(271428571 * 1 ether, 271428571 * 1 ether, 10, false);
        publicFirst = SaleStage(85714286 * 1 ether, 85714286 * 1 ether, 35, false);
        publicSecond = SaleStage(27272727 * 1 ether, 27272727 * 1 ether, 55, false);
    }


    // -----------------------------------------
    // Crowdsale external interface
    // -----------------------------------------

    /**
     * @dev fallback function
     */
    function() external payable {
        buyTokens(msg.sender);
    }

    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * @param beneficiary Address performing the token purchase
     */
    function buyTokens(address beneficiary) public payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

        // calculate wei to usd amount
        uint256 usdAmount = _getEthToUsdPrice(weiAmount);
        _usdMinAmountValidate(usdAmount);

        SaleStage storage stage = _detectInvestorGroup(usdAmount);

        uint256 tokens = _getTokenAmount(usdAmount, stage.rate);
        _stageValidation(tokens, stage.totalAmount, stage.finalized);

        stage.totalAmount = stage.totalAmount.sub(tokens);

        // Removing cents after whole calculation
        usdAmount = usdAmount.div(100);

        // update global state
        _weiRaised = _weiRaised.add(weiAmount);
        _usdRaised = _usdRaised.add(usdAmount);
        _tokensSold = _tokensSold.add(tokens);

        _processPurchase(beneficiary, tokens);

        emit TokensPurchased(
        msg.sender,
        beneficiary,
        weiAmount,
        tokens
        );

        _forwardFunds();
    }

    /**
     * @dev Transfer tokens to BTC/BCH and Fiat buyers using USD calculation
     */
    function transferTokensToNonEthBuyer(address beneficiary, uint256 usd) external onlyManyOwners {
        uint256 usdAmount = usd;
        _preValidatePurchase(beneficiary, usdAmount);

        SaleStage storage stage = _detectInvestorGroup(usdAmount);

        uint256 tokens = _getTokenAmount(usdAmount, stage.rate);
        _stageValidation(tokens, stage.totalAmount, stage.finalized);

        stage.totalAmount = stage.totalAmount.sub(tokens);

        // Removing cents after whole calculation
        usdAmount = usdAmount.div(100);

        // update global state
        _usdRaised = _usdRaised.add(usdAmount);
        _tokensSold = _tokensSold.add(tokens);

        _processPurchase(beneficiary, tokens);

        emit TokensPurchased(
        msg.sender,
        beneficiary,
        0,
        tokens
        );
    }

    /**
     * @dev Transfer tokens to Early and Equity investors using USD calculation
     */
    function transferTokensToEarlyEquityInvestor(address to, uint256 usd, bool isEquity) external onlyManyOwners {
        uint256 usdAmount = usd;
        _preValidatePurchase(to, usdAmount);

        uint256 tokenAmount = 0; // Declaring token amount for usdAmount

        if(isEquity) {
            tokenAmount = _getTokenAmount(usdAmount, equity.rate);
            _stageValidation(tokenAmount, equity.totalAmount, equity.finalized);
            equity.totalAmount = equity.totalAmount.sub(tokenAmount);
            _token.addLockedAccount(to, tokenAmount, block.timestamp + 730 days);
        } else {
            tokenAmount = _getTokenAmount(usdAmount, early.rate);
            _stageValidation(tokenAmount, early.totalAmount, early.finalized);
            early.totalAmount = early.totalAmount.sub(tokenAmount);
            _token.addLockedAccount(to, tokenAmount, block.timestamp + 365 days);
        }

        // Removing cents after whole calculation
        usdAmount = usdAmount.div(100);

        // Update the state
        _tokensSold = _tokensSold.add(tokenAmount);
        _usdRaised = _usdRaised.add(usdAmount);

        _token.safeTransfer(to, tokenAmount);
    }

    /**
     * @dev Transfer token to team, advisors or foundation wallets
     * @param to of receiver
     * @param amount for send
     * @param id - Id of Stage
     * 0 - Team
     * 1 - Advisor
     * 2 - Foundation
     * 3 - Syndicat
     */
    function transferTokensToTeam(address to, uint256 amount, uint256 id) public onlyManyOwners returns (bool){
        _preValidatePurchase(to, amount);

        if(id == 0) {
            require(_teamTokens >= amount, "Not enough tokens in team balance");
            _teamTokens = _teamTokens.sub(amount);
            _processPurchase(to, amount);
        } else if(id == 1) {
            require(_advisorsTokens >= amount, "Not enough tokens in advisors balance");
            _advisorsTokens = _advisorsTokens.sub(amount);
            _processPurchase(to, amount);
        } else if(id == 2) {
            require(_foundationTokens >= amount, "Not enough tokens in foundation balance");
            _foundationTokens = _foundationTokens.sub(amount);
            _processPurchase(to, amount);
        } else if(id == 3) {
            require(_syndicateTokens >= amount, "Not enough tokens in syndicates balance");
            _syndicateTokens = _syndicateTokens.sub(amount);
            _processPurchase(to, amount);
        }

        return true;
    }

    /**
     * @dev Transfer token to team, advisors or foundation wallets
     * @param addresses of receivers
     * @param amounts for addresses
     * @param id - Id of stage
     * 0 - Team
     * 1 - Advisor
     * 2 - Foundation
     * 3 - Syndicat
     */
    function transferTokensToTeamMany(address[] addresses, uint256[] amounts, uint256 id) public onlyManyOwners returns (uint256) {
        require(addresses.length > 0, "transferTokensToTeamMany: receivers array is empty");
        require(amounts.length > 0, "transferTokensToTeamMany: amounts array is empty");
        require(addresses.length == amounts.length, "transferTokensToTeamMany: the array of receivers and amounts is not equal");

        uint256 i = 0;

        while (i < addresses.length) {
          transferTokensToTeam(addresses[i], amounts[i], id);
          i++;
        }

        return i;
    }

    // Change ETH funding address

    /**
     * @dev Change wallet address, all future funds will be transferred to this address
     */
    function changeWallet(address newWallet) external onlyManyOwners {
        require(newWallet != address(0), "changeWallet: address is invalid");
        _wallet = newWallet;
    }

    /**
     * @dev Change wallet address, all future funds will be transferred to this address
     */
    function changeEthPriceQueryDelay(uint256 newDelay) external onlyManyOwners {
        _oraclize.changeQueryDelay(newDelay);
    }

    // -----------------------------------------
    // Emergency functions
    // -----------------------------------------

    /**
     * @dev Freeze token transactions for all token owners (Pausable token)
     */
    function freezeAllTransactions() external onlyManyOwners {
        _token.pause();
    }

    /**
     * @dev Unfreeze token transactions for all token owners (Pausable token)
     */
    function unFreezeAllTransactions() external onlyManyOwners {
        _token.unpause();
    }

    /**
     * @dev Disable incoming funds
     */
    function pauseCrowdsale() external onlyManyOwners {
        _open = false;
    }

    /**
     * @dev Ebable incoming funds
     */
    function resumeCrowdsale() external onlyManyOwners {
        _open = true;
    }

    /**
     * @dev Finalize the certain stage
     * @param id - Id of stage
     * 0 - Early investors
     * 1 - Equity investors
     * 2 - Private sale
     * 3 - Public sale first
     * 4 - Public sale second
     */
    function finalizeStage(uint256 id) external onlyManyOwners {
        SaleStage storage stage = _detectStage(id);

        if(stage.totalAmount > 0) {
            early.totalAmount = early.totalAmount.add(stage.totalAmount);
            stage.totalAmount = 0;
        }

        stage.finalized = true;
    }


    // -----------------------------------------
    // Getters interface
    // -----------------------------------------

    /**
     * @return the token being sold.
     */
    function token() external view returns(IToken) {
        return _token;
    }

    /**
     * @return the oraclize interface
     */
    function oraclize() external view returns(IEthPriceOraclize) {
        return _oraclize;
    }

    /**
     * @return the address where funds are collected.
     */
    function wallet() external view returns(address) {
        return _wallet;
    }

    /**
     * @return the address where funds are collected.
     */
    function minLimitPrivateSale() external view returns(uint256) {
        return _minLimitPrivateSale;
    }

    /**
     * @return the address where funds are collected.
     */
    function minLimitPublicFirstSale() external view returns(uint256) {
        return _minLimitPublicFirstSale;
    }

    /**
     * @return the address where funds are collected.
     */
    function minLimitPublicSecondSale() external view returns(uint256) {
        return _minLimitPublicSecondSale;
    }

    /**
     * @return the mount of wei raised.
     */
    function weiRaised() external view returns(uint256) {
        return _weiRaised;
    }

    /**
     * @return the mount of USD raised.
     */
    function usdRaised() external view returns(uint256) {
        return _usdRaised;
    }

    /**
     * @return the mount of tokens sold.
     */
    function tokensSold() external view returns(uint256) {
        return _tokensSold;
    }

    /**
     * @return the mount of tokens sold.
     */
    function isOpen() external view returns(bool) {
        return _open;
    }

    /**
     * @return tokens reserve of team, advisors, foundation and syndicat balancecs
     */
    function getTokensReserve() external view returns(uint256 teamTokens, uint256 advisorsTokens, uint256 foundationTokens, uint256 syndicateTokens) {
        teamTokens = _teamTokens;
        advisorsTokens = _advisorsTokens;
        foundationTokens = _foundationTokens;
        syndicateTokens = _syndicateTokens;
    }

    /**
     * @param id - Id of stage
     * 0 - Early investors
     * 1 - Equity investors
     * 2 - Private sale
     * 3 - Public sale first
     * 4 - Public sale second
     * @return initial amount, current amount, rate, finalized or not
     */
    function getStageState(uint256 id) external view returns(uint256, uint256, uint256, bool) {
        SaleStage memory stage = _detectStage(id);

        return (
            stage.initialAmount,
            stage.totalAmount,
            stage.rate,
            stage.finalized
        );
    }

    // -----------------------------------------
    // Internal interface
    // -----------------------------------------

    /**
     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.
     * @param beneficiary Address performing the token purchase
     * @param amount Value in wei involved in the purchase
     */
    function _preValidatePurchase(address beneficiary, uint256 amount) internal onlyIfWhitelisted(beneficiary) view {
        require(_open, "_preValidatePurchase: crowdsale closed");
        require(beneficiary != address(0), "_preValidatePurchase: beneficiary address is not valid");
        require(amount != 0, "_preValidatePurchase: amount is 0");
    }

    /**
     * @dev Validation of min amount for investing
     * @param usdAmount Amount in USD which investor was sent
     */
    function _usdMinAmountValidate(uint256 usdAmount) internal view {
        require(usdAmount >= _minLimitPublicSecondSale, "_usdMinAmountValidate: minimum contribution amount is not reached");
    }

    /**
     * @dev Validation stage details
     * @param amount of tokens which will be sent
     * @param availableTokens of this stage
     * @param finalized or not
     */
    function _stageValidation(uint256 amount, uint256 availableTokens, bool finalized) internal pure {
        require(availableTokens >= amount, "_stageValidation: not enough tokens available for purchasing");
        require(!finalized, "Stage is finished");
    }

    /**
     * @dev Convert ETH to USD and return amount
     * @param weiAmount ETH amount which will convert to USD
     */
    function _getEthToUsdPrice(uint256 weiAmount) internal view returns(uint256) {
        return weiAmount.mul(_getEthPrice()).div(1 ether);
    }

    /**
     * @dev Getting price from oraclize contract
     */
    function _getEthPrice() internal view returns (uint256) {
        return _oraclize.getEthPrice();
    }

    /**
     * @dev Override to extend the way in which usd is converted to tokens.
     * @param usdAmount Value in usd to be converted into tokens
     * @return Number of tokens that can be purchased with the specified usdAmount
     */
    function _getTokenAmount(uint256 usdAmount, uint256 rate) internal pure returns (uint256) {
        return usdAmount.mul(1 ether).div(rate);
    }

    /**
     * @dev Detect to which group investor related
     */
    function _detectInvestorGroup(uint256 usdAmount) internal view returns (SaleStage storage) {
        if(usdAmount >= _minLimitPrivateSale)
            return privateSale;
        else if(usdAmount >= _minLimitPublicFirstSale)
            return publicFirst;
        else
            return publicSecond;
    }

    /**
     * @dev Detect stage by ID
     */
    function _detectStage(uint256 id) internal view returns (SaleStage storage) {
        if(id == 0)
            return early;
        else if(id == 1)
            return equity;
        else if(id == 2)
            return privateSale;
        else if(id == 3)
            return publicFirst;
        else if(id == 4)
            return publicSecond;
        else revert();
    }

    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
     * @param beneficiary Address receiving the tokens
     * @param tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
        _token.addLockedAccount(beneficiary, tokenAmount, block.timestamp + 365 days);
        _deliverTokens(beneficiary, tokenAmount);
    }

    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
     * @param beneficiary Address performing the token purchase
     * @param tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        _token.safeTransfer(beneficiary, tokenAmount);
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
}