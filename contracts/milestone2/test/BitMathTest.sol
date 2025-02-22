// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "forge-std/Test.sol";
import "../contracts/BitMath.sol";

contract BitMathTest is Test {
    function testMostSignificantBitZero() public {
        vm.expectRevert("BitMath: ZERO_VALUE");
        BitMath.mostSignificantBit(0);
    }

    function testLeastSignificantBitZero() public {
        vm.expectRevert("BitMath: ZERO_VALUE");
        BitMath.leastSignificantBit(0);
    }

    function testMostSignificantBitOne() public {
        assertEq(BitMath.mostSignificantBit(1), 0);
    }

    function testLeastSignificantBitOne() public {
        assertEq(BitMath.leastSignificantBit(1), 0);
    }

    function testMostSignificantBitPowersOfTwo() public {
        assertEq(BitMath.mostSignificantBit(2), 1);
        assertEq(BitMath.mostSignificantBit(4), 2);
        assertEq(BitMath.mostSignificantBit(8), 3);
        assertEq(BitMath.mostSignificantBit(16), 4);
        assertEq(BitMath.mostSignificantBit(32), 5);
    }

    function testLeastSignificantBitPowersOfTwo() public {
        assertEq(BitMath.leastSignificantBit(2), 1);
        assertEq(BitMath.leastSignificantBit(4), 2);
        assertEq(BitMath.leastSignificantBit(8), 3);
        assertEq(BitMath.leastSignificantBit(16), 4);
        assertEq(BitMath.leastSignificantBit(32), 5);
    }
}
