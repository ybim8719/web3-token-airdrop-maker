// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {DurianAirDrop} from "../src/DurianAirDrop.sol";

/**
 * Original Work by:
 * @author Ciara Nightingale
 * @author Cyfrin
 */
contract ClaimAirdrop is Script {
    address public CLAIMING_ADDRESS = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    uint256 public AMOUNT_TO_COLLECT = 2000000000000000000000;
    // bytes32 proofOne = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    // bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    // bytes32[] proof = [proofOne, proofTwo];

    // bytes32[] proof =
    //     0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000002e64634f225cb5d86bbe45ae788f559d097f1674ebbe83d625d885d2f3acd861a3249c2e3e38539dd3dc2044e77620e67da13bfe20c5543bc1ab88e038f99ed8b;
    bytes private signature =
        hex"c53e1579acc7973a62e6fadd5ba73eac13d95145d6cd7cfbc9f5f4f8785419b23e751f3803e513c86165a204f40af93b3db8f6cce13ebb0961618e37b1cc59501c";

    error __ClaimAirdropScript__InvalidSignatureLength();

    // launch Interactions.s.sol / account 2 will call the claim function of airdrop by passing (anvil2 address + amount to claim + vrs from sig above + proof)
    // forge script script/Interact.s.sol:ClaimAirdrop --rpc-url http://localhost:8545 --private-key <private-key-of-anvil-account-2> --broadcast

    // STEP 5
    // check if anvil account1 has received the money
    // cast call <token-address-deployed-on-anvil> "balanceOf(address)" <address-of-anvil-account1>
    // gives 0x0000000000000000000000000000000000000000000000015af1d78b58c40000
    // convert : cast --to-dec 0x000000000000000000000000000000000000000000000015af1d78b58c40000
    // equals 25000000000000000000

    function claimAirdrop(address airdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);
        DurianAirDrop(airdrop).claim(CLAIMING_ADDRESS, AMOUNT_TO_COLLECT, proof, v, r, s);
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
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("DurianAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }
}
