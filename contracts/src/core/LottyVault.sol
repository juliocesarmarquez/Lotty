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
