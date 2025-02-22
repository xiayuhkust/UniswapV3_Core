# Math Library Comparison for SwapStep Implementation

## Test Results Summary

### MinimalFullMath Library
✅ Basic Fee Calculations
- Successfully handles standard fee calculations (1M tokens, 0.3% fee)
- Correctly calculates fees for large amounts (1e27 tokens)
- Test: `testFeeCalculation()`, `testLargeAmountFeeCalculation()`

✅ Q96 Price Calculations
- Handles Q96 fixed-point precision
- Correctly calculates price ratios
- Test: `testPriceImpactCalculation()`

❌ Max Value Handling
- Fails on maximum token amount calculations
- Incorrect results for type(uint256).max inputs
- Test: `testMaxValueFeeCalculation()`

### MinimalPRBMath Library
✅ Basic Fee Calculations
- Successfully handles standard fee calculations
- Correctly processes large amounts
- Test: `testFeeCalculation()`, `testLargeAmountFeeCalculation()`

❌ Price Impact Calculations
- Fails to maintain Q96 precision
- Assertion failures in price ratio calculations
- Test: `testPriceImpactCalculation()`

✅ Max Value Handling
- Successfully handles maximum token amounts
- Correctly processes type(uint256).max inputs
- Test: `testMaxValueFeeCalculation()`

## Analysis Against Requirements

### Fee Calculation Requirements
```solidity
uint256 amountRemainingLessFee = mulDiv(
    amountRemaining,
    1e6 - fee,
    1e6
);
```
MinimalFullMath:
- ✅ Handles normal cases
- ❌ Fails on max values
- ✅ Maintains precision

MinimalPRBMath:
- ✅ Handles normal cases
- ✅ Handles max values
- ✅ Maintains precision

### Price Calculation Requirements
```solidity
uint256 amount1 = mulDiv(
    liquidity,
    (sqrtPriceBX96 - sqrtPriceAX96),
    FixedPoint96.Q96
);
```
MinimalFullMath:
- ✅ Maintains Q96 precision
- ✅ Handles price range calculations
- ❌ Edge case handling needs improvement

MinimalPRBMath:
- ❌ Q96 precision issues
- ❌ Fails on price calculations
- ✅ Good general number handling

## Recommendation
Based on test results and requirements:
1. MinimalFullMath better suits SwapStep requirements due to:
   - Better handling of Q96 fixed-point precision
   - Successful price impact calculations
   - Matches Uniswap V3 Core's approach
2. However, needs improvement in:
   - Max value handling
   - Edge case management

The official Uniswap V3 Core FullMath implementation should be used as it:
- Handles all required calculations
- Is proven in production
- Maintains required precision
- Properly handles edge cases
