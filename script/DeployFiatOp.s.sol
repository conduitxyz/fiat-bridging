// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";

import {Proxy} from "src/optimism/Proxy.sol";

import {L2FiatBridge} from "src/optimism/L2FiatBridge.sol";

contract DeployFiatOp is Script {
    function run() public {
        uint256 deployerPK = vm.envUint("DEPLOYER_PK");
        address proxyAdmin = vm.envAddress("PROXY_ADMIN");
        address deployerAddress = vm.addr(deployerPK);

        vm.startBroadcast(deployerPK);
        // Deploy the proxy and the implementation

        Proxy proxy = new Proxy(proxyAdmin);
        L2FiatBridge impl = new L2FiatBridge();

        // proxy.upgradeToAndCall

        string memory dockerImage = vm.envString("STABLECOIN_EVM_DOCKER_IMAGE");
    }
}
