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
import { LOTTY_CORE_ABI, USDC_ABI } from '~/lib/abis';
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
