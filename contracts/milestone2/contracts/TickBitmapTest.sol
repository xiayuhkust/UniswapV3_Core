// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "./TickBitmap.sol";

contract TickBitmapTest {
    using TickBitmap for mapping(int16 => uint256);
    
    mapping(int16 => uint256) public bitmap;
    
    function testFlipTick() public {
        // Test with valid tick and spacing that are properly aligned
        int24 tick = 200;  // Using a larger tick value
        int24 spacing = 10;
        
        // Verify tick is properly spaced
        require(tick % spacing == 0, "Tick must be multiple of spacing");
        
        // Initial state should be uninitialized
        (int24 nextBefore, bool initializedBefore) = bitmap.nextInitializedTickWithinOneWord(tick - spacing, spacing, true);
        require(initializedBefore == false, "Tick should not be initialized initially");
        
        // Flip tick to initialized
        bitmap.flipTick(tick, spacing);
        
        // Check initialization through nextInitializedTickWithinOneWord
        (int24 nextAfter, bool initializedAfter) = bitmap.nextInitializedTickWithinOneWord(tick - spacing, spacing, true);
        require(initializedAfter == true, "Tick should be initialized after flip");
        require(nextAfter == tick, "Next tick should match flipped tick");
        
        // Verify the bitmap directly
        (int16 wordPos, uint8 bitPos) = position(tick / spacing);
        uint256 mask = 1 << bitPos;
        require((bitmap[wordPos] & mask) != 0, "Bit should be set in bitmap");
    }
    
    function testNextInitializedTickWithinOneWord() public {
        int24 spacing = 10;
        
        // Initialize ticks (must be multiples of spacing)
        bitmap.flipTick(200, spacing);  // 200/10 = 20
        bitmap.flipTick(400, spacing);  // 400/10 = 40
        bitmap.flipTick(800, spacing);  // 800/10 = 80
        
        // Test searching right
        (int24 next, bool initialized) = bitmap.nextInitializedTickWithinOneWord(190, spacing, false);
        require(next == 200, "Next tick to right should be 200");
        require(initialized == true, "Should find initialized tick");
        
        // Test searching left
        (next, initialized) = bitmap.nextInitializedTickWithinOneWord(500, spacing, true);
        require(next == 400, "Next tick to left should be 400");
        require(initialized == true, "Should find initialized tick");
    }
    
    // Helper function to calculate position (copied from TickBitmap for verification)
    function position(int24 tick) private pure returns (int16 wordPos, uint8 bitPos) {
        wordPos = int16(tick >> 8);
        bitPos = uint8(uint24(tick % 256));
    }
}
