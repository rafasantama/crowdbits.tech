pragma solidity ^0.4.21;

/*
  BASIC ERC20 Sale Contract

  Create this Sale contract first!
  Sale (address ETHwallet)   // this will send the received ETH funds to this address

 @author Hunter Long - BITS Ingeniería (Junior Calle - Rafael SantaMaría)
*/

contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) public constant returns (uint);
  function allowance(address owner, address spender) public constant returns (uint);
  function transfer(address to, uint value) public returns (bool ok);
  function transferFrom(address from, address to, uint value) public returns (bool ok);
  function approve(address _owner, address spender, uint value) public returns (bool ok);
  function mintToken(address to, uint256 value) public returns (uint256);
  function changeTransfer(bool allowed) public;
}

contract Sale {

    uint256 public maxMintable;
    uint256 public totalMinted;
    uint public duration;
    uint public exchangeRate;
    bool public isFunding;
    ERC20 public Token;
    address public ETHWallet;
    uint256 public heldTotal;
    uint256 public heldBlockLimit;
    uint public stage1discount;
    uint public stage2discount;
    uint public stage3discount;
    uint public actual_stage;
    uint public IDu = 0;
    uint public stage1limit;
    uint public stage2limit;
    uint public stage3limit;
    uint public stage1rate;
    uint public stage2rate;
    uint public stage3rate;
    uint stage1amount;
    uint stage2amount;
    uint stage3amount;
    uint stage4amount;
    uint public goal1;
    uint public goal2;
    uint public goal3;
    uint public goal4;
    uint public goal1_count;
    uint public goal2_count;
    uint public goal3_count;
    uint public goal4_count;
    bool public closed_state1;
    bool public closed_state2;
    bool public closed_state3;
    bool public closed_state4;
    uint public goal;
    uint public goal_count;
    uint amount;
    uint public wei_limit;
    uint public max_wei_unverified;
    bool  success;
    uint public adminTokens;
    bool private configSet;
    address public creator;
    uint public stage1amount_count;
    uint public stage2amount_count;
    uint public stage3amount_count;
    uint public stage4amount_count;
   
    mapping (address => uint256) public heldTokens;
    mapping (uint => uint256) public heldTokensTask;
    // mapping (address => uint) public heldTimeline;
    mapping (address => uint) address2WNS_stage1;
    mapping (address => uint) address2WNS_stage2;
    mapping (address => uint) address2WNS_stage3;
    mapping (address => uint) address2WNS_stage4;
    mapping (address => uint) public address2IDu;

    event Contribution(address from, uint256 amount);
    event ReleaseTokens(address from, uint256 amount);

    constructor (address _wallet,string _nombre_partner, string _doc_partner) public {
       
        maxMintable = 1000000000000; // 8 million max sellable (18 decimals)
        goal = 523000000000000000000;
        ETHWallet = _wallet;
        isFunding = true;
        creator = msg.sender;
        address2partner[msg.sender]=true;
        adminTokens = 400000000000;
        createHeldCoins();
        actual_stage = 1;
        stage1discount = 50; //Para un 50% porciento de descuento
        stage2discount = 75;  //Para un 25% porciento de descuento
        stage3discount = 85;  //Para un 15% porciento de descuento
        exchangeRate = 13692;
        stage1limit = 400000000000;
        stage2limit = 700000000000;
        stage3limit = 850000000000;
        stage1rate = exchangeRate * stage1discount / 100;
        stage2rate = exchangeRate * stage2discount / 100;
        stage3rate = exchangeRate * stage3discount / 100;
        wei_limit = 50000000000000000000;
        success = false;
        goal1 = (stage1limit - adminTokens) * stage1rate;
        goal2 = (stage2limit - stage1limit) * stage2rate;
        goal3 = (stage3limit - stage2limit) * stage3rate;
        goal4 = goal;
        max_wei_unverified = 1000000000000000000; 
        partners.push(partner(msg.sender,_nombre_partner,_doc_partner));
    }

    // setup function to be ran only 1 time
    // setup token address
    // setup end Block number
    function setup(address token_address, uint _duration) public {
        require(!configSet);
        require(msg.sender == creator);
        Token = ERC20(token_address);
        duration = now + _duration;
        heldBlockLimit = now + _duration;
        configSet = true;
    }

    function closeStage() public {
      require(msg.sender == creator);
      ETHWallet.transfer(address(this).balance);
      if (goal_count >= goal || now >= duration){
        isFunding = false;
      }
      else {
        isFunding = true;
      }
    }

    //CONTRIBUTE FUNCTION (converts ETH to TOKEN and sends new TOKEN to the sender)
    function contribute() external payable returns (uint _stage1amount, uint _stage2amount, uint _stage3amount, uint _stage4amount, uint _amount) {
        require(msg.value > 0, "ETH enviados = 0");
        require(isFunding, "La campaña ya finalizo");

        if (address2IDu[msg.sender] == 0) {
          
          address2IDu[msg.sender] = IDu;
          IDu = IDu+1;
          usuarios.push(usuario(0,0,0,0,0,msg.sender));
        }
        
        require(usuarios[address2IDu[msg.sender]].wei_invested + msg.value <= wei_limit, "Supera el monto maximo de inversión en ether por inversionista");
        require(now <= duration, "Tiempo de campaña superado");
       if (!address2verificado[msg.sender]){
            require((msg.value + usuarios[address2IDu[msg.sender]].wei_invested) <= max_wei_unverified, "Supera el monto maximo para no verificados");
        }
        
        uint buy_amount = msg.value;
       
        if (actual_stage == 1){
            stage1amount = buy_amount / stage1rate;
            if (totalMinted + stage1amount >= stage1limit){
                stage1amount = stage1limit - totalMinted;
                buy_amount = buy_amount - (stage1amount * stage1rate);
                actual_stage = 2;
            }
            goal1_count = goal1_count + stage1amount * stage1rate;
            stage1amount_count=stage1amount_count+stage1amount;
            totalMinted = totalMinted + stage1amount;
            address2WNS_stage1[msg.sender] = address2WNS_stage1[msg.sender] + stage1amount;
            usuarios[address2IDu[msg.sender]].wei_invested1 = usuarios[address2IDu[msg.sender]].wei_invested1 + stage1amount * stage1rate;
        }
       
        if (actual_stage == 2){
            stage2amount = buy_amount / stage2rate;
            if (totalMinted + stage2amount >= stage2limit){
                stage2amount = stage2limit - totalMinted;
                buy_amount = buy_amount - (stage2amount * stage2rate);
                actual_stage = 3;
            }
            goal2_count = goal2_count + stage2amount * stage2rate;
            stage2amount_count=stage2amount_count+stage2amount;
            totalMinted = totalMinted + stage2amount;
            address2WNS_stage2[msg.sender] = address2WNS_stage2[msg.sender] + stage2amount;
            usuarios[address2IDu[msg.sender]].wei_invested2 = usuarios[address2IDu[msg.sender]].wei_invested2 + stage2amount * stage2rate;
        }
       
        if (actual_stage == 3){
            stage3amount = buy_amount / stage3rate;
            if (totalMinted + stage3amount >= stage3limit){
                stage3amount = stage3limit - totalMinted;
                buy_amount = buy_amount - (stage3amount * stage3rate);
                actual_stage = 4;
            }
            goal3_count = goal3_count + stage3amount * stage3rate;
            stage3amount_count=stage3amount_count+stage3amount;
            totalMinted = totalMinted + stage3amount;
            address2WNS_stage3[msg.sender] = address2WNS_stage3[msg.sender] + stage3amount;
            usuarios[address2IDu[msg.sender]].wei_invested3 = usuarios[address2IDu[msg.sender]].wei_invested3 + stage3amount * stage3rate;
        }
       
        if (actual_stage == 4){
            stage4amount = buy_amount / exchangeRate;
            goal4_count = goal4_count + stage4amount * exchangeRate;
            stage4amount_count=stage4amount_count+stage4amount;
            totalMinted = totalMinted + stage4amount;
            address2WNS_stage4[msg.sender] = address2WNS_stage4[msg.sender] + stage4amount;
            usuarios[address2IDu[msg.sender]].wei_invested4 = usuarios[address2IDu[msg.sender]].wei_invested4 + stage4amount * exchangeRate;
        }
        require(totalMinted < maxMintable, "No es posible crear mas monedas");
        usuarios[address2IDu[msg.sender]].wei_invested = usuarios[address2IDu[msg.sender]].wei_invested + msg.value;
        goal_count = goal_count + msg.value;
        amount = stage1amount + stage2amount + stage3amount + stage4amount;
        Token.mintToken(msg.sender, amount);
        stage1amount = 0;
        stage2amount = 0;
        stage3amount = 0;
        stage4amount = 0;
        emit Contribution(msg.sender, amount);
        return(stage1amount,stage2amount,stage3amount,stage4amount, amount);
    }

    function cash_back(address _address_cliente, uint _valor) public returns (uint _stage1amount, uint _stage2amount, uint _stage3amount, uint _stage4amount, uint _amount) {
        require(isFunding, "La campaña ya finalizo");
        require(address2partner[msg.sender], "Debes ser partner para crear tokens");
        if (address2IDu[_address_cliente] == 0) {
          
          address2IDu[_address_cliente] = IDu;
          IDu = IDu+1;
          usuarios.push(usuario(0,0,0,0,0,_address_cliente));
        }
        
        require(usuarios[address2IDu[_address_cliente]].wei_invested + _valor <= wei_limit, "Supera el monto maximo de inversión en ether por inversionista");
        require(now <= duration, "Tiempo de campaña superado");
       if (!address2verificado[_address_cliente]){
            require((_valor + usuarios[address2IDu[_address_cliente]].wei_invested) <= max_wei_unverified, "Supera el monto maximo para no verificados");
        }
        
        uint buy_amount = _valor;
       
        if (actual_stage == 1){
            stage1amount = buy_amount / stage1rate;
            if (totalMinted + stage1amount >= stage1limit){
                stage1amount = stage1limit - totalMinted;
                buy_amount = buy_amount - (stage1amount * stage1rate);
                actual_stage = 2;
            }
            goal1_count = goal1_count + stage1amount * stage1rate;
            stage1amount_count=stage1amount_count+stage1amount;
            totalMinted = totalMinted + stage1amount;
            address2WNS_stage1[_address_cliente] = address2WNS_stage1[_address_cliente] + stage1amount;
            usuarios[address2IDu[_address_cliente]].wei_invested1 = usuarios[address2IDu[_address_cliente]].wei_invested1 + stage1amount * stage1rate;
        }
       
        if (actual_stage == 2){
            stage2amount = buy_amount / stage2rate;
            if (totalMinted + stage2amount >= stage2limit){
                stage2amount = stage2limit - totalMinted;
                buy_amount = buy_amount - (stage2amount * stage2rate);
                actual_stage = 3;
            }
            goal2_count = goal2_count + stage2amount * stage2rate;
            stage2amount_count=stage2amount_count+stage2amount;
            totalMinted = totalMinted + stage2amount;
            address2WNS_stage2[_address_cliente] = address2WNS_stage2[_address_cliente] + stage2amount;
            usuarios[address2IDu[_address_cliente]].wei_invested2 = usuarios[address2IDu[_address_cliente]].wei_invested2 + stage2amount * stage2rate;
        }
       
        if (actual_stage == 3){
            stage3amount = buy_amount / stage3rate;
            if (totalMinted + stage3amount >= stage3limit){
                stage3amount = stage3limit - totalMinted;
                buy_amount = buy_amount - (stage3amount * stage3rate);
                actual_stage = 4;
            }
            goal3_count = goal3_count + stage3amount * stage3rate;
            stage3amount_count=stage3amount_count+stage3amount;
            totalMinted = totalMinted + stage3amount;
            address2WNS_stage3[_address_cliente] = address2WNS_stage3[_address_cliente] + stage3amount;
            usuarios[address2IDu[_address_cliente]].wei_invested3 = usuarios[address2IDu[_address_cliente]].wei_invested3 + stage3amount * stage3rate;
        }
       
        if (actual_stage == 4){
            stage4amount = buy_amount / exchangeRate;
            goal4_count = goal4_count + stage4amount * exchangeRate;
            stage4amount_count=stage4amount_count+stage4amount;
            totalMinted = totalMinted + stage4amount;
            address2WNS_stage4[_address_cliente] = address2WNS_stage4[_address_cliente] + stage4amount;
            usuarios[address2IDu[_address_cliente]].wei_invested4 = usuarios[address2IDu[_address_cliente]].wei_invested4 + stage4amount * exchangeRate;
        }
        require(totalMinted < maxMintable, "No es posible crear mas monedas");
        usuarios[address2IDu[_address_cliente]].wei_invested = usuarios[address2IDu[_address_cliente]].wei_invested + msg.value;
        goal_count = goal_count + _valor;
        amount = stage1amount + stage2amount + stage3amount + stage4amount;
        Token.mintToken(_address_cliente, amount);
        stage1amount = 0;
        stage2amount = 0;
        stage3amount = 0;
        stage4amount = 0;
        emit Contribution(_address_cliente, amount);
        return(stage1amount,stage2amount,stage3amount,stage4amount, amount);
    }

    // change creator address
    function changeCreator(address _creator) external {
        require(msg.sender == creator);
        creator = _creator;
    }

    // internal function that allocates a specific amount of TOKENS at a specific block number.
    // only ran 1 time on initialization
    function createHeldCoins() internal {
        heldTotal += adminTokens;
        totalMinted += heldTotal;
    }

    // public function to get the amount of tokens held for an address
    function getHeldCoin(address _address) public constant returns (uint256) {
        return heldTokens[_address];
    }

    // function to create held tokens for developer
    function createHoldToken(uint256 _amount, string _taskName) public {
        require(address2partner[msg.sender], "Debes ser partner para crear tokens");
        require(heldTotal>=_amount, "No hay suficientes tokens disponibles");
        heldTokensTask[tasks.push(task(msg.sender, _taskName, 0))] = _amount;
        heldTotal -= _amount;
    }

    // function to release held tokens for developers
    function releaseHeldCoins(uint _taskID) public {
        require(address2partner[msg.sender], "Debes ser partner para crear tokens");
        require(msg.sender!=tasks[_taskID].publisher_partner);
        require(heldTokensTask[_taskID]>0, "No hay suficientes tokens para esta actividad");
        uint256 held = heldTokensTask[_taskID];
        heldTokensTask[_taskID] = 0;
        heldTotal -= held;
        Token.mintToken(tasks[_taskID].publisher_partner, held);
        task2validators[_taskID].push(msg.sender);
        task2totalValidatos[_taskID]++;
        emit ReleaseTokens(tasks[_taskID].publisher_partner, held);
    }
   
    function view_now() public view returns (uint256){
        return now;
    }

    //Register and login***
    struct usuario {

        uint256 wei_invested;
        uint256 wei_invested1;
        uint256 wei_invested2;
        uint256 wei_invested3;
        uint256 wei_invested4;
        address owner;
    }
    struct partner{
        address wallet_address;
        string name;
        string doc;
    }
    struct task{
        address publisher_partner;
        string name;
        uint estado; //01 - Creada no validada, 11 Creada Validada, 10 Creada Rechazada
    }
    usuario[] public usuarios;
    partner[] public partners;
    task[] public tasks;
    mapping (address => bool) public address2verificado;
    mapping (address => bool) public address2partner;
    mapping (uint => uint) private task2parent;
    mapping (uint => address[] ) private task2validators;
    mapping (uint => uint) public task2totalValidatos;
    function add_partner(address _wallet_partner, string _nombre_partner, string _doc) public {
        require(address2partner[msg.sender]);
       //require(address2inscrito[_usuario]);
       partners.push(partner(_wallet_partner,_nombre_partner,_doc));
        address2partner[_wallet_partner] = true;
    }   
    function autorizar(address _usuario) public {
        require(msg.sender == creator);
       //require(address2inscrito[_usuario]);
        address2verificado[_usuario] = true;
    }
    function view_stages_WNS() public view returns (uint WNS_stage1, uint WNS_stage2, uint WNS_stage3, uint WNS_stage4) {
        return(address2WNS_stage1[msg.sender], address2WNS_stage2[msg.sender], address2WNS_stage3[msg.sender], address2WNS_stage4[msg.sender]);
    }
    function is_creator() public view returns(bool _is_creator){
        if (creator==msg.sender){
            return(true);
        }
        else{
            return(false);
        }
    }
}