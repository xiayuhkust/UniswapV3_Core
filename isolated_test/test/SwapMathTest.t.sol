// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/MinimalFullMath.sol";

contract SwapMathTest is Test {
    function testSwapStep() public {
        // Test values from actual swap scenario
        uint160 sqrtPriceCurrentX96 = 79228162514264337593543950336; // 1.0
        uint160 sqrtPriceTargetX96 = 87150978765690771352898345369; // 1.1
        uint128 liquidity = 1000000;
        uint256 amountRemaining = 1000000;
        uint24 fee = 3000; // 0.3%

        // Calculate amountIn using MinimalFullMath
        uint256 amountRemainingLessFee = MinimalFullMath.mulDiv(
            amountRemaining,
            1e6 - fee,
            1e6
        );

        // Verify the result is within expected range
        assertGt(amountRemainingLessFee, 0);
        assertLt(amountRemainingLessFee, amountRemaining);
        
        // Verify exact calculation
        uint256 expectedAmount = 997000; // (1000000 * (1e6 - 3000)) / 1e6
        assertEq(amountRemainingLessFee, expectedAmount);
    }

    function testSwapStepWithMaxValues() public {
        uint256 amountRemaining = type(uint256).max;
        uint24 fee = 3000;

        uint256 amountRemainingLessFee = MinimalFullMath.mulDiv(
            amountRemaining,
            1e6 - fee,
            1e6
        );

        // Result should be 99.7% of max value
        assertEq(
            amountRemainingLessFee,
            (type(uint256).max / 1e6) * (1e6 - fee)
        );
    }
}
