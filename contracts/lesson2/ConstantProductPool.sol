// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ConstantProductPool {
    address public token0;
    address public token1;

    uint256 public reserve0;
    uint256 public reserve1;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
    }

    function _mint(address to, uint256 amount) private {
        balanceOf[to] += amount;
        totalSupply += amount;
    }

    function _burn(address from, uint256 amount) private {
        balanceOf[from] -= amount;
        totalSupply -= amount;
    }

    function swap(address tokenIn, uint256 amountIn) external returns (uint256 amountOut) {
        require(tokenIn == token0 || tokenIn == token1, "Invalid token");

        bool isToken0 = tokenIn == token0;
        (IERC20 tokenInERC20, IERC20 tokenOutERC20, uint256 reserveIn, uint256 reserveOut) = isToken0
            ? (IERC20(token0), IERC20(token1), reserve0, reserve1)
            : (IERC20(token1), IERC20(token0), reserve1, reserve0);

        tokenInERC20.transferFrom(msg.sender, address(this), amountIn);

        uint256 amountInWithFee = amountIn * 997;
        amountOut = (amountInWithFee * reserveOut) / (reserveIn * 1000 + amountInWithFee);

        tokenOutERC20.transfer(msg.sender, amountOut);

        _update(
            isToken0 ? tokenInERC20.balanceOf(address(this)) : reserve0,
            isToken0 ? reserve1 : tokenInERC20.balanceOf(address(this))
        );
    }

    function addLiquidity(uint256 amount0, uint256 amount1) external returns (uint256 shares) {
        IERC20(token0).transferFrom(msg.sender, address(this), amount0);
        IERC20(token1).transferFrom(msg.sender, address(this), amount1);

        if (reserve0 > 0 || reserve1 > 0) {
            require(reserve0 * amount1 == reserve1 * amount0, "x/y != dx/dy");
        }

        if (totalSupply == 0) {
            shares = amount0 * amount1;
        } else {
            shares = (amount0 * totalSupply) / reserve0;
        }
        require(shares > 0, "shares = 0");
        _mint(msg.sender, shares);

        _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)));
    }

    function removeLiquidity(uint256 shares) external returns (uint256 amount0, uint256 amount1) {
        uint256 bal0 = IERC20(token0).balanceOf(address(this));
        uint256 bal1 = IERC20(token1).balanceOf(address(this));

        amount0 = (shares * bal0) / totalSupply;
        amount1 = (shares * bal1) / totalSupply;
        require(amount0 > 0 && amount1 > 0, "amount0 or amount1 = 0");

        _burn(msg.sender, shares);
        _update(bal0 - amount0, bal1 - amount1);

        IERC20(token0).transfer(msg.sender, amount0);
        IERC20(token1).transfer(msg.sender, amount1);
    }

    function _update(uint256 _reserve0, uint256 _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }
}
