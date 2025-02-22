// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "forge-std/Test.sol";
import "../contracts/BitMath.sol";

contract BitMathTest is Test {
    function testMostSignificantBit() public {
        assertEq(BitMath.mostSignificantBit(1), 0, "MSB of 1");
        assertEq(BitMath.mostSignificantBit(2), 1, "MSB of 2");
        assertEq(BitMath.mostSignificantBit(4), 2, "MSB of 4");
        assertEq(BitMath.mostSignificantBit(8), 3, "MSB of 8");
        assertEq(BitMath.mostSignificantBit(16), 4, "MSB of 16");
    }

    function testLeastSignificantBit() public {
        assertEq(BitMath.leastSignificantBit(1), 0, "LSB of 1");
        assertEq(BitMath.leastSignificantBit(2), 1, "LSB of 2");
        assertEq(BitMath.leastSignificantBit(4), 2, "LSB of 4");
        assertEq(BitMath.leastSignificantBit(8), 3, "LSB of 8");
        assertEq(BitMath.leastSignificantBit(16), 4, "LSB of 16");
    }

    function testZeroInput() public {
        vm.expectRevert(bytes("BitMath: ZERO_VALUE"));
        BitMath.leastSignificantBit(0);

        vm.expectRevert(bytes("BitMath: ZERO_VALUE"));
        BitMath.mostSignificantBit(0);
    }
}
