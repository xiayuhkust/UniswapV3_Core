// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "./UniswapV3Pool.Utils.t.sol";
import "./TestUniswapV3Pool.sol";
import "./MockToken.sol";

contract UniswapV3PoolSwapsTest is Test, UniswapV3PoolUtils {
    TestUniswapV3Pool pool;
    MockToken token0;
    MockToken token1;
    bool transferInMintCallback = true;
    bool transferInSwapCallback = true;

    function setUp() public {
        token0 = new MockToken("Token0", "TK0", 18);
        token1 = new MockToken("Token1", "TK1", 18);

        pool = new TestUniswapV3Pool(
            address(token0),
            address(token1),
            uint24(3000), // 0.3%
            int24(60)
        );

        token0.mint(address(this), 10 ether);
        token1.mint(address(this), 10 ether);
    }

    function testSwapBuyToken0() public {
        LiquidityRange[] memory liquidity = new LiquidityRange[](1);
        liquidity[0] = liquidityRange(4560, 5520, 1 ether, 5000, 5000);
        TestUniswapV3Pool.MintParams memory params = TestUniswapV3Pool.MintParams({
            recipient: address(this),
            lowerTick: liquidity[0].lowerTick,
            upperTick: liquidity[0].upperTick,
            amount: liquidity[0].amount
        });

        pool.initialize(sqrtP(5000));
        token0.transfer(address(pool), liquidity[0].amount0);
        token1.transfer(address(pool), liquidity[0].amount1);
        pool.mint(
            params.recipient,
            params.lowerTick,
            params.upperTick,
            params.amount,
            ""
        );

        uint256 swapAmount = 42 ether;
        token1.mint(address(this), swapAmount);
        token1.transfer(address(pool), swapAmount);

        bool zeroForOne = false;
        int256 amountSpecified = int256(swapAmount);
        uint160 sqrtPriceLimitX96 = TickMath.MIN_SQRT_RATIO + 1;

        (int256 amount0Delta, int256 amount1Delta) = pool.swap(
            address(this),
            zeroForOne,
            amountSpecified,
            sqrtPriceLimitX96,
            ""
        );

        assertEq(amount0Delta, -0.008396714242162444 ether, "invalid token0 delta");
        assertEq(amount1Delta, 42 ether, "invalid token1 delta");

        assertEq(
            token0.balanceOf(address(this)),
            uint256(9 ether + uint256(-amount0Delta)),
            "invalid token0 balance"
        );
        assertEq(
            token1.balanceOf(address(this)),
            uint256(10 ether - uint256(amount1Delta)),
            "invalid token1 balance"
        );
    }

    function testSwapBuyToken1() public {
        LiquidityRange[] memory liquidity = new LiquidityRange[](1);
        liquidity[0] = liquidityRange(4560, 5520, 1 ether, 5000, 5000);
        TestUniswapV3Pool.MintParams memory params = TestUniswapV3Pool.MintParams({
            recipient: address(this),
            lowerTick: liquidity[0].lowerTick,
            upperTick: liquidity[0].upperTick,
            amount: liquidity[0].amount
        });

        pool.initialize(sqrtP(5000));
        token0.transfer(address(pool), liquidity[0].amount0);
        token1.transfer(address(pool), liquidity[0].amount1);
        pool.mint(
            params.recipient,
            params.lowerTick,
            params.upperTick,
            params.amount,
            ""
        );

        uint256 swapAmount = 0.01337 ether;
        token0.mint(address(this), swapAmount);
        token0.transfer(address(pool), swapAmount);

        (int256 amount0Delta, int256 amount1Delta) = pool.swap(
            address(this),
            true,
            int256(swapAmount),
            TickMath.MAX_SQRT_RATIO - 1,
            ""
        );

        assertEq(amount0Delta, 0.01337 ether, "invalid token0 delta");
        assertEq(amount1Delta, -66.803921568627443840 ether, "invalid token1 delta");

        assertEq(
            token0.balanceOf(address(this)),
            uint256(9 ether - uint256(amount0Delta)),
            "invalid token0 balance"
        );
        assertEq(
            token1.balanceOf(address(this)),
            uint256(10 ether + uint256(-amount1Delta)),
            "invalid token1 balance"
        );
    }

    function testSwapBuyToken1MultiPool() public {
        LiquidityRange[] memory liquidity = new LiquidityRange[](2);
        liquidity[0] = liquidityRange(4560, 5520, 1 ether, 5000, 5000);
        liquidity[1] = liquidityRange(5520, 6240, 1 ether, 5000, 5000);

        TestUniswapV3Pool.MintParams memory params;
        pool.initialize(sqrtP(5000));

        for (uint256 i = 0; i < liquidity.length; i++) {
            params = TestUniswapV3Pool.MintParams({
                recipient: address(this),
                lowerTick: liquidity[i].lowerTick,
                upperTick: liquidity[i].upperTick,
                amount: liquidity[i].amount
            });

            token0.transfer(address(pool), liquidity[i].amount0);
            token1.transfer(address(pool), liquidity[i].amount1);
            pool.mint(
            params.recipient,
            params.lowerTick,
            params.upperTick,
            params.amount,
            ""
        );
        }

        uint256 swapAmount = 0.01337 ether;
        token0.mint(address(this), swapAmount);
        token0.transfer(address(pool), swapAmount);

        (int256 amount0Delta, int256 amount1Delta) = pool.swap(
            address(this),
            true,
            int256(swapAmount),
            TickMath.MAX_SQRT_RATIO - 1,
            ""
        );

        assertEq(amount0Delta, 0.01337 ether, "invalid token0 delta");
        assertEq(amount1Delta, -66.803921568627443840 ether, "invalid token1 delta");

        assertEq(
            token0.balanceOf(address(this)),
            uint256(8 ether - uint256(amount0Delta)),
            "invalid token0 balance"
        );
        assertEq(
            token1.balanceOf(address(this)),
            uint256(10 ether + uint256(-amount1Delta)),
            "invalid token1 balance"
        );
    }

    function uniswapV3MintCallback(
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) public {
        if (transferInMintCallback) {
            token0.transfer(msg.sender, amount0);
            token1.transfer(msg.sender, amount1);
        }
    }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) public {
        if (transferInSwapCallback) {
            if (amount0Delta > 0) {
                token0.transfer(msg.sender, uint256(amount0Delta));
            }
            if (amount1Delta > 0) {
                token1.transfer(msg.sender, uint256(amount1Delta));
            }
        }
    }
}
