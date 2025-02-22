// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../contracts/libraries/LiquidityMath.sol";

contract LiquidityMathTest is Test {
    function testAddLiquidity() public {
        uint128 liquidity = 1000;
        int128 delta = 100;
        
        // Test adding liquidity
        uint128 newLiquidity = LiquidityMath.addLiquidity(liquidity, delta);
        assertEq(uint256(newLiquidity), uint256(1100), "Adding liquidity failed");
        
        // Test removing liquidity
        newLiquidity = LiquidityMath.addLiquidity(liquidity, -100);
        assertEq(uint256(newLiquidity), uint256(900), "Removing liquidity failed");
    }

    function testGetLiquidityForAmount0() public {
        uint160 sqrtPriceAX96 = 1 << 96;  // 1.0
        uint160 sqrtPriceBX96 = 2 << 96;  // 2.0
        uint256 amount0 = 1e18;  // 1 token

        uint128 liquidity = LiquidityMath.getLiquidityForAmount0(
            sqrtPriceAX96,
            sqrtPriceBX96,
            amount0
        );
        assertTrue(liquidity > 0, "Liquidity should be greater than 0");
    }

    function testGetLiquidityForAmount1() public {
        uint160 sqrtPriceAX96 = 1 << 96;  // 1.0
        uint160 sqrtPriceBX96 = 2 << 96;  // 2.0
        uint256 amount1 = 1e18;  // 1 token

        uint128 liquidity = LiquidityMath.getLiquidityForAmount1(
            sqrtPriceAX96,
            sqrtPriceBX96,
            amount1
        );
        assertTrue(liquidity > 0, "Liquidity should be greater than 0");
    }

    function testGetLiquidityForAmounts() public {
        uint160 sqrtPriceX96 = uint160(1.5 * (1 << 96));  // Current price 1.5
        uint160 sqrtPriceAX96 = 1 << 96;  // Lower price 1.0
        uint160 sqrtPriceBX96 = 2 << 96;  // Upper price 2.0
        uint256 amount0 = 1e18;  // 1 token0
        uint256 amount1 = 1e18;  // 1 token1

        uint128 liquidity = LiquidityMath.getLiquidityForAmounts(
            sqrtPriceX96,
            sqrtPriceAX96,
            sqrtPriceBX96,
            amount0,
            amount1
        );
        assertTrue(liquidity > 0, "Liquidity should be greater than 0");
    }
}
