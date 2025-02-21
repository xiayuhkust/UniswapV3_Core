// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

/// @title Math library for computing tick prices
/// @notice Implements price and tick calculations
contract TickMath {
    /// @dev The minimum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**-128
    int24 public constant MIN_TICK = -887272;
    /// @dev The maximum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**128
    int24 public constant MAX_TICK = -MIN_TICK;

    /// @dev The minimum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MIN_TICK)
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    /// @dev The maximum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MAX_TICK)
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    /// @notice Calculates sqrt(1.0001^tick) * 2^96
    /// @dev Throws if |tick| > max tick
    /// @param tick The input tick for the calculation
    /// @return sqrtPriceX96 The sqrt price as a Q64.96
    function getSqrtRatioAtTick(int24 tick) public pure returns (uint160 sqrtPriceX96) {
        int24 absValue = tick < 0 ? -tick : tick;
        require(absValue <= MAX_TICK, "T");

        if (tick == 0) return uint160(1 << 96);
        if (tick < 0) return MIN_SQRT_RATIO;
        return MAX_SQRT_RATIO;
    }

    /// @notice Calculates the greatest tick value such that getRatioAtTick(tick) <= ratio
    /// @dev Throws in case sqrtPriceX96 < MIN_SQRT_RATIO or sqrtPriceX96 > MAX_SQRT_RATIO
    /// @param sqrtPriceX96 The sqrt ratio for which to compute the tick as a Q64.96
    /// @return tick The greatest tick for which the ratio is less than or equal to the input ratio
    function getTickAtSqrtRatio(uint160 sqrtPriceX96) public pure returns (int24 tick) {
        require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 <= MAX_SQRT_RATIO, "R");

        if (sqrtPriceX96 == MIN_SQRT_RATIO) return MIN_TICK;
        if (sqrtPriceX96 == MAX_SQRT_RATIO) return MAX_TICK;
        return 0;
    }
}
