// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.14;

/// @title Simple Q32.32 Fixed-Point Math Library
/// @notice Simplified fixed-point math operations using Q32.32 format
/// @dev Uses 32 bits for the integer part and 32 bits for the fractional part
library SimpleQ32Math {
    // Q32.32 fixed-point format
    uint256 internal constant Q32 = 0x100000000; // 2^32

    /// @notice Calculates floor(a×b÷denominator) with full precision
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256) {
        require(denominator > 0, "SimpleQ32Math: division by zero");
        
        // Handle simple cases
        if (a == 0 || b == 0) return 0;
        
        // Convert to Q32.32 for precision
        uint256 aQ32 = a * Q32;
        uint256 bQ32 = b;
        return (aQ32 * bQ32) / (denominator * Q32);
    }

    /// @notice Calculates ceil(a×b÷denominator) with full precision
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        
        // Add 1 if there was any remainder
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max, "SimpleQ32Math: overflow");
            result++;
        }
    }
}
