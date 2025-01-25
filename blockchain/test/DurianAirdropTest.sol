// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {DurianAirDrop} from "../src/DurianAirDrop.sol";
import {DurianDurianToken} from "../src/DurianDurianToken.sol";
import {MerkleTreeBuilder} from "../src/MerkleTreeBuilder.sol";
import {FullAirDropClaim} from "../src/struct/AirdropClaim.sol";

import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployApp} from "../script/DeployApp.s.sol";
import {ScriptHelper} from "murky/script/common/ScriptHelper.sol";

contract MerkleAirdropTest is Test, ZkSyncChainChecker, ScriptHelper {
    /*//////////////////////////////////////////////////////////////
                            STATE
    //////////////////////////////////////////////////////////////*/
    DurianDurianToken public s_token;
    DurianAirDrop public s_airdrop;
    MerkleTreeBuilder public s_treeBuilder;
    address public gasPayer;
    uint256 finalizedTreeId;
    /*//////////////////////////////////////////////////////////////
                            MOCK CONSTANTS
    //////////////////////////////////////////////////////////////*/
    uint256 public constant INITIAL_MINTING_AMOUNT = 10000 * 1e18;
    address public constant ACCOUNT1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public constant ACCOUNT2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address public constant ACCOUNT3 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    address public constant ACCOUNT4 = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
    uint256 public constant ACCOUNT1_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 public constant ACCOUNT2_PRIVATE_KEY = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    uint256 public constant AMOUNT1 = 100 * 1e18;
    uint256 public constant AMOUNT2 = 300 * 1e18;
    uint256 public constant AMOUNT3 = 500 * 1e18;
    uint256 public constant AMOUNT4 = 700 * 1e18;
    bytes32 public constant ROOT = 0xcd4f4f30e5f9c3c99653cade33a38a0aeba43de7d3dbd5c16001e52c35ea8ff0;
    bytes32 public constant PARTIAL_PROOF1 = 0xe151be5479ef624d6dc5498cb022ec808d8e3050a6d7da9ea1eaf67eeecde24d;
    bytes32 public constant PARTIAL_PROOF2 = 0x790e48c02645fb7bbef96b522c95e3a425b4cfbacf621dbf1bb29697c128bdd9;
    bytes32[] PROOF1 = [PARTIAL_PROOF1, PARTIAL_PROOF2];
    uint256 PROOF1_INDEX = 0;
    uint256 PROOF2_INDEX = 1;
    bytes32 HASHED_MESSAGE1 = 0x21ce308936266c704f367120cdd19174d1837ec4709d288936ec447a93ba93a8;

    function setUp() public {
        DeployApp script = new DeployApp();
        (s_treeBuilder, s_airdrop, s_token) = script.run();
        vm.startPrank(msg.sender);
        s_token.mint(s_token.owner(), INITIAL_MINTING_AMOUNT);
        s_token.approve(address(s_treeBuilder), INITIAL_MINTING_AMOUNT);
        vm.stopPrank();
    }

    modifier treeReadyForFinalizing() {
        vm.startPrank(msg.sender);
        s_treeBuilder.addAccountAndAddress(ACCOUNT1, AMOUNT1);
        s_treeBuilder.addAccountAndAddress(ACCOUNT2, AMOUNT2);
        s_treeBuilder.addAccountAndAddress(ACCOUNT3, AMOUNT3);
        s_treeBuilder.addAccountAndAddress(ACCOUNT4, AMOUNT4);
        vm.stopPrank();
        _;
    }

    modifier merkleTreeFinalized() {
        vm.startPrank(msg.sender);
        s_treeBuilder.addAccountAndAddress(ACCOUNT1, AMOUNT1);
        s_treeBuilder.addAccountAndAddress(ACCOUNT2, AMOUNT2);
        s_treeBuilder.addAccountAndAddress(ACCOUNT3, AMOUNT3);
        s_treeBuilder.addAccountAndAddress(ACCOUNT4, AMOUNT4);
        finalizedTreeId = s_treeBuilder.getCurrentTreeId();
        s_treeBuilder.finalizeTree();
        vm.stopPrank();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                MERKEL TREE BUILDER -> addAccountAndAddress
    //////////////////////////////////////////////////////////////*/
    function testAddSeveralClaims() public {
        vm.assertEq(s_treeBuilder.getNbOfClaimsByTree(s_treeBuilder.getCurrentTreeId()), 0);
        vm.startPrank(msg.sender);
        s_treeBuilder.addAccountAndAddress(ACCOUNT1, AMOUNT1);
        s_treeBuilder.addAccountAndAddress(ACCOUNT2, AMOUNT2);
        vm.stopPrank();
        // total amount, nb of proof, claims and status must be ok
        vm.assertEq(s_treeBuilder.getNbOfClaimsByTree(s_treeBuilder.getCurrentTreeId()), 2);
        vm.assertEq(s_treeBuilder.getNumberOfProofs(s_treeBuilder.getCurrentTreeId()), 0);
        vm.assertEq(s_treeBuilder.isMerkleTreeSent(s_treeBuilder.getCurrentTreeId()), false);
        vm.assertEq(s_treeBuilder.getTotalAmountByTree(s_treeBuilder.getCurrentTreeId()), AMOUNT1 + AMOUNT2);
    }

    function testAddClaimFailsIfSameRecipient() public {
        vm.startPrank(msg.sender);
        s_treeBuilder.addAccountAndAddress(ACCOUNT1, 10);
        vm.expectRevert();
        s_treeBuilder.addAccountAndAddress(ACCOUNT1, 20);
        vm.stopPrank();
    }

    function testAddClaimFailsIfNotOwner() public {
        vm.expectRevert();
        s_treeBuilder.addAccountAndAddress(ACCOUNT1, 20);
    }

    function testAddClaimFailsIfAmountIsZero() public {
        vm.startPrank(msg.sender);
        vm.expectRevert(
            abi.encodeWithSelector(MerkleTreeBuilder.MerkleTreeBuilder__AmountCantBeZero.selector, ACCOUNT1)
        );
        s_treeBuilder.addAccountAndAddress(ACCOUNT1, 0);
        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                    MERKEL TREE BUILDER -> finalizeTree
    //////////////////////////////////////////////////////////////*/
    function testFinalizeTreeFailsIfNoClaimsInto() public {
        vm.prank(msg.sender);
        vm.expectRevert(MerkleTreeBuilder.MerkleTreeBuilder__CantFinalizeTreeWithoutClaims.selector);
        s_treeBuilder.finalizeTree();
    }

    function testFinalizeTreeWorks() public treeReadyForFinalizing {
        uint256 initialOwnerBalance = s_token.balanceOf(s_token.owner());
        vm.prank(msg.sender);
        s_treeBuilder.finalizeTree();

        uint256 previousId = s_treeBuilder.getCurrentTreeId() - 1;
        // amount of claims transfered from owner to airdrop
        assertEq(initialOwnerBalance, s_token.balanceOf(s_token.owner()) + s_token.balanceOf(address(s_airdrop)));
        // 4 claims gives 4 proofs
        assertEq(s_treeBuilder.getNumberOfProofs(previousId), 4);
        assertEq(s_treeBuilder.getNbOfClaimsByTree(previousId), 4);
        // tree is locked
        assertEq(s_treeBuilder.isMerkleTreeSent(previousId), true);
        // tests root and proofs
        assertEq(s_airdrop.getNfOfMerkleRoots(), 1);
        assertEq(s_treeBuilder.getProof(previousId, 0), PROOF1);
        assertEq(s_airdrop.getMerkleRoot(0), ROOT);
    }

    /*//////////////////////////////////////////////////////////////
                        AIRDROP -> getMessageHash
    //////////////////////////////////////////////////////////////*/
    function testGetAHashedMessage() public view {
        assertEq(s_airdrop.getMessageHash(0, ACCOUNT1, AMOUNT1), HASHED_MESSAGE1);
    }
    /*//////////////////////////////////////////////////////////////
                        AIRDROP -> claim with Sig // could find a cheatcode to general signatures
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                            AIRDROP -> claim with VRS
    //////////////////////////////////////////////////////////////*/
    function testAnotherGasPayerCanClaimOnBehalfOfLegitUser() public merkleTreeFinalized {
        gasPayer = makeAddr("gasPayer");
        uint256 startingBalance = s_token.balanceOf(ACCOUNT1);
        bytes32 digest = s_airdrop.getMessageHash(finalizedTreeId, ACCOUNT1, AMOUNT1);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ACCOUNT1_PRIVATE_KEY, digest);
        vm.prank(gasPayer);
        // user gave the v,r,s to gaspayer who will be claim onbehalf of user (but will himself pay the gas fees)
        // this could be like, "hey, the user signed himself this order to claim amount for his address, and this is
        // the proof that he is the author of this message"
        s_airdrop.claimWithVrs(
            finalizedTreeId, ACCOUNT1, AMOUNT1, s_treeBuilder.getProof(finalizedTreeId, PROOF1_INDEX), v, r, s
        );
        uint256 endingBalance = s_token.balanceOf(ACCOUNT1);
        assertEq(endingBalance - startingBalance, AMOUNT1);
    }

    function testLegitUserCanClaimItsMoney() public merkleTreeFinalized {
        uint256 startingBalance = s_token.balanceOf(ACCOUNT1);
        bytes32 digest = s_airdrop.getMessageHash(finalizedTreeId, ACCOUNT1, AMOUNT1);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ACCOUNT1_PRIVATE_KEY, digest);

        vm.startPrank(ACCOUNT1);
        s_airdrop.claimWithVrs(
            finalizedTreeId, ACCOUNT1, AMOUNT1, s_treeBuilder.getProof(finalizedTreeId, PROOF1_INDEX), v, r, s
        );
        vm.stopPrank();
        uint256 endingBalance = s_token.balanceOf(ACCOUNT1);
        assertEq(endingBalance - startingBalance, AMOUNT1);
    }

    function testLegitUserCantClaimTwoTimes() public merkleTreeFinalized {
        bytes32 digest = s_airdrop.getMessageHash(finalizedTreeId, ACCOUNT1, AMOUNT1);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ACCOUNT1_PRIVATE_KEY, digest);
        bytes32[] memory p = s_treeBuilder.getProof(finalizedTreeId, PROOF1_INDEX);
        vm.startPrank(ACCOUNT1);
        s_airdrop.claimWithVrs(finalizedTreeId, ACCOUNT1, AMOUNT1, p, v, r, s);
        vm.expectRevert(DurianAirDrop.DurianAirdrop__AlreadyClaimed.selector);
        s_airdrop.claimWithVrs(finalizedTreeId, ACCOUNT1, AMOUNT1, p, v, r, s);
        vm.stopPrank();
    }

    function testClaimFailsWithInvalidProof() public merkleTreeFinalized {
        bytes32 digest = s_airdrop.getMessageHash(finalizedTreeId, ACCOUNT1, AMOUNT1);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ACCOUNT1_PRIVATE_KEY, digest);
        // sending PROOF of Account2 instead of 1
        bytes32[] memory p = s_treeBuilder.getProof(finalizedTreeId, PROOF2_INDEX);
        vm.prank(ACCOUNT1);
        vm.expectRevert(DurianAirDrop.DurianAirdrop__InvalidProof.selector);
        s_airdrop.claimWithVrs(finalizedTreeId, ACCOUNT1, AMOUNT1, p, v, r, s);
    }

    function testClaimFailsWithInvalidSig() public merkleTreeFinalized {
        bytes32 digest = s_airdrop.getMessageHash(finalizedTreeId, ACCOUNT1, AMOUNT1);
        // signing with account2 privKey instead of 1
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ACCOUNT2_PRIVATE_KEY, digest);
        bytes32[] memory p = s_treeBuilder.getProof(finalizedTreeId, PROOF1_INDEX);
        vm.prank(ACCOUNT1);
        vm.expectRevert(DurianAirDrop.DurianAirdrop__InvalidSignature.selector);
        s_airdrop.claimWithVrs(finalizedTreeId, ACCOUNT1, AMOUNT1, p, v, r, s);
    }
}
