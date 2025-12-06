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
    address constant MOONWELL_MUSDC = 0xEdc817A28E8B93B03976FBd4a3dDBc9f7D176c22;
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
