import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import { HardhatUserConfig } from "hardhat/config";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.7.6",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true
    },
    local: {
      url: "http://127.0.0.1:8545"
    },
    tura: {
      url: "https://rpc-beta1.turablockchain.com",
      chainId: 1337,
      accounts: ["ad6fb1ceb0b9dc598641ac1cef545a7882b52f5a12d7204d6074762d96a8a474"]
    }
  }
};

export default config;
