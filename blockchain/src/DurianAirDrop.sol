// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract DurianAirDrop is EIP712 {
    using SafeERC20 for IERC20;

    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account,uint256 amount)");

    /*//////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    /*//////////////////////////////////////////////////////////////
                            EVENT
    //////////////////////////////////////////////////////////////*/
    event Claimed(address indexed account, uint256 indexed amount);

    /*//////////////////////////////////////////////////////////////
                            STATES
    //////////////////////////////////////////////////////////////*/
    IERC20 private immutable i_airdropToken;
    bytes32[] private s_merkleRoots;
    mapping(address claimer => bool hasClaimed)[] private s_hasClaimedByRoot;

    constructor(IERC20 airdropToken) EIP712("Airdrop", "1") {
        i_airdropToken = airdropToken;
    }

    /*//////////////////////////////////////////////////////////////
                            FUNCTIONS STATES
    //////////////////////////////////////////////////////////////*/
    function addMerkleTree(bytes32 merkleRoot) public {
        s_merkleRoots.push(merkleRoot);
    }

    function claim(
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // if (s_hasClaimed[account]) {
        //     revert MerkleAirdrop__AlreadyClaimed();
        // }
        // // check if account is really the signer of the message
        // if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
        //     revert MerkleAirdrop__InvalidSignature();
        // }

        // bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        // if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
        //     revert MerkleAirdrop__InvalidProof();
        // }
        // s_hasClaimed[account] = true;
        // emit Claimed(account, amount);
        // i_airdropToken.safeTransfer(account, amount);
    }

    /*//////////////////////////////////////////////////////////////
                           HELPER
    //////////////////////////////////////////////////////////////*/
    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        // return _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount}))));
    }

    /*//////////////////////////////////////////////////////////////
                            GETTERS
    //////////////////////////////////////////////////////////////*/
    function getMerkleRoot(uint256 i) public view returns (bytes32) {
        return s_merkleRoots[i];
    }

    function getMerkleRootsLength() public view returns (uint256) {
        return s_merkleRoots.length;
    }

    function getAirdropToken() public view returns (IERC20) {
        return i_airdropToken;
    }

    /*//////////////////////////////////////////////////////////////
                            UTILS
    //////////////////////////////////////////////////////////////*/
    function _isValidSignature(address signer, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (bool)
    {
        (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s);
        return (actualSigner == signer);
    }
}
