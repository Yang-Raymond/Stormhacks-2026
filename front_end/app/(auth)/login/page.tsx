import type { Metadata } from "next";
import { Suspense } from "react";
import AuthShell from "@/components/auth/AuthShell";
import LoginForm from "@/components/auth/LoginForm";
import SessionPreview from "@/components/auth/SessionPreview";
import GuestOnlyGuard from "@/components/auth/GuestOnlyGuard";

export const metadata: Metadata = {
  title: "Log in",
};

export default function LoginPage() {
  return (
    <GuestOnlyGuard>
      <AuthShell
        side="left"
        form={
          <Suspense fallback={<div className="h-96 w-full animate-pulse rounded-lg bg-surface/50" />}>
            <LoginForm />
          </Suspense>
        }
        marketing={<SessionPreview />}
      />
    </GuestOnlyGuard>
  );
}
