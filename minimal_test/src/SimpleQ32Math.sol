// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.14;

library SimpleQ32Math {
    uint256 internal constant Q32 = 0x100000000;
    error DivisionByZero();

    function mulDiv(uint256 a, uint256 b, uint256 denominator) internal pure returns (uint256) {
        if (denominator == 0) revert DivisionByZero();
        if (a == 0 || b == 0) return 0;
        uint256 aQ32 = a * Q32;
        uint256 bQ32 = b;
        return (aQ32 * bQ32) / (denominator * Q32);
    }
}
