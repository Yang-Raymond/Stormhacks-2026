"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { api, type MeResponse } from "@/lib/api";

export default function OnboardingGuard({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const [checked, setChecked] = useState(false);

  useEffect(() => {
    api<MeResponse>("/auth/me")
      .then((data) => {
        if (data.user && !data.user.onboarded) {
          router.replace("/onboarding");
          return;
        }
        setChecked(true);
      })
      .catch(() => {
        setChecked(true);
      });
  }, [router]);

  if (!checked) {
    return null;
  }

  return <>{children}</>;
}
