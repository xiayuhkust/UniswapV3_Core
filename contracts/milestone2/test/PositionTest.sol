// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;
pragma abicoder v2;

import "forge-std/Test.sol";
import "../contracts/Position.sol";

contract PositionTest is Test {
    using Position for mapping(bytes32 => Position.Info);
    
    mapping(bytes32 => Position.Info) positions;
    address owner = address(1);
    int24 lowerTick = -100;
    int24 upperTick = 100;

    function testPositionManagement() public {
        // Get initial position
        Position.Info storage position = positions.get(owner, lowerTick, upperTick);
        assertEq(uint256(position.liquidity), uint256(0), "Initial liquidity should be 0");
        assertEq(uint256(position.tokensOwed0), uint256(0), "Initial tokensOwed0 should be 0");
        assertEq(uint256(position.tokensOwed1), uint256(0), "Initial tokensOwed1 should be 0");

        // Update position with new liquidity
        int128 liquidityDelta = 1000;
        uint256 feeGrowthInside0X128 = 1;
        uint256 feeGrowthInside1X128 = 2;

        position.update(liquidityDelta, feeGrowthInside0X128, feeGrowthInside1X128);
        assertEq(uint256(position.liquidity), uint256(1000), "Liquidity not updated correctly");
        assertEq(position.feeGrowthInside0LastX128, feeGrowthInside0X128, "Fee growth 0 not updated");
        assertEq(position.feeGrowthInside1LastX128, feeGrowthInside1X128, "Fee growth 1 not updated");

        // Update position with fee growth
        feeGrowthInside0X128 = 3;
        feeGrowthInside1X128 = 4;

        position.update(0, feeGrowthInside0X128, feeGrowthInside1X128);
        assertTrue(uint256(position.tokensOwed0) > 0, "Tokens owed 0 should increase");
        assertTrue(uint256(position.tokensOwed1) > 0, "Tokens owed 1 should increase");
    }

    function testRemoveLiquidity() public {
        // First add liquidity
        Position.Info storage position = positions.get(owner, lowerTick, upperTick);
        position.update(1000, 0, 0);
        assertEq(uint256(position.liquidity), uint256(1000), "Initial liquidity not set");

        // Then remove liquidity
        position.update(-500, 0, 0);
        assertEq(uint256(position.liquidity), uint256(500), "Liquidity not removed correctly");
    }
}
