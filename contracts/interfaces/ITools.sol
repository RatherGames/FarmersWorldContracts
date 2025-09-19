// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface ITools {
    struct Tool {
        uint16 energyConsumption;
        uint16 durability;
        uint16 durabilityConsumption;
        uint32 chargeTime;
        uint256 rewardRate;
    }

    struct UserTools {
        uint256 lvl;
        uint256 durability;
        uint256 lastHarvest;
    }

    struct ToolCost {
        uint256 woodCost;
        uint256 goldCost;
        uint256 repayCost;
    }

    // View functions
    function owner() external view returns (address);
    function RewardToken() external view returns (address);
    function tools(uint256 lvl) external view returns (Tool memory);
    function toolCost(uint256 lvl) external view returns (ToolCost memory);
    function userTools(address user, uint256 id) external view returns (UserTools memory);
    function contractCallers(address contractCaller) external view returns (bool);
    
    function getTool(uint256 lvl) external view returns (Tool memory);
    function getUserTool(address user, uint256 id) external view returns (UserTools memory);
    function getAllUserTools(address user) external view returns (UserTools[] memory);
    function getToolCost(uint256 lvl) external view returns (uint256, uint256);
    function totalUserTools(address user) external view returns (uint256);
    function getTotalUserTools(address user) external view returns (uint256);

    // State-changing functions
    function setContractCaller(address _contractCaller) external;
    function setOwner(address _owner) external;
    function addTool(uint256 lvl, Tool memory tool, ToolCost memory _toolCost) external;
    function addTools(uint256[] memory lvls, Tool[] memory _tools, ToolCost[] memory _toolCosts) external;
    function editTool(uint256 lvl, Tool memory tool) external;
    function editUserTool(address user, uint256 id, uint256 lvl, uint256 durability, uint256 lastHarvest) external;
    function addUserTool(address user, uint256 lvl) external;
}

