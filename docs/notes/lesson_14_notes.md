# Lesson 14: Output Amount Calculation - Learning Notes

## Core Concepts (核心概念)

### Price Change Formula (价格变化公式)
- Token y selling formula (代币y卖出公式): ΔP = Δy/L
- Token x selling formula (代币x卖出公式): Δx = L/ΔP

### Target Price Calculation (目标价格计算)
1. For Token y (代币y)
   ```
   √Ptarget = √Pcurrent + Δ√P
   ```

2. For Token x (代币x)
   ```
   √Ptarget = (√P·L)/(Δx·√P + L)
   ```

### Amount Calculation Process (金额计算过程)
1. Input Amount Known (已知输入金额)
   - Calculate target price (计算目标价格)
   - Determine output amount (确定输出金额)

2. Price Impact (价格影响)
   - Larger trades = higher impact (交易量越大，影响越大)
   - Liquidity affects impact (流动性影响价格变化)

## Technical Implementation Details (技术实现细节)

### Python Implementation (Python实现)
```python
# Calculate new price (计算新价格)
price_next = int((liq * q96 * sqrtp_cur) // 
                 (liq * q96 + amount_in * sqrtp_cur))

# Calculate amounts (计算金额)
amount_in = calc_amount0(liq, price_next, sqrtp_cur)
amount_out = calc_amount1(liq, price_next, sqrtp_cur)
```

### Key Functions (关键函数)
```solidity
// Amount calculation functions (金额计算函数)
function calcAmount0(
    uint128 liquidity,
    uint160 sqrtPriceNext,
    uint160 sqrtPriceCurrent
) internal pure returns (int256) {
    // Implementation in next lesson
}

function calcAmount1(
    uint128 liquidity,
    uint160 sqrtPriceNext,
    uint160 sqrtPriceCurrent
) internal pure returns (int256) {
    // Implementation in next lesson
}
```

### Formula Derivation (公式推导)
1. Starting from Δx equation (从Δx方程开始)
   ```
   Δx = (1/√Ptarget - 1/√Pcurrent)·L
   ```

2. Algebraic transformation (代数变换)
   ```
   Δx·√Ptarget + L·√Ptarget = L·√Pcurrent
   √Ptarget = (√P·L)/(Δx·√P + L)
   ```

## Test Coverage (测试覆盖)

### Test Cases (测试用例)
1. Basic Swaps (基本交换)
   - Small amount swaps (小额交换)
   - Large amount swaps (大额交换)
   - Edge case amounts (边界情况)

2. Price Impact Tests (价格影响测试)
   - Verify expected price changes (验证预期价格变化)
   - Check amount calculations (检查金额计算)
   - Validate formula accuracy (验证公式准确性)

### Test Setup (测试设置)
```python
# Test parameters (测试参数)
eth = 10**18
amount_in = 0.01337 * eth
liquidity = 1517882343751509868544  # Initial liquidity

# Expected results (预期结果)
expected_price = 4993.777388290041
expected_usdc_out = 66.80838889019013
```

## Next Steps (下一步)
- Implement math calculations in Solidity (在Solidity中实现数学计算)
- Add fixed-point arithmetic support (添加定点算术支持)
- Integrate with swap function (与交换函数集成)

## Environment Prerequisites (环境先决条件)
- Python for prototyping (用于原型设计的Python)
- Solidity ^0.8.14 (使用Solidity ^0.8.14)
- Fixed-point math libraries (定点数学库)
