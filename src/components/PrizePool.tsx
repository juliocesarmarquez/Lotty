'use client';

import { useReadContract } from 'wagmi';
import { formatUnits } from 'viem';
import { LOTTY_VAULT_ABI } from '~/lib/abis';

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
