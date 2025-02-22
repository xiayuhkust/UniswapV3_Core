# Lesson 22: Different Price Ranges - Learning Notes

## Core Concepts (核心概念)

### Price Range Types (价格范围类型)
1. Active Range (活动范围)
   - Includes current price (包含当前价格)
   - Contains both tokens (包含两种代币)
   - Immediately available liquidity (立即可用流动性)

2. Below Current Price (低于当前价格)
   - Upper tick below current (上限刻度低于当前)
   - Contains only cheaper token (仅包含较便宜的代币)
   - Acts as buy limit orders (作为买入限价订单)

3. Above Current Price (高于当前价格)
   - Lower tick above current (下限刻度高于当前)
   - Contains only expensive token (仅包含较贵的代币)
   - Acts as sell limit orders (作为卖出限价订单)

### Limit Order Behavior (限价订单行为)
- Narrow ranges act as limit orders (窄范围作为限价订单)
- Token conversion at range crossing (范围交叉时的代币转换)
- Price movement triggers execution (价格移动触发执行)

## Technical Implementation Details (技术实现细节)

### Amount Calculation (金额计算)
```solidity
function mint() {
    // Above current price (高于当前价格)
    if (slot0_.tick < lowerTick) {
        amount0 = Math.calcAmount0Delta(
            TickMath.getSqrtRatioAtTick(lowerTick),
            TickMath.getSqrtRatioAtTick(upperTick),
            amount
        );
    }
    // Within current price (在当前价格范围内)
    else if (slot0_.tick < upperTick) {
        amount0 = Math.calcAmount0Delta(
            slot0_.sqrtPriceX96,
            TickMath.getSqrtRatioAtTick(upperTick),
            amount
        );
        amount1 = Math.calcAmount1Delta(
            slot0_.sqrtPriceX96,
            TickMath.getSqrtRatioAtTick(lowerTick),
            amount
        );
        liquidity = LiquidityMath.addLiquidity(liquidity, int128(amount));
    }
    // Below current price (低于当前价格)
    else {
        amount1 = Math.calcAmount1Delta(
            TickMath.getSqrtRatioAtTick(lowerTick),
            TickMath.getSqrtRatioAtTick(upperTick),
            amount
        );
    }
}
```

### Liquidity Management (流动性管理)
1. Active Range (活动范围)
   - Update liquidity tracker (更新流动性跟踪器)
   - Calculate both token amounts (计算两种代币金额)
   - Handle immediate availability (处理即时可用性)

2. Inactive Range (非活动范围)
   - Single token composition (单一代币组成)
   - Delayed activation (延迟激活)
   - Range crossing handling (范围交叉处理)

## Test Coverage (测试覆盖)

### Test Cases (测试用例)
1. Range Type Tests (范围类型测试)
   - Active range minting (活动范围铸造)
   - Below range minting (低于范围铸造)
   - Above range minting (高于范围铸造)

2. Limit Order Tests (限价订单测试)
   - Range crossing behavior (范围交叉行为)
   - Token conversion (代币转换)
   - Liquidity activation (流动性激活)

### Test Setup (测试设置)
```solidity
// Test parameters (测试参数)
int24 currentTick = 0;
int24 lowerTick = -100;
int24 upperTick = 100;
uint128 amount = 1000000;

// Expected results (预期结果)
uint256 expectedAmount0;
uint256 expectedAmount1;
uint128 expectedLiquidity;
```

## Next Steps (下一步)
- Implement cross-tick swaps (实现跨刻度交换)
- Add slippage protection (添加滑点保护)
- Calculate liquidity amounts (计算流动性金额)

## Environment Prerequisites (环境先决条件)
- Solidity ^0.8.14 (使用Solidity ^0.8.14)
- UniswapV3Pool contract (UniswapV3Pool合约)
- Test environment setup (测试环境设置)
