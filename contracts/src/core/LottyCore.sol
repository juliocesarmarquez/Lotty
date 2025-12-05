// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../libraries/LottyTypes.sol";
import "./LottyVault.sol";

/// @title LottyCore
/// @notice Main entry point for Lotty no-loss lottery
/// @dev Manages tickets, streaks, and prize draws
contract LottyCore is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using LottyTypes for *;

    // ============ STATE ============

    IERC20 public immutable usdc;
    LottyVault public immutable vault;

    // Ticket storage
    mapping(uint256 => LottyTypes.Ticket) public tickets;
    mapping(address => uint256[]) public userTickets;
    uint256 public nextTicketId = 1;
    uint256 public totalActiveTickets;

    // Streak storage
    mapping(address => LottyTypes.Streak) public streaks;

    // Draw storage
    mapping(uint256 => LottyTypes.Draw) public draws;
    uint256 public currentDrawId;
    uint256 public lastDrawTime;

    // Configuration
    uint256 public minDeposit;
    uint256 public streakWindow;
    uint256 public drawInterval;

    // ============ EVENTS ============

    event TicketPurchased(
        uint256 indexed ticketId,
        address indexed user,
        uint256 amount,
        uint256 timestamp
    );

    event TicketWithdrawn(
        uint256 indexed ticketId,
        address indexed user,
        uint256 amount
    );

    event StreakUpdated(
        address indexed user,
        uint32 newStreak,
        uint32 multiplierBps
    );

    event DrawInitiated(
        uint256 indexed drawId,
        uint256 prizePool,
        uint256 timestamp
    );

    event DrawCompleted(
        uint256 indexed drawId,
        address indexed winner,
        uint256 prizeAmount,
        uint256 winningTicketId
    );

    // ============ CONSTRUCTOR ============

    constructor(
        address _usdc,
        address _vault,
        uint256 _minDeposit,
        uint256 _streakWindow,
        uint256 _drawInterval
    ) Ownable(msg.sender) {
        if (_usdc == address(0) || _vault == address(0)) revert ZeroAddress();

        usdc = IERC20(_usdc);
        vault = LottyVault(_vault);
        minDeposit = _minDeposit;
        streakWindow = _streakWindow;
        drawInterval = _drawInterval;
        lastDrawTime = block.timestamp;
    }

    // ============ TICKET FUNCTIONS ============

    /// @notice Buy a lottery ticket by depositing USDC
    /// @param amount Amount of USDC to deposit
    /// @return ticketId The ID of the newly created ticket
    function buyTicket(uint256 amount) external nonReentrant returns (uint256 ticketId) {
        if (amount < minDeposit) revert InvalidAmount();

        // Transfer USDC from user
        usdc.safeTransferFrom(msg.sender, address(this), amount);

        // Approve and deposit to vault
        usdc.approve(address(vault), amount);
        vault.deposit(amount, address(this));

        // Create ticket
        ticketId = nextTicketId++;
        tickets[ticketId] = LottyTypes.Ticket({
            ticketId: ticketId,
            owner: msg.sender,
            amount: amount,
            purchaseTime: block.timestamp,
            isActive: true
        });

        userTickets[msg.sender].push(ticketId);
        totalActiveTickets++;

        // Update streak
        _updateStreak(msg.sender);

        emit TicketPurchased(ticketId, msg.sender, amount, block.timestamp);
    }

    /// @notice Withdraw principal by redeeming a ticket
    /// @param ticketId The ticket to redeem
    function withdrawTicket(uint256 ticketId) external nonReentrant {
        LottyTypes.Ticket storage ticket = tickets[ticketId];

        if (ticket.owner != msg.sender) revert NotAuthorized();
        if (!ticket.isActive) revert TicketNotActive();

        ticket.isActive = false;
        totalActiveTickets--;

        // Withdraw from vault
        uint256 shares = vault.convertToShares(ticket.amount);
        uint256 assets = vault.redeem(shares, msg.sender, address(this));

        emit TicketWithdrawn(ticketId, msg.sender, assets);
    }

    // ============ STREAK FUNCTIONS ============

    function _updateStreak(address user) internal {
        LottyTypes.Streak storage streak = streaks[user];

        if (block.timestamp <= streak.lastActivityTime + streakWindow) {
            // Within window - increment streak
            streak.currentStreak++;
        } else {
            // Outside window - reset streak
            streak.currentStreak = 1;
        }

        streak.lastActivityTime = uint64(block.timestamp);
        streak.multiplierBps = _calculateMultiplier(streak.currentStreak);

        emit StreakUpdated(user, streak.currentStreak, streak.multiplierBps);
    }

    function _calculateMultiplier(uint32 streakLength) internal pure returns (uint32) {
        // 1x base + 0.1x per week, max 2x
        uint32 bonus = streakLength * 1000; // 0.1x = 1000 bps
        uint32 multiplier = 10000 + bonus;  // 1x = 10000 bps

        if (multiplier > LottyTypes.MAX_MULTIPLIER_BPS) {
            return uint32(LottyTypes.MAX_MULTIPLIER_BPS);
        }
        return multiplier;
    }

    /// @notice Get user's effective ticket count with streak multiplier
    function getEffectiveTickets(address user) public view returns (uint256) {
        uint256[] memory userTicketIds = userTickets[user];
        uint256 baseTickets = 0;

        for (uint256 i = 0; i < userTicketIds.length; i++) {
            if (tickets[userTicketIds[i]].isActive) {
                baseTickets++;
            }
        }

        LottyTypes.Streak memory streak = streaks[user];

        // Check if streak is still valid
        if (block.timestamp > streak.lastActivityTime + streakWindow) {
            return baseTickets; // No multiplier if streak expired
        }

        return (baseTickets * streak.multiplierBps) / 10000;
    }

    // ============ DRAW FUNCTIONS ============

    /// @notice Initiate a new prize draw
    /// @param commitHash Hash of the random seed (commit-reveal)
    function initiateDraw(bytes32 commitHash) external onlyOwner {
        if (block.timestamp < lastDrawTime + drawInterval) revert DrawNotReady();
        if (totalActiveTickets == 0) revert NoActiveTickets();

        // Harvest yield from vault
        uint256 yield = vault.harvestYield();
        if (yield == 0) revert InsufficientPrizePool();

        currentDrawId++;
        draws[currentDrawId] = LottyTypes.Draw({
            drawId: currentDrawId,
            prizePool: yield,
            timestamp: block.timestamp,
            winner: address(0),
            winningTicketId: 0,
            status: LottyTypes.DrawStatus.CommitPhase,
            commitHash: commitHash,
            revealBlock: block.number + 10 // Reveal after 10 blocks
        });

        emit DrawInitiated(currentDrawId, yield, block.timestamp);
    }

    /// @notice Execute the draw by revealing the random seed
    /// @param randomSeed The pre-image of the commit hash
    function executeDraw(uint256 randomSeed) external onlyOwner {
        LottyTypes.Draw storage draw = draws[currentDrawId];

        if (draw.status != LottyTypes.DrawStatus.CommitPhase) revert DrawNotReady();
        if (block.number < draw.revealBlock) revert DrawNotReady();
        if (keccak256(abi.encodePacked(randomSeed)) != draw.commitHash) {
            revert NotAuthorized();
        }

        // Select winner using weighted random selection
        (address winner, uint256 winningTicketId) = _selectWinner(randomSeed);

        draw.winner = winner;
        draw.winningTicketId = winningTicketId;
        draw.status = LottyTypes.DrawStatus.Completed;
        lastDrawTime = block.timestamp;

        // Transfer prize to winner
        usdc.safeTransfer(winner, draw.prizePool);

        emit DrawCompleted(currentDrawId, winner, draw.prizePool, winningTicketId);
    }

    function _selectWinner(uint256 seed) internal view returns (address, uint256) {
        // Build weighted ticket array
        // This is simplified - production should use more gas-efficient approach
        uint256 totalWeight = 0;

        for (uint256 i = 1; i < nextTicketId; i++) {
            if (tickets[i].isActive) {
                totalWeight += getEffectiveTickets(tickets[i].owner);
            }
        }

        uint256 winningNumber = seed % totalWeight;
        uint256 cumulative = 0;

        for (uint256 i = 1; i < nextTicketId; i++) {
            if (tickets[i].isActive) {
                cumulative += getEffectiveTickets(tickets[i].owner);
                if (cumulative > winningNumber) {
                    return (tickets[i].owner, i);
                }
            }
        }

        revert NoActiveTickets();
    }

    // ============ VIEW FUNCTIONS ============

    function getUserTickets(address user) external view returns (uint256[] memory) {
        return userTickets[user];
    }

    function getTicket(uint256 ticketId) external view returns (LottyTypes.Ticket memory) {
        return tickets[ticketId];
    }

    function getStreak(address user) external view returns (LottyTypes.Streak memory) {
        return streaks[user];
    }

    function getDraw(uint256 drawId) external view returns (LottyTypes.Draw memory) {
        return draws[drawId];
    }

    function getWinProbability(address user) external view returns (uint256 userWeight, uint256 totalWeight) {
        userWeight = getEffectiveTickets(user);

        for (uint256 i = 1; i < nextTicketId; i++) {
            if (tickets[i].isActive) {
                totalWeight += getEffectiveTickets(tickets[i].owner);
            }
        }
    }
}
