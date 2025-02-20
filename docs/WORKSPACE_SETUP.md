# Workspace Setup Guide / 工作空间设置指南

## Install Dependencies / 安装依赖
```bash
# Install core dependencies / 安装核心依赖
yarn install

# Install specific versions / 安装指定版本
yarn add --dev hardhat@2.8.0 @nomiclabs/hardhat-ethers@2.0.0 ethers@5.4.7
yarn add --dev typescript ts-node @types/node
yarn add --dev chai @types/chai
yarn add --dev @nomiclabs/hardhat-waffle@2.0.0 ethereum-waffle@3.2.0
```

## Setup Lint / 设置代码检查
```bash
# Install ESLint and Prettier / 安装 ESLint 和 Prettier
yarn add --dev eslint prettier @typescript-eslint/parser @typescript-eslint/eslint-plugin eslint-config-prettier

# Run linting / 运行代码检查
yarn lint
```

## Setup Tests / 设置测试
```bash
# Run all tests / 运行所有测试
npx hardhat test

# Run specific test file / 运行指定测试文件
npx hardhat test test/specific-test.ts
```

## Setup Local App / 设置本地应用
```bash
# Compile contracts / 编译合约
npx hardhat compile

# Run local node / 运行本地节点
npx hardhat node

# Deploy contracts to local network / 部署合约到本地网络
npx hardhat run scripts/deploy.ts --network localhost
```

## Additional Notes / 补充说明

### Environment Variables / 环境变量
Create a `.env` file with the following content / 创建包含以下内容的 `.env` 文件:
```
TURA_RPC_URL=http://43.135.26.222:8000
TURA_CHAIN_ID=1337
```

### Network Configuration / 网络配置
The project is configured to work with Tura blockchain / 项目配置为使用 Tura 区块链:
- Chain ID: 1337
- RPC URL: http://43.135.26.222:8000

### Development Tools / 开发工具
- Node.js version: >=14.0.0
- Yarn version: >=1.22.0
- Hardhat version: 2.8.0
- TypeScript version: >=4.5.0

### Important Commands / 重要命令
```bash
# Build project / 构建项目
yarn build

# Run tests / 运行测试
yarn test

# Deploy contracts / 部署合约
yarn deploy

# Verify contracts / 验证合约
yarn verify
```
