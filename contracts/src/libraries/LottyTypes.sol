// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library LottyTypes {
    // ============ TICKET TYPES ============

    struct Ticket {
        uint256 ticketId;
        address owner;
        uint256 amount;          // USDC amount (6 decimals)
        uint256 purchaseTime;
        bool isActive;
    }

    // ============ STREAK TYPES ============

    struct Streak {
        uint32 currentStreak;
        uint64 lastActivityTime;
        uint32 multiplierBps;    // Basis points (10000 = 1x)
    }

    // ============ DRAW TYPES ============

    enum DrawStatus {
        Pending,
        CommitPhase,
        RevealPhase,
        Completed,
        Cancelled
    }

    struct Draw {
        uint256 drawId;
        uint256 prizePool;
        uint256 timestamp;
        address winner;
        uint256 winningTicketId;
        DrawStatus status;
        bytes32 commitHash;
        uint256 revealBlock;
    }

    // ============ POOL TYPES ============

    struct PoolState {
        uint256 totalDeposits;
        uint256 totalTickets;
        uint256 accumulatedYield;
        uint256 lastYieldHarvest;
        uint256 moonwellShares;
    }

    // ============ CONSTANTS ============

    uint256 constant MIN_DEPOSIT = 1e6;           // 1 USDC
    uint256 constant STREAK_WINDOW = 7 days;
    uint256 constant MAX_MULTIPLIER_BPS = 20000;  // 2x
    uint256 constant DRAW_INTERVAL = 7 days;
    uint256 constant PROTOCOL_FEE_BPS = 500;      // 5%
}

// ============ ERRORS ============

error NotAuthorized();
error InsufficientBalance();
error InvalidAmount();
error TicketNotFound();
error TicketNotActive();
error DrawNotReady();
error DrawAlreadyExecuted();
error NoActiveTickets();
error InsufficientPrizePool();
error StreakExpired();
error SlippageExceeded();
error ZeroAddress();
