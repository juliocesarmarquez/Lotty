"use client";

import { type ReactNode } from "react";
import { MiniKitProvider } from "@coinbase/onchainkit/minikit";
import { OnchainKitProvider } from "@coinbase/onchainkit";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { base, baseSepolia } from "viem/chains";

const queryClient = new QueryClient();

const chain = process.env.NEXT_PUBLIC_NETWORK === "mainnet" ? base : baseSepolia;

export function Providers({ children }: { children: ReactNode }) {
  return (
    <QueryClientProvider client={queryClient}>
      <MiniKitProvider enabled={true} autoConnect={true}>
        <OnchainKitProvider
          chain={chain}
          apiKey={process.env.NEXT_PUBLIC_CDP_API_KEY}
          config={{
            appearance: {
              name: "Lotty",
              logo: "/lottyGuy.png",
              mode: "dark",
              theme: "default",
            },
          }}
        >
          {children}
        </OnchainKitProvider>
      </MiniKitProvider>
    </QueryClientProvider>
  );
}

