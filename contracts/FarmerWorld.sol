// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "./interfaces/ITools.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISignatureTransfer} from "./interfaces/ISignatureTransfer.sol";

interface IAddressBook {
    function addressVerifiedUntil(address account) external view returns (uint256 timestamp);
}
 
contract FarmerWorld {
    ISignatureTransfer public permit2 = ISignatureTransfer(0x000000000022D473030F116dDEE9F6B43aC78BA3);

    struct User{
        uint256 woodBalance;
        uint256 goldBalance;
        uint256 foodBalance;
        uint256 energy;
        uint256 maxEnergy;
        bool freeClaimed;
    }

    struct gameTokenRelation{
        uint foodToEnergy;
        uint goldToEndurance;
    }


    ITools public woodTools;
    ITools public goldTools;
    ITools public foodTools;
    IERC20 public foodToken;
    IERC20 public goldToken;
    IERC20 public woodToken;
    address public owner;
    gameTokenRelation public tokenRelation;

    mapping(address user => User) public users;
    mapping(address contractCallers => bool) public contractCallers;

    constructor( address _foodToken, address _goldToken, address _woodToken, address _owner) {
        foodToken = IERC20(_foodToken);
        goldToken = IERC20(_goldToken);
        woodToken = IERC20(_woodToken);
        owner = _owner;
        contractCallers[_owner] = true;
    }

    function setTools(address _woodTools, address _goldTools, address _foodTools) public {
        require(msg.sender == owner, "Only owner can set tools");
        woodTools = ITools(_woodTools);
        goldTools = ITools(_goldTools);
        foodTools = ITools(_foodTools);
    }

    function freeClaim(uint option) public {
        require(!users[msg.sender].freeClaimed, "Free claim already claimed");
        require(IAddressBook(msg.sender).addressVerifiedUntil(msg.sender) > 0, "Address not verified");
        users[msg.sender].freeClaimed = true;
        users[msg.sender].energy = users[msg.sender].maxEnergy;
        if(option != 0){ // 0 = Food tool 1: Wood tool
            // give free wood tool
            woodTools.addUserTool(msg.sender, 1);
        }else{
            // give Food tool
            foodTools.addUserTool(msg.sender, 1);
        }
    }

    // user functions
    function craft(ITools _toolContract, uint256 _toolLvl) public {
        //get price of tool
        (uint woodCost, uint gooldCost) = _toolContract.getToolCost(_toolLvl);
        //check if user has enough tokens
        require(users[msg.sender].woodBalance >= woodCost, "Not enough wood");
        require(users[msg.sender].goldBalance >= gooldCost, "Not enough gold");
        //subtract tokens from 
        users[msg.sender].woodBalance -= woodCost;
        users[msg.sender].goldBalance -= gooldCost;
        //get max id
        // uint256 maxId = _toolContract.totalUserTools(msg.sender);
        //add tool to user in ID +1
        _toolContract.addUserTool(msg.sender, _toolLvl);
    }

    function harvest(ITools _toolContract, uint id) public {
           
        ITools.UserTools memory userToolStatus = _toolContract.userTools(msg.sender, id);
        ITools.Tool memory toolInfo = _toolContract.tools(userToolStatus.lvl); //check if tool is valid
        require(userToolStatus.lvl != 0, "Tool not found");
        require(userToolStatus.durability >= toolInfo.durabilityConsumption, "Tool is broken");
        _toolContract.editUserTool(msg.sender, id, userToolStatus.lvl, userToolStatus.durability-toolInfo.durabilityConsumption, block.timestamp);
        if(userToolStatus.durability == toolInfo.durabilityConsumption){
            deleteTool(_toolContract, id, msg.sender);
        }
        uint256 energyConsumption = _toolContract.tools(userToolStatus.lvl).energyConsumption;
        require(users[msg.sender].energy >= energyConsumption, "Not enough energy");
        users[msg.sender].energy -= energyConsumption;
        uint256 timePassed = block.timestamp - userToolStatus.lastHarvest;
        uint256 maxChargeTime = toolInfo.chargeTime;
        uint256 reward;
        
        if (timePassed >= maxChargeTime) {
            // If time passed is equal or greater than max charge time, give full reward
            reward = toolInfo.rewardRate;
        } else {
            // Calculate proportional reward based on percentage of time passed
            reward = (toolInfo.rewardRate * timePassed) / maxChargeTime;
        }
        
        if(_toolContract == woodTools){
            woodToken.transfer(msg.sender, reward);
        }else if(_toolContract == goldTools){
            goldToken.transfer(msg.sender, reward);
        }else if(_toolContract == foodTools){
            foodToken.transfer(msg.sender, reward);
        }

    }

    function repair(
        ITools _toolContract, 
        uint id, 
        ISignatureTransfer.PermitTransferFrom memory permit,
        ISignatureTransfer.SignatureTransferDetails calldata transferDetails,
        bytes calldata signature
    ) public {
        address tokenAddress = permit.permitted.token;
        uint256 goldAmount = transferDetails.requestedAmount;

        require(goldAmount > 0, "Amount must be greater than 0");
        require(transferDetails.to == address(this), "Invalid to address");
        require(tokenAddress == address(goldToken), "Only gold token is supported");

        permit2.permitTransferFrom(permit, transferDetails, msg.sender, signature);

        // get tool user info
        ITools.UserTools memory userToolStatus = _toolContract.userTools(msg.sender, id);
        ITools.Tool memory toolInfo = _toolContract.tools(userToolStatus.lvl);
        require(userToolStatus.lvl != 0, "Tool not found");

        uint256 enduranceToAdd = goldAmount * tokenRelation.goldToEndurance;
        uint256 maxEndurance = toolInfo.durability;
        uint256 newDurability = userToolStatus.durability + enduranceToAdd;
        
        if (newDurability > maxEndurance) {
            newDurability = maxEndurance;
        }
        
        //update tool durability
        _toolContract.editUserTool(msg.sender, id, userToolStatus.lvl, newDurability, userToolStatus.lastHarvest);
    }

    function buyEnergy(address user, uint goldAmount) public{
        require(users[user].goldBalance >= goldAmount, "Not enough gold");
        uint256 energyToAdd = goldAmount * tokenRelation.foodToEnergy;
        uint256 maxEnergy = users[user].maxEnergy;
        energyToAdd = energyToAdd > maxEnergy ? maxEnergy : energyToAdd;
        //update user energy
        users[user].energy += energyToAdd;
        //update user gold
        users[user].goldBalance -= goldAmount;
    }


    function deposit(
        ISignatureTransfer.PermitTransferFrom memory permit,
        ISignatureTransfer.SignatureTransferDetails calldata transferDetails,
        bytes calldata signature
    ) public {
        address tokenAddress = permit.permitted.token;
        uint256 amount = transferDetails.requestedAmount;
        
        require(amount > 0, "Amount must be greater than 0");
        require(transferDetails.to == address(this), "Invalid to address");
        
        permit2.permitTransferFrom(permit, transferDetails, msg.sender, signature);
        
        if (tokenAddress == address(woodToken)) {
            users[msg.sender].woodBalance += amount;
        } else if (tokenAddress == address(goldToken)) {
            users[msg.sender].goldBalance += amount;
        } else if (tokenAddress == address(foodToken)) {
            users[msg.sender].foodBalance += amount;
        } else {
            revert("Unsupported token");
        }
       
    }
    
    function deleteTool(ITools _toolContract, uint256 id, address user) public {
        uint256 totalTools = _toolContract.totalUserTools(user);
        require(id < totalTools, "Invalid tool ID");

        // If the tool to be deleted is not the last one, replace it with the last one.
        if (id < totalTools - 1) {
            ITools.UserTools memory lastTool = _toolContract.userTools(user, totalTools - 1);
            _toolContract.editUserTool(user, id, lastTool.lvl, lastTool.durability, lastTool.lastHarvest);
        }

        // Delete the last tool's data.
        _toolContract.editUserTool(user, totalTools - 1, 0, 0, 0);
    }

    // owner functions
    function setContractCaller(address _contractCaller) public {
        require(msg.sender == owner, "Only owner can set contract caller");
        contractCallers[_contractCaller] = true;
    }

    function setOwner(address _owner) public {
        require(msg.sender == owner, "Only owner can set owner");
        owner = _owner;
    }

    // edits contractCallers
    function editGameTokenRelation(uint _foodToEnergy, uint _goldToEndurance) public {
        require(contractCallers[msg.sender], "Only contract caller can edit game token relation");
        tokenRelation.foodToEnergy = _foodToEnergy;
        tokenRelation.goldToEndurance = _goldToEndurance;
    }

    function editUser(address user, uint256 woodBalance, uint256 goldBalance, uint256 foodBalance, uint256 energy, uint256 maxEnergy) public {
        require(contractCallers[msg.sender], "Only contract caller can edit user");
        bool freeClaimed = users[user].freeClaimed;
        users[user] = User(woodBalance, goldBalance, foodBalance, energy, maxEnergy, freeClaimed);
    }

    function editUserTool(ITools _toolContract, address user, uint256 id, uint256 lvl, uint256 durability, uint256 lastHarvest) public {
        require(contractCallers[msg.sender], "Only contract caller can edit user tool");
        _toolContract.editUserTool(user, id, lvl, durability, lastHarvest);
    }

}