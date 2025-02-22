// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../TestTokens.sol";

contract TestTokensTest {
    function testTokenSupplies() public {
        require(IERC20(TestTokens.TT1).totalSupply() == 1_000_000 * 10**18, "TT1 supply should be 1M");
        require(IERC20(TestTokens.TT2).totalSupply() == 1_000_000 * 10**18, "TT2 supply should be 1M");
    }
}
