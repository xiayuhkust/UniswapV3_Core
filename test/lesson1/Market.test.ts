import { ethers, expect } from "../setup";
import { Contract } from "ethers";

describe("Market", function() {
    let market: Contract;
    let owner: any;
    let addr1: any;

    beforeEach(async function() {
        [owner, addr1] = await ethers.getSigners();
        const Market = await ethers.getContractFactory("Market");
        market = await Market.deploy();
        await market.deployed();
    });

    describe("Order Book", function() {
        it("should allow placing orders", async function() {
            const price = 100;
            const amount = 10;
            await market.placeOrder(price, amount, true);
            expect(await market.getOrderCount()).to.equal(1);
        });

        it("should reject orders with zero amount", async function() {
            await expect(
                market.placeOrder(100, 0, true)
            ).to.be.revertedWith("Amount must be greater than 0");
        });
    });
});
