// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

/// @title Math library for computing tick prices
/// @notice Implements price and tick calculations
contract TickMath {
    /// @dev The minimum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**-128
    int24 public constant MIN_TICK = -887272;
    /// @dev The maximum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**128
    int24 public constant MAX_TICK = -MIN_TICK;

    /// @notice Calculates sqrt(1.0001^tick)
    /// @dev Throws if |tick| > max tick
    /// @param tick The input tick for the calculation
    /// @return price The sqrt price
    function getSqrtRatioAtTick(int24 tick) public pure returns (uint160 price) {
        require(tick >= MIN_TICK && tick <= MAX_TICK, 'T');
        // TODO: Implement tick to sqrt price calculation
        return 0;
    }

    /// @notice Calculates the greatest tick value such that getRatioAtTick(tick) <= ratio
    /// @dev Throws in case price < MIN_PRICE is too low or price > MAX_PRICE is too high
    /// @param price The sqrt ratio for which to compute the tick
    /// @return tick The greatest tick for which the ratio is less than or equal to the input ratio
    function getTickAtSqrtRatio(uint160 price) public pure returns (int24 tick) {
        // TODO: Implement sqrt price to tick calculation
        return 0;
    }
}
