// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "./TestUniswapV3Pool.sol";
import {MockToken} from "./MockToken.sol";
import "../interfaces/IUniswapV3MintCallback.sol";

contract UniswapV3PoolTest is Test, IUniswapV3MintCallback {
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
        pool = new TestUniswapV3Pool(
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
        // Create mock tokens
        MockToken token0Mock = new MockToken("Token0", "TK0", 18);
        MockToken token1Mock = new MockToken("Token1", "TK1", 18);
        
        // Deploy pool with mock tokens
        pool = new TestUniswapV3Pool(
            address(token0Mock),
            address(token1Mock),
            3000,
            60
        );

        // Mint tokens to this contract
        token0Mock.mint(address(this), 1e18);
        token1Mock.mint(address(this), 1e18);

        // Approve pool to spend tokens
        token0Mock.approve(address(pool), 1e18);
        token1Mock.approve(address(pool), 1e18);

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
        assertEq(amount0, 3, "Amount0 should be 3");
        assertEq(amount1, 3, "Amount1 should be 3");
    }

    function test_RevertWhen_InvalidTickOrder() public {
        // Try to mint with lower tick greater than upper tick
        vm.expectRevert();
        pool.mint(owner, 60, -60, 1000, "");
    }

    function uniswapV3MintCallback(
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external {
        MockToken(pool.token0()).transfer(msg.sender, amount0);
        MockToken(pool.token1()).transfer(msg.sender, amount1);
    }
}
