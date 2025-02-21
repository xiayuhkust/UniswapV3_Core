// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "forge-std/Test.sol";
import "../../contracts/core/Market.sol";

contract MarketTest is Test {
    Market market;

    function setUp() public {
        market = new Market();
    }

    function test_PlaceOrder() public {
        market.placeOrder(100, 10, true);
        assertEq(market.getOrderCount(), 1);
    }

    function test_RejectZeroAmount() public {
        vm.expectRevert("Amount must be greater than 0");
        market.placeOrder(100, 0, true);
    }

    function test_RejectZeroPrice() public {
        vm.expectRevert("Price must be greater than 0");
        market.placeOrder(0, 10, true);
    }
}
