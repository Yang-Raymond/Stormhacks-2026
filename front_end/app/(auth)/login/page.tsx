import { Suspense } from "react";
import AuthShell from "@/components/auth/AuthShell";
import LoginForm from "@/components/auth/LoginForm";
import SessionPreview from "@/components/auth/SessionPreview";

export default function LoginPage() {
  return (
    <AuthShell
      side="left"
      form={
        <Suspense fallback={<div className="h-96 w-full animate-pulse rounded-lg bg-[#16181d]/50" />}>
          <LoginForm />
        </Suspense>
      }
      marketing={<SessionPreview />}
    />
  );
}
