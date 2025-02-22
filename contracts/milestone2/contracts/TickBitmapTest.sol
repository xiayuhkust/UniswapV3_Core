// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.14;

import "./TickBitmap.sol";

contract TickBitmapTest {
    using TickBitmap for mapping(int16 => uint256);
    
    mapping(int16 => uint256) public bitmap;
    
    function flipTick(int24 tick, int24 spacing) public {
        require(tick % spacing == 0, "tick must be divisible by spacing");
        bitmap.flipTick(tick, spacing);
    }
    
    function checkTick(int24 tick, int24 spacing) public view returns (int24 next, bool initialized) {
        return bitmap.nextInitializedTickWithinOneWord(tick, spacing, true);
    }
    
    function nextInitializedTickWithinOneWord(
        int24 tick,
        int24 spacing,
        bool lte
    ) public view returns (int24 next, bool initialized) {
        return bitmap.nextInitializedTickWithinOneWord(tick, spacing, lte);
    }
}
