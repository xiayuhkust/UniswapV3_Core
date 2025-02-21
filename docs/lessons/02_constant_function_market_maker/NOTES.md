# 第二课：恒定函数做市商 (Lesson 2: Constant Function Market Maker)

## 核心概念 (Core Concepts)

### 1. 恒定乘积公式 (Constant Product Formula)
- x * y = k
- x 和 y 是池子中两种代币的储备量
- k 是一个常数，在每次交易后必须保持不变

### 2. 交易机制 (Trading Mechanism)
- 输入代币数量：Δx
- 输出代币数量：Δy
- 交易后新的储备量满足：(x + Δx)(y - Δy) = k

### 3. 价格计算 (Price Calculation)
- 即时价格 (Spot Price)：Px = y/x, Py = x/y
- 实际交易价格受滑点影响
- 交易量越大，滑点越大

### 4. 实现细节 (Implementation Details)
```solidity
// 核心交易公式
function getOutputAmount(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
    internal
    pure
    returns (uint256)
{
    // 计算考虑手续费后的输入金额
    uint256 amountInWithFee = amountIn.mul(997);
    // 计算输出金额
    uint256 numerator = amountInWithFee.mul(reserveOut);
    uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
    return numerator.div(denominator);
}
```

## 测试要点 (Testing Focus)
1. 基本交易功能验证
2. 储备金更新验证
3. 边界条件测试
4. 手续费计算验证

## 关键收获 (Key Takeaways)
1. CFMM通过简单的数学公式实现了自动做市
2. 价格由储备金比例自动决定
3. 大额交易会导致显著的价格影响
4. 手续费机制确保了做市商的收益

## 下一步 (Next Steps)
进入第三课：Uniswap V3的改进
- 集中流动性概念
- 价格区间管理
- 多费率层级
