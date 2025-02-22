import { ethers } from "hardhat";

async function main() {
  console.log("Deploying BitMath...");
  const BitMath = await ethers.getContractFactory("contracts/milestone2/contracts/BitMath.sol:BitMath");
  const bitMath = await BitMath.deploy();
  await bitMath.deployed();
  console.log("BitMath deployed to:", bitMath.address);

  console.log("\nDeploying TickBitmap...");
  const TickBitmap = await ethers.getContractFactory("contracts/milestone2/contracts/TickBitmap.sol:TickBitmap");
  const tickBitmap = await TickBitmap.deploy();
  await tickBitmap.deployed();
  console.log("TickBitmap deployed to:", tickBitmap.address);

  console.log("\nDeploying TickBitmapTest...");
  const TickBitmapTest = await ethers.getContractFactory("contracts/milestone2/contracts/TickBitmapTest.sol:TickBitmapTest");
  const tickBitmapTest = await TickBitmapTest.deploy();
  await tickBitmapTest.deployed();
  console.log("TickBitmapTest deployed to:", tickBitmapTest.address);

  return {
    bitMath: bitMath.address,
    tickBitmap: tickBitmap.address,
    tickBitmapTest: tickBitmapTest.address
  };
}

main()
  .then((addresses) => {
    console.log("\nDeployment Summary:", addresses);
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
