// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StudentSavingsWallet {

    
    // STRUCT
    
    struct Transaction {
        uint256 amount;
        string transactionType; // "Deposit" or "Withdraw"
        uint256 timestamp;
    }

    // STATE VARIABLES

    // Store user balances
    mapping(address => uint256) private balances;

    // Store transaction history per user
    mapping(address => Transaction[]) private transactionHistory;

    
    // EVENTS (Bonus Feature)
    
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    
    // DEPOSIT FUNCTION
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");

        balances[msg.sender] += msg.value;

        transactionHistory[msg.sender].push(
            Transaction(msg.value, "Deposit", block.timestamp)
        );

        // Emit event
        emit Deposited(msg.sender, msg.value);
    }

    // WITHDRAW FUNCTION
    function withdraw(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than 0");
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        // Update balance
        balances[msg.sender] -= _amount;

        // Transfer ETH
        payable(msg.sender).transfer(_amount);

        // Save transaction
        transactionHistory[msg.sender].push(
            Transaction(_amount, "Withdraw", block.timestamp)
        );

        // Emit event
        emit Withdrawn(msg.sender, _amount);
    }

    
    // VIEW FUNCTIONS

    // Check user balance
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    // Get full transaction history
    function getTransactionHistory() public view returns (Transaction[] memory) {
        return transactionHistory[msg.sender];
    }
}
