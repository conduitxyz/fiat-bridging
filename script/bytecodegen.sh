#!/bin/bash

forge build

forge inspect FiatManager bytecode  > bytecode/optimism/FiatManager.txt
forge inspect L2FiatBridge bytecode  > bytecode/optimism/L2FiatBridge.txt
forge inspect Proxy bytecode > bytecode/optimism/Proxy.txt
forge inspect ArbMinter bytecode  > bytecode/arbitrum/ArbMinter.txt

forge inspect FiatManager abi  > bytecode/optimism/FiatManagerABI.txt
forge inspect L2FiatBridge abi  > bytecode/optimism/L2FiatBridgeABI.txt
forge inspect Proxy abi > bytecode/optimism/ProxyABI.txt
forge inspect ArbMinter abi  > bytecode/arbitrum/ArbMinterABI.txt