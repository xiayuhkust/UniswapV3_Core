// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TestTokensTest is Test {
    IERC20 public constant WETH = IERC20(0xF0e8a104Cc6ecC7bBa4Dc89473d1C64593eA69be);
    IERC20 public constant TT1 = IERC20(0x3F26F01Fa9A5506c9109B5Ad15343363909fc0b9);
    IERC20 public constant TT2 = IERC20(0x8FDCE0D41f0A99B5f9FbcFAfd481ffcA61d01122);

    function testTokenSupplies() public {
        vm.createSelectFork("tura");
        assertEq(WETH.totalSupply(), 1_000_000 * 10**18, "WETH supply mismatch");
        assertEq(TT1.totalSupply(), 1_000_000 * 10**18, "TT1 supply mismatch");
        assertEq(TT2.totalSupply(), 1_000_000 * 10**18, "TT2 supply mismatch");
    }
}
