import { ethers } from "hardhat";

async function main() {
  console.log("Deploying BitMath...");
  const BitMath = await ethers.getContractFactory("contracts/milestone2/contracts/BitMath.sol:BitMath");
  const bitMath = await BitMath.deploy();
  await bitMath.deployed();
  console.log("BitMath deployed to:", bitMath.address);

  console.log("Deploying TickBitmap...");
  const TickBitmap = await ethers.getContractFactory("contracts/milestone2/contracts/TickBitmap.sol:TickBitmap");
  const tickBitmap = await TickBitmap.deploy();
  await tickBitmap.deployed();
  console.log("TickBitmap deployed to:", tickBitmap.address);

  return { bitMath: bitMath.address, tickBitmap: tickBitmap.address };
}

main()
  .then((addresses) => {
    console.log("Deployment successful!");
    console.log("Addresses:", addresses);
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
