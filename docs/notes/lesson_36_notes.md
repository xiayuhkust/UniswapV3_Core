# Lesson 36: Swap Fees - Learning Notes

## Core Concepts (核心概念)

### Fee Collection (费用收集)
1. Mechanism (机制)
   - Fee per swap (每次交换的费用)
   - Global fee tracking (全局费用跟踪)
   - Per-liquidity distribution (按流动性分配)

2. Fee Growth (费用增长)
   - Global accumulators (全局累加器)
   - Per-tick tracking (每刻度跟踪)
   - Position-specific calculation (头寸特定计算)

### Fee Distribution (费用分配)
1. Price Range Engagement (价格范围参与)
   - Left-to-right crossing (从左向右穿越)
   - Right-to-left crossing (从右向左穿越)
   - Range activation/deactivation (范围激活/停用)

2. Fee Calculation (费用计算)
   - Outside fees tracking (外部费用跟踪)
   - Inside fees calculation (内部费用计算)
   - Token amount conversion (代币金额转换)

## Technical Implementation Details (技术实现细节)

### Factory Contract Updates (工厂合约更新)
```solidity
contract UniswapV3Factory {
    // Fee configuration (费用配置)
    mapping(uint24 => uint24) public fees;

    constructor() {
        fees[500] = 10;   // 0.05% fee
        fees[3000] = 60;  // 0.3% fee
    }

    function createPool(
        address tokenX,
        address tokenY,
        uint24 fee
    ) public returns (address pool) {
        // Pool creation with fee (带费用的池创建)
        parameters = PoolParameters({
            factory: address(this),
            token0: tokenX,
            token1: tokenY,
            tickSpacing: fees[fee],
            fee: fee
        });
    }
}
```

### Pool Contract Updates (池合约更新)
```solidity
contract UniswapV3Pool {
    // Fee state variables (费用状态变量)
    uint24 public immutable fee;
    uint256 public feeGrowthGlobal0X128;
    uint256 public feeGrowthGlobal1X128;

    // Fee calculation in swap (交换中的费用计算)
    function _calculateSwapFee(
        int256 amountIn
    ) internal view returns (uint256) {
        return PRBMath.mulDiv(
            uint256(amountIn),
            fee,
            1e6
        );
    }

    // Fee growth update (费用增长更新)
    function _updateFeeGrowthGlobal(
        uint256 feeAmount,
        uint128 liquidity,
        bool zeroForOne
    ) internal {
        if (zeroForOne) {
            feeGrowthGlobal0X128 += PRBMath.mulDiv(
                feeAmount,
                FixedPoint128.Q128,
                liquidity
            );
        } else {
            feeGrowthGlobal1X128 += PRBMath.mulDiv(
                feeAmount,
                FixedPoint128.Q128,
                liquidity
            );
        }
    }
}
```

### Position Fee Management (头寸费用管理)
```solidity
library Position {
    struct Info {
        uint128 liquidity;
        uint256 feeGrowthInside0LastX128;
        uint256 feeGrowthInside1LastX128;
        uint128 tokensOwed0;
        uint128 tokensOwed1;
    }

    function update(
        Info storage self,
        int128 liquidityDelta,
        uint256 feeGrowthInside0X128,
        uint256 feeGrowthInside1X128
    ) internal {
        // Calculate fee tokens (计算费用代币)
        uint128 tokensOwed0 = uint128(
            PRBMath.mulDiv(
                feeGrowthInside0X128 - self.feeGrowthInside0LastX128,
                self.liquidity,
                FixedPoint128.Q128
            )
        );

        uint128 tokensOwed1 = uint128(
            PRBMath.mulDiv(
                feeGrowthInside1X128 - self.feeGrowthInside1LastX128,
                self.liquidity,
                FixedPoint128.Q128
            )
        );

        // Update state (更新状态)
        self.liquidity = LiquidityMath.addLiquidity(
            self.liquidity,
            liquidityDelta
        );
        self.feeGrowthInside0LastX128 = feeGrowthInside0X128;
        self.feeGrowthInside1LastX128 = feeGrowthInside1X128;
        
        if (tokensOwed0 > 0 || tokensOwed1 > 0) {
            self.tokensOwed0 += tokensOwed0;
            self.tokensOwed1 += tokensOwed1;
        }
    }
}
```

