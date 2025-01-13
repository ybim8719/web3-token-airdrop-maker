// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

struct AirdropClaim {
    address account;
    uint256 amount;
}

struct MerkleTree {
    AirdropClaim[] claims;
    string tree;
    bool deployed;
}
