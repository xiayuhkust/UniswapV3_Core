// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/MinimalFullMath.sol";

contract MinimalFullMathTest is Test {
    function testBasicMultiplyDivide() public pure {
        // Simple case: (10 * 20) / 5 = 40
        uint256 result = MinimalFullMath.mulDiv(10, 20, 5);
        assert(result == 40);
    }

    function testZeroInput() public pure {
        uint256 result = MinimalFullMath.mulDiv(0, 20, 5);
        assert(result == 0);
    }

    function testDivByZero() public {
        vm.expectRevert(bytes("denominator must be > 0"));
        MinimalFullMath.mulDiv(10, 20, 0);
    }

    function testMaxDivByMax() public {
        // Test max divided by max equals 1
        uint256 result = MinimalFullMath.mulDiv(
            type(uint256).max,
            1,
            type(uint256).max
        );
        assertEq(result, 1);
    }

    function testMaxTimesOneOverTwo() public {
        // Test max * 1 / 2 = max/2
        uint256 result = MinimalFullMath.mulDiv(
            type(uint256).max,
            1,
            2
        );
        assertEq(result, type(uint256).max / 2);
    }

    function testOverflow() public {
        vm.expectRevert("overflow");
        MinimalFullMath.mulDiv(
            type(uint256).max,
            type(uint256).max,
            1
        );
    }

    function testSmallNumbers() public {
        // Test with small numbers: (5 * 7) / 2 = 17
        uint256 result = MinimalFullMath.mulDiv(5, 7, 2);
        assertEq(result, 17);
    }

    function testRoundingDown() public {
        // Test that division rounds down
        // 7/2 = 3.5 should round down to 3
        uint256 result = MinimalFullMath.mulDiv(7, 1, 2);
        assertEq(result, 3);
    }

    function testPhantomOverflow() public {
        // Test with numbers that would overflow normal multiplication
        // but work with phantom overflow handling
        uint256 result = MinimalFullMath.mulDiv(
            2**128,  // Large number
            2**128,  // Large number
            2**128   // Large divisor
        );
        assertEq(result, 2**128);
    }
}
