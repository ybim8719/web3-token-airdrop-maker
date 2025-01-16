// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../../src/old/MerkleAirDrop.sol";
import {DurianDurianToken} from "../../src/DurianDurianToken.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../../script/old/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test, ZkSyncChainChecker {
    DurianDurianToken public token;
    MerkleAirdrop public airdrop;

    bytes32 ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [proofOne, proofTwo];
    uint256 amountToClaim = 25 * 1e18;
    uint256 amountToSend = 4 * amountToClaim;
    address user;
    uint256 userPrivKey;
    address public gasPayer;

    function setUp() public {
        if (!isZkSyncChain()) {
            //chain verification
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        } else {
            token = new DurianDurianToken();
            airdrop = new MerkleAirdrop(ROOT, token);
            token.mint(token.owner(), amountToSend);
            token.transfer(address(airdrop), amountToSend);
        }
        (user, userPrivKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        // will hash amount and address where to send money (for merkle tree verification later)
        // this could like an order to send the "amount" to the "address"
        bytes32 digest = airdrop.getMessageHash(user, amountToClaim);
        // this actio ncan only be done by the actual signer (user)
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);
        vm.prank(gasPayer);
        // user gave the v,r,s to gaspayer who will be claim onbehlf of user (but will himself pay the gas fees)
        // this could be like, "hey, the user signed himself this order to claim amount for his address, and this is
        // the proof that he is the author of this message"
        airdrop.claim(user, amountToClaim, proof, v, r, s);
        uint256 endingBalance = token.balanceOf(user);
        assertEq(endingBalance - startingBalance, amountToClaim);
    }
}
