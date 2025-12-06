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
