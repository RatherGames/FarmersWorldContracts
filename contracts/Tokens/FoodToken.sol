// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Food is ERC20, Ownable, ERC20Permit {
    mapping(address contractCallers => bool) public contractCallers;

    constructor(address recipient, address initialOwner)
        ERC20("Food", "Food")
        Ownable(initialOwner)
        ERC20Permit("Food")
    {
        _mint(recipient, 100000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public  {
        require(contractCallers[msg.sender], "Only contract caller can mint");
        _mint(to, amount);
    }

    function setContractCaller(address _contractCaller) public onlyOwner() {
        contractCallers[_contractCaller] = true;
    }
}