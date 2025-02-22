// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "../contracts/UniswapV3Pool.sol";

contract TestUniswapV3Pool is UniswapV3Pool {
    constructor(
        address _token0,
        address _token1,
        uint24 _fee,
        int24 _tickSpacing
    ) UniswapV3Pool(_token0, _token1, _fee, _tickSpacing) {}

    function factory() external view override returns (address) {
        return address(this);
    }
}
