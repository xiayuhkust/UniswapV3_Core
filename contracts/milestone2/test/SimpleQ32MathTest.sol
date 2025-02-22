// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../contracts/libraries/SimpleQ32Math.sol";

contract SimpleQ32MathTest is Test {
    function testBasicOperations() public pure {
        // Test basic multiplication and division
        uint256 result = SimpleQ32Math.mulDiv(100, 200, 50);
        assert(result == 400); // 100 * 200 / 50 = 400
    }

    function testFeeCalculation() public pure {
        // Test fee calculation with 1M tokens and 0.3% fee
        uint256 amount = 1000000;
        uint24 fee = 3000; // 0.3%
        uint256 result = SimpleQ32Math.mulDiv(
            amount,
            1e6 - fee,
            1e6
        );
        assert(result == 997000); // Should get 99.7% of input
    }

    function testZeroInputs() public pure {
        // Test with zero inputs
        uint256 result = SimpleQ32Math.mulDiv(0, 100, 50);
        assert(result == 0);
        
        result = SimpleQ32Math.mulDiv(100, 0, 50);
        assert(result == 0);
    }

    function testDivByZero() public {
        // Test division by zero reverts
        vm.expectRevert("SimpleQ32Math: division by zero");
        SimpleQ32Math.mulDiv(100, 200, 0);
    }

    function testLargeNumbers() public pure {
        // Test with large but safe numbers
        uint256 result = SimpleQ32Math.mulDiv(
            1e27, // 1 billion tokens with 18 decimals
            1e6 - 3000, // 99.7%
            1e6
        );
        assert(result == (1e27 * (1e6 - 3000)) / 1e6);
    }

    function testRoundingUp() public {
        // Test rounding up behavior
        uint256 result = SimpleQ32Math.mulDivRoundingUp(10, 10, 3);
        assertEq(result, 34); // Rounds up from 33.33...

        result = SimpleQ32Math.mulDivRoundingUp(100, 100, 30);
        assertEq(result, 334); // Rounds up from 333.33...
    }
}
