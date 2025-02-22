# Lesson 30: Factory Contract - Learning Notes

## Core Concepts (核心概念)

### Factory Contract Purpose (工厂合约目的)
1. Pool Registry (池注册)
   - Centralized pool tracking (集中池跟踪)
   - Token pair management (代币对管理)
   - Address lookup (地址查找)

2. Pool Deployment (池部署)
   - CREATE2 usage (使用CREATE2)
   - Deterministic addresses (确定性地址)
   - Parameter validation (参数验证)

### Tick Spacing (刻度间距)
- Gas efficiency (燃气效率)
- Price precision (价格精度)
- Pool customization (池自定义)

## Technical Implementation Details (技术实现细节)

### Factory Contract (工厂合约)
```solidity
contract UniswapV3Factory is IUniswapV3PoolDeployer {
    // State variables (状态变量)
    mapping(uint24 => bool) public tickSpacings;
    mapping(address => mapping(address => mapping(uint24 => address)))
        public pools;
    PoolParameters public parameters;

    // Constructor (构造函数)
    constructor() {
        tickSpacings[10] = true;  // For stablecoin pairs (稳定币对)
        tickSpacings[60] = true;  // For regular pairs (常规对)
    }

    // Pool creation (池创建)
    function createPool(
        address tokenX,
        address tokenY,
        uint24 tickSpacing
    ) public returns (address pool) {
        // Token validation (代币验证)
        if (tokenX == tokenY) revert TokensMustBeDifferent();
        if (!tickSpacings[tickSpacing]) revert UnsupportedTickSpacing();

        // Sort tokens (排序代币)
        (tokenX, tokenY) = tokenX < tokenY
            ? (tokenX, tokenY)
            : (tokenY, tokenX);

        // Additional checks (额外检查)
        if (tokenX == address(0)) revert TokenXCannotBeZero();
        if (pools[tokenX][tokenY][tickSpacing] != address(0))
            revert PoolAlreadyExists();

        // Set parameters (设置参数)
        parameters = PoolParameters({
            factory: address(this),
            token0: tokenX,
            token1: tokenY,
            tickSpacing: tickSpacing
        });

        // Deploy pool (部署池)
        pool = address(
            new UniswapV3Pool{
                salt: keccak256(
                    abi.encodePacked(tokenX, tokenY, tickSpacing)
                )
            }()
        );

        // Cleanup and registration (清理和注册)
        delete parameters;
        pools[tokenX][tokenY][tickSpacing] = pool;
        pools[tokenY][tokenX][tickSpacing] = pool;

        emit PoolCreated(tokenX, tokenY, tickSpacing, pool);
    }
}
```

### Pool Address Library (池地址库)
```solidity
library PoolAddress {
    function computeAddress(
        address factory,
        address token0,
        address token1,
        uint24 tickSpacing
    ) internal pure returns (address pool) {
        // Validate token order (验证代币顺序)
        require(token0 < token1);

        // Compute address (计算地址)
        pool = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(
                                abi.encodePacked(
                                    token0,
                                    token1,
                                    tickSpacing
                                )
                            ),
                            keccak256(type(UniswapV3Pool).creationCode)
                        )
                    )
                )
            )
        );
    }
}
```

## Test Coverage (测试覆盖)

### Test Cases (测试用例)
1. Pool Creation (池创建)
   - Valid parameters (有效参数)
   - Invalid parameters (无效参数)
   - Duplicate creation (重复创建)

2. Address Computation (地址计算)
   - Different token pairs (不同代币对)
   - Different tick spacings (不同刻度间距)
   - Address uniqueness (地址唯一性)

### Test Setup (测试设置)
```solidity
// Test parameters (测试参数)
address token0 = address(new ERC20Mock());
address token1 = address(new ERC20Mock());
uint24 tickSpacing = 60;

// Expected results (预期结果)
address expectedPool;
bool poolExists;
```

## Next Steps (下一步)
- Implement swap path (实现交换路径)
- Add multi-pool swaps (添加多池交换)
- Update user interface (更新用户界面)

## Environment Prerequisites (环境先决条件)
- Solidity ^0.8.14 (使用Solidity ^0.8.14)
- UniswapV3Pool contract (UniswapV3Pool合约)
- Test environment setup (测试环境设置)
