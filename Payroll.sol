// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract Payroll is Ownable {

    // Test token here. Change with USDC on mainnet.
    address public token = 0x8efd4969258920a242bD895c0EDd874E684d1c80; 

    // Employee's wallet address to their weekly salary
    mapping(address => uint) public weeklySalary;

    // Time since employee's payday
    mapping(address => uint) public lastPayday;

    constructor() {
    }
    
    // Set the initial employee address+salary and set a start time.
    function setSalaryAndTimeclock(address[] memory addrs, uint256[] memory weeklySalaries) public onlyOwner {
        for(uint i = 0; i < addrs.length; i++) {
            updateEmployeeSalary(addrs[i], weeklySalaries[i]);
            lastPayday[addrs[i]] = 1645049700; // represents Wednesday, February 16, 2022 10:15:00 PM
        }
    }

    // Set an employee's weekly salary.
    function updateEmployeeSalary(address addr, uint256 weeklySalary) public onlyOwner {
        weeklySalary[addr] = weeklySalary;
    }

    // Check how much $ you will get if you claim right now.
    function claimable(address addr) public view returns (uint) {
        return (weeklySalary[addr] / 1 weeks) * (block.timestamp - lastPayday[addr]);
    }

    // Claim salary accrued since the last time you claimed.
    function claimSalary() public {
        uint addr = msg.sender;
        ERC20(token).transfer(addr, claimable(addr));
        lastPayday[addr] = block.timestamp;
    }

    // Withdraw leftover funds.
    function withdrawAll(uint amt) public onlyOwner {
        ERC20(token).transfer(owner(), amt);
    }
}
