// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";

import {Proxy} from "src/optimism/Proxy.sol";

import {L2FiatBridge} from "src/optimism/L2FiatBridge.sol";
import {FiatManager} from "src/optimism/FiatManager.sol";

import {MockMinter} from "tests/mocks/Minter.sol";

contract DeployFiatOp is Script {
    function run() public {
        uint256 deployerPK = vm.envUint("DEPLOYER_PK");
        address l1Fiat = vm.envAddress("L1_FIAT_ADDRESS");
        address l2Fiat = vm.envAddress("L2_FIAT_ADDRESS");
        address proxyAdmin = vm.envAddress("PROXY_ADMIN");
        address l1Gateway = vm.envAddress("L1_GATEWAY");
        address masterMinterContract = vm.envAddress("MASTER_MINTER_CONTRACT");
        address deployerAddress = vm.addr(deployerPK);

        vm.startBroadcast(deployerPK);
        // Deploy the proxy and the implementation
        console2.log("Deploying FiatManager");
        FiatManager manager = new FiatManager(deployerAddress);
        console2.log("Deployed FiatManager at address", address(manager));
        console2.log("Deploying Proxy");
        Proxy proxy = new Proxy(deployerAddress);
        console2.log("Deployed Proxy at address", address(proxy));
        console2.log("Deploying L2FiatBridge");
        L2FiatBridge impl = new L2FiatBridge();

        console2.log("Deployed L2FiatBridge at address", address(impl));

        bytes memory _initializationCalldata = abi.encodeWithSelector(
            L2FiatBridge.initialize.selector,
            l1Gateway,
            l1Fiat,
            l2Fiat,
            deployerAddress
        );

        // Upgrade the proxy to the implementation
        console2.log("Upgrading Proxy");
        proxy.upgradeToAndCall(address(impl), _initializationCalldata);

        console2.log("Transferring ownership of the proxy to the proxyAdmin");
        proxy.changeAdmin(proxyAdmin);

        if (masterMinterContract == address(0)) {
            console2.log("Deploying MockMinter");
            MockMinter minter = new MockMinter();
            console2.log("Deployed MockMinter at address", address(minter));
            masterMinterContract = address(minter);
        }

        // Initialize the manager contract
        console2.log("Initializing FiatManager");
        manager.initialize(address(impl), masterMinterContract, address(proxy));
    }
}
