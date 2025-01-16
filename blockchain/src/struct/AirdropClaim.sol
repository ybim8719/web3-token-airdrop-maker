// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

struct FullAirDropClaim {
    uint256 index;
    address recipient;
    uint256 amount;
}

struct Proof {
    bytes32[] data;
}

struct AirDropClaim {
    address recipient;
    uint256 amount;
}

struct MerkleTree {
    AirDropClaim[] claims;
    bool sendToAirdrop;
    uint256 nbOfClaims;
    uint256 totalAmountToSend;
    bytes32[][] proofs;
    mapping(address recipient => bool isRegistered) recipients;
}
