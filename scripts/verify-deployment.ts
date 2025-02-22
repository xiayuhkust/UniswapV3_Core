import { ethers } from "hardhat";

async function main() {
  // Contract addresses from deployment
  const BITMATHLIB_ADDRESS = "0x684e34EB3BCC4c738A9dDDABAf7EBb34F75f56d7";
  const TICKBITMAP_ADDRESS = "0x80dc2a87a680821093C24f8AfE39FD5652bc4Be4";
  const TICKBITMAPTEST_ADDRESS = "0xf6b1DDaE29cC135D62Ad443dF63757aaeeb16cd8";
  
  console.log("Verifying deployed contracts...");
  
  // Connect to TickBitmapTest contract
  const TickBitmapTest = await ethers.getContractFactory("contracts/milestone2/contracts/TickBitmapTest.sol:TickBitmapTest");
  const tickBitmapTest = TickBitmapTest.attach(TICKBITMAPTEST_ADDRESS);
  
  try {
    console.log("\nTesting tick initialization...");
    const tick = 200;
    const spacing = 10;
    
    // Check initial state
    const [nextBefore, initializedBefore] = await tickBitmapTest.checkTick(tick, spacing);
    console.log("Initial state:", { nextBefore, initializedBefore });
    
    // Flip tick
    console.log("\nFlipping tick...");
    const tx = await tickBitmapTest.flipTick(tick, spacing);
    await tx.wait();
    console.log("Tick flipped");
    
    // Check state after flip
    const [nextAfter, initializedAfter] = await tickBitmapTest.checkTick(tick, spacing);
    console.log("State after flip:", { nextAfter, initializedAfter });
    
    // Test next initialized tick
    console.log("\nTesting next initialized tick...");
    const [nextRight, initializedRight] = await tickBitmapTest.nextInitializedTickWithinOneWord(190, spacing, false);
    console.log("Next tick to right:", { nextRight, initializedRight });
    
    console.log("\nVerification successful!");
  } catch (error) {
    console.error("Verification failed:", error);
    process.exit(1);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
