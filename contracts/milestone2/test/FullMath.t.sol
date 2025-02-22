// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../contracts/libraries/FullMath.sol";

contract FullMathTest is Test {
    uint256 constant Q128 = 2**128;
    uint256 constant MAX_UINT = type(uint256).max;

    function testMulDivFailsWithZeroDenominator() public {
        vm.expectRevert(FullMath.DivByZero.selector);
        FullMath.mulDiv(Q128, 5, 0);
    }

    function testMulDivFailsWithZeroDenominatorAndOverflow() public {
        vm.expectRevert(FullMath.DivByZero.selector);
        FullMath.mulDiv(Q128, Q128, 0);
    }

    function testMulDivFailsWithOverflow() public {
        vm.expectRevert(FullMath.MulDivOverflow.selector);
        FullMath.mulDiv(Q128, Q128, 1);
    }

    function testMulDivAllMaxInputs() public {
        unchecked {
            assertEq(FullMath.mulDiv(MAX_UINT, MAX_UINT, MAX_UINT), MAX_UINT);
        }
    }

    function testMulDivAccurateWithoutPhantomOverflow() public {
        uint256 result = Q128 / 3;
        assertEq(
            FullMath.mulDiv(
                Q128,
                (50 * Q128) / 100,  // 0.5
                (150 * Q128) / 100   // 1.5
            ),
            result
        );
    }

    function testMulDivAccurateWithPhantomOverflow() public {
        uint256 result = (4375 * Q128) / 1000;
        assertEq(
            FullMath.mulDiv(Q128, 35 * Q128, 8 * Q128),
            result
        );
    }

    function testMulDivAccurateWithPhantomOverflowAndRepeatingDecimal() public {
        uint256 result = (1 * Q128) / 3;
        assertEq(
            FullMath.mulDiv(Q128, 1000 * Q128, 3000 * Q128),
            result
        );
    }

    // MulDivRoundingUp Tests
    function testMulDivRoundingUpFailsWithZeroDenominator() public {
        vm.expectRevert(FullMath.DivByZero.selector);
        FullMath.mulDivRoundingUp(Q128, 5, 0);
    }

    function testMulDivRoundingUpFailsWithZeroDenominatorAndOverflow() public {
        vm.expectRevert(FullMath.DivByZero.selector);
        FullMath.mulDivRoundingUp(Q128, Q128, 0);
    }

    function testMulDivRoundingUpFailsWithOverflow() public {
        vm.expectRevert(FullMath.MulDivOverflow.selector);
        FullMath.mulDivRoundingUp(Q128, Q128, 1);
    }

    function testMulDivRoundingUpFailsWithOverflowCase1() public {
        vm.expectRevert(FullMath.MulDivOverflow.selector);
        FullMath.mulDivRoundingUp(
            535006138814359,
            432862656469423142931042426214547535783388063929571229938474969,
            2
        );
    }

    function testMulDivRoundingUpFailsWithOverflowCase2() public {
        vm.expectRevert(FullMath.MulDivOverflow.selector);
        FullMath.mulDivRoundingUp(
            MAX_UINT,
            MAX_UINT,
            MAX_UINT - 1
        );
    }

    function testMulDivRoundingUpAllMaxInputs() public {
        unchecked {
            assertEq(
                FullMath.mulDivRoundingUp(MAX_UINT, MAX_UINT, MAX_UINT),
                MAX_UINT
            );
        }
    }

    function testMulDivRoundingUpAccurateWithoutPhantomOverflow() public {
        uint256 result = (Q128 / 3) + 1;
        assertEq(
            FullMath.mulDivRoundingUp(
                Q128,
                (50 * Q128) / 100,  // 0.5
                (150 * Q128) / 100   // 1.5
            ),
            result
        );
    }

    function testMulDivRoundingUpAccurateWithPhantomOverflow() public {
        uint256 result = (4375 * Q128) / 1000;
        assertEq(
            FullMath.mulDivRoundingUp(Q128, 35 * Q128, 8 * Q128),
            result
        );
    }

    function testMulDivRoundingUpAccurateWithPhantomOverflowAndRepeatingDecimal() public {
        uint256 result = (1 * Q128) / 3 + 1;
        assertEq(
            FullMath.mulDivRoundingUp(Q128, 1000 * Q128, 3000 * Q128),
            result
        );
    }
}
