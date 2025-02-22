// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "./interfaces/IERC20.sol";
import "./interfaces/IUniswapV3Pool.sol";
import "./interfaces/IUniswapV3MintCallback.sol";
import "./interfaces/IUniswapV3SwapCallback.sol";

import "./libraries/SafeCast.sol";
import "./libraries/Tick.sol";
import "./libraries/TickMath.sol";
import "./libraries/Position.sol";
import "./libraries/Oracle.sol";
import "./libraries/Math.sol";
import "./libraries/SwapMath.sol";
import "./libraries/FixedPoint96.sol";
import "./libraries/LiquidityMath.sol";
import "./libraries/TickBitmap.sol";

contract UniswapV3Pool is IUniswapV3Pool {
    error AlreadyInitialized();
    error FlashLoanNotPaid();
    error InsufficientInputAmount();
    error InvalidPriceLimit();
    error InvalidTickRange();
    error NotEnoughLiquidity();
    error ZeroLiquidity();

    using SafeCast for uint256;
    using SafeCast for int256;
    using SafeCast for uint128;
    using Tick for mapping(int24 => Tick.Info);
    using Position for mapping(bytes32 => Position.Info);
    using Position for Position.Info;
    using SwapMath for uint256;
    using TickBitmap for mapping(int16 => uint256);

    // Pool tokens
    address public immutable token0;
    address public immutable token1;
    uint24 public immutable fee;

    // Tick spacing
    int24 public immutable tickSpacing;

    // Fee growth
    uint256 public feeGrowthGlobal0X128;
    uint256 public feeGrowthGlobal1X128;

    // Tick bitmap
    mapping(int16 => uint256) public tickBitmap;

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

    function balance0() internal returns (uint256) {
        return IERC20(token0).balanceOf(address(this));
    }

    function balance1() internal returns (uint256) {
        return IERC20(token1).balanceOf(address(this));
    }

    struct ModifyPositionParams {
        address owner;
        int24 lowerTick;
        int24 upperTick;
        int128 liquidityDelta;
    }

    function _modifyPosition(ModifyPositionParams memory params)
        internal
        returns (
            Position.Info storage position,
            int256 amount0,
            int256 amount1
        )
    {
        // gas optimizations
        Slot0 memory slot0_ = slot0;
        uint256 feeGrowthGlobal0X128_ = feeGrowthGlobal0X128;
        uint256 feeGrowthGlobal1X128_ = feeGrowthGlobal1X128;

        position = positions.get(
            params.owner,
            params.lowerTick,
            params.upperTick
        );

        bool flippedLower = ticks.update(
            params.lowerTick,
            slot0_.tick,
            params.liquidityDelta,
            feeGrowthGlobal0X128_,
            feeGrowthGlobal1X128_,
            false
        );

        bool flippedUpper = ticks.update(
            params.upperTick,
            slot0_.tick,
            params.liquidityDelta,
            feeGrowthGlobal0X128_,
            feeGrowthGlobal1X128_,
            true
        );

        if (flippedLower) {
            tickBitmap.flipTick(params.lowerTick, tickSpacing);
        }
        if (flippedUpper) {
            tickBitmap.flipTick(params.upperTick, tickSpacing);
        }

        (uint256 feeGrowthInside0X128, uint256 feeGrowthInside1X128) = ticks
            .getFeeGrowthInside(
                params.lowerTick,
                params.upperTick,
                slot0_.tick,
                feeGrowthGlobal0X128_,
                feeGrowthGlobal1X128_
            );

        position.update(
            params.liquidityDelta,
            feeGrowthInside0X128,
            feeGrowthInside1X128
        );

        if (slot0.tick < params.lowerTick) {
            amount0 = Math.calcAmount0Delta(
                TickMath.getSqrtRatioAtTick(params.lowerTick),
                TickMath.getSqrtRatioAtTick(params.upperTick),
                params.liquidityDelta
            );
        } else if (slot0.tick < params.upperTick) {
            amount0 = Math.calcAmount0Delta(
                slot0.sqrtPriceX96,
                TickMath.getSqrtRatioAtTick(params.upperTick),
                params.liquidityDelta
            );
            amount1 = Math.calcAmount1Delta(
                TickMath.getSqrtRatioAtTick(params.lowerTick),
                slot0.sqrtPriceX96,
                params.liquidityDelta
            );
            liquidity = LiquidityMath.addDelta(liquidity, params.liquidityDelta);
        } else {
            amount1 = Math.calcAmount1Delta(
                TickMath.getSqrtRatioAtTick(params.lowerTick),
                TickMath.getSqrtRatioAtTick(params.upperTick),
                params.liquidityDelta
            );
        }
    }

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

        slot0 = Slot0({
            sqrtPriceX96: uint160(1 << 96),
            tick: 0,
            observationIndex: 0,
            observationCardinality: 0,
            observationCardinalityNext: 0,
            feeProtocol: 0,
            unlocked: true
        });
    }

    function mint(
        address recipient,
        int24 lowerTick,
        int24 upperTick,
        uint128 amount,
        bytes calldata data
    ) external override returns (uint256 amount0, uint256 amount1) {
        if (amount == 0) revert ZeroLiquidity();
        if (
            lowerTick >= upperTick ||
            lowerTick < TickMath.MIN_TICK ||
            upperTick > TickMath.MAX_TICK
        ) revert InvalidTickRange();

        (, int256 amount0Int, int256 amount1Int) = _modifyPosition(
            ModifyPositionParams({
                owner: recipient,
                lowerTick: lowerTick,
                upperTick: upperTick,
                liquidityDelta: int128(amount)
            })
        );

        amount0 = uint256(amount0Int);
        amount1 = uint256(amount1Int);

        uint256 balance0Before;
        uint256 balance1Before;
        if (amount0 > 0) balance0Before = balance0();
        if (amount1 > 0) balance1Before = balance1();

        IUniswapV3MintCallback(msg.sender).uniswapV3MintCallback(
            amount0,
            amount1,
            data
        );

        if (amount0 > 0 && balance0Before + amount0 > balance0())
            revert InsufficientInputAmount();
        if (amount1 > 0 && balance1Before + amount1 > balance1())
            revert InsufficientInputAmount();

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
            liquidity: liquidity,
            feeGrowthGlobalX128: 0
        });

        // Single step swap for initial implementation
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

        if (amountSpecified < 0) {
            state.amountSpecifiedRemaining += step.amountIn.toInt256();
            state.amountCalculated = step.amountOut.toInt256();
        } else {
            state.amountSpecifiedRemaining -= step.amountOut.toInt256();
            state.amountCalculated = -(step.amountIn.toInt256());
        }

        state.sqrtPriceX96 = step.sqrtPriceNextX96;
        state.tick = TickMath.getTickAtSqrtRatio(state.sqrtPriceX96);

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
        uint256 feeGrowthGlobalX128;
    }

    struct StepState {
        uint160 sqrtPriceStartX96;
        uint160 sqrtPriceNextX96;
        uint256 amountIn;
        uint256 amountOut;
        uint256 feeAmount;
    }
}
