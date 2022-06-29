pragma solidity ^0.8.0;

import "./mytoken.sol";

import "./reward.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract xyz is ERC20{

    address public owner;
    MyToken public myToken;
    rewardeth public RewardETH;
    address[] public allstakers;
    mapping(address=> uint) public user_stake_balance;
    mapping(address=>bool) public addr_staked;
    mapping(address=>uint) public rewards_store;
    uint public rewardrate=10;
    uint public stake_lasttimestamp;
    uint public unstake_lasttimestamp;

    struct user_info{
        uint amount_that_staked;
        uint claimed_amount;
        uint start_block;
    }

    user_info public userinfo;
    mapping (address=>user_info) public userinforarr;
    event givereward(address addr, uint tokenAmount);

    constructor(MyToken _myToken, rewardeth _rewardtoken) ERC20("xyz Token ", "XYZ"
        ){
            owner =msg.sender;
            myToken=_myToken;
            RewardETH=_rewardtoken;
        }
        receive() external payable{}
        modifier onlyOwner{
            owner==msg.sender;
            _;
        }
        modifier stake_timestamps{
            stake_lasttimestamp=block.timestamp;
            //store time when any function runs
            _;
        }
        
        modifier unstake_timestamp{
            unstake_lasttimestamp=block.timestamp;
            _;
        }

        uint private unlocked=1;
        modifier lock{
            require(unlocked==1,"currently in transaction state");
            unlocked=0;
            _;
            unlocked=1;
        }
        function stake(uint amount) public lock{
            require(amount>0,"negative amount cannot be staked");
            userinfo.start_block=block.number;
            userinfo.amount_that_staked=amount;
            myToken.transferFrom(msg.sender,address(this),amount);
            user_stake_balance[msg.sender]+=amount;
            allstakers.push(msg.sender);
            addr_staked[msg.sender]=true;
        } 
        function claim() public returns(uint){
            uint claim_block=block.number;
            userinfo.claimed_amount=(claim_block-userinfo.start_block)*10;
        }
        function pendingReward() public view returns(uint){
            uint currentblock=block.number;
            uint elapseBlock=(currentblock-userinforarr[msg.sender].start_block)*rewardrate;
            return elapseBlock;
        }

        function claimMyReward() public{
            uint _claim=pendingReward();
            require(_claim>=0,"Not a valid claim");
            require(userinforarr[msg.sender].claimed_amount>0,"no amount for claim");
            _mint(msg.sender,_claim);
            emit givereward(msg.sender,_claim);
            }

        function unstake(uint amount) public lock unstake_timestamp{
            require(amount>0,"enter a possitive amount");
            uint balance_of_unstaker= user_stake_balance[msg.sender];
            require(balance_of_unstaker>0,"you do not have enough balance");
            require(balance_of_unstaker>= amount,"you ae entering more than you have stake");
            myToken.transfer(msg.sender, balance_of_unstaker);
            balance_of_unstaker = user_stake_balance[msg.sender]-amount;
            if(user_stake_balance[msg.sender]==0){
                addr_staked[msg.sender] = false;
            }
        }
            function mint() public payable onlyOwner lock{
                _mint(address(this), msg.value*10**18);
            }
 }








