// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "forge-std/Test.sol";
import "../contracts/BitMath.sol";

contract BitMathTest is Test {
    function testMostSignificantBitZero() public {
        try BitMath.mostSignificantBit(0) {
            fail("Expected revert on zero input");
        } catch Error(string memory error) {
            assertEq(error, "BitMath: ZERO_VALUE");
        }
    }

    function testLeastSignificantBitZero() public {
        try BitMath.leastSignificantBit(0) {
            fail("Expected revert on zero input");
        } catch Error(string memory error) {
            assertEq(error, "BitMath: ZERO_VALUE");
        }
    }

    function testMostSignificantBitOne() public {
        assertEq(uint256(BitMath.mostSignificantBit(1)), uint256(0));
    }

    function testLeastSignificantBitOne() public {
        assertEq(uint256(BitMath.leastSignificantBit(1)), uint256(0));
    }

    function testMostSignificantBitPowersOfTwo() public {
        assertEq(uint256(BitMath.mostSignificantBit(2)), uint256(1));
        assertEq(uint256(BitMath.mostSignificantBit(4)), uint256(2));
        assertEq(uint256(BitMath.mostSignificantBit(8)), uint256(3));
        assertEq(uint256(BitMath.mostSignificantBit(16)), uint256(4));
        assertEq(uint256(BitMath.mostSignificantBit(32)), uint256(5));
    }

    function testLeastSignificantBitPowersOfTwo() public {
        assertEq(uint256(BitMath.leastSignificantBit(2)), uint256(1));
        assertEq(uint256(BitMath.leastSignificantBit(4)), uint256(2));
        assertEq(uint256(BitMath.leastSignificantBit(8)), uint256(3));
        assertEq(uint256(BitMath.leastSignificantBit(16)), uint256(4));
        assertEq(uint256(BitMath.leastSignificantBit(32)), uint256(5));
    }
}
