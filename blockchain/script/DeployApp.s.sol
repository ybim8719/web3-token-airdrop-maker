// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {MerkleTreeBuilder} from "../src/MerkleTreeBuilder.sol";
import {DurianDurianToken} from "../src/DurianDurianToken.sol";
import {DurianAirDrop} from "../src/DurianAirDrop.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DeployApp is Script {
    uint256 INITIAL_AMOUNT_TO_MINT = 10000 * 1e18;

    function deployApp() public returns (MerkleTreeBuilder, DurianAirDrop, DurianDurianToken) {
        vm.startBroadcast();
        DurianDurianToken token = new DurianDurianToken(); // msg sender (YOU) will become owner of the token
        DurianAirDrop airdrop = new DurianAirDrop(DurianDurianToken(token));
        MerkleTreeBuilder builder = new MerkleTreeBuilder(DurianDurianToken(token), airdrop);
        vm.stopBroadcast();

        return (builder, airdrop, token);
    }

    // cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "getMessageHash(address,uint256)" 0xf39Fd6e51aad88F6f4ce6aB88272ffFb92266 25000000000000000000 --rpc-url http://localhost:8545
    // 0x184e30c4b19f5e304a893524210d50346dad61c461e79155b910e73fd856dc72
    function run() external returns (MerkleTreeBuilder, DurianAirDrop, DurianDurianToken) {
        return deployApp();
    }
}
