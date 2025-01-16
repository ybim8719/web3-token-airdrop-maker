// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
// import {console} from "forge-std/console.sol";
import {Merkle} from "murky/src/Merkle.sol";
import {ScriptHelper} from "murky/script/common/ScriptHelper.sol";
import {AirDropClaim} from "../src/struct/AirdropClaim.sol";

/**
 * @notice Created for tests purpose: creation of merkle root, leaves and proofs from hardcoded sets of address + amount.
 */
contract TestMakeMerkle is Script, ScriptHelper {
    using stdJson for string; // enables us to use the json cheatcodes for strings

    address public constant ACCOUNT1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public constant ACCOUNT2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address public constant ACCOUNT3 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    address public constant ACCOUNT4 = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
    uint256 public constant AMOUNT1 = 100 * 1e18;
    uint256 public constant AMOUNT2 = 300 * 1e18;
    uint256 public constant AMOUNT3 = 500 * 1e18;
    uint256 public constant AMOUNT4 = 700 * 1e18;
    Merkle private m = new Merkle(); // instance of the merkle contract from Murky to do shi

    // make three arrays the same size as the number of leaf nodes
    bytes32[] private leafs = new bytes32[](4);

    string[] private inputs = new string[](4);
    string[] private outputs = new string[](4);

    string private output;

    /// @dev Read the input file and generate the Merkle proof, then write the output file
    function run() public {
        AirDropClaim[] memory truc = new AirDropClaim[](4);
        truc[0] = AirDropClaim(ACCOUNT1, AMOUNT1);
        truc[1] = AirDropClaim(ACCOUNT2, AMOUNT2);
        truc[2] = AirDropClaim(ACCOUNT3, AMOUNT3);
        truc[3] = AirDropClaim(ACCOUNT4, AMOUNT4);

        console.log("Generating Merkle Proof");

        for (uint256 i = 0; i < truc.length; ++i) {
            bytes32[] memory data = new bytes32[](2); // actual data as a bytes32
            address recipient = truc[i].recipient;
            console.log(recipient, "recipient");
            data[0] = bytes32(uint256(uint160(recipient)));
            uint256 amount = truc[i].amount;
            console.log(amount, "amount");
            data[1] = bytes32(amount);

            console.log(bytes32ArrayToString(data), "data before leaf");

            // Create the hash for the merkle tree leaf node
            // abi encode the data array (each element is a bytes32 representation for the address and the amount)
            // Helper from Murky (ltrim64) Returns the bytes with the first 64 bytes removed
            // ltrim64 removes the offset and length from the encoded bytes. There is an offset because the array
            // is declared in memory
            // hash the encoded address and amount
            // bytes.concat turns from bytes32 to bytes
            // hash again because preimage attack
            leafs[i] = keccak256(bytes.concat(keccak256(ltrim64(abi.encode(data)))));
        }

        console.log(bytes32ArrayToString(leafs), "final leaves");

        string memory root = vm.toString(m.getRoot(leafs));
        console.log(root, "root");

        for (uint256 i = 0; i < truc.length; ++i) {
            console.log(i, "index");
            // get proof gets the nodes needed for the proof & strigify (from helper lib)
            bytes32[] memory proof = m.getProof(leafs, i);
            console.log(bytes32ArrayToString(proof), "proof");
            // TODO proof must be stored in the state of generator.
        }
    }
}
