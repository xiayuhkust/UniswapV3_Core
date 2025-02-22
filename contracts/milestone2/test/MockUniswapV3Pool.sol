// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.14;

import "../interfaces/IUniswapV3Pool.sol";

abstract contract MockUniswapV3Pool is IUniswapV3Pool {
    address public factory;
    address public token0;
    address public token1;
    uint24 public fee;
    uint24 public tickSpacing;

    constructor(
        address _token0,
        address _token1,
        uint24 _fee,
        uint24 _tickSpacing
    ) {
        token0 = _token0;
        token1 = _token1;
        fee = _fee;
        tickSpacing = _tickSpacing;
        factory = msg.sender;
    }

    function slot0() external pure virtual returns (
        uint160 sqrtPriceX96,
        int24 tick,
        uint16 observationIndex,
        uint16 observationCardinality,
        uint16 observationCardinalityNext
    ) {
        return (0, 0, 0, 0, 0);
    }

    function positions(bytes32) external pure virtual returns (
        uint128 liquidity,
        uint256 feeGrowthInside0LastX128,
        uint256 feeGrowthInside1LastX128,
        uint128 tokensOwed0,
        uint128 tokensOwed1
    ) {
        return (0, 0, 0, 0, 0);
    }

    function mint(
        address recipient,
        int24 lowerTick,
        int24 upperTick,
        uint128 amount,
        bytes calldata data
    ) external pure virtual returns (uint256 amount0, uint256 amount1) {
        return (0, 0);
    }

    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external pure virtual returns (int256 amount0, int256 amount1) {
        return (0, 0);
    }
}
