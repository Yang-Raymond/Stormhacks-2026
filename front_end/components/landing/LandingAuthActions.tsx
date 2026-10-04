"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import UserMenu from "@/components/UserMenu";
import { PrimaryButton } from "./shared";
import { api, type MeResponse, type User } from "@/lib/api";

export default function LandingAuthActions() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();

  useEffect(() => {
    api<MeResponse>("/auth/me")
      .then((data) => {
        setUser(data.user);
        setLoading(false);
      })
      .catch(() => {
        setUser(null);
        setLoading(false);
      });
  }, []);

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

  async function logout() {
    await api("/auth/logout", { method: "POST" });
    setUser(null);
    router.refresh();
  }

  if (loading) {
    return <div className="h-9 w-44" aria-hidden="true" />;
  }

  if (user) {
    return (
      <div className="flex items-center gap-4">
        <Link
          href="/problems"
          className="text-sm font-medium text-zinc-300 transition-colors hover:text-white"
        >
          Problems
        </Link>
        <UserMenu user={user} onLogout={logout} />
      </div>
    );
  }

  return (
    <div className="flex items-center gap-5">
      <Link
        href="/login"
        className="text-sm font-medium text-zinc-300 transition-colors hover:text-white"
      >
        Log in
      </Link>
      <PrimaryButton href="/register" className="h-9 px-4 text-xs font-semibold">
        Start practicing
      </PrimaryButton>
    </div>
  );
}
