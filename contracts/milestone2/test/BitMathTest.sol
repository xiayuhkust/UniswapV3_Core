// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "../contracts/BitMath.sol";

contract BitMathTest {
    function mostSignificantBit(uint256 x) external pure returns (uint8 r) {
        return BitMath.mostSignificantBit(x);
    }

    function leastSignificantBit(uint256 x) external pure returns (uint8 r) {
        require(x > 0, "BitMath: ZERO_VALUE");
        return BitMath.leastSignificantBit(x);
    }
}
