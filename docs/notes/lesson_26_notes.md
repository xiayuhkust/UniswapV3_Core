# Lesson 26: A Little Bit More on Fixed-Point Numbers - Learning Notes

## Core Concepts (核心概念)

### Fixed-Point Number Types (定点数类型)
1. Binary Fixed-Point (二进制定点数)
   - Q64.96 format (Q64.96格式)
   - Binary places (二进制位)
   - Uniswap V3 standard (Uniswap V3标准)

2. Decimal Fixed-Point (十进制定点数)
   - UD60.18 format (UD60.18格式)
   - Decimal places (十进制位)
   - PRBMath implementation (PRBMath实现)

### Number Conversion (数字转换)
1. Integer to Q64.96 (整数到Q64.96)
   ```solidity
   // Example: 42 to Q64.96 (示例：42转Q64.96)
   uint256 q64x96 = 42 << 96;  // Multiply by 2^96 (乘以2^96)
   ```

2. Decimal to Q64.96 (小数到Q64.96)
   ```solidity
   // Example: 42.1337 to Q64.96 (示例：42.1337转Q64.96)
   uint256 q64x96 = 421337 << 92;  // Scale and shift (缩放并移位)
   ```

## Technical Implementation Details (技术实现细节)

### Price to Tick Conversion (价格到刻度转换)
```solidity
function tick(
    uint256 price
) internal pure returns (int24 tick_) {
    // Convert price to Q64.64 (转换价格到Q64.64)
    int128 q64x64Price = int128(int256(price << 64));
    
    // Calculate square root (计算平方根)
    int128 sqrtPrice = ABDKMath64x64.sqrt(q64x64Price);
    
    // Convert to Q64.96 (转换到Q64.96)
    uint160 sqrtPriceX96 = uint160(
        int160(sqrtPrice << (FixedPoint96.RESOLUTION - 64))
    );
    
    // Get tick (获取刻度)
    tick_ = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
}
```

### Library Usage (库使用)
1. ABDK Math (ABDK数学库)
   - Q64.64 implementation (Q64.64实现)
   - Square root support (平方根支持)
   - Precision handling (精度处理)

2. PRBMath Limitations (PRBMath限制)
   - Decimal fixed-point (十进制定点数)
   - Precision loss (精度损失)
   - Conversion difficulties (转换困难)

## Test Coverage (测试覆盖)

### Test Cases (测试用例)
1. Integer Prices (整数价格)
   ```solidity
   function testIntegerPrices() public {
       assertEq(tick(5000), 85176);  // Expected tick for 5000
       assertEq(tick(10), 23026);    // Expected tick for 10
   }
   ```

2. Edge Cases (边界情况)
   ```solidity
   function testEdgeCases() public {
       assertEq(tick(1), 0);         // Minimum price
       assertEq(tick(2**32), 244227); // Large price
   }
   ```

### Test Setup (测试设置)
```solidity
// Test parameters (测试参数)
uint256 price = 5000;
int24 expectedTick = 85176;

// Helper functions (辅助函数)
function sqrtP(uint256 price) internal pure returns (uint160) {
    return uint160(
        int160(
            ABDKMath64x64.sqrt(
                int128(int256(price << 64))
            ) << (FixedPoint96.RESOLUTION - 64)
        )
    );
}
```

## Next Steps (下一步)
- Implement flash loans (实现闪电贷)
- Update user interface (更新用户界面)
- Study multi-pool swaps (学习多池交换)

## Environment Prerequisites (环境先决条件)
- Solidity ^0.8.14 (使用Solidity ^0.8.14)
- ABDK Math library (ABDK数学库)
- TickMath contract (TickMath合约)
