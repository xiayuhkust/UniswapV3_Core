// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract ConstantProductPool {
    using SafeMath for uint256;

    address public token0;
    address public token1;
    uint256 public reserve0;
    uint256 public reserve1;
    uint256 private constant SWAP_FEE = 997; // 0.3% fee
    uint256 private constant FEE_DENOMINATOR = 1000;

    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );

    constructor(address _token0, address _token1) {
        require(_token0 != address(0), "CP: ZERO_ADDRESS");
        require(_token1 != address(0), "CP: ZERO_ADDRESS");
        require(_token0 != _token1, "CP: IDENTICAL_ADDRESSES");
        token0 = _token0;
        token1 = _token1;
    }

    function initialize(uint256 amount0, uint256 amount1) external {
        require(reserve0 == 0 && reserve1 == 0, "CP: ALREADY_INITIALIZED");
        require(amount0 > 0 && amount1 > 0, "CP: INSUFFICIENT_LIQUIDITY");
        
        // Transfer tokens to the pool
        IERC20(token0).transferFrom(msg.sender, address(this), amount0);
        IERC20(token1).transferFrom(msg.sender, address(this), amount1);
        
        reserve0 = amount0;
        reserve1 = amount1;
    }

    function getReserves() public view returns (uint256, uint256) {
        return (reserve0, reserve1);
    }

    function swap(uint256 amount0In, uint256 amount1In, address to) external {
        require(amount0In > 0 || amount1In > 0, "CP: INSUFFICIENT_INPUT_AMOUNT");
        require(to != address(0), "CP: INVALID_TO");

        (uint256 _reserve0, uint256 _reserve1) = getReserves();
        require(_reserve0 > 0 && _reserve1 > 0, "CP: INSUFFICIENT_LIQUIDITY");
        
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        
        uint256 amount0Out = 0;
        uint256 amount1Out = 0;

        if (amount0In > 0) {
            require(amount0In <= balance0.mul(2), "CP: INSUFFICIENT_LIQUIDITY");
            amount1Out = getOutputAmount(amount0In, _reserve0, _reserve1);
        } else {
            require(amount1In <= balance1.mul(2), "CP: INSUFFICIENT_LIQUIDITY");
            amount0Out = getOutputAmount(amount1In, _reserve1, _reserve0);
        }

        require(amount0Out > 0 || amount1Out > 0, "CP: INSUFFICIENT_OUTPUT_AMOUNT");

        if (amount0Out > 0) {
            require(amount0Out < _reserve0, "CP: INSUFFICIENT_LIQUIDITY");
            IERC20(token0).transfer(to, amount0Out);
        }
        if (amount1Out > 0) {
            require(amount1Out < _reserve1, "CP: INSUFFICIENT_LIQUIDITY");
            IERC20(token1).transfer(to, amount1Out);
        }

        balance0 = IERC20(token0).balanceOf(address(this));
        balance1 = IERC20(token1).balanceOf(address(this));

        _update(balance0, balance1);

        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    function getOutputAmount(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure returns (uint256) {
        require(amountIn > 0, "CP: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "CP: INSUFFICIENT_LIQUIDITY");

        uint256 amountInWithFee = amountIn.mul(SWAP_FEE);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(FEE_DENOMINATOR).add(amountInWithFee);

        return numerator.div(denominator);
    }

    function _update(uint256 balance0, uint256 balance1) private {
        reserve0 = balance0;
        reserve1 = balance1;
    }
}
