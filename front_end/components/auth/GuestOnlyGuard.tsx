"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { api, type MeResponse } from "@/lib/api";

export default function GuestOnlyGuard({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const [checked, setChecked] = useState(false);

  useEffect(() => {
    let active = true;

    api<MeResponse>("/auth/me")
      .then(({ user }) => {
        if (!active) return;
        if (user) {
          router.replace(user.onboarded ? "/problems" : "/onboarding");
          return;
        }
        setChecked(true);
      })
      .catch(() => {
        if (active) setChecked(true);
      });

    return () => {
      active = false;
    };
  }, [router]);

  if (!checked) {
    return (
      <div role="status" className="flex min-h-screen items-center justify-center text-zinc-400">
        Loading…
      </div>
    );
  }

  return <>{children}</>;
}
