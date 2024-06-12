// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";

import {ArbMinter} from "src/arbitrum/ArbMinter.sol";

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

        // Call FiatToken deploy script here
        // Initialize
        minter.initialize(
            customGatewayL2,
            masterMinterContract,
            l2Fiat,
            l1Fiat
        );

        console2.log("Deploying Proxy");
    }
}
