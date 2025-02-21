import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract } from "ethers";

describe("CFMM", function() {
    let cfmm: Contract;
    let owner: any;

    beforeEach(async function() {
        [owner] = await ethers.getSigners();
        const CFMM = await ethers.getContractFactory("CFMM");
        cfmm = await CFMM.deploy();
        await cfmm.deployed();
    });

    describe("Initialization", function() {
        it("should initialize with correct reserves", async function() {
            await cfmm.initialize(1000, 1000);
            expect(await cfmm.reserve0()).to.equal(1000);
            expect(await cfmm.reserve1()).to.equal(1000);
        });

        it("should not allow zero amounts", async function() {
            await expect(cfmm.initialize(0, 1000))
                .to.be.revertedWith("Invalid amounts");
            await expect(cfmm.initialize(1000, 0))
                .to.be.revertedWith("Invalid amounts");
        });

        it("should not allow reinitialization", async function() {
            await cfmm.initialize(1000, 1000);
            await expect(cfmm.initialize(2000, 2000))
                .to.be.revertedWith("Already initialized");
        });
    });

    describe("Swapping", function() {
        beforeEach(async function() {
            await cfmm.initialize(10000, 10000);
        });

        it("should calculate correct output amount", async function() {
            const swapAmount = 100;
            const tx = await cfmm.swap(swapAmount);
            
            // Expected output based on formula: (y * dx * 997) / (x * 1000 + dx * 997)
            const expectedOutput = Math.floor((10000 * swapAmount * 997) / (10000 * 1000 + swapAmount * 997));
            
            await expect(tx)
                .to.emit(cfmm, "Swap")
                .withArgs(owner.address, swapAmount, expectedOutput);
        });

        it("should maintain constant product", async function() {
            const initialK = (await cfmm.reserve0()) * (await cfmm.reserve1());
            await cfmm.swap(100);
            const finalK = (await cfmm.reserve0()) * (await cfmm.reserve1());
            expect(finalK).to.be.gte(initialK);
        });

        it("should revert on invalid input", async function() {
            await expect(cfmm.swap(0))
                .to.be.revertedWith("Invalid input amount");
        });
    });
});
