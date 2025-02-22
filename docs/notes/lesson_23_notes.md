# Lesson 23: Cross-Tick Swaps - Learning Notes

## Core Concepts (核心概念)

### Cross-Tick Swapping (跨刻度交换)
- Multiple price range support (多价格范围支持)
- Dynamic liquidity tracking (动态流动性跟踪)
- Price range transitions (价格范围转换)

### Liquidity Management (流动性管理)
1. Active Range (活动范围)
   - Current price inclusion (包含当前价格)
   - Immediate liquidity availability (即时流动性可用性)
   - Range boundary handling (范围边界处理)

2. Range Transitions (范围转换)
   - Liquidity deactivation (流动性停用)
   - Next range activation (下一范围激活)
   - Boundary price calculation (边界价格计算)

## Technical Implementation Details (技术实现细节)

### Swap Step Computation (交换步骤计算)
```solidity
function computeSwapStep(
    uint160 sqrtPriceCurrentX96,
    uint160 sqrtPriceTargetX96,
    uint128 liquidity,
    int256 amountRemaining,
    uint24 fee
) internal pure returns (
    uint160 sqrtPriceNextX96,
    uint256 amountIn,
    uint256 amountOut
) {
    // Calculate input amount (计算输入金额)
    amountIn = zeroForOne
        ? Math.calcAmount0Delta(
            sqrtPriceCurrentX96,
            sqrtPriceTargetX96,
            liquidity
        )
        : Math.calcAmount1Delta(
            sqrtPriceCurrentX96,
            sqrtPriceTargetX96,
            liquidity
        );

    // Determine next price (确定下一个价格)
    if (amountRemaining >= amountIn)
        sqrtPriceNextX96 = sqrtPriceTargetX96;
    else
        sqrtPriceNextX96 = Math.getNextSqrtPriceFromInput(
            sqrtPriceCurrentX96,
            liquidity,
            amountRemaining,
            zeroForOne
        );

    // Calculate final amounts (计算最终金额)
    amountIn = Math.calcAmount0Delta(
        sqrtPriceCurrentX96,
        sqrtPriceNextX96,
        liquidity
    );
    amountOut = Math.calcAmount1Delta(
        sqrtPriceCurrentX96,
        sqrtPriceNextX96,
        liquidity
    );
}
```

### Tick Management (刻度管理)
```solidity
struct Info {
    bool initialized;
    uint128 liquidityGross;  // Total liquidity (总流动性)
    int128 liquidityNet;     // Net liquidity change (净流动性变化)
}

function cross(
    mapping(int24 => Info) storage self,
    int24 tick
) internal view returns (int128 liquidityDelta) {
    Info storage info = self[tick];
    liquidityDelta = info.liquidityNet;
}
```

## Test Coverage (测试覆盖)

### Test Scenarios (测试场景)
1. Single Price Range (单一价格范围)
   - Within range swaps (范围内交换)
   - Boundary testing (边界测试)
   - Liquidity verification (流动性验证)

2. Multiple Price Ranges (多个价格范围)
   - Consecutive ranges (连续范围)
   - Overlapping ranges (重叠范围)
   - Partial overlaps (部分重叠)

### Test Cases (测试用例)
```solidity
function testBuyETHConsecutivePriceRanges() public {
    // Setup ranges (设置范围)
    LiquidityRange[] memory liquidity = new LiquidityRange[](2);
    liquidity[0] = liquidityRange(4545, 5500, 1 ether, 5000 ether, 5000);
    liquidity[1] = liquidityRange(5500, 6250, 1 ether, 5000 ether, 5000);

    // Expected results (预期结果)
    assertSwapState(
        ExpectedStateAfterSwap({
            sqrtPriceX96: 6190476002219365604851182401841,
            tick: 87173,
            currentLiquidity: liquidity[1].amount
        })
    );
}
```

## Next Steps (下一步)
- Implement slippage protection (实现滑点保护)
- Add liquidity calculation (添加流动性计算)
- Enhance fixed-point number handling (增强定点数处理)

## Environment Prerequisites (环境先决条件)
- Solidity ^0.8.14 (使用Solidity ^0.8.14)
- UniswapV3Pool contract (UniswapV3Pool合约)
- Test environment setup (测试环境设置)
