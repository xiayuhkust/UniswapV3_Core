# 第三课：Uniswap V3 (Lesson 3: Uniswap V3)

## 核心概念 (Core Concepts)

### 1. 集中流动性 (Concentrated Liquidity)
- 流动性提供者可以选择价格范围 (LPs can choose price ranges)
- 提高资本效率 (Improved capital efficiency)
- 支持不同波动性的交易对 (Supports pairs with different volatility)

### 2. 价格范围和刻度 (Price Ranges and Ticks)
- 价格范围由刻度标记 (Price ranges marked by ticks)
- 刻度计算: p(i) = 1.0001^i
- 相邻刻度差异为1个基点 (0.01%)

### 3. 数学基础 (Mathematical Foundations)
- 流动性计算: L = √(xy)
- 价格计算: P = √(y/x)
- 输出金额计算: Δy = L * ΔP

### 4. 技术实现 (Technical Implementation)
- Q64.96 定点数表示 (Fixed-point number representation)
- 价格范围: [2^-128, 2^128]
- 刻度范围: [-887272, 887272]

## 改进要点 (Key Improvements)
1. V2 vs V3 比较 (V2 vs V3 Comparison)
   - 无限价格范围 vs 有限价格范围
   - 统一流动性 vs 集中流动性
   - 单一费率 vs 多费率

2. 资本效率 (Capital Efficiency)
   - 流动性集中在活跃价格范围
   - 减少无效资本占用
   - 提高收益率

## 下一步 (Next Steps)
准备开发环境，实现基础数学库
1. 开发工具配置
2. 数学库实现
3. 测试用例编写

