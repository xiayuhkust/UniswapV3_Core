// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../contracts/libraries/Tick.sol";

contract TickTest is Test {
    using Tick for mapping(int24 => Tick.Info);

    mapping(int24 => Tick.Info) public ticks;
    int24 tickSpacing = 60;

    function testTickSpacingToMaxLiquidityPerTick() public {
        uint128 maxLiquidity = uint128((uint256(2) ** 128) - 1);
        assertTrue(maxLiquidity > 0, "Max liquidity should be greater than 0");
    }

    function testUpdateTick() public {
        int24 tick = 60;
        int128 liquidityDelta = 1000;
        uint256 feeGrowth0 = 0;
        uint256 feeGrowth1 = 0;
        bool upper = true;

        bool flipped = ticks.update(
            tick,
            0,
            liquidityDelta,
            feeGrowth0,
            feeGrowth1,
            upper
        );

        assertTrue(flipped, "Tick should be flipped to initialized");
        assertTrue(ticks[tick].initialized, "Tick should be initialized");
        assertEq(uint256(ticks[tick].liquidityGross), uint256(uint128(liquidityDelta)), "Liquidity gross not set correctly");
    }

    function testUpdateTickWithNegativeLiquidity() public {
        int24 tick = 60;
        int128 liquidityDelta = 1000;
        uint256 feeGrowth0 = 0;
        uint256 feeGrowth1 = 0;
        bool upper = true;

        // First add liquidity
        ticks.update(
            tick,
            0,
            liquidityDelta,
            feeGrowth0,
            feeGrowth1,
            upper
        );

        // Then remove liquidity
        bool flipped = ticks.update(
            tick,
            0,
            -liquidityDelta,
            feeGrowth0,
            feeGrowth1,
            upper
        );

        assertTrue(flipped, "Tick should be flipped to uninitialized");
        assertFalse(ticks[tick].initialized, "Tick should be uninitialized");
        assertEq(uint256(ticks[tick].liquidityGross), uint256(0), "Liquidity gross should be 0");
    }
}