### Burn and Collect Implementation (销毁和收集实现)
```solidity
contract UniswapV3Pool {
    function burn(
        int24 lowerTick,
        int24 upperTick,
        uint128 amount
    ) public returns (uint256 amount0, uint256 amount1) {
        // Burn liquidity (销毁流动性)
        (
            Position.Info storage position,
            int256 amount0Int,
            int256 amount1Int
        ) = _modifyPosition(
            ModifyPositionParams({
                owner: msg.sender,
                lowerTick: lowerTick,
                upperTick: upperTick,
                liquidityDelta: -(int128(amount))
            })
        );

        // Update owed tokens (更新欠款代币)
        amount0 = uint256(-amount0Int);
        amount1 = uint256(-amount1Int);

        if (amount0 > 0 || amount1 > 0) {
            position.tokensOwed0 += uint128(amount0);
            position.tokensOwed1 += uint128(amount1);
        }
    }

    function collect(
        address recipient,
        int24 lowerTick,
        int24 upperTick,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) public returns (uint128 amount0, uint128 amount1) {
        // Get position (获取头寸)
        Position.Info storage position = positions.get(
            msg.sender,
            lowerTick,
            upperTick
        );

        // Calculate amounts (计算金额)
        amount0 = amount0Requested > position.tokensOwed0
            ? position.tokensOwed0
            : amount0Requested;
        amount1 = amount1Requested > position.tokensOwed1
            ? position.tokensOwed1
            : amount1Requested;

        // Transfer tokens (转账代币)
        if (amount0 > 0) {
            position.tokensOwed0 -= amount0;
            IERC20(token0).transfer(recipient, amount0);
        }
        if (amount1 > 0) {
            position.tokensOwed1 -= amount1;
            IERC20(token1).transfer(recipient, amount1);
        }
    }
}
```

## Test Coverage (测试覆盖)

### Test Cases (测试用例)
1. Fee Collection (费用收集)
   ```solidity
   function testFeeCollection() public {
       // Setup pool with fee (设置带费用的池)
       uint24 fee = 3000;  // 0.3%
       uint256 amount = 1 ether;
       
       // Execute swap (执行交换)
       pool.swap(...);

       // Verify fee growth (验证费用增长)
       assertGt(pool.feeGrowthGlobal0X128(), 0);
   }
   ```

2. Fee Distribution (费用分配)
   ```solidity
   function testFeeDistribution() public {
       // Add liquidity (添加流动性)
       pool.mint(...);

       // Execute swaps (执行交换)
       pool.swap(...);

       // Burn and collect (销毁和收集)
       pool.burn(...);
       (uint128 amount0, uint128 amount1) = pool.collect(...);

       // Verify collected fees (验证收集的费用)
       assertGt(amount0, 0);
   }
   ```

### Test Setup (测试设置)
```solidity
// Test parameters (测试参数)
uint24 constant FEE = 3000;  // 0.3%
uint128 constant LIQUIDITY = 1000000;
uint256 constant SWAP_AMOUNT = 1 ether;

// Expected results (预期结果)
uint256 expectedFee;
uint256 collectedAmount;
```

## Next Steps (下一步)
- Implement flash loan fees (实现闪电贷费用)
- Add protocol fees (添加协议费用)
- Develop price oracle (开发价格预言机)

## Environment Prerequisites (环境先决条件)
- Solidity ^0.8.14 (使用Solidity ^0.8.14)
- UniswapV3Pool contract (UniswapV3Pool合约)
- PRBMath library (PRBMath库)
