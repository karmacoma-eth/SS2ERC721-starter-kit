# 🪂 SS2ERC721 Starter Kit

[SS2ERC721](https://github.com/showtime-xyz/SS2ERC721) is an ERC721 base contract that uses SSTORE2 for extremely efficient batch minting, as in mass airdrops to large numbers of recipients.

This repository demonstrates how to deploy a very simple but usable implementation, [SimpleSS2ERC721](https://github.com/karmacoma-eth/SS2ERC721-starter-kit/blob/main/src/SimpleSS2ERC721.sol).

Some observations:
- it is an ownable contract that implements `SS2ERC721`
- it expects the final owner of the contract as a constructor argument
- the constructor also expects the typical `name`, `symbol` and `baseURI` parameters
- it exposes a `mintBatch(bytes calldata packedRecipients)` that only the contract owner can execute
- it exposes `tokenURI(uint256 id)`, that simply returns the concatenation of `baseURI` with the token id

And that's it! If that's all you need, you can certainly use it as is. No bells and whistles, just the simplest possible `SimpleSS2ERC721` implementation that still behaves the way you would expect from a regular NFT.

## The numbers

Using the deployment script attached:

| action | cost in gas | cost in ETH at 40 gwei |
| --- | --- | --- |
| deploy | 1.27M | 0.05 |
| mint batch of 1200 | 7.67M | 0.30 |

To put it differently, minting 1200 NFTs costs 6.4k gas per mint, about 90% cheaper than the most efficient "regular" ERC721 implementations.

## Getting started

### Pre-requisites

⚠️ **IMPORTANT**: make sure you have read and understood the [safety risks and limitations associated with SS2ERC721](https://github.com/showtime-xyz/SS2ERC721#safety)

1. [Install foundry](https://book.getfoundry.sh/getting-started/installation)
1. clone/fork this repository (or click `Use this template`)
1. `cp .env.example .env`
1. generate a new wallet/deployer address with `cast wallet new`
1. configure the `PRIVATE_KEY` section of the `.env` file with the private key you just generated
1. configure `ETHERSCAN_API_KEY` if you intend to deploy and verify the contract on a real chain
1. run `forge test`, the tests should come out clean

### Deploying and minting

The deployment script [SimpleSS2ERC721.s.sol](https://github.com/karmacoma-eth/SS2ERC721-starter-kit/blob/main/script/SimpleSS2ERC721.s.sol) will do the following:

1. load the `PRIVATE_KEY` from your `.env`, use the corresponding address to send transactions
1. load the configuration from [token-config.json](https://github.com/karmacoma-eth/SS2ERC721-starter-kit/blob/main/token-config.json)
1. deploy `SimpleSS2ERC721` with your configuration
1. mint an NFT to all the `recipients` in [token-config.json](https://github.com/karmacoma-eth/SS2ERC721-starter-kit/blob/main/token-config.json) in a single transaction
1. (optionally) transfer the ownership of the contract to the `owner` address specified in [token-config.json](https://github.com/karmacoma-eth/SS2ERC721-starter-kit/blob/main/token-config.json)

If this all makes sense to you, you are now ready to go!

```sh
# configure `token-config.json` with the parameters that make sense for your collection
# note that the `recipients` in `token-config.json` need to be sorted in ascending numerical order, with no duplicates

# run a local simulation of the deployment, you should see the token transfers to the recipients in the trace (e.g. `emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x1111111111111111111111111111111111111111, id: 1)`)

forge script script/SimpleSS2ERC721.s.sol -vvvv

# run a simulation against a network

forge script script/SimpleSS2ERC721.s.sol --rpc-url <rpc>

# if everything looks good, deploy and mint!

forge script script/SimpleSS2ERC721.s.sol --rpc-url <rpc> --broadcast --verify --watch
```

## What's the catch though?

The most notable limitation is that SS2ERC721 does not support on-demand minting, only batch minting. And in the case of the specific implementation used in this starter kit, only a _single_ batch is supported, with a maximum size of 1228 recipients.

The other big trade-off is that SS2ERC721 initializes as little storage as possible upfront, instead delaying writes to storage on transfers. This makes transfers initially more expensive, and the view functions `ownerOf` and `balanceOf` are also more complex and more expensive.

Check out the [full SS2ERC721 documentation](https://github.com/showtime-xyz/SS2ERC721#trade-offs) for more details about the trade-offs.

