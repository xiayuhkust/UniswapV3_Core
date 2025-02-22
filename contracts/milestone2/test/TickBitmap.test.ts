import { expect } from "chai";
import { ethers } from "hardhat";

describe("TickBitmap", function() {
  let tickBitmapTest: any;

  beforeEach(async function() {
    const TickBitmapTest = await ethers.getContractFactory("contracts/milestone2/contracts/TickBitmapTest.sol:TickBitmapTest");
    tickBitmapTest = await TickBitmapTest.deploy();
    await tickBitmapTest.deployed();
  });

  describe("Tick Initialization and Flipping", () => {
    it("should initialize and flip a tick correctly", async function() {
      const tick = 200;
      const spacing = 10;
      
      // Initial state should be uninitialized
      const [nextBefore, initializedBefore] = await tickBitmapTest.checkTick(tick, spacing);
      expect(initializedBefore).to.be.false;
      
      // Flip tick to initialized
      await tickBitmapTest.flipTick(tick, spacing);
      
      // Check initialization
      const [nextAfter, initializedAfter] = await tickBitmapTest.checkTick(tick, spacing);
      expect(initializedAfter).to.be.true;
      expect(nextAfter).to.equal(tick);
      
      // Flip back to uninitialized
      await tickBitmapTest.flipTick(tick, spacing);
      
      // Verify uninitialized
      const [nextFinal, initializedFinal] = await tickBitmapTest.checkTick(tick, spacing);
      expect(initializedFinal).to.be.false;
    });

    it("should revert when tick is not properly spaced", async function() {
      const tick = 205; // Not divisible by spacing
      const spacing = 10;
      
      await expect(tickBitmapTest.flipTick(tick, spacing))
        .to.be.revertedWith("tick must be divisible by spacing");
    });
  });

  describe("Next Initialized Tick", () => {
    it("should find next initialized tick within one word", async function() {
      const spacing = 10;
      
      // Initialize some ticks
      await tickBitmapTest.flipTick(200, spacing); // 200/10 = 20
      await tickBitmapTest.flipTick(400, spacing); // 400/10 = 40
      await tickBitmapTest.flipTick(800, spacing); // 800/10 = 80
      
      // Search right
      const [nextRight, initializedRight] = await tickBitmapTest.nextInitializedTickWithinOneWord(190, spacing, false);
      expect(nextRight).to.equal(200);
      expect(initializedRight).to.be.true;
      
      // Search left
      const [nextLeft, initializedLeft] = await tickBitmapTest.nextInitializedTickWithinOneWord(500, spacing, true);
      expect(nextLeft).to.equal(400);
      expect(initializedLeft).to.be.true;
    });
  });
});
