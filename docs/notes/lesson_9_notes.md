# Lesson 9: First Swap - Learning Notes

## Core Concepts (核心概念)

### Swap Calculation Basics (交换计算基础)
- Uses liquidity (L) and square root price (√P) for calculations (使用流动性和价格平方根进行计算)
- Price changes while liquidity remains constant within range (在范围内价格变化而流动性保持不变)
- Target price approach instead of pool reserves (使用目标价格而不是池储备)

### Key Formulas (关键公式)
```
L = Δy/Δ√P   # Liquidity formula (流动性公式)
Δ√P = Δy/L   # Price change formula (价格变化公式)
Δx = -L·Δ(1/√P)   # Token amount calculation (代币数量计算)
```

### Price Movement (价格变动)
- Swaps move price along the curve (交换沿曲线移动价格)
- Target price determines input/output amounts (目标价格决定输入/输出数量)
- Price movement confined to current tick range (价格移动限制在当前刻度范围内)

## Technical Implementation Details (技术实现细节)

### Swap Function Structure (交换函数结构)
```solidity
function swap(
    address recipient
) public returns (int256 amount0, int256 amount1) {
    // Calculate target price and amounts
    // Update pool state
    // Transfer tokens
    // Verify balances
    // Emit event
}
```

### State Updates (状态更新)
1. Current tick (当前刻度)
2. Square root price (价格平方根)
3. Token balances (代币余额)

### Callback Mechanism (回调机制)
- Caller must implement IUniswapV3SwapCallback (调用者必须实现回调接口)
- Verifies sufficient input amount (验证输入金额充足)
- Handles token transfers (处理代币转账)

## Test Coverage (测试覆盖)

### Test Cases (测试用例)
1. Successful ETH Purchase (成功购买ETH)
   - Correct amount calculations (正确的数量计算)
   - Proper token transfers (正确的代币转账)
   - State updates verification (状态更新验证)

2. Input Amount Validation (输入金额验证)
   - InsufficientInputAmount error case (输入金额不足错误情况)
   - Balance verification (余额验证)

### Test Setup Requirements (测试设置要求)
- Initial liquidity provision (初始流动性提供)
- Token minting for testing (代币铸造用于测试)
- Callback implementation (回调实现)

## Next Steps (下一步)
- Implement Manager Contract (实现管理器合约)
- Add deployment functionality (添加部署功能)
- Develop user interface (开发用户界面)

## Environment Prerequisites (环境先决条件)
- Solidity ^0.8.14 (使用Solidity ^0.8.14)
- Hardhat/Forge testing framework (Hardhat/Forge测试框架)
- ERC20 token contracts (ERC20代币合约)
