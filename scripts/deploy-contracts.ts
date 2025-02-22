import { ethers } from 'hardhat';

async function main() {
  console.log('Deploying contracts to Tura network...');

  // Deploy UniswapV3Pool
  const UniswapV3Pool = await ethers.getContractFactory('UniswapV3Pool');
  const pool = await UniswapV3Pool.deploy(
    '0xF0e8a104Cc6ecC7bBa4Dc89473d1C64593eA69be', // WETH
    '0x3F26F01Fa9A5506c9109B5Ad15343363909fc0b9', // TT1
    3000, // 0.3% fee
    60 // tickSpacing
  );
  await pool.deployed();

  console.log('UniswapV3Pool deployed to:', pool.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
