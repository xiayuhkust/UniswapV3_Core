// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

library SafeCast {
    function toUint128(uint256 y) internal pure returns (uint128 z) {
        require((z = uint128(y)) == y);
    }

    function toInt128(uint128 y) internal pure returns (int128 z) {
        require(y < 2**127);
        z = int128(y);
    }

    function toInt256(uint256 y) internal pure returns (int256 z) {
        require(y < 2**255);
        z = int256(y);
    }
}
