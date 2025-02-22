# Lesson 25: Liquidity Calculation - Learning Notes

## Core Concepts (核心概念)

### Liquidity Calculation (流动性计算)
- Token amount based calculation (基于代币数量的计算)
- Price range consideration (价格范围考虑)
- Safe math operations (安全数学运算)

### Formula Implementation (公式实现)
1. Token0 Liquidity (代币0流动性)
   ```
   L = (Δx * √Pu * √Pl) / (√Pu - √Pl)
   ```

2. Token1 Liquidity (代币1流动性)
   ```
   L = Δy / (√Pu - √Pl)
   ```

## Technical Implementation Details (技术实现细节)

### Liquidity Functions (流动性函数)
```solidity
function getLiquidityForAmount0(
    uint160 sqrtPriceAX96,
    uint160 sqrtPriceBX96,
    uint256 amount0
) internal pure returns (uint128 liquidity) {
    // Sort prices (排序价格)
    if (sqrtPriceAX96 > sqrtPriceBX96)
        (sqrtPriceAX96, sqrtPriceBX96) = (sqrtPriceBX96, sqrtPriceAX96);

    // Calculate intermediate value (计算中间值)
    uint256 intermediate = PRBMath.mulDiv(
        sqrtPriceAX96,
        sqrtPriceBX96,
        FixedPoint96.Q96
    );

    // Calculate liquidity (计算流动性)
    liquidity = uint128(
        PRBMath.mulDiv(
            amount0,
            intermediate,
            sqrtPriceBX96 - sqrtPriceAX96
        )
    );
}

function getLiquidityForAmount1(
    uint160 sqrtPriceAX96,
    uint160 sqrtPriceBX96,
    uint256 amount1
) internal pure returns (uint128 liquidity) {
    // Sort prices (排序价格)
    if (sqrtPriceAX96 > sqrtPriceBX96)
        (sqrtPriceAX96, sqrtPriceBX96) = (sqrtPriceBX96, sqrtPriceAX96);

    // Calculate liquidity (计算流动性)
    liquidity = uint128(
        PRBMath.mulDiv(
            amount1,
            FixedPoint96.Q96,
            sqrtPriceBX96 - sqrtPriceAX96
        )
    );
}
```

### Range-Based Calculation (基于范围的计算)
```solidity
function getLiquidityForAmounts(
    uint160 sqrtPriceX96,
    uint160 sqrtPriceAX96,
    uint160 sqrtPriceBX96,
    uint256 amount0,
    uint256 amount1
) internal pure returns (uint128 liquidity) {
    // Sort prices (排序价格)
    if (sqrtPriceAX96 > sqrtPriceBX96)
        (sqrtPriceAX96, sqrtPriceBX96) = (sqrtPriceBX96, sqrtPriceAX96);

    // Below range (低于范围)
    if (sqrtPriceX96 <= sqrtPriceAX96) {
        liquidity = getLiquidityForAmount0(
            sqrtPriceAX96,
            sqrtPriceBX96,
            amount0
        );
    }
    // Within range (在范围内)
    else if (sqrtPriceX96 <= sqrtPriceBX96) {
        uint128 liquidity0 = getLiquidityForAmount0(
            sqrtPriceX96,
            sqrtPriceBX96,
            amount0
        );
        uint128 liquidity1 = getLiquidityForAmount1(
            sqrtPriceAX96,
            sqrtPriceX96,
            amount1
        );
        liquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1;
    }
    // Above range (高于范围)
    else {
        liquidity = getLiquidityForAmount1(
            sqrtPriceAX96,
            sqrtPriceBX96,
            amount1
        );
    }
}
```

## Test Coverage (测试覆盖)

### Test Cases (测试用例)
1. Range Tests (范围测试)
   - Below current price (低于当前价格)
   - Within price range (在价格范围内)
   - Above current price (高于当前价格)

2. Amount Tests (金额测试)
   - Token0 calculation (代币0计算)
   - Token1 calculation (代币1计算)
   - Minimum liquidity selection (最小流动性选择)

### Test Setup (测试设置)
```solidity
// Test parameters (测试参数)
uint160 sqrtPriceX96 = encodePriceSqrt(1, 1);
uint160 sqrtPriceAX96 = encodePriceSqrt(1, 2);
uint160 sqrtPriceBX96 = encodePriceSqrt(2, 1);
uint256 amount0 = 1 ether;
uint256 amount1 = 2 ether;

// Expected results (预期结果)
uint128 expectedLiquidity;
```

## Next Steps (下一步)
- Study fixed-point numbers (学习定点数)
- Implement flash loans (实现闪电贷)
- Update user interface (更新用户界面)

## Environment Prerequisites (环境先决条件)
- Solidity ^0.8.14 (使用Solidity ^0.8.14)
- PRBMath library (PRBMath库)
- FixedPoint96 library (FixedPoint96库)
