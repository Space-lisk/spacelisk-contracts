import { HardhatUserConfig } from "hardhat/config";
// import '@openzeppelin/hardhat-upgrades';
import "@nomicfoundation/hardhat-toolbox";
import "dotenv/config"

const config: HardhatUserConfig =  {
  defaultNetwork: "lisk_sepolia",
  networks: {    
    lisk_sepolia: {
      url: process.env.LISK_RPC_URL,
      accounts: [process.env.TEST_PRIVATE_KEY!],
    },
  },
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
};

export default config;