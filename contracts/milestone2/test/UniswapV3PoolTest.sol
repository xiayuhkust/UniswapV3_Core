// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;
pragma abicoder v2;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
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
        assertEq(address(pool.token0()), address(token0), "Incorrect token0");
        assertEq(address(pool.token1()), address(token1), "Incorrect token1");
        assertEq(uint256(pool.fee()), uint256(3000), "Incorrect fee");
        assertEq(int24(pool.tickSpacing()), int24(60), "Incorrect tick spacing");
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
        // Verify returned amounts (currently 0 as we haven't implemented full minting logic)
        assertEq(amount0, 0, "Amount0 should be 0");
        assertEq(amount1, 0, "Amount1 should be 0");
    }

    function test_RevertWhen_InvalidTickOrder() public {
        // Try to mint with lower tick greater than upper tick
        vm.expectRevert(bytes("TLU"));  // Tick Lower > Upper
        pool.mint(owner, 60, -60, 1000, "");
    }
}
