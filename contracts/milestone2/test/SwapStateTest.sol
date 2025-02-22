// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../contracts/libraries/SwapState.sol";

contract SwapStateTest is Test {
    function testSwapStateStructLayout() public {
        SwapState.State memory state;
        state.amountSpecifiedRemaining = 100;
        state.amountCalculated = 50;
        state.sqrtPriceX96 = 79228162514264337593543950336; // 1.0 in Q96
        state.tick = 1;

        assertEq(state.amountSpecifiedRemaining, 100);
        assertEq(state.amountCalculated, 50);
        assertEq(state.sqrtPriceX96, 79228162514264337593543950336);
        assertEq(state.tick, 1);
    }

    function testStepStateStructLayout() public {
        SwapState.Step memory step;
        step.sqrtPriceStartX96 = 79228162514264337593543950336; // 1.0 in Q96
        step.nextTick = 1;
        step.sqrtPriceNextX96 = 79228162514264337593543950337;
        step.amountIn = 100;
        step.amountOut = 50;

        assertEq(step.sqrtPriceStartX96, 79228162514264337593543950336);
        assertEq(step.nextTick, 1);
        assertEq(step.sqrtPriceNextX96, 79228162514264337593543950337);
        assertEq(step.amountIn, 100);
        assertEq(step.amountOut, 50);
    }
}
