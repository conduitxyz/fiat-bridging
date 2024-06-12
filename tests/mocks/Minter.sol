// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract MockMinter {
    constructor() {}

    function configureController(address, address) external {}

    function removeController(address) external {}

    function configureMinter(uint256) external {}

    function removeMinter() external pure returns (bool) {
        return true;
    }
}
