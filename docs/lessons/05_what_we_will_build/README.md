# 第五课：我们要构建什么 (Lesson 5: What We Will Build)

## 核心概念 (Core Concepts)
1. Uniswap V3 架构概述 (Uniswap V3 Architecture Overview)
   - 核心合约结构 (Core Contract Structure)
   - 组件间交互关系 (Component Interactions)
   - 系统设计目标 (System Design Goals)

2. 主要组件 (Main Components)
   - UniswapV3Pool: 流动性池合约 (Liquidity Pool Contract)
     - 实现流动性管理和交易执行 (Implements liquidity management and swap execution)
     - 处理价格范围和手续费计算 (Handles price ranges and fee calculations)
     - 管理流动性提供者的头寸 (Manages liquidity provider positions)

   - Factory: 池工厂合约 (Pool Factory Contract)
     - 创建和管理新的交易对 (Creates and manages new trading pairs)
     - 维护已部署池的记录 (Maintains records of deployed pools)
     - 确保池的唯一性和安全性 (Ensures pool uniqueness and security)

   - Manager: 外围管理合约 (Periphery Management Contract)
     - 简化与池合约的交互 (Simplifies interaction with pool contracts)
     - 提供高级交易功能 (Provides advanced trading functions)
     - 处理代币转账和授权 (Handles token transfers and approvals)

   - Quoter: 报价合约 (Quote Contract)
     - 链上价格计算 (On-chain price calculation)
     - 模拟交易执行 (Simulates swap execution)
     - 提供价格预估服务 (Provides price estimation service)

   - NFTManager: NFT 头寸管理 (NFT Position Management)
     - 将流动性头寸代币化 (Tokenizes liquidity positions)
     - 实现 ERC721 标准 (Implements ERC721 standard)
     - 管理头寸的转让和交易 (Manages position transfers and trading)

3. 技术实现概览 (Technical Implementation Overview)
   ```solidity
   // Core pool contract interface
   interface IUniswapV3Pool {
       function initialize(uint160 sqrtPriceX96) external;
       function mint(
           address recipient,
           int24 tickLower,
           int24 tickUpper,
           uint128 amount
       ) external returns (uint256 amount0, uint256 amount1);
       function swap(
           address recipient,
           bool zeroForOne,
           int256 amountSpecified,
           uint160 sqrtPriceLimitX96
       ) external returns (int256 amount0, int256 amount1);
   }

   // Factory contract interface
   interface IUniswapV3Factory {
       function createPool(
           address tokenA,
           address tokenB,
           uint24 fee
       ) external returns (address pool);
       function getPool(
           address tokenA,
           address tokenB,
           uint24 fee
       ) external view returns (address pool);
   }
   ```

## 实现要点 (Implementation Highlights)
1. 智能合约架构 (Smart Contract Architecture)
   - 模块化设计 (Modular Design)
     - 核心合约与外围合约分离 (Separation of core and periphery contracts)
     - 清晰的接口定义 (Clear interface definitions)
     - 可升级性考虑 (Upgradeability considerations)

   - 合约间依赖关系 (Contract Dependencies)
     - Factory 部署和管理 Pool (Factory deploys and manages Pools)
     - Manager 和 Quoter 依赖于 Pool (Manager and Quoter depend on Pool)
     - NFTManager 与 Pool 交互 (NFTManager interacts with Pool)

   - 安全性考虑 (Security Considerations)
     - 重入攻击防护 (Reentrancy protection)
     - 溢出检查 (Overflow checks)
     - 权限控制 (Access control)

2. 核心功能 (Core Functions)
   - 流动性管理 (Liquidity Management)
     - 添加和移除流动性 (Add and remove liquidity)
     - 价格范围设置 (Price range setting)
     - 手续费收取 (Fee collection)

   - 交易执行 (Swap Execution)
     - 单跳交易 (Single-hop swaps)
     - 精确输入/输出 (Exact input/output)
     - 价格限制 (Price limits)

   - 价格计算 (Price Calculation)
     - sqrt(x)/sqrt(y) 价格表示 (sqrt(x)/sqrt(y) price representation)
     - tick 计算 (Tick calculations)
     - 滑点保护 (Slippage protection)

3. 开发路线图 (Development Roadmap)
   - 基础功能实现 (Basic Functionality)
     - Pool 合约核心逻辑 (Pool contract core logic)
     - Factory 部署功能 (Factory deployment functionality)
     - 基本交易功能 (Basic swap functionality)

   - 高级特性添加 (Advanced Features)
     - 多池路由 (Multi-pool routing)
     - NFT 功能 (NFT functionality)
     - Oracle 支持 (Oracle support)

   - 优化与测试 (Optimization and Testing)
     - Gas 优化 (Gas optimization)
     - 安全审计 (Security audit)
     - 全面测试覆盖 (Comprehensive test coverage)

## 下一步 (Next Steps)
准备开始第一个里程碑：实现第一笔交易 (Prepare for Milestone 1: Implementing First Swap)
- 理解基本流动性计算 (Understanding basic liquidity calculations)
- 实现简单的交易逻辑 (Implementing simple swap logic)
- 设置初始开发环境 (Setting up initial development environment)
