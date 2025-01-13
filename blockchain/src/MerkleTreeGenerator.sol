// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title MerkleTreeGenerator
 * @notice in charge of managing the creation of merkle root from accounts and addresses provided by an owner.
 * and will send these merkle roots to the airdrop for claims
 */
contract MerkleTreeGenerator {
    /*//////////////////////////////////////////////////////////////
                            Struct
    //////////////////////////////////////////////////////////////*/
    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    struct MerkleTree {
        AirdropClaim[] claims;
        string tree;
        bool deployed;
    }
    /*//////////////////////////////////////////////////////////////
                            STATES
    //////////////////////////////////////////////////////////////*/

    MerkleTree[] s_feed;
    IERC20 i_token;

    constructor(IERC20 token) {
        i_token = token;
    }

    function addAccountAndAddress(address target, uint256 amount) public {
        //is there any checks to do an addresses and amount ?
    }
}
