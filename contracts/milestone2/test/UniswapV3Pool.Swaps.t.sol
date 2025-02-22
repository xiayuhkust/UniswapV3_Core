// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "./UniswapV3Pool.Utils.t.sol";
import "./TestUniswapV3Pool.sol";
import "./MockToken.sol";
import "../interfaces/IUniswapV3SwapCallback.sol";
import "../contracts/libraries/TickMath.sol";
import "../contracts/libraries/LiquidityMath.sol";

contract UniswapV3PoolSwapsTest is Test, IUniswapV3SwapCallback, UniswapV3PoolUtils {
    struct PoolParams {
        uint256[2] balances;
        uint256 currentPrice;
        LiquidityRange[] liquidity;
        bool transferInMintCallback;
        bool transferInSwapCallback;
        bool mintLiquidity;
    }

    // Moved to Utils

    TestUniswapV3Pool pool;
    MockToken token0;
    MockToken token1;
    bool transferInMintCallback = true;
    bool transferInSwapCallback = true;
    bool mintLiquidity = true;
    bytes extra;

    function setUp() public {
        token0 = new MockToken("Token0", "TK0", 18);
        token1 = new MockToken("Token1", "TK1", 18);

        pool = new TestUniswapV3Pool(
            address(token0),
            address(token1),
            uint24(3000), // 0.3% fee
            int24(60)
        );

        extra = encodeExtra(address(token0), address(token1), address(this));
    }

    function testBuyETHOnePriceRange() public {
        LiquidityRange memory range = liquidityRange(
            4560,
            5520,
            1 ether,
            1 ether,
            5000 ether
        );

        uint256[2] memory balances = [uint256(1 ether), uint256(5000 ether)];
        (
            LiquidityRange[] memory liquidity,
            uint256 poolBalance0,
            uint256 poolBalance1
        ) = setupPool(
                PoolParams({
                    balances: balances,
                    currentPrice: 5000,
                    liquidity: liquidityRanges(range),
                    transferInMintCallback: true,
                    transferInSwapCallback: true,
                    mintLiquidity: true
                })
            );

        // Perform swap
        bool zeroForOne = true;
        int256 amountSpecified = int256(0.01 ether);
        (uint160 sqrtPriceX96,,,,) = pool.slot0();
        uint160 sqrtPriceLimitX96 = sqrtPriceX96 - uint160(100);

        (int256 amount0Delta, int256 amount1Delta) = pool.swap(
            address(this),
            zeroForOne,
            amountSpecified,
            sqrtPriceLimitX96,
            ""
        );

        assertEq(amount0Delta, 0.01 ether, "Incorrect amount0 delta");
        assertTrue(amount1Delta < 0, "Amount1 delta should be negative");
        assertTrue(
            uint256(-amount1Delta) < poolBalance1,
            "Not enough tokens received"
        );
    }

    function testSwapTwoEqualPriceRanges() public {
        LiquidityRange[] memory liquidity = new LiquidityRange[](2);
        liquidity[0] = LiquidityRange({
            lowerTick: 4560,
            upperTick: 5520,
            amount: 1 ether,
            amount0: 1 ether,
            amount1: 5000 ether
        });
        liquidity[1] = LiquidityRange({
            lowerTick: 4560,
            upperTick: 5520,
            amount: 1 ether,
            amount0: 1 ether,
            amount1: 5000 ether
        });

        uint256[2] memory balances;
        balances[0] = 2 ether;
        balances[1] = 10000 ether;

        PoolParams memory params = PoolParams({
            balances: balances,
            currentPrice: 5000,
            liquidity: liquidity,
            transferInMintCallback: true,
            transferInSwapCallback: true,
            mintLiquidity: true
        });

        setupPool(params);

        // Perform swap
        bool zeroForOne = true;
        int256 amountSpecified = int256(0.1 ether);
        (uint160 sqrtPriceX96,,,,) = pool.slot0();
        uint160 sqrtPriceLimitX96 = sqrtPriceX96 - uint160(100);

        (int256 amount0Delta, int256 amount1Delta) = pool.swap(
            address(this),
            zeroForOne,
            amountSpecified,
            sqrtPriceLimitX96,
            ""
        );

        assertEq(amount0Delta, 0.1 ether, "Incorrect amount0 delta");
        assertTrue(amount1Delta < 0, "Amount1 delta should be negative");
    }

    function testSwapConsecutivePriceRanges() public {
        LiquidityRange[] memory liquidity = new LiquidityRange[](2);
        liquidity[0] = LiquidityRange({
            lowerTick: 4560,
            upperTick: 5040,
            amount: 1 ether,
            amount0: 1 ether,
            amount1: 5000 ether
        });
        liquidity[1] = LiquidityRange({
            lowerTick: 5040,
            upperTick: 5520,
            amount: 1 ether,
            amount0: 1 ether,
            amount1: 5000 ether
        });

        uint256[2] memory balances;
        balances[0] = 2 ether;
        balances[1] = 10000 ether;

        PoolParams memory params = PoolParams({
            balances: balances,
            currentPrice: 5000,
            liquidity: liquidity,
            transferInMintCallback: true,
            transferInSwapCallback: true,
            mintLiquidity: true
        });

        setupPool(params);

        // Perform swap
        bool zeroForOne = true;
        int256 amountSpecified = int256(0.2 ether);
        (uint160 sqrtPriceX96,,,,) = pool.slot0();
        uint160 sqrtPriceLimitX96 = sqrtPriceX96 - uint160(100);

        (int256 amount0Delta, int256 amount1Delta) = pool.swap(
            address(this),
            zeroForOne,
            amountSpecified,
            sqrtPriceLimitX96,
            ""
        );

        assertEq(amount0Delta, 0.2 ether, "Incorrect amount0 delta");
        assertTrue(amount1Delta < 0, "Amount1 delta should be negative");
    }

    function testSwapPartiallyOverlappingPriceRanges() public {
        LiquidityRange[] memory liquidity = new LiquidityRange[](2);
        liquidity[0] = LiquidityRange({
            lowerTick: 4560,
            upperTick: 5160,
            amount: 1 ether,
            amount0: 1 ether,
            amount1: 5000 ether
        });
        liquidity[1] = LiquidityRange({
            lowerTick: 4920,
            upperTick: 5520,
            amount: 1 ether,
            amount0: 1 ether,
            amount1: 5000 ether
        });

        uint256[2] memory balances;
        balances[0] = 2 ether;
        balances[1] = 10000 ether;

        PoolParams memory params = PoolParams({
            balances: balances,
            currentPrice: 5000,
            liquidity: liquidity,
            transferInMintCallback: true,
            transferInSwapCallback: true,
            mintLiquidity: true
        });

        setupPool(params);

        // Perform swap
        bool zeroForOne = true;
        int256 amountSpecified = int256(0.2 ether);
        (uint160 sqrtPriceX96,,,,) = pool.slot0();
        uint160 sqrtPriceLimitX96 = sqrtPriceX96 - uint160(100);

        (int256 amount0Delta, int256 amount1Delta) = pool.swap(
            address(this),
            zeroForOne,
            amountSpecified,
            sqrtPriceLimitX96,
            ""
        );

        assertEq(amount0Delta, 0.2 ether, "Incorrect amount0 delta");
        assertTrue(amount1Delta < 0, "Amount1 delta should be negative");
    }

    function testSwapSlippageProtection() public {
        LiquidityRange[] memory liquidity = new LiquidityRange[](1);
        liquidity[0] = LiquidityRange({
            lowerTick: 4560,
            upperTick: 5520,
            amount: 1 ether,
            amount0: 1 ether,
            amount1: 5000 ether
        });

        uint256[2] memory balances;
        balances[0] = 1 ether;
        balances[1] = 5000 ether;

        PoolParams memory params = PoolParams({
            balances: balances,
            currentPrice: 5000,
            liquidity: liquidity,
            transferInMintCallback: true,
            transferInSwapCallback: true,
            mintLiquidity: true
        });

        setupPool(params);

        // Try to swap with a price limit that would result in too much slippage
        bool zeroForOne = true;
        int256 amountSpecified = int256(0.01 ether);
        uint160 sqrtPriceLimitX96 = TickMath.getSqrtRatioAtTick(5000); // Price limit too high

        vm.expectRevert("Price limit reached");
        pool.swap(
            address(this),
            zeroForOne,
            amountSpecified,
            sqrtPriceLimitX96,
            ""
        );
    }

    function setupPool(PoolParams memory params)
        internal
        returns (
            LiquidityRange[] memory liquidity,
            uint256 poolBalance0,
            uint256 poolBalance1
        )
    {
        token0.mint(address(this), params.balances[0]);
        token1.mint(address(this), params.balances[1]);

        pool.initialize(
            TickMath.getSqrtRatioAtTick(
                int24(log2(params.currentPrice) * 100)
            )
        );

        if (params.mintLiquidity) {
            token0.approve(address(pool), params.balances[0]);
            token1.approve(address(pool), params.balances[1]);

            for (uint256 i = 0; i < params.liquidity.length; i++) {
                (uint256 balance0, uint256 balance1) = pool.mint(
                    address(this),
                    params.liquidity[i].lowerTick,
                    params.liquidity[i].upperTick,
                    params.liquidity[i].amount,
                    ""
                );
                poolBalance0 += balance0;
                poolBalance1 += balance1;
            }
        }

        transferInMintCallback = params.transferInMintCallback;
        transferInSwapCallback = params.transferInSwapCallback;
        liquidity = params.liquidity;
    }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external {
        if (transferInSwapCallback) {
            if (amount0Delta > 0)
                token0.transfer(msg.sender, uint256(amount0Delta));
            if (amount1Delta > 0)
                token1.transfer(msg.sender, uint256(amount1Delta));
        }
    }

    function uniswapV3MintCallback(
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external {
        if (transferInMintCallback) {
            if (amount0 > 0) token0.transfer(msg.sender, amount0);
            if (amount1 > 0) token1.transfer(msg.sender, amount1);
        }
    }
}
