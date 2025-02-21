import { ethers, expect } from "../utils/setup";

describe("Development Environment", () => {
    it("should have ethers available", () => {
        expect(ethers).to.not.be.undefined;
    });

    it("should connect to network", async () => {
        const [signer] = await ethers.getSigners();
        expect(await signer.getAddress()).to.be.properAddress;
    });

    it("should compile contracts", async () => {
        const TestToken = await ethers.getContractFactory("TestERC20");
        const token = await TestToken.deploy("Test", "TST");
        await token.deployed();
        expect(token.address).to.be.properAddress;
    });
});
