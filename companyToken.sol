// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract CompanyToken {
    address public owner;
    mapping(address => uint) private balanceOf;
    mapping(address => uint) public lastTransferTimestamp;
    mapping(address => bool) public isEmployee;

    event Transfer(address indexed from, address indexed to, uint value);
    event PenaltyApplied(address indexed employee, uint penalty);
    event PenaltyNotApplicable(address indexed employee);
    event EmployeeAdded(address indexed employee);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyEmployee() {
        require(isEmployee[msg.sender] || msg.sender == owner, "Not an employee or owner");
        _;
    }

    constructor(uint initialOwnerTokens) {
        owner = msg.sender;
        balanceOf[owner] = initialOwnerTokens;
    }

    function addEmployee(address employee) public onlyOwner {
        require(!isEmployee[employee], "Employee already exists");
        isEmployee[employee] = true;
        balanceOf[employee] = 50;
        lastTransferTimestamp[employee] = block.timestamp;
        emit EmployeeAdded(employee);
    }

    function transfer(address to, uint value) public onlyEmployee {
        require(isEmployee[to], "Recipient is not an employee");
        require(to != address(0), "Cannot transfer to zero address");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        lastTransferTimestamp[msg.sender] = block.timestamp;

        emit Transfer(msg.sender, to, value);
    }

    function applyInactivityPenalty(address employee) public onlyOwner {
        require(isEmployee[employee], "Address is not an employee");
        uint monthsInactive = (block.timestamp - lastTransferTimestamp[employee]) / 30 days;
        if (monthsInactive >= 1) {
            uint penalty = monthsInactive * 5;
            if (penalty > balanceOf[employee]) {
                balanceOf[employee] = 0;
            } else {
                balanceOf[employee] -= penalty;
            }
            lastTransferTimestamp[employee] = block.timestamp;
            emit PenaltyApplied(employee, penalty);
        } else {
            emit PenaltyNotApplicable(employee);
        }
    }

    function getBalanceOfUser(address addr) public view onlyOwner returns (uint) {
        return balanceOf[addr];
    }

    function getMyBalance() public view onlyEmployee returns (uint) {
        return balanceOf[msg.sender];
    }
}