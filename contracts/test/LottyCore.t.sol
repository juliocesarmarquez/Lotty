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

    function supplyRatePerTimestamp() external pure returns (uint256) {
        // Mock APY of ~10%
        return 3170979198; // Approximate rate per second
    }

    // Simulate yield
    function setExchangeRate(uint256 rate) external {
        exchangeRate = rate;
    }
}

// Mock Comptroller
contract MockComptroller {
    function enterMarkets(address[] calldata) external pure returns (uint256[] memory) {
        uint256[] memory results = new uint256[](1);
        results[0] = 0; // Success
        return results;
    }
}

contract LottyCoreTest is Test {
    LottyCore public lottyCore;
    LottyVault public vault;
    MoonwellAdapter public adapter;
    MockUSDC public usdc;
    MockMToken public mUsdc;
    MockComptroller public comptroller;

    address public alice = address(0x1);
    address public bob = address(0x2);
    address public treasury = address(0x3);

    function setUp() public {
        // Deploy mocks
        usdc = new MockUSDC();
        mUsdc = new MockMToken(address(usdc));
        comptroller = new MockComptroller();

        // Deploy adapter
        adapter = new MoonwellAdapter(
            address(usdc),
            address(mUsdc),
            address(comptroller)
        );

        // Deploy vault
        vault = new LottyVault(
            IERC20(address(usdc)),
            address(adapter),
            treasury,
            500 // 5% protocol fee
        );

        // Deploy core
        lottyCore = new LottyCore(
            address(usdc),
            address(vault),
            1e6,      // 1 USDC min deposit
            7 days,   // streak window
            7 days    // draw interval
        );

        // Configure connections
        adapter.setVault(address(vault));
        vault.setLottyCore(address(lottyCore));

        // Approve adapter for vault
        vm.prank(address(vault));
        usdc.approve(address(adapter), type(uint256).max);

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

        uint256[] memory tickets = lottyCore.getUserTickets(alice);
        assertEq(tickets.length, 1);
        assertEq(tickets[0], ticketId);

        vm.stopPrank();
    }

    function testStreakIncrement() public {
        vm.startPrank(alice);
        usdc.approve(address(lottyCore), 200e6);

        // First ticket
        lottyCore.buyTicket(100e6);
        LottyTypes.Streak memory streak1 = lottyCore.getStreak(alice);
        assertEq(streak1.currentStreak, 1);

        // Second ticket within window (1 day later)
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

        // Wait beyond streak window (8 days > 7 days)
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

        // Check ticket is no longer active
        uint256[] memory tickets = lottyCore.getUserTickets(alice);
        assertEq(tickets.length, 0);

        vm.stopPrank();
    }

    function testCannotWithdrawOthersTicket() public {
        vm.prank(alice);
        usdc.approve(address(lottyCore), 100e6);

        vm.prank(alice);
        uint256 ticketId = lottyCore.buyTicket(100e6);

        vm.prank(bob);
        vm.expectRevert();
        lottyCore.withdrawTicket(ticketId);
    }

    function testMinimumDeposit() public {
        vm.startPrank(alice);
        usdc.approve(address(lottyCore), 0.5e6);

        // Should revert for amount below minimum
        vm.expectRevert();
        lottyCore.buyTicket(0.5e6);

        vm.stopPrank();
    }

    function testMultipleTickets() public {
        vm.startPrank(alice);
        usdc.approve(address(lottyCore), 500e6);

        // Buy 5 tickets
        for (uint256 i = 0; i < 5; i++) {
            lottyCore.buyTicket(100e6);
        }

        uint256[] memory tickets = lottyCore.getUserTickets(alice);
        assertEq(tickets.length, 5);
        assertEq(lottyCore.totalActiveTickets(), 5);

        vm.stopPrank();
    }

    function testGetWinProbability() public {
        vm.startPrank(alice);
        usdc.approve(address(lottyCore), 300e6);

        // Alice buys 3 tickets
        lottyCore.buyTicket(100e6);
        lottyCore.buyTicket(100e6);
        lottyCore.buyTicket(100e6);
        vm.stopPrank();

        vm.startPrank(bob);
        usdc.approve(address(lottyCore), 100e6);

        // Bob buys 1 ticket
        lottyCore.buyTicket(100e6);
        vm.stopPrank();

        (uint256 aliceWeight, uint256 totalWeight) = lottyCore.getWinProbability(alice);
        assertEq(aliceWeight, 3);
        assertEq(totalWeight, 4);

        (uint256 bobWeight, uint256 bobTotalWeight) = lottyCore.getWinProbability(bob);
        assertEq(bobWeight, 1);
        assertEq(bobTotalWeight, 4);
    }
}
