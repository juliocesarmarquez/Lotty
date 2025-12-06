'use client';

import { useEffect } from 'react';
import { useMiniKit } from '@coinbase/onchainkit/minikit';
import { LottyDashboard } from '~/components/LottyDashboard';

export default function HomePage() {
  const { setFrameReady, isFrameReady } = useMiniKit();

  useEffect(() => {
    if (!isFrameReady) {
      setFrameReady();
    }
  }, [isFrameReady, setFrameReady]);

  return (
    <main className="min-h-screen bg-gradient-to-b from-purple-900 to-black text-white">
      <LottyDashboard />
    </main>
  );
}
