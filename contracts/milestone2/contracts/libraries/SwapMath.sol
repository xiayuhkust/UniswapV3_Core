// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "./SimpleQ32Math.sol";
import "./Math.sol";

library SwapMath {
    function computeSwapStep(
        uint160 sqrtPriceCurrentX96,
        uint160 sqrtPriceTargetX96,
        uint128 liquidity,
        int256 amountRemaining,
        uint24 fee
    ) internal pure returns (
        uint160 sqrtPriceNextX96,
        uint256 amountIn,
        uint256 amountOut,
        uint256 feeAmount
    ) {
        bool zeroForOne = sqrtPriceCurrentX96 >= sqrtPriceTargetX96;
        int256 amountRemainingLessFee = SimpleQ32Math.mulDiv(
            amountRemaining,
            1e6 - fee,
            1e6
        );

        // Rest of the function remains unchanged...
        // This is just the part we're modifying to use SimpleQ32Math
    }
}
