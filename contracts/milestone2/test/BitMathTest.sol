// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "../contracts/BitMath.sol";

contract BitMathTest {
    using BitMath for uint256;

    function testLeastSignificantBit(uint256 x) public pure returns (uint8) {
        return BitMath.leastSignificantBit(x);
    }

    function testMostSignificantBit(uint256 x) public pure returns (uint8) {
        return BitMath.mostSignificantBit(x);
    }
}
