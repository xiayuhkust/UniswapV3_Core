// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

library LiquidityMath {
    /// @notice Add a signed liquidity delta to liquidity and revert if it overflows or underflows
    /// @param x The liquidity before change
    /// @param y The delta by which liquidity should be changed
    /// @return z The liquidity delta
    function addLiquidity(uint128 x, int128 y)
        internal
        pure
        returns (uint128 z)
    {
        if (y < 0) {
            require((z = x - uint128(-y)) < x, "LS");
        } else {
            require((z = x + uint128(y)) >= x, "LA");
        }
    }

    /// @notice Calculates amount of liquidity for given amount of token0
    /// @param sqrtPriceAX96 The price at the lower tick boundary
    /// @param sqrtPriceBX96 The price at the upper tick boundary
    /// @param amount0 The amount of token0
    /// @return liquidity The amount of returned liquidity
    function getLiquidityForAmount0(
        uint160 sqrtPriceAX96,
        uint160 sqrtPriceBX96,
        uint256 amount0
    ) internal pure returns (uint128 liquidity) {
        if (sqrtPriceAX96 > sqrtPriceBX96)
            (sqrtPriceAX96, sqrtPriceBX96) = (sqrtPriceBX96, sqrtPriceAX96);

        uint256 intermediate = mulDiv(
            sqrtPriceAX96,
            sqrtPriceBX96,
            0x1000000000000000000000000
        );
        return uint128(mulDiv(amount0, intermediate, sqrtPriceBX96 - sqrtPriceAX96));
    }

    /// @notice Calculates amount of liquidity for given amount of token1
    /// @param sqrtPriceAX96 The price at the lower tick boundary
    /// @param sqrtPriceBX96 The price at the upper tick boundary
    /// @param amount1 The amount of token1
    /// @return liquidity The amount of returned liquidity
    function getLiquidityForAmount1(
        uint160 sqrtPriceAX96,
        uint160 sqrtPriceBX96,
        uint256 amount1
    ) internal pure returns (uint128 liquidity) {
        if (sqrtPriceAX96 > sqrtPriceBX96)
            (sqrtPriceAX96, sqrtPriceBX96) = (sqrtPriceBX96, sqrtPriceAX96);

        return uint128(mulDiv(amount1, 0x1000000000000000000000000, sqrtPriceBX96 - sqrtPriceAX96));
    }

    /// @notice Calculates the maximum amount of liquidity received for a given amount of token0, token1
    /// @param sqrtPriceX96 The current price
    /// @param sqrtPriceAX96 The price at the lower tick boundary
    /// @param sqrtPriceBX96 The price at the upper tick boundary
    /// @param amount0 The amount of token0 being sent in
    /// @param amount1 The amount of token1 being sent in
    /// @return liquidity The maximum amount of liquidity received
    function getLiquidityForAmounts(
        uint160 sqrtPriceX96,
        uint160 sqrtPriceAX96,
        uint160 sqrtPriceBX96,
        uint256 amount0,
        uint256 amount1
    ) internal pure returns (uint128 liquidity) {
        if (sqrtPriceAX96 > sqrtPriceBX96)
            (sqrtPriceAX96, sqrtPriceBX96) = (sqrtPriceBX96, sqrtPriceAX96);

        if (sqrtPriceX96 <= sqrtPriceAX96) {
            liquidity = getLiquidityForAmount0(sqrtPriceAX96, sqrtPriceBX96, amount0);
        } else if (sqrtPriceX96 < sqrtPriceBX96) {
            uint128 liquidity0 = getLiquidityForAmount0(sqrtPriceX96, sqrtPriceBX96, amount0);
            uint128 liquidity1 = getLiquidityForAmount1(sqrtPriceAX96, sqrtPriceX96, amount1);

            liquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1;
        } else {
            liquidity = getLiquidityForAmount1(sqrtPriceAX96, sqrtPriceBX96, amount1);
        }
    }

    /// @notice Computes the result of (x * y) / z
    /// @dev Taken from Solidity-Lib
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 z
    ) internal pure returns (uint256) {
        require(z > 0);

        return (x * y) / z;
    }
}
