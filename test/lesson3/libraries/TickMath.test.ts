import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract } from "ethers";

describe("TickMath", () => {
    let tickMath: Contract;

    beforeEach(async () => {
        const TickMathFactory = await ethers.getContractFactory("TickMath");
        tickMath = await TickMathFactory.deploy();
        await tickMath.deployed();
    });

    describe("Tick Range", () => {
        it("should have correct min/max tick values", async () => {
            const minTick = await tickMath.MIN_TICK();
            const maxTick = await tickMath.MAX_TICK();
            expect(minTick).to.equal(-887272);
            expect(maxTick).to.equal(887272);
        });
    });

    describe("Price Conversion", () => {
        it("should validate tick range", async () => {
            // Test invalid tick
            await expect(
                tickMath.getSqrtRatioAtTick(-887273)
            ).to.be.revertedWith('T');
            
            await expect(
                tickMath.getSqrtRatioAtTick(887273)
            ).to.be.revertedWith('T');

            // Test valid tick
            await expect(
                tickMath.getSqrtRatioAtTick(0)
            ).not.to.be.reverted;
        });

        it("should handle zero tick correctly", async () => {
            const price = await tickMath.getSqrtRatioAtTick(0);
            expect(price).to.equal(ethers.BigNumber.from(2).pow(96));
        });
    });
});
