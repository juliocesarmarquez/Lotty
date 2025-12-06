import "~/styles/globals.css";
import { type Metadata } from "next";
import { Bungee, Bungee_Inline } from "next/font/google";
import { Providers } from "./providers";

export const metadata: Metadata = {
  title: "Lotty - No-Loss Lottery",
  description: "Win prizes without risking your principal",
  icons: [{ rel: "icon", url: "/lottyGuy.png" }],
};

const bungee = Bungee({
  subsets: ["latin"],
  weight: ["400"],
  variable: "--font-bungee",
});

const bungeeInline = Bungee_Inline({
  subsets: ["latin"],
  weight: ["400"],
  variable: "--font-bungee-inline",
});

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" className={`${bungee.variable} ${bungeeInline.variable}`}>
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
