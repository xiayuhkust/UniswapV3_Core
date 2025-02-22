// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;
pragma abicoder v2;

import "forge-std/Test.sol";
import "../contracts/UniswapV3Pool.sol";
import "../contracts/interfaces/IERC20.sol";

contract SwapTest is Test {
    UniswapV3Pool pool;
    address token0;
    address token1;
    address owner;

    function setUp() public {
        // Deploy test tokens
        token0 = 0x3F26F01Fa9A5506c9109B5Ad15343363909fc0b9; // TT1
        token1 = 0x8FDCE0D41f0A99B5f9FbcFAfd481ffcA61d01122; // TT2
        owner = address(this);

        // Deploy pool
        pool = new UniswapV3Pool(
            token0,
            token1,
            3000, // 0.3% fee tier
            60    // tick spacing
        );
    }

    function testSwapZeroForOne() public {
        // Initialize pool with some liquidity
        int24 lowerTick = -60;
        int24 upperTick = 60;
        uint128 liquidity = 1000000;

        pool.mint(owner, lowerTick, upperTick, liquidity, "");

        // Perform swap
        bool zeroForOne = true;
        int256 amountSpecified = 1000;
        uint160 sqrtPriceLimitX96 = TickMath.MIN_SQRT_RATIO + 1;

        (int256 amount0, int256 amount1) = pool.swap(
            owner,
            zeroForOne,
            amountSpecified,
            sqrtPriceLimitX96,
            ""
        );

        assertTrue(amount0 > 0, "Amount0 should be positive");
        assertTrue(amount1 < 0, "Amount1 should be negative");
    }

    function testSwapOneForZero() public {
        // Initialize pool with some liquidity
        int24 lowerTick = -60;
        int24 upperTick = 60;
        uint128 liquidity = 1000000;

        pool.mint(owner, lowerTick, upperTick, liquidity, "");

        // Perform swap
        bool zeroForOne = false;
        int256 amountSpecified = 1000;
        uint160 sqrtPriceLimitX96 = TickMath.MAX_SQRT_RATIO - 1;

        (int256 amount0, int256 amount1) = pool.swap(
            owner,
            zeroForOne,
            amountSpecified,
            sqrtPriceLimitX96,
            ""
        );

        assertTrue(amount0 < 0, "Amount0 should be negative");
        assertTrue(amount1 > 0, "Amount1 should be positive");
    }

    function test_RevertWhen_PriceLimitReached() public {
        // Initialize pool with some liquidity
        int24 lowerTick = -60;
        int24 upperTick = 60;
        uint128 liquidity = 1000000;

        pool.mint(owner, lowerTick, upperTick, liquidity, "");

        // Try to swap with invalid price limit
        bool zeroForOne = true;
        int256 amountSpecified = 1000;
        uint160 sqrtPriceLimitX96 = TickMath.MIN_SQRT_RATIO;

        vm.expectRevert("SPL");
        pool.swap(
            owner,
            zeroForOne,
            amountSpecified,
            sqrtPriceLimitX96,
            ""
        );
    }
}
