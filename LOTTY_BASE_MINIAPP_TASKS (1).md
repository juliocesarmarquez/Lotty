# Lotty Protocol - Base Mini App Edition

> **Framework**: Base MiniKit + OnchainKit
> **Smart Contracts**: Solidity (Foundry)
> **Yield Protocol**: Moonwell (ERC-4626 Compatible)
> **Chain**: Base (Coinbase L2)

## 🚀 Quick Start

```bash
# 1. Create Base Mini App
npx create-onchain --mini
cd lotty-miniapp

# 2. Install dependencies
npm install

# 3. Configure environment
cp .env.example .env.local
# Add your CDP keys, contract addresses

# 4. Start development
npm run dev
# Mini App at http://localhost:3000
```

---

## Project Overview

Lotty is a **no-loss savings lottery protocol** built as a Base Mini App. Users deposit USDC to buy tickets, their principal generates yield through Moonwell lending, and the yield is distributed as prizes through periodic draws. Users can withdraw their principal at any time.

### Why Base Mini App?

| Feature | Benefit |
|---------|---------|
| **Millions of users** | Access Base App + Farcaster social graph |
| **Built-in wallet** | Coinbase Smart Wallet, no app switching |
| **Gasless transactions** | Paymaster support for UX |
| **Social sharing** | Native cast/share functionality |
| **Notifications** | Push notifications for draws |

---

## Architecture Overview with Moonwell

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         BASE MINI APP LAYER                                  │
│                                                                              │
│  ┌──────────────┐   ┌─────────────────┐   ┌────────────────────────────┐   │
│  │ MiniKit      │   │ OnchainKit      │   │ Coinbase Smart Wallet      │   │
│  │ Provider     │   │ Components      │   │ (EIP-1193 Provider)        │   │
│  └──────────────┘   └─────────────────┘   └────────────────────────────┘   │
│         │                   │                        │                      │
│         └───────────────────┼────────────────────────┘                      │
│                             ▼                                               │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                    Next.js Frontend                                   │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────────┐  │  │
│  │  │ Dashboard  │  │ Buy Ticket │  │ Prize Draw │  │ Withdraw       │  │  │
│  │  │ Component  │  │ Component  │  │ Component  │  │ Component      │  │  │
│  │  └────────────┘  └────────────┘  └────────────┘  └────────────────┘  │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      LOTTY SMART CONTRACTS (Solidity)                        │
│                                                                              │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────────┐ │
│  │ LottyCore.sol   │───▶│ LottyVault.sol  │───▶│  MoonwellAdapter.sol    │ │
│  │                 │    │                 │    │                         │ │
│  │ - Buy tickets   │    │ - ERC-4626 vault│    │ - Deposit to Moonwell   │ │
│  │ - Track streaks │    │ - Share minting │    │ - Withdraw from Moonwell│ │
│  │ - Prize draws   │    │ - Yield tracking│    │ - Harvest yield         │ │
│  └─────────────────┘    └─────────────────┘    └───────────┬─────────────┘ │
│           │                     │                          │               │
│  ┌────────▼────────┐    ┌───────▼────────┐                │               │
│  │ LottyGovernance │    │  LottyTreasury │                │               │
│  │     .sol        │    │     .sol       │                │               │
│  └─────────────────┘    └────────────────┘                │               │
└───────────────────────────────────────────────────────────┼───────────────┘
                                                            │
                                                            ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         MOONWELL PROTOCOL (External)                         │
│                                                                              │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │                    Moonwell Lending Pool on Base                       │ │
│  │                                                                        │ │
│  │  ┌──────────────┐   ┌──────────────┐   ┌────────────────────────────┐│ │
│  │  │ mUSDC Token  │   │ Comptroller  │   │   Interest Rate Model      ││ │
│  │  │ (mToken)     │   │              │   │                            ││ │
│  │  └──────────────┘   └──────────────┘   └────────────────────────────┘│ │
│  │                                                                        │ │
│  │  Contract: 0xEDC817A28E8B93B03976Fbd4A3ddbC9F7D176C22 (mUSDC on Base) │ │
│  └───────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Key Integration Points

| Component | Responsibility | Moonwell Interaction |
|-----------|---------------|---------------------|
| LottyVault | ERC-4626 wrapper | Calls MoonwellAdapter |
| MoonwellAdapter | Protocol interface | Deposits/withdraws from mUSDC |
| Moonwell mUSDC | Yield generation | Interest-bearing token |

### What MiniKit Provides vs What to Build

| Provided by MiniKit | Build for Lotty |
|---------------------|-----------------|
| ✅ MiniKitProvider | 🔨 Lotty smart contracts (Solidity) |
| ✅ Wallet component | 🔨 LottyCore contract |
| ✅ Transaction component | 🔨 LottyVault (ERC-4626) |
| ✅ Identity component | 🔨 MoonwellAdapter contract |
| ✅ Notifications API | 🔨 Prize draw VRF integration |
| ✅ Frame/cast sharing | 🔨 Lotty UI components |
| ✅ Paymaster support | 🔨 Backend API routes |

---

## Phase 1: Project Setup with Base MiniKit

### Task 1.1: Initialize Base Mini App
```
Use the official MiniKit CLI to scaffold the project.

PREREQUISITES:
- Node.js 18+
- npm or yarn
- Coinbase Developer Platform account (for API keys)

STEP 1: Create Mini App
```bash
npx create-onchain --mini
# Project name: lotty-miniapp
# Follow prompts
cd lotty-miniapp
```

STEP 2: The scaffold creates this structure:
```
lotty-miniapp/
├── app/
│   ├── api/
│   │   ├── notification/     # Push notification handler
│   │   └── webhook/          # Webhook handler
│   ├── .well-known/
│   │   └── farcaster.json/   # Farcaster manifest
│   ├── layout.tsx
│   └── page.tsx
├── components/
│   └── ...                   # OnchainKit components
├── lib/
│   └── ...                   # Utilities
├── public/
├── .env.local
├── next.config.js
└── package.json
```

STEP 3: Install additional dependencies
```bash
npm install viem wagmi @tanstack/react-query
npm install -D @types/node typescript
```

STEP 4: Configure .env.local
```env
# CDP API Keys (from developer.coinbase.com)
NEXT_PUBLIC_CDP_API_KEY=your_cdp_api_key
NEXT_PUBLIC_ONCHAINKIT_PROJECT_ID=your_project_id

# Paymaster for gasless transactions
NEXT_PUBLIC_PAYMASTER_URL=https://api.developer.coinbase.com/rpc/v1/base/your_key

# Contract addresses (after deployment)
NEXT_PUBLIC_LOTTY_CORE=0x...
NEXT_PUBLIC_LOTTY_VAULT=0x...
NEXT_PUBLIC_USDC_ADDRESS=0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913

# Moonwell on Base
NEXT_PUBLIC_MOONWELL_MUSDC=0xEDC817A28E8B93B03976Fbd4A3ddbC9F7D176C22
NEXT_PUBLIC_MOONWELL_COMPTROLLER=0xfBb21d0380beE3312B33c4353c8936a0F13EF26C
```

STEP 5: Verify setup
```bash
npm run dev
# Open http://localhost:3000
# Should see MiniKit demo page
```
```

### Task 1.2: Set Up Smart Contract Development (Foundry)
```
Create a separate folder for Solidity contracts using Foundry.

STEP 1: Initialize Foundry project
```bash
mkdir contracts
cd contracts
forge init
```

STEP 2: Configure foundry.toml
```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc = "0.8.24"
optimizer = true
optimizer_runs = 200

[rpc_endpoints]
base = "${BASE_RPC_URL}"
base_sepolia = "https://sepolia.base.org"

[etherscan]
base = { key = "${BASESCAN_API_KEY}", url = "https://api.basescan.org/api" }
base_sepolia = { key = "${BASESCAN_API_KEY}", url = "https://api-sepolia.basescan.org/api" }
```

STEP 3: Install dependencies
```bash
forge install OpenZeppelin/openzeppelin-contracts
forge install transmissions11/solmate
forge install smartcontractkit/chainlink --no-commit
```

STEP 4: Create remappings.txt
```
@openzeppelin/=lib/openzeppelin-contracts/
@solmate/=lib/solmate/src/
@chainlink/=lib/chainlink/contracts/
```

STEP 5: Project structure
```
contracts/
├── src/
│   ├── core/
│   │   ├── LottyCore.sol
│   │   ├── LottyVault.sol
│   │   └── LottyGovernance.sol
│   ├── adapters/
│   │   └── MoonwellAdapter.sol
│   ├── interfaces/
│   │   ├── ILottyCore.sol
│   │   ├── IMoonwell.sol
│   │   └── IERC4626.sol
│   └── libraries/
│       └── LottyTypes.sol
├── test/
│   ├── LottyCore.t.sol
│   ├── LottyVault.t.sol
│   └── MoonwellAdapter.t.sol
├── script/
│   ├── Deploy.s.sol
│   └── Interactions.s.sol
├── foundry.toml
└── remappings.txt
```
```

### Task 1.3: Define Core Types and Interfaces
```
Create contracts/src/libraries/LottyTypes.sol:

```solidity
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
```

Create contracts/src/interfaces/IMoonwell.sol:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Interface for Moonwell's mToken (cToken fork)
interface IMToken {
    function mint(uint256 mintAmount) external returns (uint256);
    function redeem(uint256 redeemTokens) external returns (uint256);
    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function balanceOfUnderlying(address owner) external returns (uint256);
    function exchangeRateCurrent() external returns (uint256);
    function exchangeRateStored() external view returns (uint256);
    function underlying() external view returns (address);
    function accrueInterest() external returns (uint256);
    function totalSupply() external view returns (uint256);
    function getCash() external view returns (uint256);
    function totalBorrows() external view returns (uint256);
    function totalReserves() external view returns (uint256);
    function supplyRatePerTimestamp() external view returns (uint256);
}

/// @notice Interface for Moonwell Comptroller
interface IComptroller {
    function enterMarkets(address[] calldata mTokens) external returns (uint256[] memory);
    function exitMarket(address mToken) external returns (uint256);
    function getAccountLiquidity(address account) external view returns (uint256, uint256, uint256);
    function claimReward() external;
    function claimReward(address holder, address[] calldata mTokens) external;
}
```
```

---

## Phase 2: Core Smart Contracts (Solidity)

### Task 2.1: LottyCore Contract
```
Create contracts/src/core/LottyCore.sol:

```solidity
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
```
```

### Task 2.2: LottyVault Contract (ERC-4626)
```
Create contracts/src/core/LottyVault.sol:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../adapters/MoonwellAdapter.sol";

