import { ethers, expect } from "./setup";

describe("Development Environment", () => {
    it("should have ethers available", () => {
        expect(ethers).to.not.be.undefined;
    });

    it("should connect to network", async () => {
        const [signer] = await ethers.getSigners();
        expect(await signer.getAddress()).to.be.properAddress;
    });
});
