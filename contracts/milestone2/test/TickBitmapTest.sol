// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "forge-std/Test.sol";
import "../contracts/TickBitmap.sol";

contract TickBitmapTest is Test {
    using TickBitmap for mapping(int16 => uint256);
    
    mapping(int16 => uint256) public bitmap;
    
    function testFlipTick() public {
        int24 tick = 200;
        int24 spacing = 10;
        
        // Initial state should be uninitialized
        (int24 nextBefore, bool initializedBefore) = bitmap.nextInitializedTickWithinOneWord(tick - spacing, spacing, true);
        assertEq(initializedBefore, false, "Tick should not be initialized initially");
        
        // Flip tick to initialized
        bitmap.flipTick(tick, spacing);
        
        // Check initialization
        (int24 nextAfter, bool initializedAfter) = bitmap.nextInitializedTickWithinOneWord(tick - spacing, spacing, true);
        assertEq(initializedAfter, true, "Tick should be initialized after flip");
        assertEq(nextAfter, tick, "Next tick should match flipped tick");
    }
    
    function testNextInitializedTickWithinOneWord() public {
        int24 spacing = 10;
        
        // Initialize ticks
        bitmap.flipTick(200, spacing);  // 200/10 = 20
        bitmap.flipTick(400, spacing);  // 400/10 = 40
        bitmap.flipTick(800, spacing);  // 800/10 = 80
        
        // Test searching right
        (int24 nextRight, bool initializedRight) = bitmap.nextInitializedTickWithinOneWord(190, spacing, false);
        assertEq(nextRight, 200, "Next tick to right should be 200");
        assertEq(initializedRight, true, "Should find initialized tick");
        
        // Test searching left
        (int24 nextLeft, bool initializedLeft) = bitmap.nextInitializedTickWithinOneWord(500, spacing, true);
        assertEq(nextLeft, 400, "Next tick to left should be 400");
        assertEq(initializedLeft, true, "Should find initialized tick");
    }
}
