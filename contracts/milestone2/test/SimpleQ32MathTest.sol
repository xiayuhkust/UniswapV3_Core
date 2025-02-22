// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../contracts/libraries/SimpleQ32Math.sol";

contract SimpleQ32MathWrapper {
    using SimpleQ32Math for uint256;

    function mulDiv(uint256 a, uint256 b, uint256 denominator) external pure returns (uint256) {
        return SimpleQ32Math.mulDiv(a, b, denominator);
    }

    function mulDivRoundingUp(uint256 a, uint256 b, uint256 denominator) external pure returns (uint256) {
        return SimpleQ32Math.mulDivRoundingUp(a, b, denominator);
    }

    function divRoundingUp(uint256 numerator, uint256 denominator) external pure returns (uint256) {
        return SimpleQ32Math.divRoundingUp(numerator, denominator);
    }
}

contract SimpleQ32MathTest is Test {
    SimpleQ32MathWrapper wrapper;

    function setUp() public {
        wrapper = new SimpleQ32MathWrapper();
    }

    function testMulDiv() public {
        uint256 result = wrapper.mulDiv(2, 3, 2);
        assertEq(result, 3);
    }

    function testMulDivRoundingUp() public {
        uint256 result = wrapper.mulDivRoundingUp(2, 3, 2);
        assertEq(result, 3);
    }

    function testDivisionByZero() public {
        vm.expectRevert(abi.encodeWithSignature("DivisionByZero()"));
        wrapper.mulDiv(1, 1, 0);
    }

    function testMultiplicationOverflow() public {
        vm.expectRevert(abi.encodeWithSignature("MultiplicationOverflow()"));
        wrapper.mulDiv(type(uint256).max, 2, 1);
    }

    function testLargeNumbers() public {
        uint256 result = wrapper.mulDiv(
            1e18,
            2e18,
            1e18
        );
        assertEq(result, 2e18);
    }

    function testRoundingUpWithRemainder() public {
        uint256 result = wrapper.mulDivRoundingUp(10, 3, 2);
        assertEq(result, 15);
    }

    function testRoundingUpNoRemainder() public {
        uint256 result = wrapper.mulDivRoundingUp(10, 2, 2);
        assertEq(result, 10);
    }

    function testRoundingUpMaxValue() public {
        vm.expectRevert(abi.encodeWithSignature("MultiplicationOverflow()"));
        wrapper.mulDivRoundingUp(
            type(uint256).max,
            2,
            2
        );
    }

    function testDivRoundingUp() public {
        assertEq(wrapper.divRoundingUp(10, 3), 4);
        assertEq(wrapper.divRoundingUp(10, 2), 5);
        assertEq(wrapper.divRoundingUp(10, 1), 10);
    }

    function testDivRoundingUpEdgeCases() public {
        assertEq(wrapper.divRoundingUp(0, 1), 0);
        vm.expectRevert(abi.encodeWithSignature("DivisionByZero()"));
        wrapper.divRoundingUp(1, 0);
    }
}
