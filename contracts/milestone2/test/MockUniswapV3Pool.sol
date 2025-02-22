// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "../interfaces/IUniswapV3Pool.sol";

contract MockUniswapV3Pool is IUniswapV3Pool {
    address public override factory;
    address public override token0;
    address public override token1;
    uint24 public override fee;
    uint24 public override tickSpacing;

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

    function slot0() external pure override returns (
        uint160 sqrtPriceX96,
        int24 tick,
        uint16 observationIndex,
        uint16 observationCardinality,
        uint16 observationCardinalityNext
    ) {
        return (0, 0, 0, 0, 0);
    }

    function positions(bytes32) external pure override returns (
        uint128 liquidity,
        uint256 feeGrowthInside0LastX128,
        uint256 feeGrowthInside1LastX128,
        uint128 tokensOwed0,
        uint128 tokensOwed1
    ) {
        return (0, 0, 0, 0, 0);
    }

    function mint(
        address,
        int24,
        int24,
        uint128,
        bytes calldata
    ) external pure override returns (uint256 amount0, uint256 amount1) {
        return (0, 0);
    }

    function burn(
        int24,
        int24,
        uint128
    ) external pure override returns (uint256 amount0, uint256 amount1) {
        return (0, 0);
    }

    function collect(
        address,
        int24,
        int24,
        uint128,
        uint128
    ) external pure override returns (uint128 amount0, uint128 amount1) {
        return (0, 0);
    }

    function swap(
        address,
        bool,
        uint256,
        uint160,
        bytes calldata
    ) external pure override returns (int256, int256) {
        return (0, 0);
    }
}
