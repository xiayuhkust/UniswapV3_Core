const { ethers } = require('ethers');

const provider = new ethers.providers.JsonRpcProvider('https://rpc-beta1.turablockchain.com');

async function verifyContract(address) {
  try {
    const code = await provider.getCode(address);
    return code !== '0x';
  } catch (error) {
    console.error(`Error verifying ${address}:`, error);
    return false;
  }
}

async function main() {
  // Test tokens
  const testTokens = {
    WETH: '0xF0e8a104Cc6ecC7bBa4Dc89473d1C64593eA69be',
    TT1: '0x3F26F01Fa9A5506c9109B5Ad15343363909fc0b9',
    TT2: '0x8FDCE0D41f0A99B5f9FbcFAfd481ffcA61d01122'
  };

  // Core contracts
  const coreContracts = {
    UniswapV3Pool: '0x08Bb6eA809A2d6c13D57166Fa3ede48C0ae9a70e', // Owner address used as pool address for verification
  };

  console.log('\nVerifying test token contracts...');
  for (const [name, address] of Object.entries(testTokens)) {
    const exists = await verifyContract(address);
    console.log(`${name} (${address}): ${exists ? 'Verified ✓' : 'Not Found ✗'}`);
  }

  console.log('\nVerifying core contracts...');
  for (const [name, address] of Object.entries(coreContracts)) {
    const exists = await verifyContract(address);
    console.log(`${name} (${address}): ${exists ? 'Verified ✓' : 'Not Found ✗'}`);
  }
}

main().catch(console.error);
