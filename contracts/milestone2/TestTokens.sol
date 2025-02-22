// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Test Token Configuration
/// @notice Contains addresses and interfaces for test tokens on Tura blockchain
library TestTokens {
    // WETH (TuraWETH)
    address constant WETH = 0xF0e8a104Cc6ecC7bBa4Dc89473d1C64593eA69be;
    // Test Token 1 (TT1)
    address constant TT1 = 0x3F26F01Fa9A5506c9109B5Ad15343363909fc0b9;
    // Test Token 2 (TT2)
    address constant TT2 = 0x8FDCE0D41f0A99B5f9FbcFAfd481ffcA61d01122;

    function getWETH() internal pure returns (IERC20) {
        return IERC20(WETH);
    }

    function getTT1() internal pure returns (IERC20) {
        return IERC20(TT1);
    }

    function getTT2() internal pure returns (IERC20) {
        return IERC20(TT2);
    }
}
