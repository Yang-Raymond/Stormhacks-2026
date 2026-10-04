"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import ThemeMenu from "@/components/ThemeMenu";
import UserMenu from "@/components/UserMenu";
import { api, type User } from "@/lib/api";

const links = [
  { href: "/problems", label: "Problems" },
  { href: "/insights", label: "Insights" },
];

export default function Nav() {
  const [user, setUser] = useState<User | null>(null);
  const pathname = usePathname();
  const router = useRouter();

  useEffect(() => {
    api<{ user: User | null }>("/auth/me")
      .then((d) => setUser(d.user))
      .catch(() => setUser(null));
  }, [pathname]);

  useEffect(() => {
    function handleUserUpdated(e: Event) {
      const customEvent = e as CustomEvent<{ user: User }>;
      if (customEvent.detail?.user) {
        setUser(customEvent.detail.user);
      }
    }
    window.addEventListener("ladybug:user-updated", handleUserUpdated);
    return () => window.removeEventListener("ladybug:user-updated", handleUserUpdated);
  }, []);

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
    <nav className="sticky top-0 z-30 flex h-14 shrink-0 items-center gap-2 sm:gap-6 border-b border-line bg-canvas/90 px-4 backdrop-blur sm:px-6">
      <Link href="/" className="flex items-center gap-2 font-bold tracking-tight">
        <span className="inline-flex h-6 w-6 items-center justify-center rounded bg-accent font-mono text-xs font-bold text-zinc-950">
          &gt;_
        </span>
        LadyBug
      </Link>

      {user && (
        <div className="flex h-full items-center gap-1">
          {links.map(({ href, label }) => {
            const active = pathname.startsWith(href);
            return (
              <Link
                key={href}
                href={href}
                aria-current={active ? "page" : undefined}
                className={`relative flex h-full items-center px-2 sm:px-3 text-sm transition-colors ${
                  active ? "text-foreground" : "text-zinc-400 hover:text-zinc-200"
                }`}
              >
                {label}
                {active && <span className="absolute inset-x-3 -bottom-px h-0.5 rounded-full bg-accent" />}
              </Link>
            );
          })}
        </div>
      )}

      <div className="ml-auto flex items-center gap-3">
        <ThemeMenu />
        {user ? (
          <UserMenu user={user} onLogout={logout} />
        ) : (
          <>
            <Link href="/login" className="text-sm text-zinc-400 hover:text-zinc-100">Log in</Link>
            <Link
              href="/register"
              className="rounded-md bg-accent px-3 py-1.5 text-sm font-medium text-zinc-950 transition-colors hover:bg-accent-hover"
            >
              Debug now
            </Link>
          </>
        )}
      </div>
    </nav>
  );
}
