// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @notice ultra basic ERC20 based token
 */
contract DurianDurianToken is ERC20, Ownable {
    constructor() ERC20("Durian Durian Token", "BT") Ownable(msg.sender) { //the deployer is the owner of the contract
    }

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }
}
