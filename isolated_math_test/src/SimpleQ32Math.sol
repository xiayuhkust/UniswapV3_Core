// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.14;

library SimpleQ32Math {
    uint256 internal constant Q32 = 0x100000000;
    error DivisionByZero();
    error MultiplicationOverflow();

    function mulDiv(
        int256 amount,
        uint256 multiplier,
        uint256 denominator
    ) internal pure returns (int256) {
        if (denominator == 0) revert DivisionByZero();
        if (amount == 0 || multiplier == 0) return 0;
        
        // Handle negative numbers
        bool isNegative = amount < 0;
        uint256 absAmount = uint256(isNegative ? -amount : amount);
        
        // Perform multiplication first
        uint256 product = absAmount * multiplier;
        if (product / absAmount != multiplier) revert MultiplicationOverflow();
        
        // Perform division
        uint256 quotient = product / denominator;
        
        // Check for overflow when converting back to int256
        if (quotient > uint256(type(int256).max)) revert MultiplicationOverflow();
        
        // Convert to int256 and restore sign
        return isNegative ? -int256(quotient) : int256(quotient);
    }

    function mulDivRoundingUp(
        int256 amount,
        uint256 multiplier,
        uint256 denominator
    ) internal pure returns (int256) {
        int256 result = mulDiv(amount, multiplier, denominator);
        if (amount > 0 && mulmod(uint256(amount), multiplier, denominator) > 0) {
            if (result == type(int256).max) revert MultiplicationOverflow();
            result++;
        }
        return result;
    }
}
