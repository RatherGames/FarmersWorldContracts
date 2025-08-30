// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Tools {
    address public owner;
    address public RewardToken;
    
    struct Tool {
       uint16 energyConsumption;
       uint16 durability;
       uint16 durabilityConsumption;
       uint32 chargeTime;
       uint256 rewardRate;
    }

    struct UserTools{
        uint256 lvl;
        uint256 durability;
        uint256 lastHarvest;
    }

    struct ToolCost{
        uint256 woodCost;
        uint256 goldCost;
        uint256 repayCost;
    }


    mapping(uint256 lvl => Tool) public tools;
    mapping(uint256 lvl => ToolCost) public toolCost;
    mapping(address user => mapping(uint256 id => UserTools)) public userTools;
    mapping(address contractCallers => bool) public contractCallers;

    
    constructor() {
        owner = msg.sender;
        contractCallers[msg.sender] = true;
    }

    function setContractCaller(address _contractCaller) public {
        require(msg.sender == owner, "Only owner can set contract caller");
        contractCallers[_contractCaller] = true;
    }

    function setOwner(address _owner) public {
        require(msg.sender == owner, "Only owner can set owner");
        owner = _owner;
    }

    function addTool(uint256 lvl, Tool memory tool, ToolCost memory _toolCost) public {
        require(contractCallers[msg.sender], "Only owner can add tool");
        tools[lvl] = tool;
        toolCost[lvl] = _toolCost;
    }

    function getTool(uint256 lvl) public view returns (Tool memory) {
        return tools[lvl];
    }
    
    function editTool(uint256 lvl, Tool memory tool) public {
        require(contractCallers[msg.sender], "Only owner can edit tool");
        tools[lvl] = tool;
    }

    function editUserTool(address user, uint256 id, uint256 lvl, uint256 durability, uint256 lastHarvest) public {
        require(contractCallers[msg.sender], "Only owner can edit user tool");
        userTools[user][id] = UserTools(lvl, durability, lastHarvest);
    }

    function addUserTool(address user, uint256 id, uint256 lvl) public {
        require(contractCallers[msg.sender], "Only owner can add user tool");
        userTools[user][id] = UserTools(lvl, tools[lvl].durability, block.timestamp );
    }

    function getUserTool(address user, uint256 id) public view returns (UserTools memory) {
        return userTools[user][id];
    }

    function getAllUserTools(address user) public view returns (UserTools[] memory) {
        uint256 i = 0;
        UserTools[] memory allTools = new UserTools[](10);
        while (userTools[user][i].lvl != 0) {
            allTools[i] = userTools[user][i];
            i++;
        }
        return allTools;
    }

    function totalUserTools(address user) public view returns (uint256) {
        uint256 i = 0;
        while (userTools[user][i].lvl != 0) {
            i++;
        }
        return i;
    }

    function getToolCost(uint256 lvl) public view returns (uint256, uint256) {
        return (toolCost[lvl].woodCost, toolCost[lvl].goldCost);
    }

    
}