import { expect } from "chai";
import { ethers } from "hardhat";

describe("TickBitmap", function() {
  let tickBitmapTest: any;

  beforeEach(async function() {
    const TickBitmapTest = await ethers.getContractFactory("contracts/milestone2/contracts/TickBitmapTest.sol:TickBitmapTest");
    tickBitmapTest = await TickBitmapTest.deploy();
    await tickBitmapTest.deployed();
  });

  it("should flip tick and verify initialization", async function() {
    await tickBitmapTest.testFlipTick();
  });

  it("should find next initialized tick within one word", async function() {
    await tickBitmapTest.testNextInitializedTickWithinOneWord();
  });
});
