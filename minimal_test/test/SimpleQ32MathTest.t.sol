// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/SimpleQ32Math.sol";

contract SimpleQ32MathTest is Test {
    function testDivByZero() public {
        vm.expectRevert(SimpleQ32Math.DivisionByZero.selector);
        SimpleQ32Math.mulDiv(100, 200, 0);
    }
}
