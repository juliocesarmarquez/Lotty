// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title LottyTreasury
/// @notice Treasury contract for protocol fees
contract LottyTreasury is Ownable {
    using SafeERC20 for IERC20;

    // ============ STATE ============

    struct FeeRecipient {
        address recipient;
        uint256 shareBps;
    }

    FeeRecipient[] public recipients;
    mapping(address => uint256) public collectedFees;

    // ============ EVENTS ============

    event FeesReceived(address indexed token, uint256 amount);
    event FeesDistributed(address indexed token, uint256 amount);
    event RecipientsUpdated(uint256 count);

    // ============ CONSTRUCTOR ============

    constructor() Ownable(msg.sender) {}

    // ============ FUNCTIONS ============

    /// @notice Receive fees (called by vault)
    function receiveFees(address token, uint256 amount) external {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        collectedFees[token] += amount;
        emit FeesReceived(token, amount);
    }

    /// @notice Distribute accumulated fees to recipients
    function distributeFees(address token) external onlyOwner {
        uint256 balance = collectedFees[token];
        require(balance > 0, "No fees to distribute");

        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 share = (balance * recipients[i].shareBps) / 10000;
            if (share > 0) {
                IERC20(token).safeTransfer(recipients[i].recipient, share);
            }
        }

        collectedFees[token] = 0;
        emit FeesDistributed(token, balance);
    }

    /// @notice Update fee recipients
    function setRecipients(FeeRecipient[] calldata _recipients) external onlyOwner {
        delete recipients;

        uint256 totalShares = 0;
        for (uint256 i = 0; i < _recipients.length; i++) {
            recipients.push(_recipients[i]);
            totalShares += _recipients[i].shareBps;
        }

        require(totalShares == 10000, "Shares must total 100%");
        emit RecipientsUpdated(_recipients.length);
    }

    /// @notice Emergency withdraw
    function emergencyWithdraw(address token, uint256 amount, address to) external onlyOwner {
        IERC20(token).safeTransfer(to, amount);
    }
}
