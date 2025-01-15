// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
// import {console} from "forge-std/console.sol";
import {Merkle} from "murky/src/Merkle.sol";
import {ScriptHelper} from "murky/script/common/ScriptHelper.sol";
import {AirDropClaim} from "../src/struct/AirdropClaim.sol";

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
        AirDropClaim[](4) truc;
        truc.push(AirDropClaim(ACCOUNT1, AMOUNT1));
        truc.push(AirDropClaim(ACCOUNT2, AMOUNT2));
        truc.push(AirDropClaim(ACCOUNT3, AMOUNT3));
        truc.push(AirDropClaim(ACCOUNT4, AMOUNT4));

        console.log("Generating Merkle Proof");

        for (uint256 i = 0; i < truc.length; ++i) {
            bytes32[] memory data = new bytes32[](truc.length); // actual data as a bytes32

            for (uint256 j = 0; j < 2; ++j) {
                address recipient = truc[j].recipient;
                data.push(bytes32(uint256(uint160(recipient))));
                uint256 amount = truc[j].amount;
                data.push(bytes32(amount));
            }

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

        string memory root = vm.toString(m.getRoot(leafs));

        for (uint256 i = 0; i < truc.length; ++i) {
            // get proof gets the nodes needed for the proof & strigify (from helper lib)
            string memory proof = bytes32ArrayToString(m.getProof(leafs, i));
            // get the specific leaf working on

            // generate the Json output file (tree dump)
        }

        console.log("DONE: The output is found at %s");
    }
}
