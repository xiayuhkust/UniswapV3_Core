# Generalized Swapping Implementation

## Overview
The generalized swapping implementation enables token swaps within a single initialized tick range. This implementation handles both swap directions (zeroForOne and oneForZero) and includes fee calculations.

## Key Components

### SwapState
Tracks the state of a swap operation:
```solidity
struct SwapState {
    int256 amountSpecifiedRemaining;  // Remaining amount to be swapped
    int256 amountCalculated;          // Amount calculated for output
    uint160 sqrtPriceX96;            // Current sqrt price
    int24 tick;                       // Current tick
    uint128 liquidity;                // Current liquidity
    uint256 feeGrowthGlobalX128;      // Fee growth tracking
    uint256 amountIn;                 // Total amount in
    uint256 amountOut;                // Total amount out
}
```

### StepState
Tracks individual swap step execution:
```solidity
struct StepState {
    uint160 sqrtPriceStartX96;  // Starting sqrt price
    int24 nextTick;             // Next initialized tick
    uint160 sqrtPriceNextX96;   // Target sqrt price
    uint256 amountIn;           // Input amount for this step
    uint256 amountOut;          // Output amount for this step
    uint256 feeAmount;          // Fee amount for this step
}
```

## Implementation Details

### Price Calculation
- Uses `Math.getNextSqrtPriceFromInput` and `Math.getNextSqrtPriceFromOutput` for price updates
- Handles both exact input and exact output swaps
- Ensures price movement stays within specified limits
- Implements tick-based price range system

### Fee Calculation
- Fees are calculated per swap step using the formula: `feeAmount = amountIn * fee / (1e6 - fee)`
- Fee growth is tracked globally per token using `feeGrowthGlobal0X128` and `feeGrowthGlobal1X128`
- Fees are accumulated based on liquidity provided

### Swap Execution
- Swaps are executed step by step within initialized tick ranges
- Each step updates:
  - Current price (`sqrtPriceX96`)
  - Current tick
  - Amounts in/out
  - Fee accumulation
- Handles both swap directions (zeroForOne and oneForZero)
- Supports exact input and exact output swaps

### Error Handling
- Checks for insufficient liquidity
- Validates price limits
- Handles zero liquidity scenarios
- Prevents division by zero in calculations
- Implements custom error types for better error reporting

## Testing
Comprehensive test suite covering:
- Basic swap scenarios (zeroForOne and oneForZero)
- Fee calculations and accumulation
- Price limit validation
- Edge cases:
  - Zero liquidity
  - Exact boundaries
  - Price limit reached
- Tick movement verification
- Amount calculation accuracy

## Integration with SimpleQ32Math
- Uses SimpleQ32Math for fixed-point arithmetic
- Optimized for Tura blockchain's low gas costs
- Maintains precision while prioritizing code readability
