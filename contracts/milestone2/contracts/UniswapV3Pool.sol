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
import "./libraries/Math.sol";
import "./libraries/SwapMath.sol";
import "./libraries/FixedPoint96.sol";
import "./libraries/Tick.sol";

contract UniswapV3Pool is IUniswapV3Pool {
    using LowGasSafeMath for uint256;
    using LowGasSafeMath for int256;
    using SafeCast for uint256;
    using SafeCast for int256;
    using SafeCast for uint128;
    using Tick for mapping(int24 => Tick.Info);
    using Position for mapping(bytes32 => Position.Info);
    using Position for Position.Info;
    using SwapMath for uint256;

    // Pool tokens
    address public immutable token0;
    address public immutable token1;
    uint24 public immutable fee;

    // Tick spacing
    int24 public immutable tickSpacing;

    // Pool state
    struct Slot0 {
        // the current price
        uint160 sqrtPriceX96;
        // the current tick
        int24 tick;
        // the most-recently updated index of the observations array
        uint16 observationIndex;
        // the current maximum number of observations that are being stored
        uint16 observationCardinality;
        // the next maximum number of observations to store, triggered in observations.write
        uint16 observationCardinalityNext;
        // the current protocol fee as a percentage of the swap fee taken on withdrawal
        // represented as an integer denominator (1/x)%
        uint8 feeProtocol;
        // whether the pool is locked
        bool unlocked;
    }

    /// @dev The 0th storage slot in the pool stores many values, and is exposed as a single method to save gas
    /// when accessed externally.
    Slot0 public slot0;
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
        position.update(amount.toInt128FromUint(), 0, 0);

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

    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external override returns (int256 amount0, int256 amount1) {
        require(amountSpecified != 0, "AS");
        Slot0 memory slot0Start = slot0;

        require(slot0Start.unlocked, "LOK");
        require(
            zeroForOne
                ? sqrtPriceLimitX96 < slot0Start.sqrtPriceX96 &&
                    sqrtPriceLimitX96 > TickMath.MIN_SQRT_RATIO
                : sqrtPriceLimitX96 > slot0Start.sqrtPriceX96 &&
                    sqrtPriceLimitX96 < TickMath.MAX_SQRT_RATIO,
            "SPL"
        );

        slot0.unlocked = false;

        SwapState memory state = SwapState({
            amountSpecifiedRemaining: amountSpecified,
            amountCalculated: 0,
            sqrtPriceX96: slot0Start.sqrtPriceX96,
            tick: slot0Start.tick,
            liquidity: liquidity
        });

        while (
            state.amountSpecifiedRemaining != 0 &&
            state.sqrtPriceX96 != sqrtPriceLimitX96
        ) {
            StepState memory step;
            step.sqrtPriceStartX96 = state.sqrtPriceX96;

            (step.sqrtPriceNextX96, step.amountIn, step.amountOut, step.feeAmount) = SwapMath
                .computeSwapStep(
                    state.sqrtPriceX96,
                    sqrtPriceLimitX96,
                    state.liquidity,
                    uint256(
                        state.amountSpecifiedRemaining > 0
                            ? state.amountSpecifiedRemaining
                            : -state.amountSpecifiedRemaining
                    ),
                    fee
                );

            if (state.amountSpecifiedRemaining > 0) {
                state.amountSpecifiedRemaining -= (step.amountIn + step.feeAmount)
                    .toInt256();
                state.amountCalculated = state.amountCalculated - step.amountOut.toInt256();
            } else {
                state.amountSpecifiedRemaining += step.amountOut.toInt256();
                state.amountCalculated = state.amountCalculated + (step.amountIn + step.feeAmount)
                    .toInt256();
            }

            if (state.sqrtPriceX96 == step.sqrtPriceNextX96) {
                // price hasn't changed
                int24 nextTick = zeroForOne ? state.tick - 1 : state.tick + 1;
                (state.sqrtPriceX96, state.tick) = (
                    TickMath.getSqrtRatioAtTick(nextTick),
                    nextTick
                );
            } else {
                state.sqrtPriceX96 = step.sqrtPriceNextX96;
                state.tick = TickMath.getTickAtSqrtRatio(state.sqrtPriceX96);
            }
        }

        if (state.tick != slot0Start.tick) {
            (slot0.sqrtPriceX96, slot0.tick) = (state.sqrtPriceX96, state.tick);
        } else {
            slot0.sqrtPriceX96 = state.sqrtPriceX96;
        }

        (amount0, amount1) = zeroForOne
            ? (
                amountSpecified - state.amountSpecifiedRemaining,
                state.amountCalculated
            )
            : (
                state.amountCalculated,
                amountSpecified - state.amountSpecifiedRemaining
            );

        slot0.unlocked = true;

        emit Swap(
            msg.sender,
            recipient,
            amount0,
            amount1,
            slot0.sqrtPriceX96,
            state.liquidity,
            slot0.tick
        );
    }

    struct SwapState {
        int256 amountSpecifiedRemaining;
        int256 amountCalculated;
        uint160 sqrtPriceX96;
        int24 tick;
        uint128 liquidity;
    }

    struct StepState {
        uint160 sqrtPriceStartX96;
        uint160 sqrtPriceNextX96;
        uint256 amountIn;
        uint256 amountOut;
        uint256 feeAmount;
    }
}
