// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

/// @title Math library for computing sqrt price points
/// @notice Implements Uniswap V3 sqrt price calculations
library SqrtPriceMath {
    /// @notice Gets the next sqrt price given an input amount of token0
    /// @param sqrtPX96 The starting price, i.e., before accounting for the token0 input
    /// @param liquidity The amount of usable liquidity
    /// @param amountIn How much of token0 to add
    /// @param zeroForOne Whether token0 is being swapped for token1
    /// @return The price after adding the input amount of token0
    function getNextSqrtPriceFromInput(uint160 sqrtPX96, uint128 liquidity, uint256 amountIn, bool zeroForOne)
        internal
        pure
        returns (uint160)
    {
        require(sqrtPX96 > 0);
        require(liquidity > 0);

        // TODO: Implement sqrt price calculation
        return sqrtPX96;
    }

    /// @notice Gets the next sqrt price given an output amount of token1
    /// @param sqrtPX96 The starting price, i.e., before accounting for the token1 output
    /// @param liquidity The amount of usable liquidity
    /// @param amountOut How much of token1 to remove
    /// @param zeroForOne Whether token0 is being swapped for token1
    /// @return The price after removing the output amount of token1
    function getNextSqrtPriceFromOutput(uint160 sqrtPX96, uint128 liquidity, uint256 amountOut, bool zeroForOne)
        internal
        pure
        returns (uint160)
    {
        require(sqrtPX96 > 0);
        require(liquidity > 0);

        // TODO: Implement sqrt price calculation
        return sqrtPX96;
    }
}
