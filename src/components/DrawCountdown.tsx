'use client';

import { useState, useEffect } from 'react';
import { useReadContract } from 'wagmi';
import { LOTTY_CORE_ABI } from '~/lib/abis';

const LOTTY_CORE_ADDRESS = process.env.NEXT_PUBLIC_LOTTY_CORE as `0x${string}`;

export function DrawCountdown() {
  const { data } = useReadContract({
    address: LOTTY_CORE_ADDRESS,
    abi: LOTTY_CORE_ABI,
    functionName: 'lastDrawTime',
  });

  const { data: interval } = useReadContract({
    address: LOTTY_CORE_ADDRESS,
    abi: LOTTY_CORE_ABI,
    functionName: 'drawInterval',
  });

  const [timeLeft, setTimeLeft] = useState('--:--:--');

  useEffect(() => {
    if (!data || !interval) return;

    const lastDraw = Number(data);
    const drawInterval = Number(interval);
    const nextDraw = lastDraw + drawInterval;

    const updateCountdown = () => {
      const now = Math.floor(Date.now() / 1000);
      const diff = nextDraw - now;

      if (diff <= 0) {
        setTimeLeft('Draw Ready!');
        return;
      }

      const days = Math.floor(diff / 86400);
      const hours = Math.floor((diff % 86400) / 3600);
      const minutes = Math.floor((diff % 3600) / 60);
      const seconds = diff % 60;

      if (days > 0) {
        setTimeLeft(`${days}d ${hours}h ${minutes}m`);
      } else {
        setTimeLeft(
          `${hours.toString().padStart(2, '0')}:${minutes
            .toString()
            .padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
        );
      }
    };

    updateCountdown();
    const timer = setInterval(updateCountdown, 1000);

    return () => clearInterval(timer);
  }, [data, interval]);

  return (
    <div className="bg-gray-800/50 rounded-xl p-4 mb-6 text-center">
      <p className="text-sm text-gray-400 mb-1">Next Draw In</p>
      <p className="text-2xl font-mono font-bold text-purple-400">
        {timeLeft}
      </p>
    </div>
  );
}
