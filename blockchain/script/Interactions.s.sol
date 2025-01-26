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
contract ClaimAirdropForAccount2 is Script {
    address public ACCOUNT2_ADDRESS = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    uint256 public AMOUNT2_TO_COLLECT = 2000000000000000000000;
    // proof elements were found with call to "getProofElement(uint256 id, uint256 index, uint256 elementIndex)" with cast.
    bytes32 proofOne = 0xe64634f225cb5d86bbe45ae788f559d097f1674ebbe83d625d885d2f3acd861a;
    bytes32 proofTwo = 0x3249c2e3e38539dd3dc2044e77620e67da13bfe20c5543bc1ab88e038f99ed8b;
    bytes32[] proof = [proofOne, proofTwo];
    // signature made by account2 was handled using
    // cast wallet sign --no-hash <hashed-message> --private-key <account2-private-key>
    // and gave => 0xc53e1579acc7973a62e6fadd5ba73eac13d95145d6cd7cfbc9f5f4f8785419b23e751f3803e513c86165a204f40af93b3db8f6cce13ebb0961618e37b1cc59501c
    // hashed message was called here: "getMessageHash(uint256 index, address account, uint256 amount)"
    bytes private signature =
        hex"c53e1579acc7973a62e6fadd5ba73eac13d95145d6cd7cfbc9f5f4f8785419b23e751f3803e513c86165a204f40af93b3db8f6cce13ebb0961618e37b1cc59501c";

    error __ClaimAirdropScript__InvalidSignatureLength();

    // This script will call the claim function of airdrop by passing (account2 address + amount to claim + signature above + proof)
    // forge script script/Interact.s.sol:ClaimAirdropForAccount2 --rpc-url http://localhost:8545 --private-key <private-key-of-anvil-account-2> --broadcast
    function claimAirdrop(address airdrop) public {
        vm.startBroadcast();
        // (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);
        DurianAirDrop(airdrop).claimWithSignature(0, ACCOUNT2_ADDRESS, AMOUNT2_TO_COLLECT, signature, proof);
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("DurianAirDrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }
}
