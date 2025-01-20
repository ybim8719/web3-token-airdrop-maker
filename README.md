
# ABOUT

This repo is a personal project that I've developed over the course of my solidity apprenticeship, integrating notions I've acquired along the way (chainlink, openzeppelin, ERC721, ERC20, etc...). 

You should therefore consider this project as a sandbox, even though the applications function normally and integrate business logic.  

 **web3-token-airdrop-maker** is based on Ciara  Nightingale (Cyfrin) tutorial on Airdrop. The initial concept is enriched with an additional functionnality. Instead of a unique merkle tree injected in the airdrop contract (for unique usage), another Builder contract will be in charge of managing the writing and creation of each merkle tree in the airdrop (which now will handle multiple sets of claims).


## Getting Started

1. Clone this repository.
2. Install Forge using the instructions found at [https://github.com/foundry-rs/foundry](https://github.com/foundry-rs/foundry).
3. Run the following command to compile the contract:

```bash
cd blockchain
forge build
```

Launch the unit tests :
```bash
forge test
```

## More about the general behaviour of the app

DurianDurianToken is the reference with the classical functions of a ERC20 token. Owner of the Token is also the owner of tne MerkleTreeBuilder, its purpose is to create a set of couple Recipient/Amount of token (also callec Claim) to be gathered in a MerkleTree. 

When all Claims are set, the merkle root is generated, MerkleRoot and an id is passed to the Airdrop, and proofs are store for each Claim.

Then any legit recipient can sign the hashed message and claim its amount by calling the Airdrop contract with required params (sig and claim info).

If all works fine, balance of the recipient will be increased with the correct amount. 

## Deployment Script 

### WIP 

Use script to deploy the 3 contracts. 

1) Mint enougth token to process

2) trasnfer them to owner

3) give approval for TreeBuilder contract

4) add claims to tree builder

5) Achieved merkle Tree

6) create sig with cast 

7) claim airdrop 

8) verify balance of recipient



## Deployment Script on Sepolia (testnet)


