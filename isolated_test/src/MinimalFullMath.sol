// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

library MinimalFullMath {
    error DivByZero();
    error MulDivOverflow();

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        if (denominator == 0) {
            revert DivByZero();
        }

        // Handle phantom overflow
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2**256
            require(denominator > prod1, "overflow");

            // 512 by 256 division
            assembly {
                // 512-bit dividend
                let remainder := mulmod(x, y, denominator)

                // Factor powers of two out of denominator and compute largest power of two divisor
                let twos := and(sub(0, denominator), denominator)
                // Divide denominator by twos
                denominator := div(denominator, twos)
                // Divide [prod1 prod0] by twos
                prod0 := div(prod0, twos)
                // Flip twos such that it is 2**256 / twos
                twos := add(div(sub(0, twos), twos), 1)
                // Shift in bits from prod1 into prod0
                prod0 := or(prod0, mul(prod1, twos))

                // Invert denominator mod 2**256
                let inv := mul(3, denominator)
                inv := mul(inv, sub(2, mul(denominator, inv)))
                inv := mul(inv, sub(2, mul(denominator, inv)))
                inv := mul(inv, sub(2, mul(denominator, inv)))
                inv := mul(inv, sub(2, mul(denominator, inv)))
                inv := mul(inv, sub(2, mul(denominator, inv)))
                inv := mul(inv, sub(2, mul(denominator, inv)))
                inv := mul(inv, sub(2, mul(denominator, inv)))
                inv := mul(inv, sub(2, mul(denominator, inv)))

                // Because the division is now exact we can divide by multiplying
                result := mul(prod0, inv)
            }
        }
    }
}
