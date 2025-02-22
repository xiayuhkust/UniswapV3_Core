// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "forge-std/Test.sol";
import "../contracts/BitMath.sol";

contract BitMathTest is Test {
    function testMostSignificantBit(uint256 x) public {
        vm.assume(x > 0);
        uint8 result = BitMath.mostSignificantBit(x);
        assertGt(result, 0, "MSB should be > 0 for non-zero input");
    }

    function testLeastSignificantBit(uint256 x) public {
        vm.assume(x > 0);
        uint8 result = BitMath.leastSignificantBit(x);
        assertLt(result, 256, "LSB should be < 256");
    }

    function testLeastSignificantBitZero() public {
        vm.expectRevert("BitMath: ZERO_VALUE");
        BitMath.leastSignificantBit(0);
    }
}
