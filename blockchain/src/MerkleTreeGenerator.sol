// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {AirdropClaim, MerkleTree} from "./struct/AirdropClaim.sol";

/**
 * @title MerkleTreeGenerator
 * @notice in charge of managing the creation of merkle root from accounts and addresses provided by an owner.
 * and will send these merkle roots to the airdrop for claims
 */
contract MerkleTreeGenerator {
    /*//////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/
    error noDataProvided();

    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/
    // tree achieved and root sent

    /*//////////////////////////////////////////////////////////////
                            STATES
    //////////////////////////////////////////////////////////////*/
    MerkleTree[] s_feed;
    IERC20 i_token;
    uint256 currentTreeIndex;

    constructor(IERC20 token) {
        i_token = token;
        currentTreeIndex = 0;
        AirdropClaim[] memory claims;
        MerkleTree memory merkleTree = MerkleTree({claims: claims, deployed: false});
        s_feed[currentTreeIndex] = merkleTree;
    }

    /*//////////////////////////////////////////////////////////////
                            FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function addAccountAndAddress(address target, uint256 amount) public {
        //is there any checks to do an addresses and amount ?
    }

    function CalculateRootAndSendToAirdrop() public {}

    /*//////////////////////////////////////////////////////////////
                            GETTERS
    //////////////////////////////////////////////////////////////*/
    function isMerkleTreeAchieved() public returns (bool) {}
}
