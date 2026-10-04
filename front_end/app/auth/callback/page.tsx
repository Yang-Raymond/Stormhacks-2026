"use client";

import { Suspense, useEffect } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { api, type MeResponse } from "@/lib/api";
import Logo from "@/components/auth/Logo";

function CallbackHandler() {
  const router = useRouter();
  const searchParams = useSearchParams();

  useEffect(() => {
    const error = searchParams.get("error");
    const from = searchParams.get("from") === "register" ? "register" : "login";

    if (error) {
      router.replace(`/${from}?error=${encodeURIComponent(error)}`);
      return;
    }

    api<MeResponse>("/auth/me")
      .then((data) => {
        if (!data.user) {
          router.replace(`/${from}?error=oauth_failed`);
          return;
        }
        router.replace(data.user.onboarded ? "/problems" : "/onboarding");
      })
      .catch(() => {
        router.replace(`/${from}?error=oauth_failed`);
      });
  }, [router, searchParams]);

  return (
    <div className="flex flex-col items-center gap-4">
      <Logo />
      <div className="flex items-center gap-3 mt-4 text-sm text-zinc-400">
        <svg
          className="h-5 w-5 animate-spin text-[#f2b544]"
          viewBox="0 0 24 24"
          fill="none"
        >
          <circle
            className="opacity-25"
            cx="12"
            cy="12"
            r="10"
            stroke="currentColor"
            strokeWidth="4"
          />
          <path
            className="opacity-75"
            fill="currentColor"
            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
          />
        </svg>
        <span>Signing you in...</span>
      </div>
    </div>
  );
}

export default function CallbackPage() {
  return (
    <div className="min-h-screen w-full flex items-center justify-center bg-[#0d0e12] text-zinc-100 p-6">
      <Suspense
        fallback={
          <div className="flex flex-col items-center gap-4">
            <Logo />
            <div className="flex items-center gap-3 mt-4 text-sm text-zinc-400">
              <span>Loading...</span>
            </div>
          </div>
        }
      >
        <CallbackHandler />
      </Suspense>
    </div>
  );
}
