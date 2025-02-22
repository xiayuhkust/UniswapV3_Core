// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "forge-std/Test.sol";

contract MinimalFullMathTest is Test {
    function testBasicMultiplyDivide() public {
        // Simple case: (10 * 20) / 5 = 40
        uint256 a = 10;
        uint256 b = 20;
        uint256 denominator = 5;
        
        unchecked {
            uint256 prod0 = a * b;
            require(denominator > 0, "denominator must be > 0");
            uint256 result = prod0 / denominator;
            assertEq(result, 40);
        }
    }

    function testSimpleOverflow() public {
        // Test with numbers that would overflow normal multiplication
        uint256 a = type(uint128).max;
        uint256 b = 2;
        uint256 denominator = 2;
        
        unchecked {
            uint256 prod0 = a * b;
            require(denominator > 0, "denominator must be > 0");
            uint256 result = prod0 / denominator;
            assertEq(result, type(uint128).max);
        }
    }
}
