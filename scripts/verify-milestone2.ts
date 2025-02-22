import { ethers } from "hardhat";

async function main() {
  console.log("Deploying BitMathTest...");
  const BitMathTest = await ethers.getContractFactory("contracts/milestone2/test/BitMathTest.sol:BitMathTest");
  const bitMathTest = await BitMathTest.deploy();
  await bitMathTest.deployed();
  console.log("BitMathTest deployed to:", bitMathTest.address);

  try {
    console.log("\nTesting BitMath functions...");
    const testValue = ethers.BigNumber.from("0x100");
    
    console.log("Testing leastSignificantBit...");
    const lsb = await bitMathTest.testLeastSignificantBit(testValue);
    console.log("LSB of 0x100:", lsb.toString());
    
    console.log("Testing mostSignificantBit...");
    const msb = await bitMathTest.testMostSignificantBit(testValue);
    console.log("MSB of 0x100:", msb.toString());
    
    console.log("BitMath verification successful!");
  } catch (error) {
    console.error("BitMath verification failed:", error);
    process.exit(1);
  }

  console.log("\nDeploying TickBitmapTest...");
  const TickBitmapTest = await ethers.getContractFactory("contracts/milestone2/contracts/TickBitmapTest.sol:TickBitmapTest");
  const tickBitmapTest = await TickBitmapTest.deploy();
  await tickBitmapTest.deployed();
  console.log("TickBitmapTest deployed to:", tickBitmapTest.address);

  try {
    console.log("\nTesting TickBitmap functions...");
    await tickBitmapTest.testFlipTick();
    console.log("Flip tick test passed");
    
    await tickBitmapTest.testNextInitializedTickWithinOneWord();
    console.log("Next initialized tick test passed");
    
    console.log("TickBitmap verification successful!");
  } catch (error) {
    console.error("TickBitmap verification failed:", error);
    process.exit(1);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
