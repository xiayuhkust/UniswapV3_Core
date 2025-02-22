// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "./TestUniswapV3Pool.sol";
import "./MockToken.sol";
import "interfaces/IERC20.sol";
import "interfaces/IUniswapV3MintCallback.sol";
import "interfaces/IUniswapV3SwapCallback.sol";

contract SwapTest is Test, IUniswapV3MintCallback, IUniswapV3SwapCallback {
    UniswapV3Pool pool;
    address token0;
    address token1;
    address owner;

    function setUp() public {
        // Deploy mock tokens
        MockToken token0Mock = new MockToken("Token0", "TK0", 18);
        MockToken token1Mock = new MockToken("Token1", "TK1", 18);
        token0 = address(token0Mock);
        token1 = address(token1Mock);
        owner = address(this);

        // Mint tokens to this contract
        token0Mock.mint(address(this), type(uint256).max);
        token1Mock.mint(address(this), type(uint256).max);

        // Deploy pool
        pool = new TestUniswapV3Pool(
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
        int256 amountSpecified = -1000; // Negative means exact input
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
        uint128 liquidity = 1000000;

        pool.mint(owner, lowerTick, upperTick, liquidity, "");

        // Perform swap
        bool zeroForOne = false;
        int256 amountSpecified = -1000; // Negative means exact input
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
        int256 amountSpecified = -1000;
        uint160 sqrtPriceLimitX96 = TickMath.MIN_SQRT_RATIO;

        vm.expectRevert(bytes("SPL"));
        pool.swap(
            owner,
            zeroForOne,
            amountSpecified,
            sqrtPriceLimitX96,
            ""
        );
    }

    function uniswapV3MintCallback(
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external {
        MockToken(token0).transfer(msg.sender, amount0);
        MockToken(token1).transfer(msg.sender, amount1);
    }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external {
        if (amount0Delta > 0) {
            MockToken(token0).transfer(msg.sender, uint256(amount0Delta));
        }
        if (amount1Delta > 0) {
            MockToken(token1).transfer(msg.sender, uint256(amount1Delta));
        }
    }
}
