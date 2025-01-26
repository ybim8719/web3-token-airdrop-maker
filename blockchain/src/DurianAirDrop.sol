// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {FullAirDropClaim} from "../src/struct/AirdropClaim.sol";
import {console} from "forge-std/Script.sol";

contract DurianAirDrop is EIP712 {
    using SafeERC20 for IERC20;

    bytes32 private constant MESSAGE_TYPEHASH =
        keccak256("FullAirDropClaim(uint256 index,address recipient,uint256 amount)");

    /*//////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/
    error DurianAirdrop__InvalidProof();
    error DurianAirdrop__AlreadyClaimed();
    error DurianAirdrop__InvalidSignature();
    error DurianAirdrop__InvalidSignatureLength();

    /*//////////////////////////////////////////////////////////////
                            EVENT
    //////////////////////////////////////////////////////////////*/
    event Claimed(uint256 id, address indexed account, uint256 indexed amount);

    /*//////////////////////////////////////////////////////////////
                            STATES
    //////////////////////////////////////////////////////////////*/
    IERC20 private immutable i_airdropToken;
    mapping(uint256 rootId => bytes32 root) private s_merkleRoots;
    mapping(uint256 rootId => mapping(address claimer => bool hasClaimed)) private s_hasClaimed;
    uint256 private s_nbOfMerkleRoots = 0;

    constructor(IERC20 airdropToken) EIP712("Airdrop", "1") {
        i_airdropToken = airdropToken;
    }

    /*//////////////////////////////////////////////////////////////
                            FUNCTIONS STATES
    //////////////////////////////////////////////////////////////*/
    function addMerkleRoot(uint256 rootId, bytes32 merkleRoot) public {
        s_merkleRoots[rootId] = merkleRoot;
        s_nbOfMerkleRoots++;
    }

    // sig can be generated wiyh cast : cast wallet sign --no-hash <hashed-message> --private-key <private-key>
    // however couldn't find out it how it be done programmatically with vm (for test purposes)
    function claimWithSignature(
        uint256 id,
        address account,
        uint256 amount,
        bytes memory sig,
        bytes32[] calldata merkleProof
    ) external {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
        checkAndHandleTransfer(id, account, amount, merkleProof, v, r, s);
    }

    function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) {
            revert DurianAirdrop__InvalidSignatureLength();
        }
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function claimWithVrs(
        uint256 id,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        checkAndHandleTransfer(id, account, amount, merkleProof, v, r, s);
    }

    function checkAndHandleTransfer(
        uint256 id,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        if (s_hasClaimed[id][account]) {
            revert DurianAirdrop__AlreadyClaimed();
        }
        // // check if account is really the signer of the message
        if (!_isValidSignature(account, getMessageHash(id, account, amount), v, r, s)) {
            revert DurianAirdrop__InvalidSignature();
        }

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, s_merkleRoots[id], leaf)) {
            revert DurianAirdrop__InvalidProof();
        }

        console.log("account is ", account);
        console.log("amout is ", amount);

        s_hasClaimed[id][account] = true;
        emit Claimed(id, account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    /*//////////////////////////////////////////////////////////////
                            GETTERS
    //////////////////////////////////////////////////////////////*/
    function getNfOfMerkleRoots() public view returns (uint256) {
        return s_nbOfMerkleRoots;
    }

    function hasClaimed(uint256 id, address account) public view returns (bool) {
        return s_hasClaimed[id][account];
    }

    /*//////////////////////////////////////////////////////////////
                            TOOLS
    //////////////////////////////////////////////////////////////*/
    function getMessageHash(uint256 index, address account, uint256 amount) public view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(
                abi.encode(MESSAGE_TYPEHASH, FullAirDropClaim({index: index, recipient: account, amount: amount}))
            )
        );
    }

    function _isValidSignature(address signer, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (bool)
    {
        (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s);
        return (actualSigner == signer);
    }
}
