// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/MinimalPRBMath.sol";

contract MinimalPRBMathTest is Test {
    function testBasicMultiplyDivide() public pure {
        // Simple case: (10 * 20) / 5 = 40
        uint256 result = MinimalPRBMath.mulDiv(10, 20, 5);
        assert(result == 40);
    }

    function testZeroInput() public pure {
        uint256 result = MinimalPRBMath.mulDiv(0, 20, 5);
        assert(result == 0);
    }

    function testDivByZero() public {
        vm.expectRevert();
        MinimalPRBMath.mulDiv(10, 20, 0);
    }

    function testPhantomOverflow() public pure {
        // Test with numbers that would overflow normal multiplication
        // but work with phantom overflow handling
        uint256 result = MinimalPRBMath.mulDiv(
            2**128,  // Large number
            2**128,  // Large number
            2**128   // Large divisor
        );
        assert(result == 2**128);
    }

    function testSmallNumbers() public pure {
        // Test with small numbers: (5 * 7) / 2 = 17
        uint256 result = MinimalPRBMath.mulDiv(5, 7, 2);
        assert(result == 17);
    }

    function testLargeNumbers() public pure {
        // Test with larger numbers that won't overflow
        uint256 result = MinimalPRBMath.mulDiv(
            1000000000000000000,  // 1e18
            2000000000000000000,  // 2e18
            1000000000000000000   // 1e18
        );
        assert(result == 2000000000000000000); // Should equal 2e18
    }

    function testEdgeCases() public pure {
        // Test with max uint256 divided by itself
        uint256 result = MinimalPRBMath.mulDiv(
            type(uint256).max,
            1,
            type(uint256).max
        );
        assert(result == 1);
    }

    function testRoundingDown() public pure {
        // Test rounding behavior: (10 * 10) / 3 = 33
        uint256 result = MinimalPRBMath.mulDiv(10, 10, 3);
        assert(result == 33);
    }

    function testMaxDivByMax() public pure {
        // Test max divided by max equals 1
        uint256 result = MinimalPRBMath.mulDiv(
            type(uint256).max,
            1,
            type(uint256).max
        );
        assert(result == 1);
    }

    function testMaxTimesOneOverTwo() public pure {
        // Test max * 1 / 2 = max/2
        uint256 result = MinimalPRBMath.mulDiv(
            type(uint256).max,
            1,
            2
        );
        assert(result == type(uint256).max / 2);
    }
}
