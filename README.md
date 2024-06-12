## Fiat Bridging Contracts


The files under optimism/ are a direct fork of the BOB USDC Bridge ([Proxy](https://explorer.gobob.xyz/address/0xe497788f8fcc30b773c9a181a0ffe2e60645ce90?tab=contract), [Implementation](https://explorer.gobob.xyz/address/0xF3f7831F9ebF1065dAD83b8Eb579b47D29F9198F)), and the USDC Manager [Contract](https://explorer.gobob.xyz/address/0x6b9f677B6c45c32F5f10A5EfA14bDfefE2135B67?tab=contract)


FiatMinterManager is a fork of the USDC manager contract, with additional functions to directly support minting and burning so that it can be used in conjunction with the Arbitrum Custom Gateway contract.