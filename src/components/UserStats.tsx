'use client';

import { useReadContracts } from 'wagmi';
import { formatUnits } from 'viem';
import { LOTTY_CORE_ABI } from '~/lib/abis';

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
