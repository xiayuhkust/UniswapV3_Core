// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

/// @title SwapState library for Uniswap V3
/// @notice Contains state data structures used in swap operations
library SwapState {
    /// @notice Represents the state of a swap operation
    /// @param amountSpecifiedRemaining How much of the swap amount remains to be swapped
    /// @param amountCalculated The amount that has been calculated for the swap output
    /// @param sqrtPriceX96 The current sqrt price of the pool
    /// @param tick The current tick of the pool
    struct State {
        uint256 amountSpecifiedRemaining;
        uint256 amountCalculated;
        uint160 sqrtPriceX96;
        int24 tick;
    }

    /// @notice Represents the state for a single step in a swap
    /// @param sqrtPriceStartX96 The sqrt price at the start of the step
    /// @param nextTick The next initialized tick in the swap direction
    /// @param sqrtPriceNextX96 The target sqrt price for this step
    /// @param amountIn The amount of tokens being swapped in for this step
    /// @param amountOut The amount of tokens being received for this step
    struct Step {
        uint160 sqrtPriceStartX96;
        int24 nextTick;
        uint160 sqrtPriceNextX96;
        uint256 amountIn;
        uint256 amountOut;
    }
}
