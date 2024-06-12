#!/bin/bash

forge build

forge inspect FiatManager bytecode  > bytecode/optimism/FiatManager.txt
forge inspect L2FiatBridge bytecode  > bytecode/optimism/L2FiatBridge.txt
forge inspect Proxy bytecode > bytecode/optimism/Proxy.txt
forge inspect ArbMinter bytecode  > bytecode/arbitrum/ArbMinter.txt