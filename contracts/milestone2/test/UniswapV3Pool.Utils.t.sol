// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../contracts/libraries/TickMath.sol";
import "../contracts/libraries/LiquidityMath.sol";
import "../contracts/libraries/SwapMath.sol";
import "./TestUniswapV3Pool.sol";
import "./MockToken.sol";

function encodeExtra(
    address token0,
    address token1,
    address payer
) pure returns (bytes memory) {
    return abi.encode(token0, token1, payer);
}

function sqrtP(uint256 price) pure returns (uint160) {
    return TickMath.getSqrtRatioAtTick(tick(price));
}

function tick(uint256 price) pure returns (int24) {
    return int24(log2(price) * 100);
}

function log2(uint256 value) pure returns (int24) {
    require(value > 0, "Invalid price");
    uint256 val = value;
    uint256 result = 0;
    
    // Find the position of the most significant bit
    for (uint8 i = 128; i >= 1; i >>= 1) {
        if (val >= (1 << i)) {
            val >>= i;
            result += i;
        }
    }
    require(result <= uint256(uint24(type(int24).max)), "Price out of range");
    return int24(uint24(result));
}

struct LiquidityRange {
    int24 lowerTick;
    int24 upperTick;
    uint128 amount;
    uint256 amount0;
    uint256 amount1;
}

function liquidityRange(
    int24 lowerTick,
    int24 upperTick,
    uint128 amount,
    uint256 amount0,
    uint256 amount1
) pure returns (LiquidityRange memory) {
    return LiquidityRange({
        lowerTick: lowerTick,
        upperTick: upperTick,
        amount: amount,
        amount0: amount0,
        amount1: amount1
    });
}

function liquidityRanges(LiquidityRange memory range1, LiquidityRange memory range2)
    pure
    returns (LiquidityRange[] memory ranges)
{
    ranges = new LiquidityRange[](2);
    ranges[0] = range1;
    ranges[1] = range2;
}

function liquidityRanges(LiquidityRange memory range)
    pure
    returns (LiquidityRange[] memory ranges)
{
    ranges = new LiquidityRange[](1);
    ranges[0] = range;
}

contract UniswapV3PoolUtils is Test {
    // Test utilities

    // Test utilities
    struct ExpectedStateAfterSwap {
        uint160 sqrtPriceX96;
        int24 tick;
        uint128 liquidity;
        uint256[] tokenBalances;
        uint256 fee;
    }

    struct ExpectedPositionShort {
        address owner;
        int24[2] ticks;
        uint128 liquidity;
        uint256[2] feeGrowth;
        uint128[2] tokensOwed;
    }

    struct ExpectedTickShort {
        int24 tick;
        bool initialized;
        uint128 liquidityGross;
        int128 liquidityNet;
    }

    struct ExpectedObservationShort {
        uint32 index;
        uint32 timestamp;
        int56 tickCumulative;
        bool initialized;
    }

    function assertPosition(TestUniswapV3Pool pool, ExpectedPositionShort memory expected) internal {
        (
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        ) = pool.positions(
                keccak256(
                    abi.encodePacked(
                        expected.owner,
                        expected.ticks[0],
                        expected.ticks[1]
                    )
                )
            );

        assertEq(liquidity, expected.liquidity, "incorrect liquidity");
        assertEq(
            feeGrowthInside0LastX128,
            expected.feeGrowth[0],
            "incorrect feeGrowth0"
        );
        assertEq(
            feeGrowthInside1LastX128,
            expected.feeGrowth[1],
            "incorrect feeGrowth1"
        );
        assertEq(tokensOwed0, expected.tokensOwed[0], "incorrect tokensOwed0");
        assertEq(tokensOwed1, expected.tokensOwed[1], "incorrect tokensOwed1");
    }

    function assertTick(
        TestUniswapV3Pool pool,
        ExpectedTickShort memory expected
    ) internal {
        IUniswapV3Pool.TickInfo memory info = pool.ticks(expected.tick);

        assertEq(info.initialized, expected.initialized, "incorrect tick initialized");
        assertEq(
            info.liquidityGross,
            expected.liquidityGross,
            "incorrect tick liquidityGross"
        );
        assertEq(
            info.liquidityNet,
            expected.liquidityNet,
            "incorrect tick liquidityNet"
        );
    }

    function assertObservation(
        TestUniswapV3Pool pool,
        ExpectedObservationShort memory expected
    ) internal {
        (,,,uint16 observationCardinality,uint16 observationCardinalityNext) = pool.slot0();
        
        assertEq(
            expected.index,
            0,  // First observation
            "incorrect observation index"
        );
        assertEq(
            observationCardinality,
            1,
            "incorrect observation cardinality"
        );
        assertEq(
            observationCardinalityNext,
            1,
            "incorrect observation cardinality next"
        );
    }
}
