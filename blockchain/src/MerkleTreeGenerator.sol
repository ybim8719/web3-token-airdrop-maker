// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

/**
 * @title MerkleTreeGenerator
 * @notice in charge of managing the creation of merkle root from accounts and addresses provided by an owner.
 * and will send these merkle roots to the airdrop for claims
 */
contract MerkleTreeGenerator {
    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    struct MerkleTree {
        AirdropClaim[] claims;
        string tree;
        bool deployed;
    }

    MerkleTree[] s_feed;

    function addAccountAndAddress(address target, uint256 amount) public {
        //is there any checks
    }
}
