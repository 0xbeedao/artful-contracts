import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";

import { promises as fs } from "fs";

import * as dotenv from "dotenv";
import { HardhatUserConfig, task } from "hardhat/config";

import { deployNFTGallery } from "./src/nfts";

dotenv.config();

const PK = process.env.DEV_WALLET = process.env.DEV_WALLET || '0x0';

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task("balance", "Prints an account's balance")
.addParam("account", "The account's address or index")
.setAction(async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();
  let account = accounts[0];
  if (taskArgs.account) {
    if (accounts[taskArgs.account]) {
      account = accounts[taskArgs.account];
    } else if (parseInt(taskArgs.account) > 100) {
      account = taskArgs.account;
    }
  }
  const balance = await account.getBalance();
  console.log(`Account: ${account.address} balance:  ${ethers.utils.formatEther(balance)}`);
 });

task("deploy", "Deploys the contract")
  .setAction(async(taskArgs, hre) => {

  const contractCID = 'bafybeiazjlqz2z7lx2lluhreuujgxv3hou7z2gowcn4omypja6w4zjl5bi';
  const [deployer] = await hre.ethers.getSigners();
  if (!deployer) {
    console.error(`No account to deploy with.`);
    return;
  }
  const contract = await hre.ethers.getContractFactory("BeeMinter");
  const deployed = await contract.deploy("ArtfulOne", "BEE", contractCID);
  console.log(`BeeMinter deployed to: ${deployed.address} from ${deployer.address}`);
  const outDir = `deployments/${hre.network.name}`;
  return fs
    .mkdir(outDir)
    .then(() => fs
    .writeFile(
      `deployments/${hre.network.name}/beeminter.json`, 
      JSON.stringify({
        tx: deployed.deployTransaction.hash,
        address: deployed.address,
        deployer: deployer.address,
        timestamp: new Date().toISOString(),
      }, null, 2)
    ));
});

task("ipfs-upload")
.setAction(async(taskArgs, hre) => {
  return deployNFTGallery('art', 'Artful One OG NFT Collection')
    .then(results => {
      console.log(results);
      return results;
    });
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
  solidity: "0.8.11",
  networks: {
    ropsten: {
      url: process.env.ROPSTEN_URL || "",
      accounts: [PK],
    },
    'matic_testnet': {
  		url: "https://matic-mumbai.chainstacklabs.com",
			accounts: [PK],
			// gasPrice: 8000000000
		}
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.POLYGONSCAN_API_KEY,
  },
  typechain: {
    outDir: "./artifacts/types",
  }
};

export default config;
