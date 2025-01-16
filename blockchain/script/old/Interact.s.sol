// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirDrop.sol";

/**
 * Original Work by:
 * @author Ciara Nightingale
 * @author Cyfrin
 */
contract ClaimAirdrop is Script {
    address public CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 public AMOUNT_TO_COLLECT = 25 * 1e18;
    bytes32 proofOne = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [proofOne, proofTwo];
    bytes private signature =
        hex"2c8855d7cbe1062b7d933545a4b5b7f9290a8f886b988f6355effa3980b6830237e9e17437c20a3ce29bde800e0777bbd7f0c08f9b952ebefd22c5f5691998721b";

    error __ClaimAirdropScript__InvalidSignatureLength();

    // RECAP of what to do :

    // STEP 1: launch DeployMerkleAirdrop with anvil OPEN
    // Account 1 of anvil is allowed to claim the 25 * 10e18 ETH (because written in merkle leaf and proof and so on)
    // Deployment of DeployMerkleAirdrop will deploy DurianDurianToken and MerkleAirdrop contracts. Merkle root is passed to airdrop so it can ensure who is approved to claim
    // using make deploy

    // STEP 2
    // CLI:  hash the message using the helper in airdrop (pass anvil account1 & amount to transfer)
    // cast call <airdrop-contract-address-in-anvil> "getMessageHash(address,uint256)" <anvil-account-1> <authorized-amount-in-merkle-tree-> --rpc-url http://localhost:8545
    // a hased message is retrieve and used below

    // STEP 3
    // CLI: anvil account 1 signs the hashed message (digest) with the private key
    // SIGNING OF MESSAGE WILL BE DONE DIRECTLY WITH CAST
    // cast wallet sign --no-hash <hashed-message> --private-key <private-key-of-anvil-account-1>
    // gives this final signature (r,s,v inside):
    // 0x2c8855d7cbe1062b7d933545a4b5b7f9290a8f886b988f6355effa3980b6830237e9e17437c20a3ce29bde800e0777bbd7f0c08f9b952ebefd22c5f5691998721b
    // remove the 0x and keep the rest as signature pasted in the bytes private signature above

    // STEP 4
    // launch Interact.s.sol / account 2 will call the claim function of airdrop by passing (anvil1 + amount to claim + vrs from sig above)
    // The airdrop will verify that sig is made by the account 1 authorize the transfer.
    // forge script script/Interact.s.sol:ClaimAirdrop --rpc-url http://localhost:8545 --private-key <private-key-of-anvil-account-2> --broadcast
    // private here is the second account of anvil
    //

    // STEP 5
    // check if anvil account1 has received the money
    // cast call <token-address-deployed-on-anvil> "balanceOf(address)" <address-of-anvil-account1>
    // gives 0x0000000000000000000000000000000000000000000000015af1d78b58c40000
    // convert : cast --to-dec 0x000000000000000000000000000000000000000000000015af1d78b58c40000
    // equals 25000000000000000000

    function claimAirdrop(address airdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, AMOUNT_TO_COLLECT, proof, v, r, s);
        vm.stopBroadcast();
    }

    function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) {
            revert __ClaimAirdropScript__InvalidSignatureLength();
        }
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }
}
