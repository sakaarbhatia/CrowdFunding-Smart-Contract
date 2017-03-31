pragma solidity ^0.4.2;
contract GeneralToken {

	string public name = "General.1";
    string public symbol = "V.1";
    
    mapping(address => uint) GeneralBalances;

    uint public presaleTokenSupply = 21000000;
    uint public presaleTokenDistributed = 0;

    address public founder = 0x0;

    event Transfer(string name, string symbol, address indexed from, address indexed to, uint256 value);


    function transfer(address _to, uint256 _value) {
        if (GeneralBalances[founder] < _value) throw;           
        if (GeneralBalances[_to] + _value < GeneralBalances[_to]) throw;

        GeneralBalances[founder] -= _value;                    
        GeneralBalances[_to] += _value; 

        presaleTokenDistributed += _value;

        Transfer(name, symbol, founder, _to, _value) ;                  
    }


    function GeneralToken( uint _tokenSupply) {
    	founder = msg.sender;
    	presaleTokenSupply = _tokenSupply;
    	GeneralBalances[founder] = _tokenSupply;
    } 
    
    function getDistributedToken() returns(uint) {
        return presaleTokenDistributed;
    }
    
    function getTotalTokens() returns(uint){
        return presaleTokenSupply;
    }

}


    
    
contract GeneralTokenCrowdSale {

    
    uint public deadline; 
    uint public price;
    
    address public founder = 0x0;
    address public beneficiary = 0x0;

    GeneralToken public tokenReward;

    bool crowdsaleClosed = false;

    uint public presaleEtherRaised = 0;
    uint public presaleEtherToWithdraw = 0;

    bool public halted = false; 

    Funder[] public funders;

    struct Funder {
        address addr;
        uint amount;
        uint tokenCount;
    }

    event FundTransfer(address backer, uint amount, bool isContribution);
    event Withdraw(address sender, address to, uint eth);
   
    function GeneralTokenCrowdSale( uint _durationInMinutes, uint _etherCostOfEachToken, GeneralToken _addressOfTokenUsedAsReward) {
        founder = msg.sender;
        beneficiary = msg.sender;
        deadline = now + _durationInMinutes * 1 minutes;
        price = _etherCostOfEachToken * 1 wei;
        tokenReward = GeneralToken(_addressOfTokenUsedAsReward);
    }

    // Buy entry point
    function buyGeneralToken() payable {
        if (crowdsaleClosed) throw;
        uint amount = msg.value;
        uint tokenForTheAmount =  amount / price;
        if (checkIfTokenCountLimitAcheived(tokenForTheAmount) || checkIfDeadlineCrossed() || halted ) throw;
       
        var numFunders = funders.length;
        Funder f = funders[numFunders++];
        f.addr = msg.sender;
        f.amount = amount;
        f.tokenCount = tokenForTheAmount;
        
        presaleEtherRaised += amount;
        presaleEtherToWithdraw += amount;

        tokenReward.transfer(msg.sender, tokenForTheAmount);
        
        FundTransfer(msg.sender, amount, true);

    }


    function checkIfDeadlineCrossed() returns(bool){
        if(now > deadline){
            crowdsaleClosed = true;
            return true;
        }else{
            return false;
        }
    }

    function checkIfTokenCountLimitAcheived(uint _tokenForTheAmount) returns(bool){
        if(tokenReward.getDistributedToken() + _tokenForTheAmount > tokenReward.getTotalTokens() ){
            crowdsaleClosed = true;
            return true;
        }else{
            return false;
        }
    }

    modifier onlyOwner {
        if (msg.sender != founder) throw;
        _;
    }

    function getTokenPrice() onlyOwner returns(uint) {
        return price;
    }

    function updateTokenPrice(uint _etherCostOfEachToken) onlyOwner{
        price = _etherCostOfEachToken * 1 ether;
    }


    function halt() onlyOwner{
        halted = true;
    }

    function unhalt() onlyOwner{
        halted = false;
    }

    function changeBeneficiary(address _newBeneficiary) onlyOwner{
        beneficiary = _newBeneficiary;
    }

    function transferFunds() onlyOwner{
        if (!beneficiary.call.value(presaleEtherToWithdraw)()) throw; // send Ether to beneficiary address
        
        Withdraw(founder,beneficiary,presaleEtherToWithdraw);
        presaleEtherToWithdraw = 0;
    }
    
    
    /**
     * Do not allow direct deposits.
     */
    function() {
        throw;
    }

}

