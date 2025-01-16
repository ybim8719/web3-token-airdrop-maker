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
    bool deployed;
    uint256 nbOfClaims;
    uint256 totalAmountToSend;
    Proof[] proofs;
    mapping(address recipient => bool isRegistered) recipients;
}
