import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract } from "ethers";

describe("SqrtPriceMath", () => {
    let sqrtPriceMath: Contract;

    beforeEach(async () => {
        const SqrtPriceMathFactory = await ethers.getContractFactory("SqrtPriceMath");
        sqrtPriceMath = await SqrtPriceMathFactory.deploy();
        await sqrtPriceMath.deployed();
    });

    describe("Price Calculations", () => {
        it("should calculate next price from input", async () => {
            // TODO: Add price calculation tests once implementation is complete
        });

        it("should calculate next price from output", async () => {
            // TODO: Add price calculation tests once implementation is complete
        });
    });
});
