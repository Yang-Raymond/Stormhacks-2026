import { Suspense } from "react";
import AuthShell from "@/components/auth/AuthShell";
import FeatureList from "@/components/auth/FeatureList";
import SignupForm from "@/components/auth/SignupForm";
import GuestOnlyGuard from "@/components/auth/GuestOnlyGuard";

export default function RegisterPage() {
  return (
    <GuestOnlyGuard>
      <AuthShell
        side="right"
        form={
          <Suspense fallback={<div className="h-96 w-full animate-pulse rounded-lg bg-[#16181d]/50" />}>
            <SignupForm />
          </Suspense>
        }
        marketing={<FeatureList />}
      />
    </GuestOnlyGuard>
  );
}
