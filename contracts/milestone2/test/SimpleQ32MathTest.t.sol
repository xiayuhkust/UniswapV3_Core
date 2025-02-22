// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../contracts/libraries/SimpleQ32Math.sol";

contract SimpleQ32MathTest is Test {
    function testDivByZero() public {
        vm.expectRevert(SimpleQ32Math.DivisionByZero.selector);
        SimpleQ32Math.mulDiv(100, 200, 0);
    }

    function testSignedMulDiv() public {
        assertEq(SimpleQ32Math.mulDiv(-100, 200, 100), -200);
        assertEq(SimpleQ32Math.mulDiv(100, 200, 100), 200);
    }

    function testZeroInputs() public {
        assertEq(SimpleQ32Math.mulDiv(0, 200, 100), 0);
        assertEq(SimpleQ32Math.mulDiv(100, 0, 100), 0);
    }

    function testRoundingUp() public {
        assertEq(SimpleQ32Math.mulDivRoundingUp(101, 200, 100), 203);
        assertEq(SimpleQ32Math.mulDivRoundingUp(-101, 200, 100), -202);
    }

    function testOverflow() public {
        vm.expectRevert(SimpleQ32Math.MultiplicationOverflow.selector);
        SimpleQ32Math.mulDiv(type(int256).max, type(uint256).max, 1);
    }

    function testQ32Precision() public {
        // Test Q32.32 fixed-point precision
        assertEq(SimpleQ32Math.mulDiv(1e18, 1e18, 1e18), 1e18);
        assertEq(SimpleQ32Math.mulDiv(-1e18, 1e18, 1e18), -1e18);
    }

    function testFeeCalculation() public {
        // Test fee calculation (0.3% fee)
        assertEq(SimpleQ32Math.mulDiv(1000000, 997000, 1000000), 997000); // 99.7% of 1M
        assertEq(SimpleQ32Math.mulDiv(-1000000, 997000, 1000000), -997000); // 99.7% of -1M
    }
}
