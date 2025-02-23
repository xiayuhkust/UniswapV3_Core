// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "./SimpleQ32Math.sol";
import "./Math.sol";
import "./TickMath.sol";

using SimpleQ32Math for uint256;

library SwapMath {
    function computeSwapStep(
        uint160 sqrtPriceCurrentX96,
        uint160 sqrtPriceTargetX96,
        uint128 liquidity,
        int256 amountRemaining,
        uint24 fee
    )
        internal
        pure
        returns (
            uint160 sqrtPriceNextX96,
            uint256 amountIn,
            uint256 amountOut,
            uint256 feeAmount
        )
    {
        bool exactInput = amountRemaining > 0;
        uint256 absAmount = uint256(amountRemaining > 0 ? amountRemaining : -amountRemaining);
        bool zeroForOne = sqrtPriceCurrentX96 >= sqrtPriceTargetX96;
        
        if (liquidity == 0 || absAmount == 0) {
            return (sqrtPriceTargetX96, 0, 0, 0);
        }

        // Calculate amount after fee
        uint256 amountRemainingLessFee;
        if (exactInput) {
            amountRemainingLessFee = SimpleQ32Math.mulDiv(
                absAmount,
                1e6 - fee,
                1e6
            );
        } else {
            amountRemainingLessFee = absAmount;
        }

        // Calculate next sqrt price
        sqrtPriceNextX96 = exactInput
            ? Math.getNextSqrtPriceFromInput(
                sqrtPriceCurrentX96,
                liquidity,
                amountRemainingLessFee,
                zeroForOne
            )
            : Math.getNextSqrtPriceFromOutput(
                sqrtPriceCurrentX96,
                liquidity,
                amountRemainingLessFee,
                zeroForOne
            );

        // Ensure price doesn't move beyond target
        if (zeroForOne && sqrtPriceNextX96 < sqrtPriceTargetX96) {
            sqrtPriceNextX96 = sqrtPriceTargetX96;
        } else if (!zeroForOne && sqrtPriceNextX96 > sqrtPriceTargetX96) {
            sqrtPriceNextX96 = sqrtPriceTargetX96;
        }

        // Calculate amounts
        if (zeroForOne) {
            amountIn = Math.calcAmount0Delta(
                sqrtPriceCurrentX96,
                sqrtPriceNextX96,
                liquidity,
                true
            );
            amountOut = Math.calcAmount1Delta(
                sqrtPriceCurrentX96,
                sqrtPriceNextX96,
                liquidity,
                false
            );
        } else {
            amountIn = Math.calcAmount1Delta(
                sqrtPriceCurrentX96,
                sqrtPriceNextX96,
                liquidity,
                true
            );
            amountOut = Math.calcAmount0Delta(
                sqrtPriceCurrentX96,
                sqrtPriceNextX96,
                liquidity,
                false
            );
        }

        // Calculate fee amount
        feeAmount = SimpleQ32Math.mulDiv(amountIn, fee, 1e6 - fee);

        // Ensure price doesn't move beyond target
        if (zeroForOne) {
            if (sqrtPriceNextX96 < sqrtPriceTargetX96) {
                sqrtPriceNextX96 = sqrtPriceTargetX96;
            }
        } else {
            if (sqrtPriceNextX96 > sqrtPriceTargetX96) {
                sqrtPriceNextX96 = sqrtPriceTargetX96;
            }
        }

        // Calculate final amounts
        if (zeroForOne) {
            amountIn = Math.calcAmount0Delta(
                sqrtPriceCurrentX96,
                sqrtPriceNextX96,
                liquidity,
                true
            );
            amountOut = Math.calcAmount1Delta(
                sqrtPriceCurrentX96,
                sqrtPriceNextX96,
                liquidity,
                false
            );
        } else {
            amountIn = Math.calcAmount1Delta(
                sqrtPriceCurrentX96,
                sqrtPriceNextX96,
                liquidity,
                true
            );
            amountOut = Math.calcAmount0Delta(
                sqrtPriceCurrentX96,
                sqrtPriceNextX96,
                liquidity,
                false
            );
        }

        // Calculate fee amount
        feeAmount = Math.mulDivRoundingUp(amountIn, fee, 1e6 - fee);

        // Handle exact output swaps
        if (!exactInput) {
            if (amountOut > absAmount) {
                amountOut = absAmount;
            }
            feeAmount = Math.mulDivRoundingUp(amountIn, fee, 1e6 - fee);
        } else {
            amountIn += feeAmount;
        }
    }
}