/// @title LottyVault
/// @notice ERC-4626 vault that deposits to Moonwell for yield generation
/// @dev Wraps Moonwell mUSDC with standard vault interface
contract LottyVault is ERC4626, Ownable {
    using SafeERC20 for IERC20;
    
    // ============ STATE ============
    
    MoonwellAdapter public adapter;
    address public lottyCore;
    address public treasury;
    
    uint256 public protocolFeeBps;
    uint256 public totalPrincipal;
    uint256 public lastHarvestTime;
    
    // ============ EVENTS ============
    
    event YieldHarvested(uint256 yield, uint256 protocolFee, uint256 timestamp);
    event AdapterUpdated(address oldAdapter, address newAdapter);
    
    // ============ MODIFIERS ============
    
    modifier onlyLottyCore() {
        require(msg.sender == lottyCore, "Only LottyCore");
        _;
    }
    
    // ============ CONSTRUCTOR ============
    
    constructor(
        IERC20 _asset,
        address _adapter,
        address _treasury,
        uint256 _protocolFeeBps
    ) 
        ERC4626(_asset)
        ERC20("Lotty Vault USDC", "lvUSDC")
        Ownable(msg.sender)
    {
        adapter = MoonwellAdapter(_adapter);
        treasury = _treasury;
        protocolFeeBps = _protocolFeeBps;
        
        // Approve adapter to spend USDC
        _asset.approve(_adapter, type(uint256).max);
    }
    
    // ============ ADMIN FUNCTIONS ============
    
    function setLottyCore(address _lottyCore) external onlyOwner {
        lottyCore = _lottyCore;
    }
    
    function setAdapter(address _newAdapter) external onlyOwner {
        address oldAdapter = address(adapter);
        
        // Withdraw all from old adapter
        adapter.withdrawAll();
        
        // Set new adapter
        adapter = MoonwellAdapter(_newAdapter);
        IERC20(asset()).approve(_newAdapter, type(uint256).max);
        
        // Deposit all to new adapter
        uint256 balance = IERC20(asset()).balanceOf(address(this));
        if (balance > 0) {
            adapter.deposit(balance);
        }
        
        emit AdapterUpdated(oldAdapter, _newAdapter);
    }
    
    // ============ VAULT FUNCTIONS ============
    
    /// @notice Total assets = principal in Moonwell + accumulated yield
    function totalAssets() public view override returns (uint256) {
        return adapter.getTotalValue();
    }
    
    /// @inheritdoc ERC4626
    function _deposit(
        address caller,
        address receiver,
        uint256 assets,
        uint256 shares
    ) internal override {
        super._deposit(caller, receiver, assets, shares);
        
        // Forward to Moonwell via adapter
        adapter.deposit(assets);
        totalPrincipal += assets;
    }
    
    /// @inheritdoc ERC4626
    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal override {
        // Withdraw from Moonwell
        adapter.withdraw(assets);
        totalPrincipal -= assets;
        
        super._withdraw(caller, receiver, owner, assets, shares);
    }
    
    /// @notice Harvest yield from Moonwell
    /// @return yield The amount of yield harvested (after fees)
    function harvestYield() external onlyLottyCore returns (uint256 yield) {
        uint256 totalValue = adapter.getTotalValue();
        
        if (totalValue <= totalPrincipal) {
            return 0;
        }
        
        uint256 grossYield = totalValue - totalPrincipal;
        
        // Calculate protocol fee
        uint256 protocolFee = (grossYield * protocolFeeBps) / 10000;
        yield = grossYield - protocolFee;
        
        // Withdraw yield from adapter
        adapter.withdraw(grossYield);
        
        // Send fee to treasury
        if (protocolFee > 0) {
            IERC20(asset()).safeTransfer(treasury, protocolFee);
        }
        
        // Transfer yield to LottyCore for prize distribution
        if (yield > 0) {
            IERC20(asset()).safeTransfer(lottyCore, yield);
        }
        
        lastHarvestTime = block.timestamp;
        
        emit YieldHarvested(yield, protocolFee, block.timestamp);
    }
    
    /// @notice Get pending yield (not yet harvested)
    function getPendingYield() external view returns (uint256) {
        uint256 totalValue = adapter.getTotalValue();
        if (totalValue <= totalPrincipal) {
            return 0;
        }
        return totalValue - totalPrincipal;
    }
}
```
```

### Task 2.3: MoonwellAdapter Contract
```
Create contracts/src/adapters/MoonwellAdapter.sol:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IMoonwell.sol";

/// @title MoonwellAdapter
/// @notice Adapter for interacting with Moonwell lending protocol on Base
/// @dev Deposits USDC to Moonwell and tracks mUSDC shares
contract MoonwellAdapter is Ownable {
    using SafeERC20 for IERC20;
    
    // ============ STATE ============
    
    IERC20 public immutable usdc;
    IMToken public immutable mUsdc;
    IComptroller public immutable comptroller;
    
    address public vault;
    
    // ============ EVENTS ============
    
    event Deposited(uint256 amount, uint256 mTokensReceived);
    event Withdrawn(uint256 amount, uint256 mTokensBurned);
    event RewardsClaimed(uint256 amount);
    
    // ============ MODIFIERS ============
    
    modifier onlyVault() {
        require(msg.sender == vault, "Only vault");
        _;
    }
    
    // ============ CONSTRUCTOR ============
    
    /// @param _usdc USDC token address on Base
    /// @param _mUsdc Moonwell mUSDC address on Base
    /// @param _comptroller Moonwell Comptroller address
    constructor(
        address _usdc,
        address _mUsdc,
        address _comptroller
    ) Ownable(msg.sender) {
        usdc = IERC20(_usdc);
        mUsdc = IMToken(_mUsdc);
        comptroller = IComptroller(_comptroller);
        
        // Approve mUSDC to spend USDC
        usdc.approve(_mUsdc, type(uint256).max);
        
        // Enter market for USDC
        address[] memory markets = new address[](1);
        markets[0] = _mUsdc;
        comptroller.enterMarkets(markets);
    }
    
    // ============ ADMIN FUNCTIONS ============
    
    function setVault(address _vault) external onlyOwner {
        vault = _vault;
    }
    
    // ============ CORE FUNCTIONS ============
    
    /// @notice Deposit USDC to Moonwell
    /// @param amount Amount of USDC to deposit
    /// @return mTokensReceived Amount of mUSDC received
    function deposit(uint256 amount) external onlyVault returns (uint256 mTokensReceived) {
        // Transfer USDC from vault
        usdc.safeTransferFrom(msg.sender, address(this), amount);
        
        // Get mToken balance before
        uint256 mBalanceBefore = mUsdc.balanceOf(address(this));
        
        // Deposit to Moonwell
        uint256 err = mUsdc.mint(amount);
        require(err == 0, "Moonwell mint failed");
        
        // Calculate mTokens received
        mTokensReceived = mUsdc.balanceOf(address(this)) - mBalanceBefore;
        
        emit Deposited(amount, mTokensReceived);
    }
    
    /// @notice Withdraw USDC from Moonwell
    /// @param amount Amount of USDC to withdraw
    /// @return actualAmount Actual amount withdrawn
    function withdraw(uint256 amount) external onlyVault returns (uint256 actualAmount) {
        uint256 balanceBefore = usdc.balanceOf(address(this));
        
        // Redeem underlying (USDC)
        uint256 err = mUsdc.redeemUnderlying(amount);
        require(err == 0, "Moonwell redeem failed");
        
        actualAmount = usdc.balanceOf(address(this)) - balanceBefore;
        
        // Transfer to vault
        usdc.safeTransfer(vault, actualAmount);
        
        emit Withdrawn(actualAmount, 0);
    }
    
    /// @notice Withdraw all USDC from Moonwell
    /// @return amount Total USDC withdrawn
    function withdrawAll() external onlyVault returns (uint256 amount) {
        uint256 mBalance = mUsdc.balanceOf(address(this));
        if (mBalance == 0) return 0;
        
        uint256 balanceBefore = usdc.balanceOf(address(this));
        
        // Redeem all mTokens
        uint256 err = mUsdc.redeem(mBalance);
        require(err == 0, "Moonwell redeem failed");
        
        amount = usdc.balanceOf(address(this)) - balanceBefore;
        
        // Transfer to vault
        usdc.safeTransfer(vault, amount);
        
        emit Withdrawn(amount, mBalance);
    }
    
    /// @notice Claim WELL rewards from Moonwell
    function claimRewards() external onlyVault {
        address[] memory markets = new address[](1);
        markets[0] = address(mUsdc);
        comptroller.claimReward(address(this), markets);
        
        // Note: WELL tokens stay in adapter, can be swept by owner
    }
    
    // ============ VIEW FUNCTIONS ============
    
    /// @notice Get total value in USDC terms
    /// @return Total USDC value (principal + accrued interest)
    function getTotalValue() public view returns (uint256) {
        uint256 mBalance = mUsdc.balanceOf(address(this));
        if (mBalance == 0) return 0;
        
        // exchangeRateStored is scaled by 1e18
        uint256 exchangeRate = mUsdc.exchangeRateStored();
        
        // mBalance * exchangeRate / 1e18 = underlying value
        return (mBalance * exchangeRate) / 1e18;
    }
    
    /// @notice Get current mUSDC balance
    function getMTokenBalance() external view returns (uint256) {
        return mUsdc.balanceOf(address(this));
    }
    
    /// @notice Get current exchange rate
    function getExchangeRate() external view returns (uint256) {
        return mUsdc.exchangeRateStored();
    }
    
    /// @notice Get current supply APY (approximate)
    function getSupplyApy() external view returns (uint256) {
        // supplyRatePerTimestamp is per second, scaled by 1e18
        uint256 ratePerSecond = mUsdc.supplyRatePerTimestamp();
        // APY = (1 + ratePerSecond)^secondsPerYear - 1
        // Simplified: APY ≈ ratePerSecond * secondsPerYear
        return ratePerSecond * 365 days;
    }
}
```
```

### Task 2.4: LottyTreasury Contract
```
Create contracts/src/core/LottyTreasury.sol:

```solidity
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
```
```

### Task 2.5: Chainlink VRF Integration (Alternative to Commit-Reveal)
```
Create contracts/src/vrf/LottyVRF.sol:

For production, integrate with Chainlink VRF for provably fair randomness.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2Plus.sol";
import "@chainlink/contracts/src/v0.8/vrf/libraries/VRFV2PlusClient.sol";

/// @title LottyVRF
/// @notice Chainlink VRF integration for fair prize draws
abstract contract LottyVRF is VRFConsumerBaseV2Plus {
    
    // Chainlink VRF Config for Base
    // Note: Check docs.chain.link for current Base addresses
    uint256 public subscriptionId;
    bytes32 public keyHash;
    uint32 public callbackGasLimit = 100000;
    uint16 public requestConfirmations = 3;
    uint32 public numWords = 1;
    
    mapping(uint256 => uint256) public vrfRequestToDrawId;
    mapping(uint256 => uint256) public drawRandomWords;
    
    event RandomnessRequested(uint256 requestId, uint256 drawId);
    event RandomnessFulfilled(uint256 requestId, uint256 drawId, uint256 randomWord);
    
    constructor(
        address _vrfCoordinator,
        uint256 _subscriptionId,
        bytes32 _keyHash
    ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
    }
    
    function _requestRandomness(uint256 drawId) internal returns (uint256 requestId) {
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: ""
            })
        );
        
        vrfRequestToDrawId[requestId] = drawId;
        emit RandomnessRequested(requestId, drawId);
    }
    
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {
        uint256 drawId = vrfRequestToDrawId[requestId];
        drawRandomWords[drawId] = randomWords[0];
        
        emit RandomnessFulfilled(requestId, drawId, randomWords[0]);
        
        // Call internal function to complete draw
        _onRandomnessReceived(drawId, randomWords[0]);
    }
    
    function _onRandomnessReceived(uint256 drawId, uint256 randomWord) internal virtual;
}
```
```

---

## Phase 3: Frontend Development with MiniKit

### Task 3.1: Configure MiniKit Provider
```
Update app/layout.tsx:

```typescript
import { Providers } from './providers';
import './globals.css';

