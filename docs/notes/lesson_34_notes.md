# Lesson 34: Tick Rounding - Learning Notes

## Core Concepts (核心概念)

### Tick Spacing (刻度间距)
- Multiple-based ticks (基于倍数的刻度)
- Range boundaries (范围边界)
- Spacing validation (间距验证)

### Rounding Rules (舍入规则)
1. Basic Rules (基本规则)
   - Less than 0.5: round down (小于0.5：向下舍入)
   - Greater than 0.5: round up (大于0.5：向上舍入)
   - Equal to 0.5: round up (等于0.5：向上舍入)

2. Boundary Handling (边界处理)
   - MIN_TICK adjustment (最小刻度调整)
   - MAX_TICK adjustment (最大刻度调整)
   - Spacing correction (间距修正)

## Technical Implementation Details (技术实现细节)

### JavaScript Implementation (JavaScript实现)
```javascript
function nearestUsableTick(tick, tickSpacing) {
    // Input validation (输入验证)
    invariant(
        Number.isInteger(tick) && Number.isInteger(tickSpacing),
        'INTEGERS'
    );
    invariant(tickSpacing > 0, 'TICK_SPACING');
    invariant(
        tick >= TickMath.MIN_TICK && tick <= TickMath.MAX_TICK,
        'TICK_BOUND'
    );

    // Round to nearest tick (舍入到最近的刻度)
    const rounded = Math.round(tick / tickSpacing) * tickSpacing;

    // Boundary adjustments (边界调整)
    if (rounded < TickMath.MIN_TICK) return rounded + tickSpacing;
    if (rounded > TickMath.MAX_TICK) return rounded - tickSpacing;
    return rounded;
}
```

### Solidity Implementation (Solidity实现)
```solidity
// Division with rounding (带舍入的除法)
function divRound(
    int128 x,
    int128 y
) internal pure returns (int128 result) {
    // Perform division (执行除法)
    int128 quot = ABDKMath64x64.div(x, y);
    result = quot >> 64;

    // Check remainder for rounding (检查余数进行舍入)
    if (quot % 2**64 >= 0x8000000000000000) {
        result += 1;
    }
}

// Nearest usable tick calculation (最近可用刻度计算)
function nearestUsableTick(
    int24 tick_,
    uint24 tickSpacing
) internal pure returns (int24 result) {
    // Round to nearest spacing (舍入到最近的间距)
    result = int24(
        divRound(
            int128(tick_),
            int128(int24(tickSpacing))
        )
    ) * int24(tickSpacing);

    // Boundary adjustments (边界调整)
    if (result < TickMath.MIN_TICK) {
        result += int24(tickSpacing);
    } else if (result > TickMath.MAX_TICK) {
        result -= int24(tickSpacing);
    }
}
```

### Integration Example (集成示例)
```javascript
// Mint parameters with tick rounding (带刻度舍入的铸造参数)
const mintParams = {
    tokenA: pair.token0.address,
    tokenB: pair.token1.address,
    tickSpacing: pair.tickSpacing,
    lowerTick: nearestUsableTick(lowerTick, pair.tickSpacing),
    upperTick: nearestUsableTick(upperTick, pair.tickSpacing),
    amount0Desired,
    amount1Desired,
    amount0Min,
    amount1Min
};
```

## Test Coverage (测试覆盖)

### Test Cases (测试用例)
1. Rounding Tests (舍入测试)
   ```solidity
   function testRounding() public {
       // Test parameters (测试参数)
       int24 tick = 100;
       uint24 spacing = 60;

       // Test cases (测试用例)
       assertEq(
           nearestUsableTick(tick, spacing),
           120
       );  // 100/60 = 1.67 -> 2 * 60 = 120

       assertEq(
           nearestUsableTick(85, spacing),
           60
       );   // 85/60 = 1.42 -> 1 * 60 = 60
   }
   ```

2. Boundary Tests (边界测试)
   ```solidity
   function testBoundaries() public {
       // Test MIN_TICK (测试最小刻度)
       assertEq(
           nearestUsableTick(TickMath.MIN_TICK, 60),
           TickMath.MIN_TICK
       );

       // Test MAX_TICK (测试最大刻度)
       assertEq(
           nearestUsableTick(TickMath.MAX_TICK, 60),
           TickMath.MAX_TICK - (TickMath.MAX_TICK % 60)
       );
   }
   ```

### Test Setup (测试设置)
```solidity
// Test parameters (测试参数)
int24 constant TICK_SPACING = 60;
int24 constant MIN_TICK = -887272;
int24 constant MAX_TICK = 887272;

// Helper functions (辅助函数)
function encodePriceSqrt(
    uint256 price,
    uint256 decimals
) internal pure returns (uint160) {
    return uint160(
        int160(
            divRound(
                int128(int256(price)),
                int128(int256(10**decimals))
            )
        )
    );
}
```

## Next Steps (下一步)
- Study fees and price oracle (学习费用和价格预言机)
- Implement swap fees (实现交换费用)
- Add flash loan fees (添加闪电贷费用)

## Environment Prerequisites (环境先决条件)
- Solidity ^0.8.14 (使用Solidity ^0.8.14)
- ABDKMath64x64 library (ABDKMath64x64库)
- TickMath contract (TickMath合约)
