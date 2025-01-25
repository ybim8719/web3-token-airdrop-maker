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

Launch the unit tests with forked URL :

set up your .env with your SEPOLIA_RPC_URL : 

```bash
source .env
```

```bash
forge test --fork-url $SEPOLIA_RPC_URL 
```

## More about the general behaviour of the app

DurianDurianToken is the reference with the classical functions of a ERC20 token. Owner of the Token is also the owner of tne MerkleTreeBuilder, its purpose is to create a set of couple Recipient/Amount of token (also callec Claim) to be gathered in a MerkleTree. 

When all Claims are set, the merkle root is generated, MerkleRoot and an id is passed to the Airdrop, and proofs are store for each Claim.

Then any legit recipient can sign the hashed message and claim its amount by calling the Airdrop contract with required params (sig and claim info).

If all works fine, balance of the recipient will be increased with the correct amount. 


## Local Deployment and manual tests

1. run Anvil (on a separate terminal): 

```anvil --gas-limit 300000001 ```


2. Run the following command to deploy the 3 contracts to a local network (<u>the private key given in example is the default account1 on anvil</u>):

```bash
forge script script/DeployApp.s.sol --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
```
Please keep the 3 given addresses for the next steps. 

Account1 is now the owner of both token and merkleTreeBuilder contracts

3. Account1 Mints enougth token as owner to proceed (10e5 ETH): 

```bash
cast send <PASTE-ADDRESS-OF-TOKEN-CONTRACT> "mint(address account, uint256 amount)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 100000000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

4. Verify account1's balance: 

```bash
cast call <PASTE-ADDRESS-OF-TOKEN-CONTRACT> "balanceOf(address account)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 
```

must be : 100000000000000000000000

(TODO )

5. account1 gives approval on its behalf to TreeBuilder address to handle transferts 

```bash
cast send <PASTE-ADDRESS-OF-TOKEN-CONTRACT> "approve(address spender, uint256 value)" <PASTE-ADDRESS-OF-MERKLE-TREE-BUILDER> 100000000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```


6. account1 add claims for account2, 3 and 4 to merkleTreeBuilder

```bash
cast send <PASTE-THE-ADDRESS-OF-MERKLE-GENERATOR> "addAccountAndAddress(address recipient, uint256 amount)" 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 2000000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

cast send <PASTE-THE-ADDRESS-OF-MERKLE-GENERATOR> "addAccountAndAddress(address recipient, uint256 amount)" 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC 3000000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

cast send <PASTE-THE-ADDRESS-OF-MERKLE-GENERATOR> "addAccountAndAddress(address recipient, uint256 amount)" 0x90F79bf6EB2c4f870365E785982E1f101E93b906 4000000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

7. do verifications : 

```bash
cast call <PASTE-THE-ADDRESS-OF-TOKEN-CONTRACT> "getCurrentTotalAmount()" 
```

=> must return : 900000000000000000000

```bash
cast call <PASTE-ADDRESS-OF-TOKEN-CONTRACT> "getCurrentNbOfClaims()" 
```

=> must return : 3



8. Finalize current merkle Tree

```bash
cast send <PASTE-ADDRESS-OF-MERKLE-BUILDER> "finalizeTree()"  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

=> merkle root was generated and sent to the Airdrop. 


9. Account2 can claim, it must first retrieve the hashed message (digest) with params corresponding to its claim: 

```bash
cast call <PASTE-ADDRESS-OF-AIRDROP> "getMessageHash(uint256 index, address account, uint256 amount)" 0 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 2000000000000000000000 
```

10. then sign the digest with its private key 

```bash
cast wallet sign --no-hash <digest> --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
```

11. Retrieve the associated proof (is index 0 since its claimed was created first)

```bash
cast call <PASTE-ADDRESS-OF-MERKLE-BUILDER> "getProof(uint256 id, uint256 index)" 0 0 
```

12. verify balance of account2 before claim

```bash
cast call <PASTE-ADDRESS-OF-TOKEN-CONTRACT> "balanceOf(address account)" 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
```

=> must return 0


13. Finally account2 claims its due amount by sending signature + address + amount to claim + proof : 

TODO....




```bash
cast send <PASTE-ADDRESS-OF-AIRDROP-CONTRACT> "claimWithSignature(uint256 id,address account,uint256 amount,bytes memory sig,bytes32[] calldata merkleProof)" 0 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 2000000000000000000000 <paste-signed-message> <paste-merkle-proof> --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
```

14. verify balance of account2 after claim


BONUS : can claimed (and pay the feed on behalf of someone else if owns the signed message)

15.


## Deployment Script on Sepolia (testnet)

### WIP 


### Convert uint with cast (hex to decimal) : 

```bash 
cast --to-base <uint-to-convert> dec
```

### Decode strings with cast abi-decode :

```bash
cast abi-decode "<function-signature> (<return-type>)" <returned-encoded-value>
```

Example : 

```
cast call <PASTE-THE-ADDRESS-OF-CONTRACT> "getName(uint256 i)" 0
```

returns :

```
0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000064a65616e4d690000000000000000000000000000000000000000000000000000
```

decode with :

```
cast abi-decode "getName(uint256 i)(string memory)" 0x0000000000000000000000000000000000000000000000000000
00000000002000000000000000000000000000000000000000000000000000000000000000064a65616e4d690000000000000000000000000000000000000000000000000000
```

result (as string):

```
"JeanMi"
```

