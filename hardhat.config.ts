/**
 * @type import('hardhat/config').HardhatUserConfig
 */
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import "hardhat-abi-exporter";
import "hardhat-deploy";
import "hardhat-contract-sizer";
// import 'hardhat-gas-reporter';
// import '@typechain/hardhat';
// import 'solidity-coverage';

import { HardhatUserConfig } from "hardhat/types";
import * as fs from "fs";
import {extTask} from "./hardhat.task";

console.log("config hardhat.");

// set proxy
const { ProxyAgent, setGlobalDispatcher } = require("undici");
const proxyAgent = new ProxyAgent('http://127.0.0.1:7890');
setGlobalDispatcher(proxyAgent);

extTask.RegTasks();

//get prikeys from a json file
let buffer = fs.readFileSync("testprikeys.json");
let srcjson = JSON.parse(buffer.toString());

let namedkeys: { [id: string]: number } = srcjson["namedkeys"];
let onlykeys: string[] = srcjson["prikeys"] as string[];
let hardhat_prikeys:any[] = [];
for (var i = 0; i < onlykeys.length; i++)

  hardhat_prikeys.push({ "privateKey": onlykeys[i], "balance": "99000000000000000000" });


const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.15",
    settings: {
      optimizer: {
        enabled: true,
        runs: 20000
      }
    }
  },
  contractSizer:
  {
      alphaSort:true,
      disambiguatePaths:false,
      runOnCompile:true,
  },
  namedAccounts: namedkeys,//from json
  paths: {
    artifacts: "artifacts-eos",
    deploy: "deploy",
    sources: "contracts",
    tests: "test",
  },

  defaultNetwork: "zkSyncTestnet",
  networks: {
    hardhat: {
      accounts: hardhat_prikeys
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: onlykeys,
      chainId: 4,
      live: true,
      saveDeployments: true,
      tags: ["staging"],
      timeout: 60000
    },
    bscTest: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      accounts: onlykeys,
      chainId: 97,
      live: true,
      saveDeployments: true,
      tags: ["staging"],
    },
    bscMain: {
      url: "https://bsc-dataseed.binance.org/",
      accounts: onlykeys,
      chainId: 56,
      live: true,
      saveDeployments: true,
      tags: ["staging"],
    },
    arbitrumOne: {
      url: "https://arb1.arbitrum.io/rpc",
      accounts: onlykeys,
      chainId: 42161,
      live: true,
      saveDeployments: true,
      tags: ["staging"],
    },
    arbitrumTest: {
      url: "https://goerli-rollup.arbitrum.io/rpc",
      accounts: onlykeys,
      chainId: 421613,
      live: true,
      saveDeployments: true,
      tags: ["staging"],
    },
    zkSyncTestnet: {
      url: "https://testnet.era.zksync.dev",
      ethNetwork: "goerli", // RPC URL of the network (e.g. `https://goerli.infura.io/v3/<API_KEY>`)
      zksync: true,
      accounts: onlykeys,
      chainId: 280,
      live: true,
      saveDeployments: true,
      tags: ["staging"],
    },
    zkSyncMainnet: {
      url: "https://mainnet.era.zksync.io",
      ethNetwork: "goerli", // RPC URL of the network (e.g. `https://goerli.infura.io/v3/<API_KEY>`)
      zksync: true,
      accounts: onlykeys,
      chainId: 324,
      live: true,
      saveDeployments: true,
      tags: ["staging"],
    },
    eosMain: {
      url: "https://api.evm.eosnetwork.com/",
      accounts: onlykeys,
      chainId: 17777,
      live: true,
      saveDeployments: true,
      tags: ["staging"],
    },
    eosTest: {
      url: "https://api.testnet.evm.eosnetwork.com/",
      accounts: onlykeys,
      chainId: 15557,
      live: true,
      saveDeployments: true,
      tags: ["staging"],
    },
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://bscscan.com/
    apiKey: ""
  },
  mocha: {
    timeout: 600000
  }
};

export default config;