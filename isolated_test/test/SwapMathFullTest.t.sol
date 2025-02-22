// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/MinimalFullMath.sol";
import "../src/FixedPoint96.sol";

contract SwapMathFullTest is Test {
    // Constants from actual Uniswap V3 deployments
    uint160 constant MIN_SQRT_RATIO = 4295128739;
    uint160 constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;
    
    function testFeeCalculation() public {
        // Test with realistic pool values
        uint256 amount = 1000000; // 1M tokens
        uint24 fee = 3000; // 0.3% fee
        
        uint256 amountLessFee = MinimalFullMath.mulDiv(
            amount,
            1e6 - fee,
            1e6
        );
        
        // Should be 997,000 (99.7% of 1M)
        assertEq(amountLessFee, 997000);
    }
    
    function testLargeAmountFeeCalculation() public {
        // Test with large but realistic amounts
        uint256 amount = 1e27; // 1 billion tokens with 18 decimals
        uint24 fee = 3000; // 0.3% fee
        
        uint256 amountLessFee = MinimalFullMath.mulDiv(
            amount,
            1e6 - fee,
            1e6
        );
        
        // Should be 99.7% of input
        assertEq(amountLessFee, (amount * (1e6 - fee)) / 1e6);
    }

    function testMaxValueFeeCalculation() public {
        // Test with maximum possible token amount
        uint256 amount = type(uint256).max;
        uint24 fee = 3000; // 0.3% fee
        
        uint256 amountLessFee = MinimalFullMath.mulDiv(
            amount,
            1e6 - fee,
            1e6
        );
        
        // Should handle max value correctly
        assertEq(amountLessFee, (amount / 1e6) * (1e6 - fee));
    }

    function testPriceImpactCalculation() public {
        // Test price impact calculation with realistic values
        uint160 sqrtPriceCurrentX96 = 79228162514264337593543950336; // 1.0
        uint160 sqrtPriceTargetX96 = 87150978765690771352898345369;  // 1.1
        uint128 liquidity = 1000000;
        
        // Calculate price impact using mulDiv
        uint256 priceRatio = MinimalFullMath.mulDiv(
            uint256(sqrtPriceTargetX96),
            FixedPoint96.Q96,
            uint256(sqrtPriceCurrentX96)
        );
        
        // Price ratio should be approximately 1.1
        assertGt(priceRatio, FixedPoint96.Q96);
        assertLt(priceRatio, (11 * FixedPoint96.Q96) / 10);
    }
}
