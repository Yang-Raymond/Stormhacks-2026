import OnboardingGuard from "@/components/OnboardingGuard";

export default function ProblemsLayout({ children }: { children: React.ReactNode }) {
  return (
    <OnboardingGuard>
      <div className="p-6 flex-1 flex flex-col">{children}</div>
    </OnboardingGuard>
  );
}
