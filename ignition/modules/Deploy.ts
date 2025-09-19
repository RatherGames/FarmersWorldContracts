import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const DeployModule = buildModule("DeployModule", (m) => {
    // Deploy Tokens
    const woodToken = "0xd4fAEbEbfa262d4Bb30CDab5858fA6B760d3d531";
    const goldToken = "0x573Ad22d8eE4916F9cefeBc50C5247F69e5c62c2";
    const foodToken = '0xf5B63B0D91AdA138232fc58d14f03AF2885Cb667';

    // Deploy Tools contracts
    const woodTools = "0x9865e76262926a4E37BEdfE6fC893283D976c11E";    
    const goldTools = "0xB8F24cDdf9F36Be85E9AA5d3F54909825E65D1F0";
    const foodTools = "0x17c44Cc3d397348Fa43F704b1C0a477228d7d63c";

    // Deploy FarmerWorld contract
    const farmerWorld = m.contract("FarmerWorld", [ 
        foodToken,
        goldToken,
        woodToken,
        "0x999561c6c239C9ef660DfbE38cc2CE6BD0c2EcBa"
    ]);

    return {
        farmerWorld,
    };
});

export default DeployModule;
