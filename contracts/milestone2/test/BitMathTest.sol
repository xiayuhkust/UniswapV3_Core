// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "forge-std/Test.sol";
import "../contracts/BitMath.sol";

contract BitMathTest is Test {
    function testMostSignificantBit() public {
        assertEq(BitMath.mostSignificantBit(1), 0);
        assertEq(BitMath.mostSignificantBit(2), 1);
        assertEq(BitMath.mostSignificantBit(4), 2);
    }

    function testLeastSignificantBit() public {
        assertEq(BitMath.leastSignificantBit(1), 0);
        assertEq(BitMath.leastSignificantBit(2), 1);
        assertEq(BitMath.leastSignificantBit(4), 2);
    }

    function testZeroInput() public {
        vm.expectRevert(bytes("BitMath: ZERO_VALUE"));
        BitMath.leastSignificantBit(0);

        vm.expectRevert(bytes("BitMath: ZERO_VALUE"));
        BitMath.mostSignificantBit(0);
    }
}
