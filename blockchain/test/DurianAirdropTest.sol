// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {DurianAirDrop} from "../src/DurianAirDrop.sol";
import {DurianDurianToken} from "../src/DurianDurianToken.sol";
import {MerkleTreeGenerator} from "../src/MerkleTreeGenerator.sol";
import {FullAirDropClaim} from "../src/struct/AirdropClaim.sol";

import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployApp} from "../script/DeployApp.s.sol";

contract MerkleAirdropTest is Test, ZkSyncChainChecker {
    /*//////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/
    DurianDurianToken public s_token;
    DurianAirDrop public s_airdrop;
    MerkleTreeGenerator public s_generator;
    /*//////////////////////////////////////////////////////////////
                            MOCK CONSTANTS
    //////////////////////////////////////////////////////////////*/
    uint256 public constant INITIAL_MINTING_AMOUNT = 10000 * 1e18;
    address public constant ACCOUNT1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public constant ACCOUNT2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address public constant ACCOUNT3 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    address public constant ACCOUNT4 = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
    uint256 public constant AMOUNT1 = 100 * 1e18;
    uint256 public constant AMOUNT2 = 300 * 1e18;
    uint256 public constant AMOUNT3 = 500 * 1e18;
    uint256 public constant AMOUNT4 = 700 * 1e18;

    // bytes32 ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    // bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    // bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    // bytes32[] proof = [proofOne, proofTwo];
    // uint256 amountToClaim = 25 * 1e18;
    // uint256 amountToSend = 4 * amountToClaim;
    // address user;
    // uint256 userPrivKey;
    // address public gasPayer;

    function setUp() public {
        DeployApp script = new DeployApp();
        (s_generator, s_airdrop, s_token) = script.run();
        vm.startPrank(msg.sender);
        s_token.mint(s_token.owner(), INITIAL_MINTING_AMOUNT);
        s_token.approve(address(s_generator), INITIAL_MINTING_AMOUNT);
        vm.stopPrank();
    }

    function testAddSeveralClaims() public {
        vm.assertEq(s_generator.getNbOfClaimsByTree(s_generator.getCurrentTreeCounter()), 0);
        vm.startPrank(msg.sender);
        s_generator.addAccountAndAddress(ACCOUNT1, AMOUNT1);
        s_generator.addAccountAndAddress(ACCOUNT2, AMOUNT2);
        vm.stopPrank();
        vm.assertEq(s_generator.getNbOfClaimsByTree(s_generator.getCurrentTreeCounter()), 2);
        vm.assertEq(s_generator.getNumberOfProofs(s_generator.getCurrentTreeCounter()), 0);
        vm.assertEq(s_generator.isMerkleTreeSent(s_generator.getCurrentTreeCounter()), false);
        vm.assertEq(s_generator.getTotalAmountByTree(s_generator.getCurrentTreeCounter()), AMOUNT1 + AMOUNT2);
    }

    function testAddClaimFailsIfSameRecipient() public {
        vm.startPrank(msg.sender);
        s_generator.addAccountAndAddress(ACCOUNT1, 10);
        vm.expectRevert();
        s_generator.addAccountAndAddress(ACCOUNT1, 20);
        vm.stopPrank();
    }

    function testAddClaimFailsIfNotOwner() public {
        vm.expectRevert();
        s_generator.addAccountAndAddress(ACCOUNT1, 20);
    }

    function testAddClaimFailsIfAmountIsZero() public {
        vm.startPrank(msg.sender);
        vm.expectRevert();
        s_generator.addAccountAndAddress(ACCOUNT1, 0);
        vm.stopPrank();
    }

    // vm.prank(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    // console.log(s_generator.getCurrentTreeCounter());
    // console.log(s_generator.isMerkleTreeSent(0));
    // console.log(s_generator.getNumberOfProofs(0));

    // function testUsersCanClaim() public {
    //     // uint256 startingBalance = token.balanceOf(user);
    //     // // will hash amount and address where to send money (for merkle tree verification later)
    //     // // this could like an order to send the "amount" to the "address"
    //     // bytes32 digest = airdrop.getMessageHash(user, amountToClaim);
    //     // // this actio ncan only be done by the actual signer (user)
    //     // (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);
    //     // vm.prank(gasPayer);
    //     // // user gave the v,r,s to gaspayer who will be claim onbehlf of user (but will himself pay the gas fees)
    //     // // this could be like, "hey, the user signed himself this order to claim amount for his address, and this is
    //     // // the proof that he is the author of this message"
    //     // airdrop.claim(user, amountToClaim, proof, v, r, s);
    //     // uint256 endingBalance = token.balanceOf(user);
    //     // console.log("Ending balance: %d", endingBalance);
    //     // assertEq(endingBalance - startingBalance, amountToClaim);
    // }
}
