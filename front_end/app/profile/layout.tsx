import type { Metadata } from "next";
import OnboardingGuard from "@/components/OnboardingGuard";

export const metadata: Metadata = {
  title: "Profile",
  description: "View and manage your LadyBug profile and statistics",
};

export default function ProfileLayout({ children }: { children: React.ReactNode }) {
  return (
    <OnboardingGuard>
      <div className="flex flex-1 flex-col">{children}</div>
    </OnboardingGuard>
  );
}
