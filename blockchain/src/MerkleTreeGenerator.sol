// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {MerkleTree, AirDropClaim} from "./struct/AirdropClaim.sol";
import {DurianAirDrop} from "./DurianAirDrop.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MerkleTreeGenerator
 * @notice in charge of managing the creation of merkle root from accounts and addresses provided by an owner.
 * and will send these merkle roots to the airdrop for claims
 */
contract MerkleTreeGenerator is Ownable {
    /*//////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/
    error MerkleTreeGenerator__NoDataProvided();
    error MerkleTreeGenerator__RecipientAlreadyAdded(address recipient);
    error MerkleTreeGenerator__AmountCantBeZero(address recipient);

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
        s_feed[s_currentTreeCounter].claims.push(AirDropClaim(recipient, amount));
        s_feed[s_currentTreeCounter].nbOfClaims++;
        s_feed[s_currentTreeCounter].totalAmountToSend += amount;
        s_feed[s_currentTreeCounter].recipients[recipient] = true;
        emit RecipientAdded(amount, recipient);
    }

    function closeTreeAndSendRoot() public {
        // id exists ?
        // has claims ?

        // loop on claims and build root +
        // s_token.transfer(address(airdrop), amountToSend);
    }

    /*//////////////////////////////////////////////////////////////
                            GETTERS
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

    function getAmountAndAndRecipient(uint256 id, uint256 index) public view returns (AirDropClaim memory) {
        return s_feed[id].claims[index];
    }

    function getCurrentTreeCounter() public view returns (uint256) {
        return s_currentTreeCounter;
    }

    function isRecipentAlreadyRegistered(uint256 id, address recipientToFind) public view returns (bool) {
        return s_feed[id].recipients[recipientToFind];
    }

    function getNumberOfProofs(uint256 id) public view returns (uint256) {
        return s_feed[id].proofs.length;
    }
}
