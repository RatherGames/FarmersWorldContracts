import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const DeployModule = buildModule("DeployModule", (m) => {
    // Deploy Tokens
    const woodToken = m.contract("Wood", [m.getAccount(0), m.getAccount(0)]);
    const goldToken = m.contract("Gold", [m.getAccount(0), m.getAccount(0)]);
    const foodToken = m.contract("Food", [m.getAccount(0), m.getAccount(0)]);

    // Deploy Tools contracts
    const woodTools = m.contract("Tools");
    const goldTools = m.contract("Tools");
    const foodTools = m.contract("Tools");

    // Deploy FarmerWorld contract
    const farmerWorld = m.contract("FarmerWorld", [
        woodTools,
        goldTools,
        foodTools,
        goldToken, // Assuming GoldToken is the reward token for now
    ]);

    return {
        woodToken,
        goldToken,
        foodToken,
        woodTools,
        goldTools,
        foodTools,
        farmerWorld,
    };
});

export default DeployModule;
