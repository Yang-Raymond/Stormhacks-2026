"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { api, type User } from "@/lib/api";

export default function Nav() {
  const [user, setUser] = useState<User | null>(null);
  const pathname = usePathname();
  const router = useRouter();

  useEffect(() => {
    api<{ user: User | null }>("/auth/me")
      .then((d) => setUser(d.user))
      .catch(() => setUser(null));
  }, [pathname]);

  if (
    pathname === "/login" ||
    pathname === "/register" ||
    pathname === "/signup" ||
    pathname === "/onboarding" ||
    pathname === "/auth/callback"
  ) {
    return null;
  }

  async function logout() {
    await api("/auth/logout", { method: "POST" });
    setUser(null);
    router.push("/login");
  }

  return (
    <nav className="flex items-center gap-4 border-b border-zinc-700 px-6 py-3">
      <Link href="/" className="font-bold flex items-center gap-2">
        <span className="inline-flex items-center justify-center w-6 h-6 rounded bg-[#f2b544] text-zinc-950 font-mono text-xs font-bold">
          &gt;_
        </span>
        LadyBug
      </Link>
      <Link href="/problems">Problems</Link>
      <div className="ml-auto flex items-center gap-4">
        {user ? (
          <>
            <span className="text-zinc-400">{user.fullName || user.email}</span>
            <button onClick={logout} className="underline hover:text-zinc-200">Logout</button>
          </>
        ) : (
          <>
            <Link href="/login" className="hover:text-zinc-300">Login</Link>
            <Link href="/register" className="hover:text-zinc-300">Register</Link>
          </>
        )}
      </div>
    </nav>
  );
}
