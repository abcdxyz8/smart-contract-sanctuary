pragma solidity ^0.4.25;



library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting &#39;a&#39; not being zero, but the
    // benefit is lost if &#39;b&#39; is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}


library Locklist {
  
  struct List {
    mapping(address => bool) registry;
  }
  
  function add(List storage list, address _addr)
    internal
  {
    list.registry[_addr] = true;
  }

  function remove(List storage list, address _addr)
    internal
  {
    list.registry[_addr] = false;
  }

  function check(List storage list, address _addr)
    view
    internal
    returns (bool)
  {
    return list.registry[_addr];
  }
}

contract Locklisted  {

  Locklist.List private _list;
  
  modifier onlyLocklisted() {
    require(Locklist.check(_list, msg.sender) == true);
    _;
  }

  event AddressAdded(address _addr);
  event AddressRemoved(address _addr);
  
  function LocklistedAddress()
  public
  {
    Locklist.add(_list, msg.sender);
  }

  function LocklistAddressenable(address _addr)
    public
  {
    Locklist.add(_list, _addr);
    emit AddressAdded(_addr);
  }

  function LocklistAddressdisable(address _addr)
    public
  {
    Locklist.remove(_list, _addr);
   emit AddressRemoved(_addr);
  }
  
  function LocklistAddressisListed(address _addr)
  public
  view
  returns (bool)
  {
      return Locklist.check(_list, _addr);
  }
}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable is Locklisted{
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  // function renounceOwnership() public onlyOwner {
  //   emit OwnershipRenounced(owner);
  //   owner = address(0);
  // }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    transferOwnership(_newOwner);
  }



  

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  
}

contract Kamal is Ownable {
  using SafeMath for uint256;

  event Transfer(address indexed from,address indexed to,uint256 _tokenId);
  event Approval(address indexed owner,address indexed approved,uint256 _tokenId);



  string public constant symbol = "KML";
  string public constant name = "kamal";
  uint8 public decimals = 5;

  uint256 public totalSupply = 2000000000 * 10 ** uint256(decimals);
  uint256 public totalsell;
  
  mapping(address => uint256) balances;
  mapping(address => mapping (address => uint256)) allowed;


   


  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }


  constructor() public {
    balances[msg.sender] = totalSupply;
  }


  function approve(address _spender, uint256 _amount) public returns (bool success) {
    allowed[msg.sender][_spender] = _amount;
    emit   Approval(msg.sender, _spender, _amount);
    return true;
  }

  function allowance(address _owner, address _spender ) public view returns (uint256) {
    return allowed[_owner][_spender];
  }


  function transfer(address _to, uint256 _value) public returns (bool) {
    require(!LocklistAddressisListed(_to));
    require(_value <= balances[msg.sender]);
    require(_to != address(0));
    totalsell = totalsell.add(_value);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool)
  {
    require(!LocklistAddressisListed(_to));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }
  
  
  
   function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    balances[newOwner] = balances[owner];
    balances[owner] = 0;
    owner = newOwner;
    emit OwnershipTransferred(owner, newOwner);
  }


  
   

}