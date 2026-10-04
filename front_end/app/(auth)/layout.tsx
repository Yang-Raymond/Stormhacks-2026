import { IBM_Plex_Sans, IBM_Plex_Mono } from "next/font/google";

const ibmPlexSans = IBM_Plex_Sans({
  subsets: ["latin"],
  weight: "400",
  variable: "--font-ibm-plex-sans",
  display: "swap",
});

const ibmPlexMono = IBM_Plex_Mono({
  subsets: ["latin"],
  weight: "400",
  variable: "--font-ibm-plex-mono",
  display: "swap",
});

export default function AuthLayout({ children }: { children: React.ReactNode }) {
  return (
    <div
      className={`${ibmPlexSans.variable} ${ibmPlexMono.variable} min-h-screen bg-[#0d0e12] text-zinc-100 selection:bg-[#f2b544]/25 selection:text-[#f2b544]`}
      style={{ fontFamily: "var(--font-ibm-plex-sans), -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif" }}
    >
      {children}
    </div>
  );
}
