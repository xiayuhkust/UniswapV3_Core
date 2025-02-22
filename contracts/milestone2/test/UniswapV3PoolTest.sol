// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;
pragma abicoder v2;

import "forge-std/Test.sol";
import "../contracts/UniswapV3Pool.sol";
import "../contracts/interfaces/IERC20.sol";

contract UniswapV3PoolTest is Test {
    UniswapV3Pool pool;
    address token0;
    address token1;
    address owner;

    function setUp() public {
        // Deploy test tokens
        token0 = 0x3F26F01Fa9A5506c9109B5Ad15343363909fc0b9; // TT1
        token1 = 0x8FDCE0D41f0A99B5f9FbcFAfd481ffcA61d01122; // TT2
        owner = address(this);

        // Deploy pool
        pool = new UniswapV3Pool(
            token0,
            token1,
            3000, // 0.3% fee tier
            60    // tick spacing
        );
    }

    function testInitialState() public {
        assertEq(pool.token0(), token0, "Incorrect token0");
        assertEq(pool.token1(), token1, "Incorrect token1");
        assertEq(pool.fee(), 3000, "Incorrect fee");
        assertEq(pool.tickSpacing(), 60, "Incorrect tick spacing");
    }

    function testMint() public {
        int24 lowerTick = -60;
        int24 upperTick = 60;
        uint128 amount = 1000;

        // Mint new position
        (uint256 amount0, uint256 amount1) = pool.mint(
            owner,
            lowerTick,
            upperTick,
            amount,
            ""
        );

        // Get position info
        bytes32 positionKey = keccak256(abi.encodePacked(owner, lowerTick, upperTick));
        (uint128 liquidity,,,,) = pool.positions(positionKey);

        assertEq(uint256(liquidity), uint256(amount), "Incorrect liquidity");
    }

    function testFailMintWithInvalidTicks() public {
        // Try to mint with lower tick greater than upper tick
        pool.mint(owner, 60, -60, 1000, "");
    }
}
