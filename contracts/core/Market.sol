// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.14;

/// @title Basic Market Implementation
/// @notice Demonstrates fundamental market concepts from Lesson 1
contract Market {
    struct Order {
        address trader;
        uint256 price;
        uint256 amount;
        bool isBuyOrder;
    }

    Order[] public orderBook;

    event OrderPlaced(address indexed trader, uint256 price, uint256 amount, bool isBuyOrder);

    function placeOrder(uint256 price, uint256 amount, bool isBuyOrder) external {
        require(amount > 0, "Amount must be greater than 0");
        require(price > 0, "Price must be greater than 0");

        orderBook.push(Order({trader: msg.sender, price: price, amount: amount, isBuyOrder: isBuyOrder}));

        emit OrderPlaced(msg.sender, price, amount, isBuyOrder);
    }

    function getOrderCount() external view returns (uint256) {
        return orderBook.length;
    }
}
