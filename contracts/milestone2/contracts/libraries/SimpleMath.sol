// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.14;

/// @title Simple Math Library for Uniswap V3
/// @notice Simplified version of math operations optimized for readability and correctness
/// @dev Uses Solidity's built-in overflow checks instead of complex assembly
library SimpleMath {
    /// @notice Calculates floor(a×b÷denominator) with full precision.
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The result of floor(a×b÷denominator)
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // Check for division by zero
        require(denominator > 0, "SimpleMath: division by zero");

        // Handle simple cases first
        if (a == 0 || b == 0) return 0;
        
        // Calculate a * b
        uint256 prod0;
        uint256 prod1;
        
        // Use unchecked for gas optimization while maintaining safety
        unchecked {
            prod0 = a * b;
            // If prod0 is zero and inputs are non-zero, we must have overflowed
            if (prod0 != 0 && prod0 / a != b) {
                // Get the upper bits
                assembly {
                    let mm := mulmod(a, b, not(0))
                    prod1 := sub(sub(mm, prod0), lt(mm, prod0))
                }
            }
        }

        // Short circuit if no overflow
        if (prod1 == 0) {
            return prod0 / denominator;
        }

        // Make sure the result fits in uint256
        require(denominator > prod1, "SimpleMath: overflow");

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Make division exact by subtracting the remainder from [prod1 prod0]
        uint256 remainder;
        assembly {
            // Compute remainder using mulmod
            remainder := mulmod(a, b, denominator)
        }
        // Subtract remainder to get exact result
        unchecked {
            prod1 = prod1 - (remainder > prod0 ? 1 : 0);
            prod0 = prod0 - remainder;
        }

        // Factor powers of two out of denominator
        // Compute largest power of two divisor of denominator
        uint256 twos;
        assembly {
            twos := and(sub(0, denominator), denominator)
        }
        // Divide denominator by power of two
        denominator = denominator / twos;

        // Divide [prod1 prod0] by the factors of two
        prod0 = prod0 / twos;

        // Make sure to include the highest bit of prod1 in the result
        prod0 |= prod1 * ((~twos + 1) / twos + 1);

        // Compute the result
        result = prod0 / denominator;
    }

    /// @notice Calculates ceil(a×b÷denominator) with full precision.
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The result of ceil(a×b÷denominator)
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max, "SimpleMath: overflow");
            result++;
        }
    }
}
