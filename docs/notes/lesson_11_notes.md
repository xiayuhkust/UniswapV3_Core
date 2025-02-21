# Lesson 11: Deployment - Learning Notes

## Core Concepts (核心概念)

### Local Blockchain Requirements (本地区块链要求)
1. Real Blockchain (真实区块链)
   - Must be real Ethereum network (必须是真实的以太坊网络)
   - Not an emulation (非模拟环境)
   - Ensures mainnet compatibility (确保主网兼容性)

2. Development Features (开发功能)
   - Fast transaction mining (快速交易挖矿)
   - Ether generation capability (以太币生成能力)
   - Advanced debugging features (高级调试功能)

### Development Network Options (开发网络选项)
1. Ganache (Truffle Suite)
   - Traditional solution (传统解决方案)
   - JavaScript-based testing (基于JavaScript的测试)

2. Hardhat
   - Modern development environment (现代开发环境)
   - Widely adopted (广泛采用)
   - JavaScript ecosystem (JavaScript生态系统)

3. Anvil (Foundry)
   - Latest solution (最新解决方案)
   - Solidity-based testing (基于Solidity的测试)
   - Native deployment scripts (原生部署脚本)

## Technical Implementation Details (技术实现细节)

### Deployment Process (部署流程)
```solidity
// Deployment Script Structure (部署脚本结构)
contract DeployDevelopment is Script {
    function run() public {
        // 1. Define deployment parameters (定义部署参数)
        uint256 wethBalance = 1 ether;
        uint256 usdcBalance = 5042 ether;
        
        // 2. Deploy contracts (部署合约)
        vm.startBroadcast();
        // Deploy tokens, pool, manager
        vm.stopBroadcast();
    }
}
```

### Contract Interaction Methods (合约交互方法)
1. Low-level JSON-RPC (底层JSON-RPC)
   ```bash
   # Function selector calculation (函数选择器计算)
   cast keccak "balanceOf(address)"
   
   # Contract call (合约调用)
   curl -X POST -H 'Content-Type: application/json' \
   --data '{"method":"eth_call",...}'
   ```

2. Cast Tool Usage (Cast工具使用)
   ```bash
   # Balance check (余额检查)
   cast balance ADDRESS
   
   # Contract call (合约调用)
   cast call ADDRESS "function()"
   ```

## Test Coverage (测试覆盖)

### Deployment Testing (部署测试)
1. Contract Creation (合约创建)
   - Verify bytecode deployment (验证字节码部署)
   - Check constructor parameters (检查构造函数参数)
   - Validate initial state (验证初始状态)

2. Integration Testing (集成测试)
   - Token minting verification (代币铸造验证)
   - Pool initialization check (池初始化检查)
   - Manager contract setup (管理合约设置)

### Network Interaction Testing (网络交互测试)
1. JSON-RPC Calls (JSON-RPC调用)
   - Function selector validation (函数选择器验证)
   - Parameter encoding check (参数编码检查)
   - Return value decoding (返回值解码)

2. Cast Tool Commands (Cast工具命令)
   - Balance queries (余额查询)
   - Contract state reads (合约状态读取)
   - Transaction sending (交易发送)

## Next Steps (下一步)
- Implement user interface (实现用户界面)
- Test contract interactions (测试合约交互)
- Document deployment process (记录部署流程)

## Environment Prerequisites (环境先决条件)
- Foundry toolkit installed (安装Foundry工具包)
- Anvil for local blockchain (使用Anvil作为本地区块链)
- Solidity ^0.8.14 (使用Solidity ^0.8.14)
