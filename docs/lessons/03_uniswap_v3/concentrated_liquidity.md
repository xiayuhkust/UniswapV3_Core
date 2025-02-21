# Concentrated Liquidity (集中流动性)

## Overview (概述)
Concentrated liquidity is the key innovation of Uniswap V3, allowing liquidity providers to specify price ranges for their liquidity. This improves capital efficiency by concentrating liquidity where it's most needed.

## Key Concepts (核心概念)

### 1. Price Ranges (价格范围)
- Liquidity providers specify min and max prices
- Liquidity is only active within the specified range
- Multiple positions can be created with different ranges

### 2. Ticks (价格刻度)
- Prices are represented as ticks
- Each tick represents a 0.01% price change
- Tick range: [-887272, 887272]
- Price = 1.0001^tick

### 3. Sqrt Price (平方根价格)
- Internal price representation uses square root
- Improves computational efficiency
- Stored in Q64.96 format

### 4. Capital Efficiency (资本效率)
- Concentrated positions earn more fees
- Reduced capital requirements
- Better price stability in active ranges

## Mathematical Foundation (数学基础)

### Price Calculation (价格计算)
```
P = √(y/x)
tick = log(1.0001, P)
```

### Liquidity Calculation (流动性计算)
```
L = √(x * y)
Δy = L * ΔP
```

## Implementation Notes (实现注意事项)

### 1. Price Range Management (价格范围管理)
- Validate tick bounds
- Handle tick spacing
- Track active ranges

### 2. Position Management (头寸管理)
- Track individual positions
- Calculate fees per position
- Handle position updates

### 3. Swap Execution (交易执行)
- Calculate price impact
- Update active liquidity
- Cross tick boundaries
