import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import { themeScript } from "@/lib/theme";
import Nav from "@/components/Nav";
import "./globals.css";

const geistSans = Geist({ subsets: ["latin"], variable: "--font-geist-sans" });
const geistMono = Geist_Mono({ subsets: ["latin"], variable: "--font-geist-mono" });

export const metadata: Metadata = {
  title: {
    default: "LadyBug",
    template: "%s · LadyBug",
  },
  description: "Debug AI-generated code with confidence",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning className={`h-full ${geistSans.variable} ${geistMono.variable}`}>
      <head>
        <script dangerouslySetInnerHTML={{ __html: themeScript }} />
      </head>
      <body className="flex min-h-full flex-col bg-canvas font-sans text-zinc-100 antialiased selection:bg-accent/25 selection:text-accent-ink">
        <Nav />
        <main className="flex flex-1 flex-col">{children}</main>
      </body>
    </html>
  );
}
