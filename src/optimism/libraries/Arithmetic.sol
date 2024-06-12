// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SignedMath} from "@openzeppelin/contracts/utils/math/SignedMath.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

/// @title Arithmetic
/// @notice Even more math than before.
library Arithmetic {
    /// @notice Clamps a value between a minimum and maximum.
    /// @param _value The value to clamp.
    /// @param _min   The minimum value.
    /// @param _max   The maximum value.
    /// @return The clamped value.
    function clamp(
        int256 _value,
        int256 _min,
        int256 _max
    ) internal pure returns (int256) {
        return SignedMath.min(SignedMath.max(_value, _min), _max);
    }
}
