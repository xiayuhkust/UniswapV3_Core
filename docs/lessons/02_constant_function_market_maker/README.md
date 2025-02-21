# 第二课：恒定函数做市商 (Lesson 2: Constant Function Market Maker)

## 核心概念 (Core Concepts)
1. 恒定乘积公式 (Constant Product Formula)
   - x * y = k
   - 交易前后乘积保持不变 (Product remains constant before and after trades)
   - 价格影响 (Price Impact)

2. 交易机制 (Trading Mechanism)
   - 输入金额计算 (Input Amount Calculation)
   - 输出金额计算 (Output Amount Calculation)
   ```solidity
   // (x + Δx)(y - Δy) = k
   amount1Out = (reserve1 * amount0InWithFee) / 
                ((reserve0 * FEE_DENOMINATOR) + amount0InWithFee);
   ```
   - 手续费处理 (Fee Handling): 0.3% fee

3. 技术实现 (Technical Implementation)
   - 储备更新 (Reserve Updates)
   - 常数乘积验证 (Constant Product Verification)
   - 事件发出 (Event Emission)

## 实现要点 (Implementation Highlights)
1. 储备管理 (Reserve Management)
   - 维护两种代币储备 (Maintain reserves for both tokens)
   - 储备更新逻辑 (Reserve update logic)
   - 初始化保护 (Initialization protection)

2. 交易计算 (Trade Calculation)
   - 考虑手续费 (Fee consideration)
   - 精确计算 (Precise calculation)
   - 溢出保护 (Overflow protection)

3. 测试覆盖 (Test Coverage)
   - 初始化测试 (Initialization tests)
   - 交易计算测试 (Trade calculation tests)
   - 边界条件测试 (Edge case tests)

## 下一步 (Next Steps)
准备学习第三课：Uniswap V3 (Moving on to Lesson 3: Uniswap V3)
- 集中流动性概念 (Concentrated liquidity concept)
- 价格范围管理 (Price range management)
- 费用层级系统 (Fee tier system)
