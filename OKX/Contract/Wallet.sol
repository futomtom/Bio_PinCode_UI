pragma solidity ^0.8.0;

contract Wallet {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    function deposit() public payable {
        // Implement deposit functionality here
    }

    function withdraw(uint amount) public onlyOwner {
        // Implement withdrawal functionality here
        // Make sure to check if the contract has enough balance to fulfill the withdrawal
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
