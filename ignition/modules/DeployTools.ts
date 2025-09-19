import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

// Tools configuration data
const toolsConfig = {
    woodTools: {
        lvls: [0, 1, 2],
        stats: [
            {
                energyConsumption: 10,
                durability: 100,
                durabilityConsumption: 5,
                chargeTime: 3600,
                rewardRate: 5
            },
            {
                energyConsumption: 20,
                durability: 300,
                durabilityConsumption: 15,
                chargeTime: 3600,
                rewardRate: 17
            },
            {
                energyConsumption: 40,
                durability: 900,
                durabilityConsumption: 45,
                chargeTime: 3600,
                rewardRate: 54
            }
        ],
        costs: [
            {
                woodCost: "2400000000000000000000", // 2400 * 10^18
                goldCost: "400000000000000000000",  // 400 * 10^18
                repayCost: "1000000000000000000"    // 1 * 10^18
            },
            {
                woodCost: "7200000000000000000000", // 7200 * 10^18
                goldCost: "1200000000000000000000", // 1200 * 10^18
                repayCost: "1000000000000000000"    // 1 * 10^18
            },
            {
                woodCost: "21600000000000000000000", // 21600 * 10^18
                goldCost: "3600000000000000000000",  // 3600 * 10^18
                repayCost: "1000000000000000000"    // 1 * 10^18
            }
        ]
    },
    FoodTools: {
        lvls: [0, 1, 2],
        stats: [
            {
                energyConsumption: 0,
                durability: 200,
                durabilityConsumption: 5,
                chargeTime: 3600,
                rewardRate: 5
            },
            {
                energyConsumption: 0,
                durability: 800,
                durabilityConsumption: 20,
                chargeTime: 3600,
                rewardRate: 20
            },
            {
                energyConsumption: 0,
                durability: 3200,
                durabilityConsumption: 32,
                chargeTime: 3600,
                rewardRate: 80
            }
        ],
        costs: [
            {
                woodCost: "1200000000000000000000", // 1200 * 10^18
                goldCost: "200000000000000000000",  // 200 * 10^18
                repayCost: "3000000000000000000"    // 3 * 10^18
            },
            {
                woodCost: "4800000000000000000000", // 4800 * 10^18
                goldCost: "800000000000000000000",  // 800 * 10^18
                repayCost: "1000000000000000000"    // 1 * 10^18
            },
            {
                woodCost: "19200000000000000000000", // 19200 * 10^18
                goldCost: "3200000000000000000000",  // 3200 * 10^18
                repayCost: "1000000000000000000"    // 1 * 10^18
            }
        ]
    },
    GoldTools: {
        lvls: [0],
        stats: [
            {
                energyConsumption: 44,
                durability: 250,
                durabilityConsumption: 5,
                chargeTime: 7200,
                rewardRate: 100
            }
        ],
        costs: [
            {
                woodCost: "24000000000000000000000", // 24000 * 10^18
                goldCost: "400000000000000000000",   // 400 * 10^18
                repayCost: "2000000000000000000"     // 2 * 10^18
            }
        ]
    }
};

const DeployToolsModule = buildModule("DeployToolsModule", (m) => {
    // Token addresses (same as in Deploy.ts)
    const woodToken = "0xd4fAEbEbfa262d4Bb30CDab5858fA6B760d3d531";
    const goldToken = "0x573Ad22d8eE4916F9cefeBc50C5247F69e5c62c2";
    const foodToken = '0xf5B63B0D91AdA138232fc58d14f03AF2885Cb667';

    // FarmerWorld address (will be set as contract caller)
    const farmerWorld = "0x0000000000000000000000000000000000000000"; // TODO: Update with actual FarmerWorld address

    // Deploy WoodTools contract
    const woodTools = m.contract("Tools", [
        woodToken, // rewardToken
        toolsConfig.woodTools.lvls,
        toolsConfig.woodTools.stats,
        toolsConfig.woodTools.costs,
        farmerWorld // farmerManager
    ], {
        id: "woodTools"
    });

    // Deploy FoodTools contract
    const foodTools = m.contract("Tools", [
        foodToken, // rewardToken
        toolsConfig.FoodTools.lvls,
        toolsConfig.FoodTools.stats,
        toolsConfig.FoodTools.costs,
        farmerWorld // farmerManager
    ], {
        id: "foodTools"
    });

    // Deploy GoldTools contract
    const goldTools = m.contract("Tools", [
        goldToken, // rewardToken
        toolsConfig.GoldTools.lvls,
        toolsConfig.GoldTools.stats,
        toolsConfig.GoldTools.costs,
        farmerWorld // farmerManager
    ], {
        id: "goldTools"
    });

    return {
        woodTools,
        foodTools,
        goldTools
    };
});

export default DeployToolsModule;
