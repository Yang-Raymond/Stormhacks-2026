"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { LogOutIcon } from "@/components/ui/icons";
import { api, type User } from "@/lib/api";

const links = [{ href: "/problems", label: "Problems" }];

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
    pathname === "/" ||
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

  const name = user?.fullName || user?.email || "";

  return (
    <nav className="sticky top-0 z-30 flex h-14 shrink-0 items-center gap-6 border-b border-line bg-canvas/90 px-4 backdrop-blur sm:px-6">
      <Link href="/" className="flex items-center gap-2 font-bold tracking-tight">
        <span className="inline-flex h-6 w-6 items-center justify-center rounded bg-accent font-mono text-xs font-bold text-zinc-950">
          &gt;_
        </span>
        LadyBug
      </Link>

      <div className="flex h-full items-center gap-1">
        {links.map(({ href, label }) => {
          const active = pathname.startsWith(href);
          return (
            <Link
              key={href}
              href={href}
              aria-current={active ? "page" : undefined}
              className={`relative flex h-full items-center px-3 text-sm transition-colors ${
                active ? "text-white" : "text-zinc-400 hover:text-zinc-200"
              }`}
            >
              {label}
              {active && <span className="absolute inset-x-3 -bottom-px h-0.5 rounded-full bg-accent" />}
            </Link>
          );
        })}
      </div>

      <div className="ml-auto flex items-center gap-3">
        {user ? (
          <>
            <span className="hidden items-center gap-2 sm:flex">
              <span className="flex h-7 w-7 items-center justify-center rounded-full border border-line-strong bg-surface-2 text-xs font-semibold uppercase text-zinc-300">
                {name.charAt(0)}
              </span>
              <span className="max-w-48 truncate text-sm text-zinc-400">{name}</span>
            </span>
            <button
              onClick={logout}
              className="flex items-center gap-1.5 rounded-md px-2.5 py-1.5 text-sm text-zinc-400 transition-colors hover:bg-surface-2 hover:text-zinc-100"
            >
              <LogOutIcon className="size-3.5" />
              Log out
            </button>
          </>
        ) : (
          <>
            <Link href="/login" className="text-sm text-zinc-400 hover:text-zinc-100">Log in</Link>
            <Link
              href="/register"
              className="rounded-md bg-accent px-3 py-1.5 text-sm font-medium text-zinc-950 transition-colors hover:bg-accent-hover"
            >
              Sign up
            </Link>
          </>
        )}
      </div>
    </nav>
  );
}
