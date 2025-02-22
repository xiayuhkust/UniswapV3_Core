const { ethers } = require('ethers');
const fs = require('fs');
const path = require('path');

// Load environment variables
const PRIVATE_KEY = 'ad6fb1ceb0b9dc598641ac1cef545a7882b52f5a12d7204d6074762d96a8a474';
const RPC_URL = 'https://rpc-beta1.turablockchain.com';

const provider = new ethers.providers.JsonRpcProvider(RPC_URL);
const wallet = new ethers.Wallet(PRIVATE_KEY, provider);

async function deployContract(name, args = []) {
  console.log(`Deploying ${name}...`);
  
  // Load contract artifacts
  const artifactPath = path.join(__dirname, '..', 'artifacts', 'contracts', 'milestone2', 'contracts', `${name}.sol`, `${name}.json`);
  const artifact = JSON.parse(fs.readFileSync(artifactPath, 'utf8'));
  
  // Deploy contract
  const factory = new ethers.ContractFactory(artifact.abi, artifact.bytecode, wallet);
  const contract = await factory.deploy(...args);
  await contract.deployed();
  
  console.log(`${name} deployed to:`, contract.address);
  return contract;
}

async function main() {
  // Deploy core contracts
  const uniswapV3Pool = await deployContract('UniswapV3Pool', [
    '0xF0e8a104Cc6ecC7bBa4Dc89473d1C64593eA69be', // WETH
    '0x3F26F01Fa9A5506c9109B5Ad15343363909fc0b9', // TT1
    3000, // 0.3% fee
    60 // tickSpacing
  ]);

  console.log('\nDeployment Summary:');
  console.log('-------------------');
  console.log('UniswapV3Pool:', uniswapV3Pool.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
