// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.14;

library SimpleQ32Math {
    uint256 internal constant Q32 = 0x100000000;

    function mulDiv(
        int256 amount,
        uint256 multiplier,
        uint256 denominator
    ) internal pure returns (int256) {
        require(denominator > 0, "SimpleQ32Math: division by zero");
        if (amount == 0 || multiplier == 0) return 0;
        
        // Handle negative numbers
        bool isNegative = amount < 0;
        
        // Safe conversion to absolute value
        uint256 absAmount;
        if (amount == type(int256).min) {
            if (multiplier > 1) {
                revert("SimpleQ32Math: multiplication overflow");
            }
            // For int256.min, we need special handling since abs(min) > max
            absAmount = uint256(type(int256).max) + 1;
        } else {
            absAmount = uint256(isNegative ? -amount : amount);
        }
        
        // Check for multiplication overflow
        uint256 product;
        unchecked {
            product = absAmount * multiplier;
            if (multiplier != 0) {
                if (product / multiplier != absAmount) {
                    revert("SimpleQ32Math: multiplication overflow");
                }
            }
        }
        
        // Perform division and check for overflow
        uint256 quotient = product / denominator;
        
        // For negative numbers, we need special handling for int256.min
        if (isNegative) {
            if (amount == type(int256).min && multiplier == 1 && denominator == 1) {
                return type(int256).min;
            }
            if (quotient > uint256(type(int256).max)) {
                revert("SimpleQ32Math: result overflow");
            }
            return -int256(quotient);
        } else {
            if (quotient > uint256(type(int256).max)) {
                revert("SimpleQ32Math: result overflow");
            }
            return int256(quotient);
        }
    }

    function mulDivRoundingUp(
        int256 amount,
        uint256 multiplier,
        uint256 denominator
    ) internal pure returns (int256) {
        // Handle zero cases first
        if (amount == 0 || multiplier == 0) return 0;
        require(denominator > 0, "SimpleQ32Math: division by zero");
        
        // Handle negative numbers
        bool isNegative = amount < 0;
        uint256 absAmount;
        
        // Safe conversion to absolute value
        if (amount == type(int256).min) {
            if (multiplier > 1) {
                revert("SimpleQ32Math: multiplication overflow");
            }
            absAmount = uint256(type(int256).max) + 1;
        } else {
            absAmount = uint256(isNegative ? -amount : amount);
        }
        
        // Calculate result and check for overflow
        uint256 product = absAmount * multiplier;
        if (multiplier != 0 && product / multiplier != absAmount) {
            revert("SimpleQ32Math: multiplication overflow");
        }
        
        // Calculate quotient and remainder
        uint256 quotient = product / denominator;
        uint256 remainder = product % denominator;
        
        // For both positive and negative numbers, round up if there's any remainder
        if (remainder > 0) {
            require(quotient < type(uint256).max, "SimpleQ32Math: result overflow");
            quotient++;
        }
        
        // Convert back to signed and handle overflow checks
        if (isNegative) {
            if (quotient > uint256(type(int256).max) + 1) {
                revert("SimpleQ32Math: result overflow");
            }
            return -int256(quotient);
        } else {
            if (quotient > uint256(type(int256).max)) {
                revert("SimpleQ32Math: result overflow");
            }
            return int256(quotient);
        }
    }
}
