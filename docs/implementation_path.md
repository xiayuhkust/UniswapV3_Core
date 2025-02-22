# Implementation Path for SwapStep Math Library

## Current Usage Analysis

### SwapMath.sol
```solidity
// Fee calculation
uint256 amountRemainingLessFee = FullMath.mulDiv(
    amountRemaining,
    1e6 - fee,
    1e6
);

// Price calculations
uint256 amount1 = FullMath.mulDiv(
    liquidity,
    (sqrtPriceBX96 - sqrtPriceAX96),
    FixedPoint96.Q96
);
```

## Implementation Requirements

1. Math Library Source
   - Location: milestone_6/src/lib in Jeiwan/uniswapv3-code
   - Files needed:
     - FullMath.sol
     - FixedPoint96.sol

2. Integration Points
   - SwapMath.sol: Fee calculations
   - Math.sol: Price calculations
   - Position.sol: Liquidity calculations

## Current Issues

1. PRBMath Integration Issues
   - ❌ Price impact calculations fail
   - ❌ Q96 precision not maintained
   - ✅ Basic fee calculations work
   ```solidity
   // Example of failing calculation
   uint256 priceRatio = MinimalPRBMath.mulDiv(
       uint256(sqrtPriceTargetX96),
       FixedPoint96.Q96,
       uint256(sqrtPriceCurrentX96)
   );
   ```

2. MinimalFullMath Issues
   - ❌ Max value handling fails
   - ✅ Q96 calculations work
   - ✅ Basic fee calculations work
   ```solidity
   // Example of failing calculation
   uint256 amountLessFee = MinimalFullMath.mulDiv(
       type(uint256).max,
       1e6 - fee,
       1e6
   );
   ```

## Implementation Steps

1. Source Official Implementation
   ```bash
   # Copy from milestone_6/src/lib
   cp milestone_6/src/lib/FullMath.sol contracts/milestone2/contracts/libraries/
   ```

2. Update Import Paths
   ```solidity
   // In SwapMath.sol
   import "./FullMath.sol";
   import "./FixedPoint96.sol";
   ```

3. Verify Integration Points
   - SwapMath.sol: Fee calculations
   - Math.sol: Price and amount calculations
   - Position.sol: Liquidity calculations

4. Test Coverage Required
   - Basic fee calculations
   - Price impact calculations
   - Max value handling
   - Q96 precision maintenance

## Next Steps

1. Implement Official FullMath
   - Source from milestone_6/src/lib
   - Maintain version compatibility (^0.8.14)
   - Keep existing test suite

2. Update Documentation
   - Update PROGRESS.md
   - Update deployment_records.md
   - Update tests.md with new test results

3. Verify Integration
   - Run full test suite
   - Verify all swap operations
   - Document any remaining issues
