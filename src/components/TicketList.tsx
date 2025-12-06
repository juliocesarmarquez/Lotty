'use client';

import { useReadContract } from 'wagmi';
import { LOTTY_CORE_ABI } from '~/lib/abis';

const LOTTY_CORE_ADDRESS = process.env.NEXT_PUBLIC_LOTTY_CORE as `0x${string}`;

interface TicketListProps {
  address: string;
}

export function TicketList({ address }: TicketListProps) {
  const { data: tickets, isLoading } = useReadContract({
    address: LOTTY_CORE_ADDRESS,
    abi: LOTTY_CORE_ABI,
    functionName: 'getUserTickets',
    args: [address as `0x${string}`],
  });

  const ticketIds = tickets as bigint[] | undefined;

  if (isLoading) {
    return (
      <div className="bg-gray-800/50 rounded-xl p-6">
        <h3 className="font-semibold mb-4">Your Tickets</h3>
        <p className="text-gray-400 text-sm">Loading tickets...</p>
      </div>
    );
  }

  if (!ticketIds || ticketIds.length === 0) {
    return (
      <div className="bg-gray-800/50 rounded-xl p-6">
        <h3 className="font-semibold mb-4">Your Tickets</h3>
        <p className="text-gray-400 text-sm">No tickets yet. Buy your first ticket to get started!</p>
      </div>
    );
  }

  return (
    <div className="bg-gray-800/50 rounded-xl p-6">
      <h3 className="font-semibold mb-4">Your Tickets ({ticketIds.length})</h3>
      <div className="space-y-2">
        {ticketIds.map((ticketId) => (
          <div
            key={ticketId.toString()}
            className="bg-gray-700/50 rounded-lg p-4 flex items-center justify-between"
          >
            <div className="flex items-center gap-3">
              <span className="text-2xl">🎟️</span>
              <div>
                <p className="font-medium">Ticket #{ticketId.toString()}</p>
                <p className="text-xs text-gray-400">Active in current draw</p>
              </div>
            </div>
            <div className="text-right">
              <p className="text-sm text-purple-400">Entered</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
