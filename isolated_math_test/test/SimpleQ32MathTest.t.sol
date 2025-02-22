// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/SimpleQ32Math.sol";

contract SimpleQ32MathTest is Test {
    function testDivByZero() public {
        vm.expectRevert("SimpleQ32Math: division by zero");
        this.callMulDiv(100, 200, 0);
    }

    function testSignedMulDiv() public pure {
        assertEq(SimpleQ32Math.mulDiv(-100, 200, 100), -200);
        assertEq(SimpleQ32Math.mulDiv(100, 200, 100), 200);
    }

    function testZeroInputs() public pure {
        assertEq(SimpleQ32Math.mulDiv(0, 200, 100), 0);
        assertEq(SimpleQ32Math.mulDiv(100, 0, 100), 0);
    }

    function testRoundingUp() public pure {
        // Test basic rounding for positive numbers
        assertEq(SimpleQ32Math.mulDivRoundingUp(101, 200, 100), 202); // 202.0 exact
        // Test basic rounding for negative numbers
        assertEq(SimpleQ32Math.mulDivRoundingUp(-101, 200, 100), -202); // -202.0 exact
        // Test no remainder case
        assertEq(SimpleQ32Math.mulDivRoundingUp(100, 200, 100), 200); // 200.0 exact
        assertEq(SimpleQ32Math.mulDivRoundingUp(-100, 200, 100), -200); // -200.0 exact
        // Test rounding with small numbers that have remainder
        assertEq(SimpleQ32Math.mulDivRoundingUp(3, 2, 2), 3); // 1.5 rounds up to 3
        assertEq(SimpleQ32Math.mulDivRoundingUp(-3, 2, 2), -3); // -1.5 rounds to -3
        // Test actual rounding case
        assertEq(SimpleQ32Math.mulDivRoundingUp(101, 201, 100), 204); // 203.01 rounds up to 204
        assertEq(SimpleQ32Math.mulDivRoundingUp(-101, 201, 100), -204); // -203.01 rounds to -204
    }

    function testOverflowRoundingUp() public {
        vm.expectRevert("SimpleQ32Math: result overflow");
        this.callMulDivRoundingUp(type(int256).max, 2, 1);
    }

    function testOverflow() public {
        vm.expectRevert("SimpleQ32Math: multiplication overflow");
        this.callMulDiv(type(int256).min, 2, 1);
    }

    function testEdgeCases() public {
        // Test min int256 with multiplier 1 (should work)
        assertEq(this.callMulDiv(type(int256).min, 1, 1), type(int256).min);
        // Test max int256 with multiplier 1 (should work)
        assertEq(this.callMulDiv(type(int256).max, 1, 1), type(int256).max);
    }

    // External functions for testing reverts
    function callMulDiv(int256 amount, uint256 multiplier, uint256 denominator) external pure returns (int256) {
        return SimpleQ32Math.mulDiv(amount, multiplier, denominator);
    }

    function callMulDivRoundingUp(int256 amount, uint256 multiplier, uint256 denominator) external pure returns (int256) {
        return SimpleQ32Math.mulDivRoundingUp(amount, multiplier, denominator);
    }

    function testQ32Precision() public pure {
        // Test Q32.32 fixed-point precision
        assertEq(SimpleQ32Math.mulDiv(1e18, 1e18, 1e18), 1e18);
        assertEq(SimpleQ32Math.mulDiv(-1e18, 1e18, 1e18), -1e18);
    }

    function testFeeCalculation() public pure {
        // Test fee calculation (0.3% fee)
        assertEq(SimpleQ32Math.mulDiv(1000000, 997000, 1000000), 997000); // 99.7% of 1M
        assertEq(SimpleQ32Math.mulDiv(-1000000, 997000, 1000000), -997000); // 99.7% of -1M
    }
}
