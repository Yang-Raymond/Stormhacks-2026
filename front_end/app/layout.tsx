import type { Metadata } from "next";
import Nav from "@/components/Nav";
import "./globals.css";

export const metadata: Metadata = {
  title: "Debug-Code",
  description: "Fix AI-generated buggy code",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="en" className="h-full">
      <body className="min-h-full bg-zinc-900 text-zinc-100">
        <Nav />
        <main className="p-6">{children}</main>
      </body>
    </html>
  );
}
