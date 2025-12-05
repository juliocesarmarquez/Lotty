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
        // Simplified: APY H ratePerSecond * secondsPerYear
        return ratePerSecond * 365 days;
    }
}
