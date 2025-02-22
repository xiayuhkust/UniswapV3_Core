// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

/// @title SimpleQ32Math
/// @notice A simplified math library for Uniswap V3 on Tura blockchain
/// @dev Provides basic multiplication and division operations with overflow checks
library SimpleQ32Math {
    /// @notice Custom error for division by zero
    error DivisionByZero();
    /// @notice Custom error for multiplication overflow
    error MultiplicationOverflow();

    /// @notice Calculates floor(a×b÷denominator) with full precision
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The floor(a×b÷denominator)
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // Check for division by zero
        if (denominator == 0) revert DivisionByZero();

        // Check for multiplication overflow using the standard trick
        // If a * b = prod, then a = prod / b if there was no overflow
        uint256 prod0;
        unchecked {
            prod0 = a * b;
            if (a != 0 && prod0 / a != b) revert MultiplicationOverflow();
        }

        // Perform division
        result = prod0 / denominator;
    }

    /// @notice Calculates ceil(a×b÷denominator) with full precision
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The ceil(a×b÷denominator)
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        unchecked {
            if (mulmod(a, b, denominator) > 0) {
                if (result >= type(uint256).max) revert MultiplicationOverflow();
                result++;
            }
        }
    }

    /// @notice Calculates ceil(numerator÷denominator)
    /// @param numerator The numerator
    /// @param denominator The divisor
    /// @return result The ceil(numerator÷denominator)
    function divRoundingUp(uint256 numerator, uint256 denominator)
        internal
        pure
        returns (uint256 result)
    {
        if (denominator == 0) revert DivisionByZero();
        result = (numerator + denominator - 1) / denominator;
    }
}
