// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirDrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DeployMerkleAirdrop is Script {
    uint256 AMOUNT_TO_TRANSFER = 100 * 1e18;
    bytes32 ROOT =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;

    function deployMerkleAirdrop() public returns (MerkleAirdrop, BagelToken) {
        vm.startBroadcast();
        BagelToken bagelToken = new BagelToken(); // msg sender (YOU) will become owner of the token
        MerkleAirdrop airdrop = new MerkleAirdrop(ROOT, IERC20(bagelToken));
        bagelToken.mint(bagelToken.owner(), AMOUNT_TO_TRANSFER); // amount for four claimers / transfer from adress 0 to YOU
        IERC20(bagelToken).transfer(address(airdrop), AMOUNT_TO_TRANSFER); // transfer tokens to the airdrop contract (from YOU to airdrop)
        vm.stopBroadcast();

        return (airdrop, bagelToken);
    }

    // cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "getMessageHash(address,uint256)" 0xf39Fd6e51aad88F6f4ce6aB88272ffFb92266 25000000000000000000 --rpc-url http://localhost:8545
    // 0x184e30c4b19f5e304a893524210d50346dad61c461e79155b910e73fd856dc72
    function run() external returns (MerkleAirdrop, BagelToken) {
        return deployMerkleAirdrop();
    }
}
