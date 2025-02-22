# Lesson 16: Tick Bitmap Index - Learning Notes

## Core Concepts (核心概念)

### Bitmap Indexing (位图索引)
- Compact data storage technique (紧凑的数据存储技术)
- Binary representation of flags (标志的二进制表示)
- Each bit represents tick state (每个位代表刻度状态)
- 256 flags per word (每个字256个标志)

### Tick Organization (刻度组织)
1. Word Structure (字结构)
   - uint256 for storage (使用uint256存储)
   - 256 bits per word (每个字256位)
   - Continuous array of words (连续的字数组)

2. Position Calculation (位置计算)
   ```solidity
   wordPos = tick >> 8;     // Division by 256 (除以256)
   bitPos = tick % 256;     // Remainder (余数)
   ```

## Technical Implementation Details (技术实现细节)

### Tick Bitmap Contract (刻度位图合约)
```solidity
contract UniswapV3Pool {
    using TickBitmap for mapping(int16 => uint256);
    mapping(int16 => uint256) public tickBitmap;
}
```

### Flag Operations (标志操作)
1. Flip Function (翻转函数)
   ```solidity
   function flipTick(
       mapping(int16 => uint256) storage self,
       int24 tick,
       int24 tickSpacing
   ) internal {
       (int16 wordPos, uint8 bitPos) = position(tick / tickSpacing);
       uint256 mask = 1 << bitPos;
       self[wordPos] ^= mask;
   }
   ```

2. Next Tick Finding (下一个刻度查找)
   ```solidity
   function nextInitializedTickWithinOneWord(
       mapping(int16 => uint256) storage self,
       int24 tick,
       int24 tickSpacing,
       bool lte
   ) internal view returns (
       int24 next,
       bool initialized
   )
   ```

### Search Directions (搜索方向)
1. Selling Token X (卖出代币X)
   - Search right in current word (在当前字中向右搜索)
   - Mask bits right of current (掩码当前位右侧)
   - Return next initialized tick (返回下一个初始化刻度)

2. Selling Token Y (卖出代币Y)
   - Search left in next word (在下一个字中向左搜索)
   - Mask bits left of current (掩码当前位左侧)
   - Return previous initialized tick (返回前一个初始化刻度)

## Test Coverage (测试覆盖)

### Test Cases (测试用例)
1. Tick Flipping (刻度翻转)
   - Initialize new tick (初始化新刻度)
   - Verify bit setting (验证位设置)
   - Test multiple flips (测试多次翻转)

2. Next Tick Finding (下一个刻度查找)
   - Right direction search (向右搜索)
   - Left direction search (向左搜索)
   - Cross-word boundary cases (跨字边界情况)

### Test Setup (测试设置)
```solidity
// Test data setup (测试数据设置)
tick = 85176;
wordPos = tick >> 8;    // 332
bitPos = tick % 256;    // 184

// Mask calculation (掩码计算)
mask = 1 << bitPos;
```

## Next Steps (下一步)
- Implement generalized minting (实现通用铸造)
- Add generalized swapping (添加通用交换)
- Integrate with quoter contract (与报价合约集成)

## Environment Prerequisites (环境先决条件)
- Solidity ^0.8.14 (使用Solidity ^0.8.14)
- Bitmap manipulation libraries (位图操作库)
- Test environment setup (测试环境设置)
