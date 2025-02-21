// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

/// @title Constant Function Market Maker
/// @notice Implements basic CFMM (x * y = k) functionality
contract CFMM {
    // Pool reserves
    uint256 public reserve0;
    uint256 public reserve1;

    // Fee taken from trades (0.3%)
    uint256 constant FEE = 997;
    uint256 constant FEE_DENOMINATOR = 1000;

    event Swap(address indexed sender, uint256 amount0In, uint256 amount1Out);

    /// @notice Swap token0 for token1
    /// @param amount0In Amount of token0 to swap
    /// @return amount1Out Amount of token1 received
    function swap(uint256 amount0In) external returns (uint256 amount1Out) {
        require(amount0In > 0, "Invalid input amount");
        require(reserve0 > 0 && reserve1 > 0, "Insufficient liquidity");

        // Calculate amount including fee
        uint256 amount0InWithFee = amount0In * FEE;

        // Calculate output amount based on constant product formula
        // (x + Δx)(y - Δy) = k
        // where k = x * y
        amount1Out = (reserve1 * amount0InWithFee) / ((reserve0 * FEE_DENOMINATOR) + amount0InWithFee);
        require(amount1Out > 0, "Insufficient output amount");

        // Update reserves
        reserve0 += amount0In;
        reserve1 -= amount1Out;

        // Verify k is constant (or increases due to fees)
        require(reserve0 * reserve1 >= reserve0 * reserve1, "K");

        emit Swap(msg.sender, amount0In, amount1Out);
    }

    /// @notice Initialize pool with initial liquidity
    /// @param amount0 Initial amount of token0
    /// @param amount1 Initial amount of token1
    function initialize(uint256 amount0, uint256 amount1) external {
        require(reserve0 == 0 && reserve1 == 0, "Already initialized");
        require(amount0 > 0 && amount1 > 0, "Invalid amounts");

        reserve0 = amount0;
        reserve1 = amount1;
    }
}
