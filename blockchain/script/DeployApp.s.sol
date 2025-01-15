// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {MerkleTreeGenerator} from "../src/MerkleTreeGenerator.sol";
import {DurianDurianToken} from "../src/DurianDurianToken.sol";
import {DurianAirDrop} from "../src/DurianAirDrop.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DeployApp is Script {
    uint256 INITIAL_AMOUNT_TO_MINT = 10000 * 1e18;

    function deployAll() public returns (MerkleTreeGenerator, DurianAirDrop, DurianDurianToken) {
        vm.startBroadcast();
        DurianDurianToken token = new DurianDurianToken(); // msg sender (YOU) will become owner of the token
        DurianAirDrop airdrop = new DurianAirDrop(IERC20(token));
        MerkleTreeGenerator generator = new MerkleTreeGenerator(IERC20(token), airdrop);
        // token.mint(token.owner(), INITIAL_AMOUNT_TO_MINT); // amount for four claimers / transfer from adress 0 to YOU

        // delegate approval to generator.
        // token.approve()
        // IERC20(token).transfer(address(airdrop), AMOUNT_TO_TRANSFER); // transfer tokens to the airdrop contract (from YOU to airdrop)
        vm.stopBroadcast();

        return (generator, airdrop, token);
    }

    // cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "getMessageHash(address,uint256)" 0xf39Fd6e51aad88F6f4ce6aB88272ffFb92266 25000000000000000000 --rpc-url http://localhost:8545
    // 0x184e30c4b19f5e304a893524210d50346dad61c461e79155b910e73fd856dc72
    function run() external returns (MerkleTreeGenerator, DurianAirDrop, DurianDurianToken) {
        return deployAll();
    }
}
