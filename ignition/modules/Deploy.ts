import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const DeployModule = buildModule("DeployModule", (m) => {
    // Deploy Tokens
    const woodToken = "0xd4fAEbEbfa262d4Bb30CDab5858fA6B760d3d531";
    const goldToken = "0x573Ad22d8eE4916F9cefeBc50C5247F69e5c62c2";
    const foodToken = '0xf5B63B0D91AdA138232fc58d14f03AF2885Cb667';

    // Deploy Tools contracts
    const woodTools = "0xB637f5e7AB92cf8443a07ffeEfacC9c0aB0c88dB";    
    const goldTools = "0x492DEe1430d871A559AE062c547Eb248929a85B3";
    const foodTools = "0x37Ab199494C9256D9Db31834C2F520F20036956b";

    // Deploy FarmerWorld contract
    const farmerWorld = m.contract("FarmerWorld", [
        woodTools,
        goldTools,
        foodTools,
        foodToken,
        goldToken,
        woodToken,
    ]);

    return {
        
        farmerWorld,
    };
});

export default DeployModule;
