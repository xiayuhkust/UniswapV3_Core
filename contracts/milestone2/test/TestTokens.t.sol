// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TestTokensTest is Test {
    IERC20 public constant WETH = IERC20(0xF0e8a104Cc6ecC7bBa4Dc89473d1C64593eA69be);
    IERC20 public constant TT1 = IERC20(0x3F26F01Fa9A5506c9109B5Ad15343363909fc0b9);
    IERC20 public constant TT2 = IERC20(0x8FDCE0D41f0A99B5f9FbcFAfd481ffcA61d01122);

    function setUp() public {
        string memory rpc = vm.envOr("ETH_RPC_URL", "https://rpc-beta1.turablockchain.com");
        uint256 forkId = vm.createSelectFork(rpc);
        require(forkId >= 0, "Fork creation failed");
        require(block.number > 0, "Fork not created properly");
    }

    function testTokenSupplies() public {
        uint256 wethSupply = WETH.totalSupply();
        console.log("WETH supply:", wethSupply);
        uint256 tt1Supply = TT1.totalSupply();
        console.log("TT1 supply:", tt1Supply);
        uint256 tt2Supply = TT2.totalSupply();
        console.log("TT2 supply:", tt2Supply);

        assertEq(wethSupply, 1_000_000 * 10**18, "WETH supply mismatch");
        assertEq(tt1Supply, 1_000_000 * 10**18, "TT1 supply mismatch");
        assertEq(tt2Supply, 1_000_000 * 10**18, "TT2 supply mismatch");
    }
}
