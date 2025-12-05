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
