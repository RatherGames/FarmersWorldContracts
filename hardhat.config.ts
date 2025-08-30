import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
const { vars } = require("hardhat/config");

const PRIVATE_KEY = vars.get("RATHER_DEVELOPER_KEY");
const ETHERSCAN_API_KEY = vars.get("ETHERSCAN_API_KEY");

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.28",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    world: {
      url: `https://worldchain-mainnet.gateway.tenderly.co`,
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    // apiKey: ETHERSCAN_API_KEY,
    customChains: [
      {
        network: "world",
        chainId: 480,
        urls: {
          apiURL: "https://api.worldscan.org/api",
          browserURL: "https://worldscan.org/",
        },
      },
    ],
    apiKey: "VEE2298VR55P2XDFFYDANFEICEF9V9G95R",
  },
};

export default config;
