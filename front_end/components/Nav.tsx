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

  async function logout() {
    await api("/auth/logout", { method: "POST" });
    setUser(null);
    router.push("/login");
  }

  return (
    <nav className="flex items-center gap-4 border-b border-zinc-700 px-6 py-3">
      <Link href="/" className="font-bold">Debug-Code</Link>
      <Link href="/problems">Problems</Link>
      <div className="ml-auto flex items-center gap-4">
        {user ? (
          <>
            <span className="text-zinc-400">{user.email}</span>
            <button onClick={logout} className="underline">Logout</button>
          </>
        ) : (
          <>
            <Link href="/login">Login</Link>
            <Link href="/register">Register</Link>
          </>
        )}
      </div>
    </nav>
  );
}
