# 第一课：市场介绍 (Lesson 1: Introduction to Markets)

## 核心概念 (Core Concepts)
1. 集中式交易所工作原理 (How Centralized Exchanges Work)
   - 订单簿结构和管理 (Order book structure and management)
   - 买卖订单匹配机制 (Buy/sell order matching)
   - 价格发现过程 (Price discovery process)

2. 做市商角色 (Market Maker Role)
   - 提供市场流动性 (Providing market liquidity)
   - 维持市场效率 (Maintaining market efficiency)
   - 基本做市策略 (Basic market making strategies)

3. 技术实现细节 (Implementation Details)
   - 基础订单结构设计 (Basic order structure design)
   ```solidity
   struct Order {
       address trader;      // 交易者地址
       uint256 price;      // 订单价格
       uint256 amount;     // 订单数量
       bool isBuyOrder;    // 是否为买单
   }
   ```
   - 订单验证逻辑 (Order validation logic)
   - 事件透明机制 (Event transparency mechanism)

## 实现要点 (Implementation Highlights)
1. 订单结构 (Order Structure)
   - 交易者地址 (Trader address)
   - 价格和数量 (Price and amount)
   - 买卖方向 (Buy/sell direction)

2. 核心功能 (Core Functions)
   - placeOrder: 下单功能
   - getOrderCount: 获取订单数量

3. 事件定义 (Event Definitions)
   - OrderPlaced: 订单创建事件

## 测试覆盖 (Test Coverage)
1. 基本订单操作 (Basic Order Operations)
   - 订单创建测试
   - 事件发出验证
   - 参数验证测试

## 下一步 (Next Steps)
准备学习第二课：恒定函数做市商 (Constant Function Market Maker)