export const metadata = {
  title: 'Lotty - No-Loss Lottery',
  description: 'Win prizes without risking your principal',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
```

Create app/providers.tsx:

```typescript
'use client';

import { ReactNode } from 'react';
import { MiniKitProvider } from '@coinbase/onchainkit/minikit';
import { base, baseSepolia } from 'viem/chains';

const chain = process.env.NEXT_PUBLIC_NETWORK === 'mainnet' ? base : baseSepolia;

export function Providers({ children }: { children: ReactNode }) {
  return (
    <MiniKitProvider
      apiKey={process.env.NEXT_PUBLIC_CDP_API_KEY}
      chain={chain}
      config={{
        appearance: {
          name: 'Lotty',
          logo: '/logo.png',
          mode: 'dark',
          theme: 'default',
        },
      }}
    >
      {children}
    </MiniKitProvider>
  );
}
```
```

### Task 3.2: Create Main App Page
```
Update app/page.tsx:

```typescript
'use client';

import { useEffect } from 'react';
import { useMiniKit } from '@coinbase/onchainkit/minikit';
import { LottyDashboard } from '@/components/LottyDashboard';

export default function HomePage() {
  const { setFrameReady, isFrameReady } = useMiniKit();

  useEffect(() => {
    if (!isFrameReady) {
      setFrameReady();
    }
  }, [isFrameReady, setFrameReady]);

  return (
    <main className="min-h-screen bg-gradient-to-b from-purple-900 to-black text-white">
      <LottyDashboard />
    </main>
  );
}
```
```

### Task 3.3: Create Lotty Dashboard Component
```
Create components/LottyDashboard.tsx:

```typescript
'use client';

import { useState } from 'react';
import { useAccount } from 'wagmi';
import { 
  ConnectWallet, 
  Wallet, 
  WalletDropdown,
  WalletDropdownDisconnect 
} from '@coinbase/onchainkit/wallet';
import { 
  Avatar, 
  Name, 
  Identity 
} from '@coinbase/onchainkit/identity';
import { TicketPurchase } from './TicketPurchase';
import { UserStats } from './UserStats';
import { PrizePool } from './PrizePool';
import { DrawCountdown } from './DrawCountdown';
import { TicketList } from './TicketList';

export function LottyDashboard() {
  const { address, isConnected } = useAccount();
  const [activeTab, setActiveTab] = useState<'buy' | 'tickets' | 'history'>('buy');

  return (
    <div className="container mx-auto px-4 py-8 max-w-md">
      {/* Header */}
      <header className="flex justify-between items-center mb-8">
        <div className="flex items-center gap-2">
          <span className="text-3xl">🎰</span>
          <h1 className="text-2xl font-bold">Lotty</h1>
        </div>
        
        <Wallet>
          <ConnectWallet>
            <Avatar className="h-6 w-6" />
            <Name />
          </ConnectWallet>
          <WalletDropdown>
            <Identity className="px-4 pt-3 pb-2" hasCopyAddressOnClick>
              <Avatar />
              <Name />
            </Identity>
            <WalletDropdownDisconnect />
          </WalletDropdown>
        </Wallet>
      </header>

      {isConnected ? (
        <>
          {/* Prize Pool Card */}
          <PrizePool />

          {/* Countdown to Next Draw */}
          <DrawCountdown />

          {/* User Stats */}
          <UserStats address={address!} />

          {/* Tab Navigation */}
          <div className="flex gap-2 mb-4">
            {(['buy', 'tickets', 'history'] as const).map((tab) => (
              <button
                key={tab}
                onClick={() => setActiveTab(tab)}
                className={`flex-1 py-2 px-4 rounded-lg font-medium transition-colors ${
                  activeTab === tab
                    ? 'bg-purple-600 text-white'
                    : 'bg-gray-800 text-gray-400 hover:bg-gray-700'
                }`}
              >
                {tab.charAt(0).toUpperCase() + tab.slice(1)}
              </button>
            ))}
          </div>

          {/* Tab Content */}
          {activeTab === 'buy' && <TicketPurchase />}
          {activeTab === 'tickets' && <TicketList address={address!} />}
          {activeTab === 'history' && <DrawHistory />}
        </>
      ) : (
        <div className="text-center py-20">
          <h2 className="text-xl mb-4">Welcome to Lotty!</h2>
          <p className="text-gray-400 mb-8">
            Connect your wallet to start playing the no-loss lottery
          </p>
          <Wallet>
            <ConnectWallet className="bg-purple-600 hover:bg-purple-700 px-8 py-3 rounded-lg font-medium" />
          </Wallet>
        </div>
      )}
    </div>
  );
}

function DrawHistory() {
  // TODO: Implement draw history
  return (
    <div className="bg-gray-800/50 rounded-xl p-6">
      <h3 className="font-semibold mb-4">Recent Draws</h3>
      <p className="text-gray-400 text-sm">Coming soon...</p>
    </div>
  );
}
```
```

### Task 3.4: Create Ticket Purchase Component with Transaction
```
Create components/TicketPurchase.tsx:

```typescript
'use client';

import { useState, useCallback } from 'react';
import { useAccount } from 'wagmi';
import { parseUnits, encodeFunctionData } from 'viem';
import {
  Transaction,
  TransactionButton,
  TransactionStatus,
  TransactionStatusLabel,
  TransactionStatusAction,
} from '@coinbase/onchainkit/transaction';
import type { LifecycleStatus } from '@coinbase/onchainkit/transaction';
import { LOTTY_CORE_ABI, USDC_ABI } from '@/lib/abis';
import { baseSepolia } from 'viem/chains';

const LOTTY_CORE_ADDRESS = process.env.NEXT_PUBLIC_LOTTY_CORE as `0x${string}`;
const USDC_ADDRESS = process.env.NEXT_PUBLIC_USDC_ADDRESS as `0x${string}`;

export function TicketPurchase() {
  const { address } = useAccount();
  const [amount, setAmount] = useState('10');
  const [isLoading, setIsLoading] = useState(false);

  const amountWei = parseUnits(amount || '0', 6); // USDC has 6 decimals

  // Build transaction calls
  const calls = [
    // 1. Approve USDC spending
    {
      to: USDC_ADDRESS,
      data: encodeFunctionData({
        abi: USDC_ABI,
        functionName: 'approve',
        args: [LOTTY_CORE_ADDRESS, amountWei],
      }),
    },
    // 2. Buy ticket
    {
      to: LOTTY_CORE_ADDRESS,
      data: encodeFunctionData({
        abi: LOTTY_CORE_ABI,
        functionName: 'buyTicket',
        args: [amountWei],
      }),
    },
  ];

  const handleOnStatus = useCallback((status: LifecycleStatus) => {
    console.log('Transaction status:', status.statusName);
    if (status.statusName === 'success') {
      setIsLoading(false);
      // TODO: Refresh user stats
    }
  }, []);

  return (
    <div className="bg-gray-800/50 rounded-xl p-6">
      <h3 className="font-semibold mb-4">Buy Tickets</h3>
      
      {/* Amount Input */}
      <div className="mb-4">
        <label className="block text-sm text-gray-400 mb-2">
          Amount (USDC)
        </label>
        <div className="flex gap-2">
          <input
            type="number"
            min="1"
            step="1"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            className="flex-1 bg-gray-700 rounded-lg px-4 py-3 text-white focus:outline-none focus:ring-2 focus:ring-purple-500"
            placeholder="10"
          />
          <button
            onClick={() => setAmount('100')}
            className="px-4 py-2 bg-gray-700 rounded-lg text-sm hover:bg-gray-600"
          >
            Max
          </button>
        </div>
      </div>

      {/* Quick Amount Buttons */}
      <div className="flex gap-2 mb-6">
        {['10', '50', '100', '500'].map((preset) => (
          <button
            key={preset}
            onClick={() => setAmount(preset)}
            className={`flex-1 py-2 rounded-lg text-sm ${
              amount === preset
                ? 'bg-purple-600 text-white'
                : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
            }`}
          >
            ${preset}
          </button>
        ))}
      </div>

      {/* Transaction Button */}
      <Transaction
        chainId={baseSepolia.id}
        calls={calls}
        onStatus={handleOnStatus}
      >
        <TransactionButton 
          text="Buy Ticket 🎟️"
          className="w-full bg-purple-600 hover:bg-purple-700 py-3 rounded-lg font-medium"
        />
        <TransactionStatus>
          <TransactionStatusLabel />
          <TransactionStatusAction />
        </TransactionStatus>
      </Transaction>

      {/* Info */}
      <p className="text-xs text-gray-500 mt-4 text-center">
        Your principal is never at risk. You can withdraw anytime.
      </p>
    </div>
  );
}
```
```

### Task 3.5: Create User Stats Component
```
Create components/UserStats.tsx:

```typescript
'use client';

import { useReadContracts } from 'wagmi';
import { formatUnits } from 'viem';
import { LOTTY_CORE_ABI } from '@/lib/abis';

const LOTTY_CORE_ADDRESS = process.env.NEXT_PUBLIC_LOTTY_CORE as `0x${string}`;

interface UserStatsProps {
  address: `0x${string}`;
}

export function UserStats({ address }: UserStatsProps) {
  const { data, isLoading } = useReadContracts({
    contracts: [
      {
        address: LOTTY_CORE_ADDRESS,
        abi: LOTTY_CORE_ABI,
        functionName: 'getUserTickets',
        args: [address],
      },
      {
        address: LOTTY_CORE_ADDRESS,
        abi: LOTTY_CORE_ABI,
        functionName: 'getStreak',
        args: [address],
      },
      {
        address: LOTTY_CORE_ADDRESS,
        abi: LOTTY_CORE_ABI,
        functionName: 'getWinProbability',
        args: [address],
      },
    ],
  });

  const tickets = data?.[0]?.result as bigint[] | undefined;
  const streak = data?.[1]?.result as any;
  const probability = data?.[2]?.result as [bigint, bigint] | undefined;

  const activeTickets = tickets?.length || 0;
  const currentStreak = streak?.currentStreak || 0;
  const multiplier = streak?.multiplierBps 
    ? Number(streak.multiplierBps) / 10000 
    : 1;
  
  const winChance = probability && probability[1] > 0n
    ? (Number(probability[0]) / Number(probability[1]) * 100).toFixed(2)
    : '0';

  return (
    <div className="grid grid-cols-3 gap-4 mb-6">
      <StatCard
        label="Tickets"
        value={activeTickets.toString()}
        icon="🎟️"
        loading={isLoading}
      />
      <StatCard
        label="Streak"
        value={`${currentStreak} wks`}
        icon="🔥"
        subtext={`${multiplier}x`}
        loading={isLoading}
      />
      <StatCard
        label="Win Chance"
        value={`${winChance}%`}
        icon="🎯"
        loading={isLoading}
      />
    </div>
  );
}

function StatCard({
  label,
  value,
  icon,
  subtext,
  loading,
}: {
  label: string;
  value: string;
  icon: string;
  subtext?: string;
  loading?: boolean;
}) {
  return (
    <div className="bg-gray-800/50 rounded-xl p-4 text-center">
      <div className="text-2xl mb-1">{icon}</div>
      <div className="text-lg font-bold">
        {loading ? '...' : value}
      </div>
      <div className="text-xs text-gray-400">{label}</div>
      {subtext && (
        <div className="text-xs text-purple-400 mt-1">{subtext}</div>
      )}
    </div>
  );
}
```
```

### Task 3.6: Create Prize Pool and Countdown Components
```
Create components/PrizePool.tsx:

```typescript
'use client';

import { useReadContract } from 'wagmi';
import { formatUnits } from 'viem';
import { LOTTY_VAULT_ABI } from '@/lib/abis';

const LOTTY_VAULT_ADDRESS = process.env.NEXT_PUBLIC_LOTTY_VAULT as `0x${string}`;

export function PrizePool() {
  const { data: pendingYield, isLoading } = useReadContract({
    address: LOTTY_VAULT_ADDRESS,
    abi: LOTTY_VAULT_ABI,
    functionName: 'getPendingYield',
  });

  const prizeAmount = pendingYield 
    ? parseFloat(formatUnits(pendingYield as bigint, 6)).toFixed(2)
    : '0.00';

  return (
    <div className="bg-gradient-to-r from-purple-600 to-pink-600 rounded-xl p-6 mb-6 text-center">
      <p className="text-sm text-purple-200 mb-1">Current Prize Pool</p>
      <h2 className="text-4xl font-bold mb-2">
        {isLoading ? '...' : `$${prizeAmount}`}
      </h2>
      <p className="text-xs text-purple-200">USDC</p>
    </div>
  );
}
```

Create components/DrawCountdown.tsx:

```typescript
'use client';

import { useState, useEffect } from 'react';
import { useReadContract } from 'wagmi';
import { LOTTY_CORE_ABI } from '@/lib/abis';

const LOTTY_CORE_ADDRESS = process.env.NEXT_PUBLIC_LOTTY_CORE as `0x${string}`;

export function DrawCountdown() {
  const { data } = useReadContract({
    address: LOTTY_CORE_ADDRESS,
    abi: LOTTY_CORE_ABI,
    functionName: 'lastDrawTime',
  });

  const { data: interval } = useReadContract({
    address: LOTTY_CORE_ADDRESS,
    abi: LOTTY_CORE_ABI,
    functionName: 'drawInterval',
  });

  const [timeLeft, setTimeLeft] = useState('--:--:--');

  useEffect(() => {
    if (!data || !interval) return;

    const lastDraw = Number(data);
    const drawInterval = Number(interval);
    const nextDraw = lastDraw + drawInterval;

    const updateCountdown = () => {
      const now = Math.floor(Date.now() / 1000);
      const diff = nextDraw - now;

      if (diff <= 0) {
        setTimeLeft('Draw Ready!');
        return;
      }

      const days = Math.floor(diff / 86400);
      const hours = Math.floor((diff % 86400) / 3600);
      const minutes = Math.floor((diff % 3600) / 60);
      const seconds = diff % 60;

      if (days > 0) {
        setTimeLeft(`${days}d ${hours}h ${minutes}m`);
      } else {
        setTimeLeft(
          `${hours.toString().padStart(2, '0')}:${minutes
            .toString()
            .padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
        );
      }
    };

    updateCountdown();
    const timer = setInterval(updateCountdown, 1000);

    return () => clearInterval(timer);
  }, [data, interval]);

  return (
    <div className="bg-gray-800/50 rounded-xl p-4 mb-6 text-center">
      <p className="text-sm text-gray-400 mb-1">Next Draw In</p>
      <p className="text-2xl font-mono font-bold text-purple-400">
        {timeLeft}
      </p>
    </div>
  );
}
```
```

### Task 3.7: Create Contract ABIs
```
Create lib/abis.ts:

```typescript
export const LOTTY_CORE_ABI = [
  {
    inputs: [{ name: 'amount', type: 'uint256' }],
    name: 'buyTicket',
    outputs: [{ name: 'ticketId', type: 'uint256' }],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [{ name: 'ticketId', type: 'uint256' }],
    name: 'withdrawTicket',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [{ name: 'user', type: 'address' }],
    name: 'getUserTickets',
    outputs: [{ name: '', type: 'uint256[]' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ name: 'user', type: 'address' }],
    name: 'getStreak',
    outputs: [
      {
        components: [
          { name: 'currentStreak', type: 'uint32' },
          { name: 'lastActivityTime', type: 'uint64' },
          { name: 'multiplierBps', type: 'uint32' },
        ],
        type: 'tuple',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ name: 'user', type: 'address' }],
    name: 'getWinProbability',
    outputs: [
      { name: 'userWeight', type: 'uint256' },
      { name: 'totalWeight', type: 'uint256' },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'lastDrawTime',
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'drawInterval',
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
] as const;

export const LOTTY_VAULT_ABI = [
  {
    inputs: [],
    name: 'getPendingYield',
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'totalAssets',
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
] as const;

export const USDC_ABI = [
  {
    inputs: [
      { name: 'spender', type: 'address' },
      { name: 'amount', type: 'uint256' },
    ],
    name: 'approve',
    outputs: [{ name: '', type: 'bool' }],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [{ name: 'account', type: 'address' }],
    name: 'balanceOf',
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
] as const;
```
```

---

## Phase 4: Testing & Deployment

### Task 4.1: Smart Contract Tests
```
Create contracts/test/LottyCore.t.sol:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/core/LottyCore.sol";
import "../src/core/LottyVault.sol";
import "../src/adapters/MoonwellAdapter.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Mock USDC
contract MockUSDC is ERC20 {
    constructor() ERC20("USD Coin", "USDC") {
        _mint(msg.sender, 1_000_000e6);
    }
    
    function decimals() public pure override returns (uint8) {
        return 6;
    }
    
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

// Mock mToken
contract MockMToken {
    IERC20 public underlying;
    mapping(address => uint256) public balances;
    uint256 public exchangeRate = 1e18;
    
    constructor(address _underlying) {
        underlying = IERC20(_underlying);
    }
    
    function mint(uint256 amount) external returns (uint256) {
        underlying.transferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
        return 0;
    }
    
    function redeemUnderlying(uint256 amount) external returns (uint256) {
        balances[msg.sender] -= amount;
        underlying.transfer(msg.sender, amount);
        return 0;
    }
    
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
    
    function exchangeRateStored() external view returns (uint256) {
        return exchangeRate;
    }
    
    // Simulate yield
    function setExchangeRate(uint256 rate) external {
        exchangeRate = rate;
    }
}

contract LottyCoreTest is Test {
    LottyCore public lottyCore;
    LottyVault public vault;
    MoonwellAdapter public adapter;
    MockUSDC public usdc;
    MockMToken public mUsdc;
    
    address public alice = address(0x1);
    address public bob = address(0x2);
    address public treasury = address(0x3);
    
    function setUp() public {
        // Deploy mocks
        usdc = new MockUSDC();
        mUsdc = new MockMToken(address(usdc));
        
        // Deploy adapter (mock comptroller)
        // Note: In real test, mock the comptroller too
        
        // Deploy vault
        // vault = new LottyVault(...);
        
        // Deploy core
        // lottyCore = new LottyCore(...);
        
        // Fund users
        usdc.mint(alice, 10_000e6);
        usdc.mint(bob, 10_000e6);
    }
    
    function testBuyTicket() public {
        vm.startPrank(alice);
        usdc.approve(address(lottyCore), 100e6);
        
        uint256 ticketId = lottyCore.buyTicket(100e6);
        
        assertEq(ticketId, 1);
        assertEq(lottyCore.totalActiveTickets(), 1);
        
        LottyTypes.Ticket memory ticket = lottyCore.getTicket(ticketId);
        assertEq(ticket.owner, alice);
        assertEq(ticket.amount, 100e6);
        assertTrue(ticket.isActive);
        
        vm.stopPrank();
    }
    
    function testStreakIncrement() public {
        vm.startPrank(alice);
        usdc.approve(address(lottyCore), 200e6);
        
        // First ticket
        lottyCore.buyTicket(100e6);
        LottyTypes.Streak memory streak1 = lottyCore.getStreak(alice);
        assertEq(streak1.currentStreak, 1);
        
        // Second ticket within window
        vm.warp(block.timestamp + 1 days);
        lottyCore.buyTicket(100e6);
        LottyTypes.Streak memory streak2 = lottyCore.getStreak(alice);
        assertEq(streak2.currentStreak, 2);
        
        vm.stopPrank();
    }
    
    function testStreakReset() public {
        vm.startPrank(alice);
        usdc.approve(address(lottyCore), 200e6);
        
        // First ticket
        lottyCore.buyTicket(100e6);
        
        // Wait beyond streak window (7 days)
        vm.warp(block.timestamp + 8 days);
        
        lottyCore.buyTicket(100e6);
        LottyTypes.Streak memory streak = lottyCore.getStreak(alice);
        assertEq(streak.currentStreak, 1); // Reset to 1
        
        vm.stopPrank();
    }
    
    function testWithdrawTicket() public {
        vm.startPrank(alice);
        usdc.approve(address(lottyCore), 100e6);
        
        uint256 ticketId = lottyCore.buyTicket(100e6);
        
        uint256 balanceBefore = usdc.balanceOf(alice);
        lottyCore.withdrawTicket(ticketId);
        uint256 balanceAfter = usdc.balanceOf(alice);
        
        assertEq(balanceAfter - balanceBefore, 100e6);
        assertFalse(lottyCore.getTicket(ticketId).isActive);
        
        vm.stopPrank();
    }
    
    function testCannotWithdrawOthersTicket() public {
        vm.prank(alice);
        usdc.approve(address(lottyCore), 100e6);
        
        vm.prank(alice);
        uint256 ticketId = lottyCore.buyTicket(100e6);
        
        vm.prank(bob);
        vm.expectRevert(NotAuthorized.selector);
        lottyCore.withdrawTicket(ticketId);
    }
}
```
```

### Task 4.2: Deployment Script
```
Create contracts/script/Deploy.s.sol:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/core/LottyCore.sol";
import "../src/core/LottyVault.sol";
import "../src/core/LottyTreasury.sol";
import "../src/adapters/MoonwellAdapter.sol";

contract DeployLotty is Script {
    // Base Mainnet Addresses
    address constant USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
    address constant MOONWELL_MUSDC = 0xEDC817A28E8B93B03976Fbd4A3ddbC9F7D176C22;
    address constant MOONWELL_COMPTROLLER = 0xfBb21d0380beE3312B33c4353c8936a0F13EF26C;
    
    // Config
    uint256 constant MIN_DEPOSIT = 1e6;        // 1 USDC
    uint256 constant STREAK_WINDOW = 7 days;
    uint256 constant DRAW_INTERVAL = 7 days;
    uint256 constant PROTOCOL_FEE_BPS = 500;   // 5%
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deploying from:", deployer);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 1. Deploy Treasury
        LottyTreasury treasury = new LottyTreasury();
        console.log("Treasury deployed at:", address(treasury));
        
        // 2. Deploy Moonwell Adapter
        MoonwellAdapter adapter = new MoonwellAdapter(
            USDC,
            MOONWELL_MUSDC,
            MOONWELL_COMPTROLLER
        );
        console.log("MoonwellAdapter deployed at:", address(adapter));
        
        // 3. Deploy Vault
        LottyVault vault = new LottyVault(
            IERC20(USDC),
            address(adapter),
            address(treasury),
            PROTOCOL_FEE_BPS
        );
        console.log("LottyVault deployed at:", address(vault));
        
        // 4. Deploy Core
        LottyCore lottyCore = new LottyCore(
            USDC,
            address(vault),
            MIN_DEPOSIT,
            STREAK_WINDOW,
            DRAW_INTERVAL
        );
        console.log("LottyCore deployed at:", address(lottyCore));
        
        // 5. Configure connections
        adapter.setVault(address(vault));
        vault.setLottyCore(address(lottyCore));
        
        console.log("\n=== Deployment Complete ===");
        console.log("Treasury:", address(treasury));
        console.log("Adapter:", address(adapter));
        console.log("Vault:", address(vault));
        console.log("Core:", address(lottyCore));
        
        vm.stopBroadcast();
    }
}
```

Deploy commands:
```bash
# Load environment
source .env

# Deploy to Base Sepolia (testnet)
forge script script/Deploy.s.sol:DeployLotty \
  --rpc-url $BASE_SEPOLIA_RPC \
  --broadcast \
  --verify

# Deploy to Base Mainnet
forge script script/Deploy.s.sol:DeployLotty \
  --rpc-url $BASE_RPC_URL \
  --broadcast \
  --verify
```
```

---

## Phase 5: Notifications & Social Features

### Task 5.1: Setup Notifications API
```
The MiniKit scaffold includes notification infrastructure. Configure for Lotty:

Update app/api/notification/route.ts:

```typescript
import { NextRequest, NextResponse } from 'next/server';

// Notification types for Lotty
type NotificationType = 
  | 'draw_initiated'
  | 'draw_completed'
  | 'streak_warning'
  | 'prize_won';

interface LottyNotification {
  type: NotificationType;
  title: string;
  body: string;
  targetUrl?: string;
}

export async function POST(request: NextRequest) {
  try {
    const { fid, notification } = await request.json() as {
      fid: string;
      notification: LottyNotification;
    };

    // Forward to Farcaster notification service
    const response = await fetch('https://api.farcaster.xyz/v1/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.FARCASTER_API_KEY}`,
      },
      body: JSON.stringify({
        targetFid: fid,
        notification: {
          title: notification.title,
          body: notification.body,
          targetUrl: notification.targetUrl || process.env.NEXT_PUBLIC_APP_URL,
        },
      }),
    });

    if (!response.ok) {
      throw new Error('Failed to send notification');
    }

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Notification error:', error);
    return NextResponse.json(
      { error: 'Failed to send notification' },
      { status: 500 }
    );
  }
}

// Helper functions for sending specific notifications
export async function sendDrawNotification(
  fids: string[],
  prizeAmount: string
) {
  for (const fid of fids) {
    await fetch(`${process.env.NEXT_PUBLIC_APP_URL}/api/notification`, {
      method: 'POST',
      body: JSON.stringify({
        fid,
        notification: {
          type: 'draw_initiated',
          title: '🎰 Prize Draw Starting!',
          body: `$${prizeAmount} USDC prize pool is being drawn now!`,
        },
      }),
    });
  }
}

export async function sendWinnerNotification(
  winnerFid: string,
  prizeAmount: string
) {
  await fetch(`${process.env.NEXT_PUBLIC_APP_URL}/api/notification`, {
    method: 'POST',
    body: JSON.stringify({
      fid: winnerFid,
      notification: {
        type: 'prize_won',
        title: '🎉 You Won!',
        body: `Congratulations! You won $${prizeAmount} USDC!`,
      },
    }),
  });
}
```
```

### Task 5.2: Add Social Sharing
```
Create components/ShareButton.tsx:

```typescript
'use client';

import { useCallback } from 'react';
import { useMiniKit } from '@coinbase/onchainkit/minikit';

interface ShareButtonProps {
  ticketCount: number;
  streak: number;
}

export function ShareButton({ ticketCount, streak }: ShareButtonProps) {
  const { sdk } = useMiniKit();

  const handleShare = useCallback(async () => {
    if (!sdk) return;

    const text = `🎰 I'm playing Lotty - the no-loss lottery on Base!\n\n` +
      `🎟️ ${ticketCount} tickets\n` +
      `🔥 ${streak} week streak\n\n` +
      `Join me and win prizes without risking your principal!`;

    try {
      await sdk.actions.composeCast({
        text,
        embeds: [process.env.NEXT_PUBLIC_APP_URL!],
      });
    } catch (error) {
      console.error('Failed to share:', error);
    }
  }, [sdk, ticketCount, streak]);

  return (
    <button
      onClick={handleShare}
      className="w-full bg-blue-600 hover:bg-blue-700 py-3 rounded-lg font-medium flex items-center justify-center gap-2"
    >
      <span>📣</span>
      Share on Farcaster
    </button>
  );
}
```
```

---

## Quick Start Commands (Base Mini App)

```bash
# ============ INITIAL SETUP ============

# Create Mini App
npx create-onchain --mini
cd lotty-miniapp

# Install dependencies
npm install

# Create contracts folder
mkdir contracts && cd contracts
forge init

# ============ DEVELOPMENT ============

# Start frontend
npm run dev
# Open http://localhost:3000

# Run contract tests
cd contracts && forge test

# Build contracts
forge build

# ============ DEPLOYMENT ============

# Deploy contracts to Base Sepolia
cd contracts
forge script script/Deploy.s.sol:DeployLotty \
  --rpc-url https://sepolia.base.org \
  --broadcast \
  --verify

# Deploy to Base Mainnet
forge script script/Deploy.s.sol:DeployLotty \
  --rpc-url $BASE_RPC_URL \
  --broadcast \
  --verify

# ============ VERIFICATION ============

# Verify on Basescan
forge verify-contract <ADDRESS> LottyCore \
  --chain-id 8453 \
  --etherscan-api-key $BASESCAN_API_KEY

# ============ FRONTEND DEPLOYMENT ============

# Build for production
npm run build

# Deploy to Vercel
vercel --prod
```

---

## Priority Order for Implementation

### Week 1: Foundation
- **Task 1.1**: Initialize Base Mini App with MiniKit
- **Task 1.2**: Set up Foundry for smart contracts
- **Task 1.3**: Define types and interfaces

### Week 2: Core Contracts
- **Task 2.1**: LottyCore contract
- **Task 2.2**: LottyVault (ERC-4626)
- **Task 2.3**: MoonwellAdapter

### Week 3: Additional Contracts
- **Task 2.4**: LottyTreasury
- **Task 2.5**: VRF Integration (optional)

### Week 4: Frontend Components
- **Task 3.1-3.2**: MiniKit setup, providers
- **Task 3.3-3.4**: Dashboard, ticket purchase
- **Task 3.5-3.7**: Stats, countdown, ABIs

### Week 5: Testing & Integration
- **Task 4.1**: Smart contract tests
- **Task 4.2**: Deployment scripts

### Week 6: Polish & Launch
- **Task 5.1-5.2**: Notifications, social sharing
- Testing in Base App / Farcaster
- Mainnet deployment

---

## Notes for Claude Code

### Base Mini App Specific
- Use `npx create-onchain --mini` to scaffold
- MiniKitProvider wraps the app with wallet + transaction support
- OnchainKit components handle wallet, identity, transactions
- Use Paymaster for gasless UX (configure in CDP dashboard)
- Notifications via Farcaster/Base App API

### Solidity Development (Foundry)
- Use Foundry for Solidity development
- OpenZeppelin contracts for ERC-4626, access control
- Test with `forge test`
- Deploy with `forge script`

### Moonwell Integration
- mUSDC on Base: `0xEDC817A28E8B93B03976Fbd4A3ddbC9F7D176C22`
- Comptroller: `0xfBb21d0380beE3312B33c4353c8936a0F13EF26C`
- USDC: `0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913`
- Use `mint()` to deposit, `redeemUnderlying()` to withdraw
- Track `exchangeRateStored()` for yield calculation

### Contract Template
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyContract is Ownable {
    constructor() Ownable(msg.sender) {}
}
```

---

## Appendix: Key Addresses

### Base Mainnet
```
USDC: 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913
Moonwell mUSDC: 0xEDC817A28E8B93B03976Fbd4A3ddbC9F7D176C22
Moonwell Comptroller: 0xfBb21d0380beE3312B33c4353c8936a0F13EF26C
Chainlink VRF Coordinator: (check docs.chain.link for Base)
```

### Base Sepolia (Testnet)
```
USDC: (deploy mock or use testnet USDC)
Moonwell: (check testnet deployment)
```

---

---

## Phase 6: Frontend Migration & Agent Integration

> **Objective**: Reutilizar el frontend existente de Lotty (Stellar) y migrarlo a Base MiniKit, integrando agentes para automatización de operaciones.

### Task 6.1: Migrate Existing Frontend Structure

El proyecto ya tiene un frontend funcional con estos componentes:
- `DashboardPage` - Página principal con tabs
- `PoolsSection` - Información del pool
- `ProfileSection` - Perfil del usuario
- `SavingStreakSection` - Sistema de rachas
- `TicketsSection` - Gestión de tickets
- `WalletButton` - Conexión de wallet

**STEP 1: Actualizar la estructura de carpetas**

```
lotty-miniapp/
├── app/
│   ├── api/
│   │   ├── notification/
│   │   ├── webhook/
│   │   └── agent/              # NEW: Agent endpoints
│   │       ├── draw/route.ts
│   │       ├── harvest/route.ts
│   │       └── notify/route.ts
│   ├── dashboard/
│   │   └── page.tsx            # Migrated dashboard
│   ├── .well-known/
│   ├── layout.tsx              # Updated with MiniKit
│   └── page.tsx                # Landing/connect page
├── components/
│   ├── ui/                     # Existing UI components
│   │   └── card.tsx
│   ├── PoolsSection.tsx        # MIGRATE
│   ├── ProfileSection.tsx      # MIGRATE
│   ├── SavingStreakSection.tsx # MIGRATE
│   ├── TicketsSection.tsx      # MIGRATE
│   └── WalletButton.tsx        # REPLACE with OnchainKit
├── hooks/
│   ├── useWallet.ts            # REPLACE with wagmi
│   ├── useWalletBalance.ts     # REPLACE with wagmi
│   ├── useLottyContract.ts     # NEW
│   └── useAgent.ts             # NEW: Agent hooks
├── lib/
│   ├── abis.ts
│   ├── contracts.ts
│   └── agent.ts                # NEW: Agent client
├── providers/
│   └── WalletProvider.tsx      # REPLACE with MiniKit
└── styles/
    └── globals.css
```

**STEP 2: Migrar el Layout principal**

Reemplazar `layout.tsx`:

```typescript
// app/layout.tsx
import "~/styles/globals.css";
import { type Metadata } from "next";
import { Bungee, Bungee_Inline } from "next/font/google";
import { Providers } from "./providers";

export const metadata: Metadata = {
  title: "Lotty - Base",
  description: "The first no-loss lottery on Base",
  icons: [{ rel: "icon", url: "/lottyGuy.png" }],
};

const bungee = Bungee({
  subsets: ["latin"],
  weight: ["400"],
  variable: "--font-bungee",
});

const bungeeInline = Bungee_Inline({
  subsets: ["latin"],
  weight: ["400"],
  variable: "--font-bungee-inline",
});

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" className={`${bungee.variable} ${bungeeInline.variable}`}>
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
```

**STEP 3: Crear nuevo Providers con MiniKit**

```typescript
// app/providers.tsx
"use client";

import { ReactNode } from "react";
import { MiniKitProvider } from "@coinbase/onchainkit/minikit";
import { OnchainKitProvider } from "@coinbase/onchainkit";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { base, baseSepolia } from "viem/chains";

const queryClient = new QueryClient();

const chain = process.env.NEXT_PUBLIC_NETWORK === "mainnet" ? base : baseSepolia;

export function Providers({ children }: { children: ReactNode }) {
  return (
    <QueryClientProvider client={queryClient}>
      <MiniKitProvider
        apiKey={process.env.NEXT_PUBLIC_CDP_API_KEY}
        chain={chain}
        config={{
          appearance: {
            name: "Lotty",
            logo: "/lottyGuy.png",
            mode: "light",
            theme: "default",
          },
        }}
      >
        <OnchainKitProvider chain={chain}>
          {children}
        </OnchainKitProvider>
      </MiniKitProvider>
    </QueryClientProvider>
  );
}
```

### Task 6.2: Migrate Dashboard Page

Adaptar el `DashboardPage` existente para usar hooks de wagmi y OnchainKit:

```typescript
// app/dashboard/page.tsx
"use client";

import Image from "next/image";
import { useAccount, useBalance } from "wagmi";
import { useReadContracts } from "wagmi";
import { 
  ConnectWallet, 
  Wallet, 
  WalletDropdown,
  WalletDropdownDisconnect 
} from "@coinbase/onchainkit/wallet";
import { Avatar, Name, Identity } from "@coinbase/onchainkit/identity";
import { Card } from "~/components/ui/card";
import { PoolsSection } from "~/components/PoolsSection";
import { ProfileSection } from "~/components/ProfileSection";
import { SavingStreakSection } from "~/components/SavingStreakSection";
import { TicketsSection } from "~/components/TicketsSection";
import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { formatUnits } from "viem";
import { LOTTY_CORE_ABI, LOTTY_VAULT_ABI, USDC_ABI } from "~/lib/abis";

type TabId = "profile" | "tickets" | "pools" | "saving-streak";

const LOTTY_CORE = process.env.NEXT_PUBLIC_LOTTY_CORE as `0x${string}`;
const LOTTY_VAULT = process.env.NEXT_PUBLIC_LOTTY_VAULT as `0x${string}`;
const USDC_ADDRESS = process.env.NEXT_PUBLIC_USDC_ADDRESS as `0x${string}`;

export default function DashboardPage() {
  // Replace useWallet with wagmi's useAccount
  const { address, isConnecting, isConnected } = useAccount();
  const router = useRouter();
  const [activeTab, setActiveTab] = useState<TabId>("pools");
  const [copied, setCopied] = useState(false);
  const [ticketAmount, setTicketAmount] = useState(1);

  // Get USDC balance
  const { data: usdcBalance } = useBalance({
    address,
    token: USDC_ADDRESS,
  });

  // Read contract data
  const { data: contractData, refetch } = useReadContracts({
    contracts: [
      {
        address: LOTTY_CORE,
        abi: LOTTY_CORE_ABI,
        functionName: "getUserTickets",
        args: address ? [address] : undefined,
      },
      {
        address: LOTTY_CORE,
        abi: LOTTY_CORE_ABI,
        functionName: "getStreak",
        args: address ? [address] : undefined,
      },
      {
        address: LOTTY_CORE,
        abi: LOTTY_CORE_ABI,
        functionName: "totalActiveTickets",
      },
      {
        address: LOTTY_VAULT,
        abi: LOTTY_VAULT_ABI,
        functionName: "totalAssets",
      },
      {
        address: LOTTY_VAULT,
        abi: LOTTY_VAULT_ABI,
        functionName: "getPendingYield",
      },
    ],
  });

  // Parse contract data
  const userTickets = contractData?.[0]?.result as bigint[] | undefined;
  const streak = contractData?.[1]?.result as any;
  const totalTickets = contractData?.[2]?.result as bigint | undefined;
  const totalPool = contractData?.[3]?.result as bigint | undefined;
  const pendingYield = contractData?.[4]?.result as bigint | undefined;

  // Build poolData from contract reads
  const poolData = {
    totalPool: totalPool ? Number(formatUnits(totalPool, 6)) : 0,
    prize: pendingYield ? Number(formatUnits(pendingYield, 6)) : 0,
    apy: 13.5, // TODO: Get from Moonwell
    tickets: totalTickets ? Number(totalTickets) : 0,
    winners: 15, // TODO: Get from events
    round: 1, // TODO: Get from contract
    userTickets: userTickets?.length || 0,
    userBalance: usdcBalance ? Number(formatUnits(usdcBalance.value, 6)) : 0,
  };

  const userStats = {
    streak: streak?.currentStreak || 0,
    weekActivity: [true, true, false, true, true, false, false], // TODO: Calculate from events
    currentAPY: 11,
    multiplierBps: streak?.multiplierBps || 10000,
  };

  // Route protection
  useEffect(() => {
    if (!isConnecting && !isConnected) {
      router.push("/");
    }
  }, [isConnected, isConnecting, router]);

  const copyToClipboard = async (text: string) => {
    try {
      await navigator.clipboard.writeText(text);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (err) {
      console.error("Failed to copy:", err);
    }
  };

  // Wallet state object for compatibility with existing components
  const walletState = {
    balance: usdcBalance ? formatUnits(usdcBalance.value, 6) : "0",
    isLoading: false,
  };

  const renderContent = () => {
    switch (activeTab) {
      case "profile":
        return (
          <ProfileSection
            address={address ?? null}
            poolData={poolData}
            userStats={userStats}
            walletState={walletState}
            copied={copied}
            copyToClipboard={copyToClipboard}
          />
        );

      case "tickets":
        return (
          <TicketsSection
            address={address ?? null}
            ticketAmount={ticketAmount}
            setTicketAmount={setTicketAmount}
            userTicketIds={userTickets || []}
            onTransactionSuccess={() => refetch()}
          />
        );

      case "pools":
        return <PoolsSection address={address ?? null} poolData={poolData} />;

      case "saving-streak":
        return (
          <SavingStreakSection
            address={address ?? null}
            userStats={userStats}
          />
        );

      default:
        return (
          <div className="cuphead-text text-center text-2xl font-bold text-[#2C1810]">
            Section under development
          </div>
        );
    }
  };

  // Loading state
  if (isConnecting || !address) {
    return (
      <main className="relative flex h-screen w-screen items-center justify-center bg-gradient-to-b from-[#fefcf4] to-[#FFD93D]">
        <div className="rounded-2xl border-4 border-[#FFD93D] bg-[#2C1810] p-8 text-center">
          <div className="mb-4 inline-block h-12 w-12 animate-spin rounded-full border-4 border-solid border-[#FFD93D] border-r-transparent"></div>
          <p className="cuphead-text text-xl font-bold text-[#FFD93D]">
            Verifying connection...
          </p>
        </div>
      </main>
    );
  }

  return (
    <main className="relative flex h-screen w-screen flex-col">
      {/* Header with OnchainKit Wallet */}
      <header className="flex w-full shrink-0 justify-end px-6 py-2">
        <Wallet>
          <ConnectWallet className="bg-[#FFD93D] text-[#2C1810] font-bold rounded-lg px-4 py-2 hover:bg-[#f0c836]">
            <Avatar className="h-6 w-6" />
            <Name />
          </ConnectWallet>
          <WalletDropdown>
            <Identity className="px-4 pt-3 pb-2" hasCopyAddressOnClick>
              <Avatar />
              <Name />
            </Identity>
            <WalletDropdownDisconnect />
          </WalletDropdown>
        </Wallet>
      </header>

      {/* Main content - unchanged from original */}
      <section className="flex h-[calc(100vh-54px)] w-full gap-4 p-6 pt-0">
        {/* Navigation - same as original */}
        <nav className="flex h-full w-full max-w-[280px] flex-col justify-between py-4">
          <div className="flex flex-col gap-4 p-2">
            {[
              {
                id: "pools" as TabId,
                icon: <Image src="/lottyRuleta.png" alt="Pool" width={32} height={32} />,
                label: "Pool Information",
              },
              {
                id: "tickets" as TabId,
                icon: <Image src="/lottyPig.png" alt="Tickets" width={32} height={32} />,
                label: "Your Tickets",
              },
              {
                id: "saving-streak" as TabId,
                icon: <Image src="/lottyCaja.png" alt="Streak" width={32} height={32} />,
                label: "Saving Streak",
              },
              {
                id: "profile" as TabId,
                icon: <Image src="/lottyGuy.png" alt="Profile" width={32} height={32} />,
                label: "Your Profile",
              },
            ].map((item) => (
              <button
                key={item.id}
                onClick={() => setActiveTab(item.id)}
                className={`flex w-full cursor-pointer items-center gap-3 rounded-lg border-3 px-4 py-3 text-left text-sm font-bold transition-all duration-200 ${
                  activeTab === item.id
                    ? "scale-105 border-[#2C1810] bg-[#FFD93D] text-[#2C1810] shadow-lg"
                    : "border-transparent text-[#5D4E37] hover:scale-105 hover:border-[#2C1810]"
                }`}
              >
                <span className={activeTab === item.id ? "text-[#2C1810]" : "text-[#5D4E37]"}>
                  {item.icon}
                </span>
                <span>{item.label}</span>
              </button>
            ))}
          </div>

          {/* Stats Cards - updated with real data */}
          <div className="flex flex-col gap-3 px-4">
            <div className="group border-foreground hover:border-primary relative overflow-hidden rounded-lg border-2 bg-[#fefcf4] p-4 text-center transition-all duration-300 hover:-translate-y-1 hover:shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
              <div className="absolute top-2 right-2 text-2xl opacity-20">💰</div>
              <p className="text-muted-foreground mb-1 text-xs font-bold tracking-wide uppercase">
                Pool Total
              </p>
              <p className="text-foreground text-2xl font-black">
                ${poolData.totalPool >= 1000 
                  ? `${(poolData.totalPool / 1000).toFixed(0)}K` 
                  : poolData.totalPool.toFixed(0)}
              </p>
            </div>

            <div className="group border-foreground hover:border-primary relative overflow-hidden rounded-lg border-2 bg-[#fefcf4] p-4 text-center transition-all duration-300 hover:-translate-y-1 hover:shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
              <div className="absolute top-2 right-2 text-2xl opacity-30">🎟️</div>
              <p className="text-muted-foreground mb-1 text-xs font-bold tracking-wide uppercase">
                Your Tickets
              </p>
              <p className="text-primary text-2xl font-black">{poolData.userTickets}</p>
            </div>

            <div className="group hover:border-primary relative overflow-hidden rounded-lg border-2 bg-[#fefcf4] p-4 text-center transition-all duration-300 hover:-translate-y-1 hover:shadow-[4px_4px_0px_0px_rgba(246,197,66,1)]">
              <div className="absolute top-2 right-2 text-2xl opacity-30">🏆</div>
              <p className="text-foreground/70 mb-1 text-xs font-bold tracking-wide uppercase">
                Weekly Prize
              </p>
              <p className="text-foreground text-2xl font-black">
                ${poolData.prize.toLocaleString()}
              </p>
            </div>
          </div>
        </nav>

        <Card className="flex-1 overflow-y-auto scroll-auto border-0 p-6 shadow-[6px_6px_0px_0px_rgba(0,0,0,0.5)]">
          <div style={{ fontFamily: "ui-sans-serif, system-ui, sans-serif" }}>
            {renderContent()}
          </div>
        </Card>
      </section>
    </main>
  );
}
```

### Task 6.3: Migrate TicketsSection with Transaction Component

```typescript
// components/TicketsSection.tsx
"use client";

import { useState, useCallback } from "react";
import { parseUnits, encodeFunctionData, formatUnits } from "viem";
import {
  Transaction,
  TransactionButton,
  TransactionStatus,
  TransactionStatusLabel,
  TransactionStatusAction,
} from "@coinbase/onchainkit/transaction";
import type { LifecycleStatus } from "@coinbase/onchainkit/transaction";
import { useReadContracts } from "wagmi";
import { LOTTY_CORE_ABI, USDC_ABI } from "~/lib/abis";
import { baseSepolia, base } from "viem/chains";

const LOTTY_CORE = process.env.NEXT_PUBLIC_LOTTY_CORE as `0x${string}`;
const USDC_ADDRESS = process.env.NEXT_PUBLIC_USDC_ADDRESS as `0x${string}`;
const TICKET_PRICE = 10; // 10 USDC per ticket

interface TicketsSectionProps {
  address: string | null;
  ticketAmount: number;
  setTicketAmount: (amount: number) => void;
  userTicketIds: bigint[];
  onTransactionSuccess: () => void;
}

export function TicketsSection({
  address,
  ticketAmount,
  setTicketAmount,
  userTicketIds,
  onTransactionSuccess,
}: TicketsSectionProps) {
  const [isLoading, setIsLoading] = useState(false);

  // Fetch ticket details
  const { data: ticketDetails } = useReadContracts({
    contracts: userTicketIds.map((id) => ({
      address: LOTTY_CORE,
      abi: LOTTY_CORE_ABI,
      functionName: "getTicket",
      args: [id],
    })),
  });

  const totalAmount = ticketAmount * TICKET_PRICE;
  const amountWei = parseUnits(totalAmount.toString(), 6);

  // Build transaction calls for buying tickets
  const buyTicketCalls = [
    {
      to: USDC_ADDRESS,
      data: encodeFunctionData({
        abi: USDC_ABI,
        functionName: "approve",
        args: [LOTTY_CORE, amountWei],
      }),
    },
    {
      to: LOTTY_CORE,
      data: encodeFunctionData({
        abi: LOTTY_CORE_ABI,
        functionName: "buyTicket",
        args: [amountWei],
      }),
    },
  ];

  const handleBuyStatus = useCallback(
    (status: LifecycleStatus) => {
      console.log("Buy ticket status:", status.statusName);
      if (status.statusName === "success") {
        setIsLoading(false);
        onTransactionSuccess();
      }
    },
    [onTransactionSuccess]
  );

  // Build withdraw call for a specific ticket
  const buildWithdrawCalls = (ticketId: bigint) => [
    {
      to: LOTTY_CORE,
      data: encodeFunctionData({
        abi: LOTTY_CORE_ABI,
        functionName: "withdrawTicket",
        args: [ticketId],
      }),
    },
  ];

  const chainId = process.env.NEXT_PUBLIC_NETWORK === "mainnet" 
    ? base.id 
    : baseSepolia.id;

  return (
    <div className="space-y-6">
      {/* Buy Tickets Section */}
      <div className="rounded-xl border-2 border-[#2C1810] bg-[#fefcf4] p-6">
        <h3 className="text-xl font-bold text-[#2C1810] mb-4">🎟️ Buy Tickets</h3>
        
        <div className="flex items-center gap-4 mb-4">
          <button
            onClick={() => setTicketAmount(Math.max(1, ticketAmount - 1))}
            className="w-10 h-10 rounded-lg bg-[#2C1810] text-[#FFD93D] font-bold text-xl hover:bg-[#3d2a1f]"
          >
            -
          </button>
          <div className="flex-1 text-center">
            <p className="text-3xl font-bold text-[#2C1810]">{ticketAmount}</p>
            <p className="text-sm text-[#5D4E37]">tickets</p>
          </div>
          <button
            onClick={() => setTicketAmount(ticketAmount + 1)}
            className="w-10 h-10 rounded-lg bg-[#2C1810] text-[#FFD93D] font-bold text-xl hover:bg-[#3d2a1f]"
          >
            +
          </button>
        </div>

        <p className="text-center text-lg mb-4">
          Total: <span className="font-bold text-[#2C1810]">${totalAmount} USDC</span>
        </p>

        <Transaction
          chainId={chainId}
          calls={buyTicketCalls}
          onStatus={handleBuyStatus}
        >
          <TransactionButton
            text={`Buy ${ticketAmount} Ticket${ticketAmount > 1 ? "s" : ""} 🎟️`}
            className="w-full bg-[#FFD93D] hover:bg-[#f0c836] text-[#2C1810] font-bold py-3 rounded-lg transition-all"
          />
          <TransactionStatus>
            <TransactionStatusLabel />
            <TransactionStatusAction />
          </TransactionStatus>
        </Transaction>
      </div>

      {/* Your Tickets List */}
      <div className="rounded-xl border-2 border-[#2C1810] bg-[#fefcf4] p-6">
        <h3 className="text-xl font-bold text-[#2C1810] mb-4">
          📋 Your Tickets ({userTicketIds.length})
        </h3>

        {userTicketIds.length === 0 ? (
          <p className="text-center text-[#5D4E37] py-8">
            You don't have any tickets yet. Buy some to participate!
          </p>
        ) : (
          <div className="space-y-3">
            {userTicketIds.map((ticketId, index) => {
              const ticket = ticketDetails?.[index]?.result as any;
              const isActive = ticket?.isActive ?? true;

              return (
                <div
                  key={ticketId.toString()}
                  className={`flex items-center justify-between p-4 rounded-lg border-2 ${
                    isActive 
                      ? "border-[#2C1810] bg-white" 
                      : "border-gray-300 bg-gray-100 opacity-60"
                  }`}
                >
                  <div>
                    <p className="font-bold text-[#2C1810]">
                      Ticket #{ticketId.toString().slice(-4)}
                    </p>
                    <p className="text-sm text-[#5D4E37]">
                      {ticket ? `$${formatUnits(ticket.amount, 6)} USDC` : "Loading..."}
                    </p>
                  </div>

                  {isActive && (
                    <Transaction
                      chainId={chainId}
                      calls={buildWithdrawCalls(ticketId)}
                      onStatus={(status) => {
                        if (status.statusName === "success") {
                          onTransactionSuccess();
                        }
                      }}
                    >
                      <TransactionButton
                        text="Withdraw"
                        className="bg-red-500 hover:bg-red-600 text-white font-bold px-4 py-2 rounded-lg text-sm"
                      />
                    </Transaction>
                  )}
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
```

### Task 6.4: CDP AgentKit Integration for Automated Operations

Instalar y configurar CDP AgentKit para automatizar operaciones como:
- Ejecución automática de sorteos (prize draws)
- Harvest de yield
- Notificaciones a usuarios

**STEP 1: Instalar dependencias del agente**

```bash
npm install @coinbase/cdp-agentkit-core @coinbase/cdp-langchain langchain @langchain/openai
```

**STEP 2: Crear el cliente del agente**

```typescript
// lib/agent.ts
import { CdpAgentkit } from "@coinbase/cdp-agentkit-core";
import { CdpToolkit } from "@coinbase/cdp-langchain";
import { ChatOpenAI } from "@langchain/openai";
import { createReactAgent } from "@langchain/langgraph/prebuilt";

// Configuration
const CDP_API_KEY_NAME = process.env.CDP_API_KEY_NAME!;
const CDP_API_KEY_PRIVATE_KEY = process.env.CDP_API_KEY_PRIVATE_KEY!;
const OPENAI_API_KEY = process.env.OPENAI_API_KEY!;
const NETWORK_ID = process.env.NEXT_PUBLIC_NETWORK === "mainnet" ? "base-mainnet" : "base-sepolia";

// Wallet data persistence (in production, use a database)
let walletDataStr: string | null = null;

export async function initializeAgent() {
  // Initialize CDP AgentKit
  const config = {
    cdpApiKeyName: CDP_API_KEY_NAME,
    cdpApiKeyPrivateKey: CDP_API_KEY_PRIVATE_KEY,
    networkId: NETWORK_ID,
  };

  // Load existing wallet or create new one
  const agentkit = walletDataStr
    ? await CdpAgentkit.configureWithWallet({ ...config, cdpWalletData: walletDataStr })
    : await CdpAgentkit.configureWithWallet(config);

  // Save wallet data
  walletDataStr = await agentkit.exportWallet();

  // Create toolkit with Lotty-specific tools
  const toolkit = new CdpToolkit(agentkit);
  const tools = toolkit.getTools();

  // Add custom Lotty tools
  const lottyTools = createLottyTools(agentkit);
  const allTools = [...tools, ...lottyTools];

  // Initialize LLM
  const llm = new ChatOpenAI({
    model: "gpt-4o-mini",
    apiKey: OPENAI_API_KEY,
  });

  // Create agent
  const agent = createReactAgent({
    llm,
    tools: allTools,
    messageModifier: `
      You are Lotty Agent, an AI assistant for the Lotty no-loss lottery protocol on Base.
      You can help with:
      - Executing weekly prize draws
      - Harvesting yield from Moonwell
      - Sending notifications to users
      - Checking pool status and statistics
      
      Always be helpful and explain what you're doing.
      Current network: ${NETWORK_ID}
    `,
  });

  return { agent, agentkit };
}

// Custom tools for Lotty operations
function createLottyTools(agentkit: CdpAgentkit) {
  return [
    {
      name: "lotty_initiate_draw",
      description: "Initiates a new prize draw for the Lotty lottery. Requires owner permissions.",
      func: async (input: { commitHash: string }) => {
        try {
          const wallet = agentkit.wallet;
          const result = await wallet.invokeContract({
            contractAddress: process.env.NEXT_PUBLIC_LOTTY_CORE!,
            method: "initiateDraw",
            args: { commitHash: input.commitHash },
            abi: LOTTY_CORE_ABI,
          });
          return `Draw initiated successfully. TX: ${result.getTransactionHash()}`;
        } catch (error) {
          return `Failed to initiate draw: ${error}`;
        }
      },
    },
    {
      name: "lotty_execute_draw",
      description: "Executes a pending prize draw with the random seed.",
      func: async (input: { randomSeed: string }) => {
        try {
          const wallet = agentkit.wallet;
          const result = await wallet.invokeContract({
            contractAddress: process.env.NEXT_PUBLIC_LOTTY_CORE!,
            method: "executeDraw",
            args: { randomSeed: input.randomSeed },
            abi: LOTTY_CORE_ABI,
          });
          return `Draw executed! TX: ${result.getTransactionHash()}`;
        } catch (error) {
          return `Failed to execute draw: ${error}`;
        }
      },
    },
    {
      name: "lotty_harvest_yield",
      description: "Harvests accumulated yield from Moonwell and prepares it for the prize pool.",
      func: async () => {
        try {
          const wallet = agentkit.wallet;
          const result = await wallet.invokeContract({
            contractAddress: process.env.NEXT_PUBLIC_LOTTY_VAULT!,
            method: "harvestYield",
            args: {},
            abi: LOTTY_VAULT_ABI,
          });
          return `Yield harvested! TX: ${result.getTransactionHash()}`;
        } catch (error) {
          return `Failed to harvest yield: ${error}`;
        }
      },
    },
    {
      name: "lotty_check_pool_status",
      description: "Checks the current status of the Lotty pool.",
      func: async () => {
        try {
          // Read contract state
          const totalAssets = await readContract({
            address: process.env.NEXT_PUBLIC_LOTTY_VAULT as `0x${string}`,
            abi: LOTTY_VAULT_ABI,
            functionName: "totalAssets",
          });
          
          const pendingYield = await readContract({
            address: process.env.NEXT_PUBLIC_LOTTY_VAULT as `0x${string}`,
            abi: LOTTY_VAULT_ABI,
            functionName: "getPendingYield",
          });

          return JSON.stringify({
            totalAssets: formatUnits(totalAssets as bigint, 6),
            pendingYield: formatUnits(pendingYield as bigint, 6),
          });
        } catch (error) {
          return `Failed to check status: ${error}`;
        }
      },
    },
  ];
}

// Import ABIs
import { LOTTY_CORE_ABI, LOTTY_VAULT_ABI } from "./abis";
import { readContract } from "wagmi/actions";
import { formatUnits } from "viem";
```

**STEP 3: Crear API Routes para el agente**

```typescript
// app/api/agent/draw/route.ts
import { NextRequest, NextResponse } from "next/server";
import { initializeAgent } from "~/lib/agent";
import { HumanMessage } from "@langchain/core/messages";
import crypto from "crypto";

export async function POST(request: NextRequest) {
  try {
    // Verify admin authorization
    const authHeader = request.headers.get("authorization");
    if (authHeader !== `Bearer ${process.env.AGENT_API_KEY}`) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const { agent } = await initializeAgent();

    // Generate random seed for the draw
    const randomSeed = crypto.randomBytes(32).toString("hex");
    const commitHash = crypto.createHash("sha256").update(randomSeed).digest("hex");

    // Step 1: Initiate draw
    const initiateResponse = await agent.invoke({
      messages: [new HumanMessage(`Initiate a prize draw with commit hash: 0x${commitHash}`)],
    });

    // Wait for reveal block (in production, this would be scheduled)
    // For demo, we execute immediately
    
    // Step 2: Execute draw
    const executeResponse = await agent.invoke({
      messages: [new HumanMessage(`Execute the draw with random seed: ${randomSeed}`)],
    });

    return NextResponse.json({
      success: true,
      initiate: initiateResponse,
      execute: executeResponse,
    });
  } catch (error) {
    console.error("Agent draw error:", error);
    return NextResponse.json(
      { error: "Failed to execute draw" },
      { status: 500 }
    );
  }
}
```

```typescript
// app/api/agent/harvest/route.ts
import { NextRequest, NextResponse } from "next/server";
import { initializeAgent } from "~/lib/agent";
import { HumanMessage } from "@langchain/core/messages";

export async function POST(request: NextRequest) {
  try {
    const authHeader = request.headers.get("authorization");
    if (authHeader !== `Bearer ${process.env.AGENT_API_KEY}`) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const { agent } = await initializeAgent();

    // Check status first
    const statusResponse = await agent.invoke({
      messages: [new HumanMessage("Check the current pool status")],
    });

    // Harvest yield
    const harvestResponse = await agent.invoke({
      messages: [new HumanMessage("Harvest the yield from Moonwell")],
    });

    return NextResponse.json({
      success: true,
      status: statusResponse,
      harvest: harvestResponse,
    });
  } catch (error) {
    console.error("Agent harvest error:", error);
    return NextResponse.json(
      { error: "Failed to harvest yield" },
      { status: 500 }
    );
  }
}
```

**STEP 4: Crear hook para interactuar con el agente desde el frontend**

```typescript
// hooks/useAgent.ts
import { useState, useCallback } from "react";

interface AgentResponse {
  success: boolean;
  data?: any;
  error?: string;
}

export function useAgent() {
  const [isLoading, setIsLoading] = useState(false);
  const [lastResponse, setLastResponse] = useState<AgentResponse | null>(null);

  const triggerDraw = useCallback(async () => {
    setIsLoading(true);
    try {
      const response = await fetch("/api/agent/draw", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${process.env.NEXT_PUBLIC_AGENT_API_KEY}`,
        },
      });
      const data = await response.json();
      setLastResponse({ success: true, data });
      return data;
    } catch (error) {
      setLastResponse({ success: false, error: String(error) });
      throw error;
    } finally {
      setIsLoading(false);
    }
  }, []);

  const harvestYield = useCallback(async () => {
    setIsLoading(true);
    try {
      const response = await fetch("/api/agent/harvest", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${process.env.NEXT_PUBLIC_AGENT_API_KEY}`,
        },
      });
      const data = await response.json();
      setLastResponse({ success: true, data });
      return data;
    } catch (error) {
      setLastResponse({ success: false, error: String(error) });
      throw error;
    } finally {
      setIsLoading(false);
    }
  }, []);

  const checkStatus = useCallback(async () => {
    setIsLoading(true);
    try {
      const response = await fetch("/api/agent/status", {
        method: "GET",
      });
      const data = await response.json();
      setLastResponse({ success: true, data });
      return data;
    } catch (error) {
      setLastResponse({ success: false, error: String(error) });
      throw error;
    } finally {
      setIsLoading(false);
    }
  }, []);

  return {
    triggerDraw,
    harvestYield,
    checkStatus,
    isLoading,
    lastResponse,
  };
}
```

**STEP 5: Agregar panel de administración para agentes**

```typescript
// components/AdminAgentPanel.tsx
"use client";

import { useState } from "react";
import { useAgent } from "~/hooks/useAgent";

export function AdminAgentPanel() {
  const { triggerDraw, harvestYield, checkStatus, isLoading, lastResponse } = useAgent();
  const [logs, setLogs] = useState<string[]>([]);

  const addLog = (message: string) => {
    setLogs((prev) => [...prev, `[${new Date().toLocaleTimeString()}] ${message}`]);
  };

  const handleDraw = async () => {
    addLog("🎰 Initiating prize draw...");
    try {
      const result = await triggerDraw();
      addLog(`✅ Draw completed: ${JSON.stringify(result)}`);
    } catch (error) {
      addLog(`❌ Draw failed: ${error}`);
    }
  };

  const handleHarvest = async () => {
    addLog("🌾 Harvesting yield from Moonwell...");
    try {
      const result = await harvestYield();
      addLog(`✅ Harvest completed: ${JSON.stringify(result)}`);
    } catch (error) {
      addLog(`❌ Harvest failed: ${error}`);
    }
  };

  const handleStatus = async () => {
    addLog("📊 Checking pool status...");
    try {
      const result = await checkStatus();
      addLog(`✅ Status: ${JSON.stringify(result)}`);
    } catch (error) {
      addLog(`❌ Status check failed: ${error}`);
    }
  };

  return (
    <div className="rounded-xl border-2 border-[#2C1810] bg-[#fefcf4] p-6">
      <h3 className="text-xl font-bold text-[#2C1810] mb-4">🤖 Agent Control Panel</h3>
      
      <div className="grid grid-cols-3 gap-4 mb-6">
        <button
          onClick={handleStatus}
          disabled={isLoading}
          className="bg-blue-500 hover:bg-blue-600 disabled:bg-gray-400 text-white font-bold py-3 rounded-lg transition-all"
        >
          📊 Check Status
        </button>
        
        <button
          onClick={handleHarvest}
          disabled={isLoading}
          className="bg-green-500 hover:bg-green-600 disabled:bg-gray-400 text-white font-bold py-3 rounded-lg transition-all"
        >
          🌾 Harvest Yield
        </button>
        
        <button
          onClick={handleDraw}
          disabled={isLoading}
          className="bg-purple-500 hover:bg-purple-600 disabled:bg-gray-400 text-white font-bold py-3 rounded-lg transition-all"
        >
          🎰 Execute Draw
        </button>
      </div>

      {/* Agent Logs */}
      <div className="bg-[#2C1810] rounded-lg p-4 h-48 overflow-y-auto">
        <p className="text-[#FFD93D] font-mono text-sm mb-2">Agent Logs:</p>
        {logs.length === 0 ? (
          <p className="text-gray-400 font-mono text-xs">No logs yet...</p>
        ) : (
          logs.map((log, index) => (
            <p key={index} className="text-green-400 font-mono text-xs mb-1">
              {log}
            </p>
          ))
        )}
      </div>

      {isLoading && (
        <div className="mt-4 text-center">
          <div className="inline-block h-6 w-6 animate-spin rounded-full border-2 border-solid border-[#FFD93D] border-r-transparent"></div>
          <p className="text-[#2C1810] text-sm mt-2">Agent working...</p>
        </div>
      )}
    </div>
  );
}
```

### Task 6.5: Environment Variables for Agent

Agregar al `.env.local`:

```env
# ============ CDP AgentKit ============
CDP_API_KEY_NAME=your-cdp-api-key-name
CDP_API_KEY_PRIVATE_KEY=your-cdp-private-key

# ============ OpenAI (for LLM) ============
OPENAI_API_KEY=sk-...

# ============ Agent Security ============
AGENT_API_KEY=your-secure-agent-api-key
NEXT_PUBLIC_AGENT_API_KEY=your-public-agent-key  # For admin panel

# ============ Existing vars ============
NEXT_PUBLIC_CDP_API_KEY=your_cdp_api_key
NEXT_PUBLIC_ONCHAINKIT_PROJECT_ID=your_project_id
NEXT_PUBLIC_PAYMASTER_URL=https://api.developer.coinbase.com/rpc/v1/base/your_key
NEXT_PUBLIC_NETWORK=sepolia  # or mainnet
NEXT_PUBLIC_LOTTY_CORE=0x...
NEXT_PUBLIC_LOTTY_VAULT=0x...
NEXT_PUBLIC_USDC_ADDRESS=0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913
NEXT_PUBLIC_MOONWELL_MUSDC=0xEDC817A28E8B93B03976Fbd4A3ddbC9F7D176C22
```

### Task 6.6: Scheduled Agent Tasks with Cron

Para ejecutar los agentes automáticamente, usar Vercel Cron o un servicio externo:

```typescript
// app/api/cron/weekly-draw/route.ts
import { NextRequest, NextResponse } from "next/server";

export async function GET(request: NextRequest) {
  // Verify cron secret
  const authHeader = request.headers.get("authorization");
  if (authHeader !== `Bearer ${process.env.CRON_SECRET}`) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  try {
    // Trigger the agent to execute weekly draw
    const response = await fetch(`${process.env.NEXT_PUBLIC_APP_URL}/api/agent/draw`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${process.env.AGENT_API_KEY}`,
      },
    });

    const result = await response.json();
    
    return NextResponse.json({
      success: true,
      message: "Weekly draw executed",
      result,
    });
  } catch (error) {
    console.error("Cron draw error:", error);
    return NextResponse.json({ error: "Draw failed" }, { status: 500 });
  }
}
```

Configurar en `vercel.json`:

```json
{
  "crons": [
    {
      "path": "/api/cron/weekly-draw",
      "schedule": "0 12 * * 0"
    },
    {
      "path": "/api/cron/harvest",
      "schedule": "0 0 * * *"
    }
  ]
}
```

### Migration Checklist

| Component | Status | Action |
|-----------|--------|--------|
| `layout.tsx` | ⬜ | Replace WalletProvider with MiniKitProvider |
| `page.tsx` (Dashboard) | ⬜ | Migrate to wagmi hooks |
| `WalletButton` | ⬜ | Replace with OnchainKit Wallet |
| `PoolsSection` | ⬜ | Update props to use contract data |
| `ProfileSection` | ⬜ | Update props to use contract data |
| `SavingStreakSection` | ⬜ | Update props to use contract data |
| `TicketsSection` | ⬜ | Add Transaction component |
| `useWallet` hook | ⬜ | Remove, use wagmi |
| `useWalletBalance` hook | ⬜ | Remove, use wagmi |
| Auth actions | ⬜ | Remove server-side auth, use wallet |
| Agent integration | ⬜ | Add CDP AgentKit |
| Cron jobs | ⬜ | Configure Vercel crons |

---

## Resources

- **Base Mini Apps**: https://docs.base.org/builderkits/minikit
- **OnchainKit**: https://docs.base.org/builderkits/onchainkit
- **CDP AgentKit**: https://docs.cdp.coinbase.com/agentkit
- **CDP AgentKit GitHub**: https://github.com/coinbase/cdp-agentkit
- **Moonwell Docs**: https://docs.moonwell.fi
- **Moonwell on Base**: https://moonwell.fi/markets?chain=base
- **Foundry Book**: https://book.getfoundry.sh
- **ERC-4626 Standard**: https://eips.ethereum.org/EIPS/eip-4626
- **Chainlink VRF (Base)**: https://docs.chain.link/vrf
- **Vercel Cron Jobs**: https://vercel.com/docs/cron-jobs
