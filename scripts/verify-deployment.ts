import { ethers } from 'hardhat';

async function main() {
  const provider = new ethers.providers.JsonRpcProvider('https://rpc-beta1.turablockchain.com');
  
  const testTokens = {
    WETH: '0xF0e8a104Cc6ecC7bBa4Dc89473d1C64593eA69be',
    TT1: '0x3F26F01Fa9A5506c9109B5Ad15343363909fc0b9',
    TT2: '0x8FDCE0D41f0A99B5f9FbcFAfd481ffcA61d01122'
  };

  console.log('\nVerifying test token contracts...');
  for (const [name, address] of Object.entries(testTokens)) {
    const code = await provider.getCode(address);
    console.log(`${name} (${address}): ${code !== '0x' ? 'Verified ✓' : 'Not Found ✗'}`);
  }

  // We'll add the pool address here once deployment is complete
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
