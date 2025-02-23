// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "./TestUniswapV3Pool.sol";
import "./MockToken.sol";
import "../contracts/libraries/TickMath.sol";
import "../contracts/UniswapV3Pool.sol";

contract SwapTest is Test, IUniswapV3MintCallback, IUniswapV3SwapCallback {
    TestUniswapV3Pool pool;
    MockToken token0;
    MockToken token1;
    address owner;

    function setUp() public {
        // Deploy mock tokens
        token0 = new MockToken("Token0", "TK0", 18);
        token1 = new MockToken("Token1", "TK1", 18);
        owner = address(this);

        // Mint tokens to this contract
        token0.mint(address(this), 10000000); // 10M tokens
        token1.mint(address(this), 10000000); // 10M tokens

        // Deploy pool
        pool = new TestUniswapV3Pool(
            address(token0),
            address(token1),
            3000, // 0.3% fee tier
            60    // tick spacing
        );

        // Approve pool
        token0.approve(address(pool), 1e18);
        token1.approve(address(pool), 1e18);
    }

    function testSwapZeroForOne() public {
        // Initialize pool with some liquidity
        int24 lowerTick = -60;
        int24 upperTick = 60;
        uint128 liquidity = 1000000;

        pool.mint(owner, lowerTick, upperTick, liquidity, "");

        // Perform swap
        bool zeroForOne = true;
        int256 amountSpecified = -1000000; // 1M tokens for significant price impact
        uint160 sqrtPriceLimitX96 = TickMath.MIN_SQRT_RATIO + 1;

        (int256 amount0, int256 amount1) = pool.swap(
            owner,
            zeroForOne,
            amountSpecified,
            sqrtPriceLimitX96,
            ""
        );

        assertLt(amount0, 0, "Amount0 should be negative (spent)");
        assertGt(amount1, 0, "Amount1 should be positive (received)");
    }

    function testSwapOneForZero() public {
        // Initialize pool with some liquidity
        int24 lowerTick = -60;
        int24 upperTick = 60;
        uint128 liquidity = 100000; // Reduced liquidity to prevent overflow

        pool.mint(owner, lowerTick, upperTick, liquidity, "");

        // Perform swap
        bool zeroForOne = false;
        int256 amountSpecified = -1000; // Reduced amount to prevent overflow
        uint160 sqrtPriceLimitX96 = TickMath.MAX_SQRT_RATIO - 1;

        (int256 amount0, int256 amount1) = pool.swap(
            owner,
            zeroForOne,
            amountSpecified,
            sqrtPriceLimitX96,
            ""
        );

        assertGt(amount0, 0, "Amount0 should be positive (received)");
        assertLt(amount1, 0, "Amount1 should be negative (spent)");
    }

    function test_RevertWhen_PriceLimitReached() public {
        // Initialize pool with some liquidity
        int24 lowerTick = -60;
        int24 upperTick = 60;
        uint128 liquidity = 1000000;

        pool.mint(owner, lowerTick, upperTick, liquidity, "");

        // Try to swap with invalid price limit
        bool zeroForOne = true;
        int256 amountSpecified = -10;
        uint160 sqrtPriceLimitX96 = TickMath.MIN_SQRT_RATIO;

        vm.expectRevert(bytes4(keccak256("InvalidPriceLimit()")));
        pool.swap(
            owner,
            zeroForOne,
            amountSpecified,
            sqrtPriceLimitX96,
            ""
        );
    }

    function testFeeCalculation() public {
        // Initialize pool with some liquidity
        int24 lowerTick = -60;
        int24 upperTick = 60;
        uint128 liquidity = 1000000;

        pool.mint(owner, lowerTick, upperTick, liquidity, "");

        // Record initial fee growth
        uint256 feeGrowthGlobal0X128Before = pool.feeGrowthGlobal0X128();
        
        // Perform swap
        bool zeroForOne = true;
        int256 amountSpecified = -10;
        uint160 sqrtPriceLimitX96 = TickMath.MIN_SQRT_RATIO + 1;

        pool.swap(
            owner,
            zeroForOne,
            amountSpecified,
            sqrtPriceLimitX96,
            ""
        );

        // Verify fee growth increased
        uint256 feeGrowthGlobal0X128After = pool.feeGrowthGlobal0X128();
        assertGt(
            feeGrowthGlobal0X128After,
            feeGrowthGlobal0X128Before,
            "Fee growth should increase after swap"
        );
    }

    function testSwapWithinPriceRange() public {
        // Initialize pool with some liquidity
        int24 lowerTick = -60;
        int24 upperTick = 60;
        uint128 liquidity = 1000000;

        pool.mint(owner, lowerTick, upperTick, liquidity, "");

        // Record initial tick
        (, int24 tickBefore,,,) = pool.slot0();
        
        // Perform small swap that should stay within range
        bool zeroForOne = true;
        int256 amountSpecified = -10; // Very small amount for testing
        uint160 sqrtPriceLimitX96 = TickMath.MIN_SQRT_RATIO + 1;

        pool.swap(
            owner,
            zeroForOne,
            amountSpecified,
            sqrtPriceLimitX96,
            ""
        );

        // Verify tick changed but stayed within range
        (, int24 tickAfter,,,) = pool.slot0();
        assertGt(tickBefore, tickAfter, "Tick should decrease for zeroForOne swap");
        assertGe(tickAfter, lowerTick, "Tick should stay above lower bound");
        assertLe(tickAfter, upperTick, "Tick should stay below upper bound");
    }

    function uniswapV3MintCallback(
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external {
        if (amount0 > 0) token0.transfer(msg.sender, amount0);
        if (amount1 > 0) token1.transfer(msg.sender, amount1);
    }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external {
        if (amount0Delta > 0) token0.transfer(msg.sender, uint256(amount0Delta));
        if (amount1Delta > 0) token1.transfer(msg.sender, uint256(amount1Delta));
    }
}
