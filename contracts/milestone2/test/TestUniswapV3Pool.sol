// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "../contracts/UniswapV3Pool.sol";

contract TestUniswapV3Pool is UniswapV3Pool {
    struct MintParams {
        address recipient;
        int24 lowerTick;
        int24 upperTick;
        uint128 amount;
    }
    constructor(
        address _token0,
        address _token1,
        uint24 _fee,
        int24 _tickSpacing
    ) UniswapV3Pool(_token0, _token1, _fee, _tickSpacing) {}

    function factory() external view override returns (address) {
        return address(this);
    }

    function initialize(uint160 sqrtPriceX96) public override {
        require(slot0_.sqrtPriceX96 == 0, "AI");
        
        int24 tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        slot0_ = Slot0({
            sqrtPriceX96: sqrtPriceX96,
            tick: tick,
            observationIndex: 0,
            observationCardinality: 1,
            observationCardinalityNext: 1
        });
    }

    function slot0()
        external
        view
        override
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext
        )
    {
        return (
            slot0_.sqrtPriceX96,
            slot0_.tick,
            slot0_.observationIndex,
            slot0_.observationCardinality,
            slot0_.observationCardinalityNext
        );
    }

    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) public override returns (int256 amount0, int256 amount1) {
        return super.swap(recipient, zeroForOne, amountSpecified, sqrtPriceLimitX96, data);
    }
}
