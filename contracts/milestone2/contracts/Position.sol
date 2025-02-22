// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;

import "./FixedPoint128.sol";
import "./LiquidityMath.sol";

library Position {
    struct Info {
        uint128 liquidity;
        uint256 feeGrowthInside0LastX128;
        uint256 feeGrowthInside1LastX128;
        uint128 tokensOwed0;
        uint128 tokensOwed1;
    }

    /// @notice Returns the Info struct of a position, given an owner and position boundaries
    /// @param self The mapping containing all user positions
    /// @param owner The address of the position owner
    /// @param lowerTick The lower tick boundary of the position
    /// @param upperTick The upper tick boundary of the position
    /// @return position The position info struct of the given position
    function get(
        mapping(bytes32 => Info) storage self,
        address owner,
        int24 lowerTick,
        int24 upperTick
    ) internal view returns (Position.Info storage position) {
        position = self[keccak256(abi.encodePacked(owner, lowerTick, upperTick))];
    }

    /// @notice Updates a position with the given liquidity delta and fee growth
    /// @param self The position to update
    /// @param liquidityDelta The change in liquidity
    /// @param feeGrowthInside0X128 The all-time fee growth in token0, per unit of liquidity, inside the position's tick boundaries
    /// @param feeGrowthInside1X128 The all-time fee growth in token1, per unit of liquidity, inside the position's tick boundaries
    function update(
        Info storage self,
        int128 liquidityDelta,
        uint256 feeGrowthInside0X128,
        uint256 feeGrowthInside1X128
    ) internal {
        uint128 tokensOwed0 = uint128(
            mulDiv(
                feeGrowthInside0X128 - self.feeGrowthInside0LastX128,
                self.liquidity,
                FixedPoint128.Q128
            )
        );
        uint128 tokensOwed1 = uint128(
            mulDiv(
                feeGrowthInside1X128 - self.feeGrowthInside1LastX128,
                self.liquidity,
                FixedPoint128.Q128
            )
        );

        self.liquidity = LiquidityMath.addLiquidity(self.liquidity, liquidityDelta);
        self.feeGrowthInside0LastX128 = feeGrowthInside0X128;
        self.feeGrowthInside1LastX128 = feeGrowthInside1X128;

        if (tokensOwed0 > 0 || tokensOwed1 > 0) {
            self.tokensOwed0 += tokensOwed0;
            self.tokensOwed1 += tokensOwed1;
        }
    }

    /// @notice Computes the result of (x * y) / z
    /// @dev Taken from Solidity-Lib
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 z
    ) internal pure returns (uint256) {
        require(z > 0, "MD");
        uint256 a = x / z;
        uint256 b = x % z;
        uint256 c = y / z;
        uint256 d = y % z;

        return a * y + b * c + (b * d) / z;
    }
}
