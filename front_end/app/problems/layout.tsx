import type { Metadata } from "next";
import OnboardingGuard from "@/components/OnboardingGuard";

export const metadata: Metadata = {
  title: "Problems",
};

// Pages set their own padding: the list is a centered column, the workspace is full-bleed.
export default function ProblemsLayout({ children }: { children: React.ReactNode }) {
  return (
    <OnboardingGuard>
      <div className="flex flex-1 flex-col">{children}</div>
    </OnboardingGuard>
  );
}
