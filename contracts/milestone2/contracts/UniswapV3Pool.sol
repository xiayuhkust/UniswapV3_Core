// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;

import "./interfaces/IERC20.sol";
import "./interfaces/IUniswapV3Pool.sol";
import "./interfaces/IUniswapV3MintCallback.sol";
import "./interfaces/IUniswapV3SwapCallback.sol";

import "./libraries/LowGasSafeMath.sol";
import "./libraries/SafeCast.sol";
import "./libraries/Tick.sol";
import "./libraries/TickMath.sol";
import "./libraries/Position.sol";
import "./libraries/Oracle.sol";

contract UniswapV3Pool is IUniswapV3Pool {
    using LowGasSafeMath for uint256;
    using LowGasSafeMath for int256;
    using SafeCast for uint256;
    using SafeCast for int256;
    using Tick for mapping(int24 => Tick.Info);
    using Position for mapping(bytes32 => Position.Info);
    using Position for Position.Info;

    // Pool tokens
    address public immutable token0;
    address public immutable token1;
    uint24 public immutable fee;

    // Tick spacing
    int24 public immutable tickSpacing;

    // Pool state
    uint160 public slot0;
    uint128 public liquidity;

    // Positions
    mapping(bytes32 => Position.Info) public positions;
    mapping(int24 => Tick.Info) public ticks;

    constructor(
        address _token0,
        address _token1,
        uint24 _fee,
        int24 _tickSpacing
    ) {
        token0 = _token0;
        token1 = _token1;
        fee = _fee;
        tickSpacing = _tickSpacing;
    }

    function mint(
        address recipient,
        int24 lowerTick,
        int24 upperTick,
        uint128 amount,
        bytes calldata data
    ) external override returns (uint256 amount0, uint256 amount1) {
        require(lowerTick < upperTick, "TLU");
        require(lowerTick >= TickMath.MIN_TICK, "TLM");
        require(upperTick <= TickMath.MAX_TICK, "TUM");

        // Get position
        Position.Info storage position = positions.get(
            recipient,
            lowerTick,
            upperTick
        );

        // Update position
        position.update(amount.toInt128(), 0, 0);

        // TODO: Calculate token amounts and collect fees
        // This will be implemented in subsequent steps

        emit Mint(
            msg.sender,
            recipient,
            lowerTick,
            upperTick,
            amount,
            amount0,
            amount1
        );
    }
}
