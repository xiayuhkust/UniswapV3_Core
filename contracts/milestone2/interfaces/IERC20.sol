// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.14;

interface IERC20 {
    function symbol() external view returns (string memory);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}
