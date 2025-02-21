# 第四课：开发环境搭建 (Lesson 4: Development Environment)

## 项目概述 (Project Overview)
1. 两个应用组件 (Two Application Components)
   - 链上应用：部署在以太坊的智能合约 (On-chain: Smart contracts deployed on Ethereum)
   - 链下应用：与智能合约交互的前端应用 (Off-chain: Frontend application for contract interaction)

## 开发工具 (Development Tools)
1. Foundry
   - 安装命令 (Installation)
     ```bash
     curl -L https://foundry.paradigm.xyz | bash
     foundryup
     ```
   - 主要组件 (Main Components)
     * Forge: 合约测试框架 (Contract testing framework)
     * Cast: 与以太坊交互的命令行工具 (CLI for Ethereum interaction)
     * Anvil: 本地以太坊节点 (Local Ethereum node)

2. 以太坊基础 (Ethereum Basics)
   - 账户状态 (Account State)
     * 余额 (Balance)
     * 代码 (Code)
     * 存储 (Storage)
     * Nonce

   - 网络特点 (Network Characteristics)
     * 去中心化访问 (Decentralized access)
     * 共识机制 (Consensus mechanism)
     * 部署成本 (Deployment costs)

## 开发流程 (Development Process)
1. 合约开发 (Contract Development)
   - 使用Solidity (Using Solidity)
   - 本地测试 (Local testing)
   - 部署验证 (Deployment verification)

2. 前端开发 (Frontend Development)
   - React应用 (React application)
   - Web3集成 (Web3 integration)
   - MetaMask连接 (MetaMask connection)

## 注意事项 (Important Notes)
1. 合约特性 (Contract Characteristics)
   - 不可变性 (Immutability)
   - Gas费用 (Gas fees)
   - 安全考虑 (Security considerations)

2. 开发建议 (Development Tips)
   - 本地测试优先 (Prioritize local testing)
   - 代码审计重要性 (Code audit importance)
   - 文档完整性 (Documentation completeness)

## 下一步 (Next Steps)
1. 开始实现基础功能 (Start implementing basic features)
2. 编写测试用例 (Write test cases)
3. 构建前端界面 (Build frontend interface)
