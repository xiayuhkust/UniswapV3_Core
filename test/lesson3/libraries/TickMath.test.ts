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
            const minTick = await tickMath.MIN_TICK();
            const maxTick = await tickMath.MAX_TICK();
            
            await expect(
                tickMath.getSqrtRatioAtTick(minTick.sub(1))
            ).to.be.revertedWith('T');
            
            await expect(
                tickMath.getSqrtRatioAtTick(maxTick.add(1))
            ).to.be.revertedWith('T');
        });
    });
});
