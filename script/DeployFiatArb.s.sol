// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";

import {ArbMinter} from "src/arbitrum/ArbMinter.sol";
import {MockMinter} from "tests/mocks/Minter.sol";

contract DeployFiatArb is Script {
    function run() public {
        uint256 deployerPK = vm.envUint("DEPLOYER_PK");
        address l1Fiat = vm.envAddress("L1_FIAT_ADDRESS");
        address l2Fiat = vm.envAddress("L2_FIAT_ADDRESS");
        address masterMinterContract = vm.envAddress("MASTER_MINTER_CONTRACT");
        address customGatewayL2 = vm.envAddress("CUSTOM_GATEWAY_L2");
        address deployerAddress = vm.addr(deployerPK);

        vm.startBroadcast(deployerPK);
        console2.log("Deploying FiatManager");
        ArbMinter minter = new ArbMinter(deployerAddress);

        if (masterMinterContract == address(0)) {
            console2.log("Deploying MockMinter");
            MockMinter mockMint = new MockMinter();
            console2.log("Deployed MockMinter at address", address(minter));
            masterMinterContract = address(mockMint);
        }

        // Call FiatToken deploy script here
        // Initialize
        console2.log("Initializing FiatManager");
        minter.initialize(
            customGatewayL2,
            masterMinterContract,
            l2Fiat,
            l1Fiat
        );
    }
}
