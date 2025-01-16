// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleTree, AirDropClaim, Proof} from "./struct/AirdropClaim.sol";
import {DurianAirDrop} from "./DurianAirDrop.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {Merkle} from "murky/src/Merkle.sol";
import {ScriptHelper} from "murky/script/common/ScriptHelper.sol";

/**
 * @title MerkleTreeGenerator
 * @notice in charge of managing the creation of merkle root from accounts and addresses provided by an owner.
 * and will send these merkle roots to the airdrop for claims
 */
contract MerkleTreeGenerator is Ownable, ScriptHelper {
    using stdJson for string; // enables us to use the json cheatcodes for strings

    Merkle private m = new Merkle(); // instance of the merkle contract from Murky to do shi

    /*//////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/

    error MerkleTreeGenerator__NoDataProvided();
    error MerkleTreeGenerator__RecipientAlreadyAdded(address recipient);
    error MerkleTreeGenerator__AmountCantBeZero(address recipient);
    error MerkleTreeGenerator__CantAchieveTreeWithoutClaims();

    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/
    event MerkleRootSent(uint256 id);
    event RecipientAdded(uint256 amount, address recipient);

    /*//////////////////////////////////////////////////////////////
                            STATES
    //////////////////////////////////////////////////////////////*/
    uint256 s_currentTreeCounter;
    mapping(uint256 index => MerkleTree) s_feed;
    IERC20 i_token;
    DurianAirDrop i_airdrop;

    constructor(IERC20 token, DurianAirDrop airdrop) Ownable(msg.sender) {
        i_token = token;
        i_airdrop = airdrop;
        s_currentTreeCounter = 1;
    }

    /*//////////////////////////////////////////////////////////////
                            FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function addAccountAndAddress(address recipient, uint256 amount) public onlyOwner {
        if (amount == 0) {
            revert MerkleTreeGenerator__AmountCantBeZero(recipient);
        }
        // account already added ?
        if (isRecipentAlreadyRegistered(s_currentTreeCounter, recipient)) {
            revert MerkleTreeGenerator__RecipientAlreadyAdded(recipient);
        }
        // add claim to existing MerkleTreeAirdropClaim
        // bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
        // bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
        // bytes32[] memory proof = [proofOne, proofTwo];

        s_feed[s_currentTreeCounter].claims.push(AirDropClaim(recipient, amount));

        s_feed[s_currentTreeCounter].nbOfClaims++;
        s_feed[s_currentTreeCounter].totalAmountToSend += amount;
        s_feed[s_currentTreeCounter].recipients[recipient] = true;
        emit RecipientAdded(amount, recipient);
    }

    function closeCurrentTreeAndSendRoot() public {
        // has claims ?
        if (getCurrentNbOfClaims() == 0) {
            revert MerkleTreeGenerator__CantAchieveTreeWithoutClaims();
        }
        makeMerkleRoot();
        // loop on claims and build root +
        // s_token.transfer(address(airdrop), amountToSend);
    }

    function makeMerkleRoot() internal {
        AirDropClaim[] memory claims = s_feed[getCurrentTreeCounter()].claims;
        bytes32[] memory leafs = new bytes32[](claims.length);
        for (uint256 i = 0; i < claims.length; ++i) {
            // convert recipient and amount to bytes32
            bytes32[] memory data = new bytes32[](2);
            address recipient = claims[i].recipient;
            // cannot push on array of bytes32
            data[0] = bytes32(uint256(uint160(recipient)));
            uint256 amount = claims[i].amount;
            data[1] = bytes32(amount);

            // abi encode the data array (each element is a bytes32 representation for the address and the amount)
            // ltrim64 Returns the bytes with the first 64 bytes removed
            // ltrim64 removes the offset and length from the encoded bytes. There is an offset because the array is declared in memory
            // hash the encoded address and amount
            // bytes.concat turns from bytes32 to bytes
            // hash again because preimage attack
            leafs[i] = keccak256(bytes.concat(keccak256(ltrim64(abi.encode(data)))));
        }

        for (uint256 i = 0; i < claims.length; ++i) {
            // bytes32[] storage truc = s_feed[getCurrentTreeCounter()].proofs;
            // // each proof is associated to related claim
            bytes32[] memory proof = m.getProof(leafs, i);
            Proof[] storage proofs = s_feed[getCurrentTreeCounter()].proofs;
            proofs.push(Proof(proof));
        }
        // string memory root = vm.toString(m.getRoot(leafs));

        // sent Root
    }

    // Ajouter une preuve
    function addMerkleProof(Proof memory proofData) public {}

    /*//////////////////////////////////////////////////////////////
                  GETTERS RELATED TO CURRENT ID 
    //////////////////////////////////////////////////////////////*/
    function getCurrentTreeCounter() public view returns (uint256) {
        return s_currentTreeCounter;
    }

    function isCurrentMerkleTreeSent() public view returns (bool) {
        return isMerkleTreeSent(getCurrentTreeCounter());
    }

    function getCurrentTotalAmount() public view returns (uint256) {
        return getTotalAmountByTree(getCurrentTreeCounter());
    }

    function getCurrentNbOfClaims() public view returns (uint256) {
        return getNbOfClaimsByTree(getCurrentTreeCounter());
    }

    function getCurrentNumberOfProofs() public view returns (uint256) {
        return getNumberOfProofs(getCurrentTreeCounter());
    }

    /*//////////////////////////////////////////////////////////////
                            OTHERS GETTERS
    //////////////////////////////////////////////////////////////*/
    function isMerkleTreeSent(uint256 id) public view returns (bool) {
        return s_feed[id].deployed;
    }

    function getTotalAmountByTree(uint256 id) public view returns (uint256) {
        return s_feed[id].totalAmountToSend;
    }

    function getNbOfClaimsByTree(uint256 id) public view returns (uint256) {
        return s_feed[id].nbOfClaims;
    }

    // function getAmountAndAndRecipient(uint256 id, uint256 index) public view returns (AirDropClaim memory) {
    //     return s_feed[id].claims[index];
    // }

    function isRecipentAlreadyRegistered(uint256 id, address recipientToFind) public view returns (bool) {
        return s_feed[id].recipients[recipientToFind];
    }

    function getNumberOfProofs(uint256 id) public view returns (uint256) {
        return s_feed[id].proofs.length;
    }
}
