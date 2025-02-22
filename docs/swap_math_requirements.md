# SwapStep Math Requirements

## Core Math Operations

### 1. Fee Calculation
```solidity
uint256 amountRemainingLessFee = FullMath.mulDiv(
    amountRemaining,
    1e6 - fee,
    1e6
);
```
Requirements:
- Input range: 0 to type(uint256).max
- Fee range: 0 to 1e6 (100%)
- Precision: No loss of precision allowed
- Rounding: Round down to favor the protocol

### 2. Price Calculations
```solidity
// From Math.sol
uint256 amount0 = FullMath.mulDiv(
    numerator1,
    numerator2,
    sqrtPriceBX96
) / sqrtPriceAX96;

uint256 amount1 = FullMath.mulDiv(
    liquidity,
    (sqrtPriceBX96 - sqrtPriceAX96),
    FixedPoint96.Q96
);
```
Requirements:
- Q96 fixed-point precision (FixedPoint96.Q96 = 2^96)
- Price range: MIN_SQRT_RATIO (4295128739) to MAX_SQRT_RATIO (1461446703485210103287273052203988822378723970342)
- Liquidity range: 0 to type(uint128).max
- Precision: Must maintain Q96 precision throughout calculations
- Rounding: Configurable rounding direction based on operation

### 3. Price Impact Calculations
```solidity
uint160 sqrtPriceNextX96 = Math.getNextSqrtPriceFromInput(
    sqrtPriceX96,
    liquidity,
    amountIn,
    zeroForOne
);
```
Requirements:
- Must handle phantom overflow
- Must maintain Q96 precision
- Must handle full range of sqrt prices
- Must handle both token0 and token1 calculations

## Critical Requirements

1. Precision Requirements:
   - No loss of precision in fee calculations
   - Maintain Q96 fixed-point precision for prices
   - Handle phantom overflow without precision loss

2. Value Ranges:
   - Amounts: 0 to type(uint256).max
   - Prices: MIN_SQRT_RATIO to MAX_SQRT_RATIO
   - Liquidity: 0 to type(uint128).max
   - Fees: 0 to 1e6 (100%)

3. Error Handling:
   - Revert on division by zero
   - Revert on overflow conditions
   - Revert on invalid price ranges

4. Performance Requirements:
   - Gas efficient calculations
   - Minimal intermediate storage
   - Optimized assembly for core operations

## Test Scenarios Required

1. Basic Operations:
   - Standard fee calculations
   - Normal price range swaps
   - Typical liquidity values

2. Edge Cases:
   - Maximum token amounts
   - Minimum and maximum prices
   - Zero liquidity
   - Maximum fees

3. Precision Tests:
   - Q96 fixed-point calculations
   - Rounding behavior
   - Phantom overflow handling

4. Error Cases:
   - Division by zero
   - Price range violations
   - Overflow conditions
