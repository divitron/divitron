pragma solidity ^0.4.8;

interface tokenRecipient {
  function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;
}
contract DiviTron{
  
  string public name="POT";
  string public symbol="POT";
  uint8 public decimals=6 ;
  uint256 public totalSupply;
  
  
  
  
  // This creates an array with all balances
  mapping (address => uint256) public balanceOf;
  mapping (address => mapping (address => uint256)) public allowance;
  mapping(address => uint) public owner_address;
  
  //////////burada EVENTLAR duruyor
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  event Burn(address indexed from, uint256 value);
  
  constructor(
  
  ) public {
    totalSupply =100000000 * 10 ** uint256(decimals); // Update total supply with the decimal amount
    balanceOf[msg.sender] = totalSupply; // Give the creator all initial tokens
    owner_address[msg.sender] = 1;
    
  }
  
  /////////token i?in standart functionlar /////////////////
  function _transfer(address _from, address _to, uint _value) internal {
    // Prevent transfer to 0x0 address. Use burn() instead
    require(_to != address(0x0));
    // Check if the sender has enough
    require(balanceOf[_from] >= _value);
    // Check for overflows
    require(balanceOf[_to] + _value >= balanceOf[_to]);
    // Save this for an assertion in the future
    uint previousBalances = balanceOf[_from] + balanceOf[_to];
    // Subtract from the sender
    balanceOf[_from] -= _value;
    // Add the same to the recipient
    balanceOf[_to] += _value;
    emit Transfer(_from, _to, _value);
    // Asserts are used to use static analysis to find bugs in your code. They should never fail
    assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
  }
  
  function transfer(address _to, uint256 _value) public returns (bool success) {
    _transfer(msg.sender, _to, _value);
    return true;
  }
  
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    require(_value <= allowance[_from][msg.sender]); // Check allowance
    allowance[_from][msg.sender] -= _value;
    _transfer(_from, _to, _value);
    return true;
  }
  
  function approve(address _spender, uint256 _value) public
  returns (bool success) {
    allowance[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }
  
  function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
  public
  returns (bool success) {
    tokenRecipient spender = tokenRecipient(_spender);
    if (approve(_spender, _value)) {
      spender.receiveApproval(msg.sender, _value, address(this), _extraData);
      return true;
    }
  }
  
  function burn(uint256 _value) public returns (bool success) {
    require(balanceOf[msg.sender] >= _value); // Check if the sender has enough
    balanceOf[msg.sender] -= _value; // Subtract from the sender
    totalSupply -= _value; // Updates totalSupply
    emit Burn(msg.sender, _value);
    return true;
  }
  
  function burnFrom(address _from, uint256 _value) public returns (bool success) {
    require(balanceOf[_from] >= _value); // Check if the targeted balance is enough
    require(_value <= allowance[_from][msg.sender]); // Check allowance
    balanceOf[_from] -= _value; // Subtract from the targeted balance
    allowance[_from][msg.sender] -= _value; // Subtract from the sender's allowance
    totalSupply -= _value; // Update totalSupply
    emit Burn(_from, _value);
    return true;
  }
  
  uint constant WAD = 10 ** 18;
  uint constant RAY = 10**1;
  
  address public owner = msg.sender;
  
  modifier onlyOwner() {
    uint yetkilimi = owner_address[msg.sender] ;
    require (yetkilimi > 0);
    _;
  }
  
  function New_Owner (address new_owner_address) onlyOwner returns(bool) {
    owner_address[new_owner_address] = 1;
    return true;
  }
  
  
  struct minedtoken{
  uint qty; }
  
  struct frozentoken{
  uint qty; }
  
  struct unfrozentoken{
    uint qty;
  uint256 unlockTime; }
  
  
  mapping(address => minedtoken) public minners;
  mapping(address => frozentoken) public frozeners;
  mapping(address => unfrozentoken) public unfrozeners;
  mapping (int8 => address) public frozenersIndex;
  int8 public frozenersIndexSize;
  mapping (int8 => address) public minnersIndex;
  
  
  function WithDraw(address wallet , uint amount) onlyOwner returns(bool) {
    wallet.transfer(amount);
    casino_balance -= amount;
    return true;
  }
  
  event Prize_Trx_Sends(address _to, uint amount_trx , uint amount_pot);
  function Prize_Trx_Send(address wallet , uint amount_trx, uint amount_pot) onlyOwner returns(bool) {
    
    wallet.transfer(amount_trx);
    if (amount_pot >0) updateminedtokenQty(wallet,amount_pot);
    emit Prize_Trx_Sends(wallet,amount_trx,amount_pot);
  }
  
  
  ///////////////?NEML? TOKENLARIN DONDURULACA?I ADRES BURADAN SE??LECEK
  address public token_frozen_store ;
  function Set_Token_Frozen_Store_Address(address newfrozestore) onlyOwner returns(bool) {
    token_frozen_store = newfrozestore;
  }
  /////////////////////////////////////////////////////////////////////////////////
  
  
  /////Genel veriler;
  function Customer_Waiting_Token() public view returns (uint) {
    return (minners[msg.sender].qty);
  }
  
  uint public casino_balance =0;
  function Set_Casino_Balance (uint balance) onlyOwner {
    casino_balance = balance;
  }
  
  uint public divid_profit =80;
  function Set_Divid_Profit (uint _divid_profit) onlyOwner {
    divid_profit = _divid_profit;
  }
  
  
  function Divid_Balance() public view returns (uint) {
    uint divid_balance;
    if (this.balance<=casino_balance) divid_balance=0 ;
    if (this.balance>casino_balance) {
      uint divid_balance_full = this.balance - casino_balance;
      divid_balance =uint128((divid_balance_full * divid_profit) / 100);
    }
    return (divid_balance);
  }
  
  function contract_balance () public view returns (uint) {
    return this.balance;
  }
  
  function Customer_Token_Balance() public view returns (uint) {
    return (balanceOf[msg.sender]);
  }
  
  function Customer_Frozen_Token_Balance() public view returns (uint) {
    return (frozeners[msg.sender].qty);
  }
  
  function Customer_Waiting_Unfreeze_Token_Balance() public view returns (uint) {
    return (unfrozeners[msg.sender].qty);
  }
  
  function Customer_Waiting_Unfreeze_Time() public view returns (uint) {
    return (unfrozeners[msg.sender].unlockTime);
  }
  
  
  
  uint public level_stage =1;
  uint public next_level =1000000000000;
  uint256 public level_trx =1000000000;
  function getlevel () public view returns(uint) {
    if (totalmined>=next_level) {next_level +=1000000000000;
    level_trx +=10000000;
    level_stage+=1;
  }
  return (level_trx) ;
}



uint256 public totalmined;
function updateminedtokenQty(address _minedaddress, uint _qty) internal returns (uint) {
  if (totalmined<100000000000000) {
    uint128 team_token =uint128((_qty * 20) / 100);
    uint dusulecek_total = team_token + _qty;
    balanceOf[owner] -= dusulecek_total ;//Token genel balance'da d??elim
    minners[_minedaddress].qty = minners[_minedaddress].qty + _qty; //adedi ekle
    balanceOf[team_token_wallet] += team_token ;
    totalmined+=dusulecek_total;
    return minners[_minedaddress].qty; // son_adedi goster
  }
}

function Outgame_Mining_Token(address _minedaddress, uint256 _qty) onlyOwner {
  if (totalmined<100000000000000) {
    uint128 team_token =uint128((_qty * 20) / 100);
    uint dusulecek_total = team_token + _qty;
    balanceOf[owner] -= dusulecek_total ;//Token genel balance'da d??elim
    minners[_minedaddress].qty = minners[_minedaddress].qty + _qty; //adedi ekle
    balanceOf[team_token_wallet] += team_token ;
    totalmined+=dusulecek_total;
  }
}


//Burada kaz?lan tokenlar? c?zdana aktaracak
function Waiting_Token_Withdraw () public returns (uint){
  balanceOf[msg.sender] +=minners[msg.sender].qty;
  minners[msg.sender].qty=0;
  return balanceOf[msg.sender] ;
}

////
uint public Freeze_Total_Token;

//Tokenlar? Dondur
function Set_Frozen() public {
  if (frozeners[msg.sender].qty==0) {
    frozenersIndex[frozenersIndexSize] = msg.sender;
    frozenersIndexSize +=1;
  }
  //?nce tokeni hesaptan kendi hesab?na al...
  balanceOf[token_frozen_store] +=balanceOf[msg.sender]; // dondurulmu? token c?zdan?na al?yoruz
  frozeners[msg.sender].qty += balanceOf[msg.sender]; //gelen tutar? donduruyoruz
  Freeze_Total_Token +=balanceOf[msg.sender];
  balanceOf[msg.sender] =0; // adam?n tokenini al?yoruz
}


uint public Unfreeze_Wait_Long =86300; //30000 trx casino balanci
function Set_Unfreeze_Wait_Long (uint _unfreeze_wait_long) onlyOwner {
  Unfreeze_Wait_Long = _unfreeze_wait_long;
}

function Unfreeze_Get () public returns (uint256) {
  require(frozeners[msg.sender].qty>0);
  uint256 unlockTime;
  uint256 now_time=block.timestamp;
  if (now_time >0 ) {
    unlockTime =now_time + Unfreeze_Wait_Long;
    Freeze_Total_Token-=frozeners[msg.sender].qty;
    unfrozeners[msg.sender].qty += frozeners[msg.sender].qty;
    unfrozeners[msg.sender].unlockTime= unlockTime;
    frozeners[msg.sender].qty = 0;
    return (unlockTime);
  }
}

function Unfreeze_Claim () public {
  require(unfrozeners[msg.sender].qty>0);
  uint256 now_time=block.timestamp;
  if (now_time >0 ) {
    if (unfrozeners[msg.sender].unlockTime<=now_time)
    {
      balanceOf[token_frozen_store] -= unfrozeners[msg.sender].qty;
      balanceOf[msg.sender] += unfrozeners[msg.sender].qty;
      unfrozeners[msg.sender].qty =0;
    }
  }
}



address team_token_wallet;
function Set_Team_Token_Wallet (address wallet) onlyOwner {
  team_token_wallet = wallet;
}


uint public Divid_Add_Time =86400; //30000 trx casino balanci
function Set_Divid_Add_Time (uint _divid_add_time) onlyOwner {
  Divid_Add_Time = _divid_add_time;
}


uint256 public next_divid_time = block.timestamp +86400;
function Set_Next_Divid_Time (uint _next_divid_time) onlyOwner {
  next_divid_time = _next_divid_time;
}


event Divid_Transfer(address divid_sent_address, uint256 amount,uint256 frozen_amount);
function divident_send () onlyOwner {
  next_divid_time =block.timestamp + Divid_Add_Time ;
  uint per_user_divid_trx = (Divid_Balance()/Freeze_Total_Token);
  int8 i;
  for (i=0;i<frozenersIndexSize;i++) {
    address customer_addr = frozenersIndex[i];
    uint customer_total_frozen =frozeners[frozenersIndex[i]].qty;
    uint send_divid_trx =per_user_divid_trx * customer_total_frozen;
    if (send_divid_trx>0) customer_addr.transfer(send_divid_trx);
    emit Divid_Transfer(customer_addr,send_divid_trx, customer_total_frozen);
  }
  if (Divid_Balance()>0) casino_balance= this.balance;
}

bool state=false;
function Is_Paused (bool set_state) onlyOwner {
  state=set_state;
}


function deal( uint8 number, uint8 param) internal returns (uint256) {
  uint b = block.number;
  uint timestamp = block.timestamp;
  return uint8(uint256(keccak256(block.blockhash(b), msg.sender,timestamp)) % 100);
}


uint256 public min_bet = 5000000;
uint256 public max_bet = 100000000000;

function Set_Min_Max_Bet (uint256 _min_bet, uint256 _max_bet) onlyOwner {
  min_bet = _min_bet;
  max_bet = _max_bet;
  
}

uint256 public Rvp = 99000;
function Set_Rvp (uint256 _rvp) onlyOwner {
  Rvp = _rvp;
}


uint blok_no = block.number;
event dice_result(address bettor, uint8 number, uint8 prediction, uint256 sonuc, uint256 bets, uint256 payout);
function betting (uint8 number, uint8 param) payable returns(uint256){
  require (msg.value>=min_bet);
  require (msg.value<=max_bet);
  require(state==false);
  // require (blok_no<block.number);
  blok_no = block.number;
  address bettor = msg.sender;
  uint256 sonuc=deal(number,param);
  uint256 sayi_aralik;
  uint256 kar_orani;
  uint256 donecek_odeme;
  
  //kazilan token hesaplama
  uint minedqty;
  uint totalqty; // c?zdan?n toplam bekleyn tokeni
  //token 6 decimal yani bir milyonla ?arp
  uint gelen_bahis = msg.value * 100000;
  minedqty = rdiv(gelen_bahis,getlevel()); //10 milyona kadar ?arp zorlu?u
  totalqty =updateminedtokenQty(msg.sender, minedqty);
  
  
  if (sonuc > number && number>=4 && number <=98 && param==1){
    sayi_aralik = 99-number;
    kar_orani = rdiv(Rvp,sayi_aralik);
    donecek_odeme =( msg.value * kar_orani )/10000;
    bettor.transfer(donecek_odeme);
    emit dice_result(bettor,number,param,sonuc,msg.value,donecek_odeme);
    return donecek_odeme;
    } else if (param==1) {
      
      emit dice_result(bettor,number,param,sonuc,msg.value,donecek_odeme);
      return sonuc;
    }
    
    //e?er alt dediyse
    if (sonuc < number && number<=95 && number>=1 && param==0){
      sayi_aralik =number;
      kar_orani = rdiv(Rvp,sayi_aralik);
      donecek_odeme =( msg.value * kar_orani )/10000;
      bettor.transfer(donecek_odeme);
      emit dice_result(bettor,number,param,sonuc,msg.value,donecek_odeme);
      return donecek_odeme;
      } else if (param==0) {
        
        emit dice_result(bettor,number,param,sonuc,msg.value,donecek_odeme);
        return sonuc;
      }
      
      
      
    }
    
    //matematikler
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
      require(b != 0);
      return a % b;
    }
    function add(uint x, uint y) internal pure returns (uint z) {
      require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
      require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
      require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
    
    function min(uint x, uint y) internal pure returns (uint z) {
      return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
      return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
      return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
      return x >= y ? x : y;
    }
    
    
    
    function wmul(uint x, uint y) internal pure returns (uint z) {
      z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
      z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
      z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
      z = add(mul(x, RAY), y / 2) / y;
    }
    
    function rpow(uint x, uint n) internal pure returns (uint z) {
      z = n % 2 != 0 ? x : RAY;
      
      for (n /= 2; n != 0; n /= 2) {
        x = rmul(x, x);
        
        if (n % 2 != 0) {
          z = rmul(z, x);
        }
      }
    }
    //matematikler
    
    
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  