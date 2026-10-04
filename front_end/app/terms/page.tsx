import Link from "next/link";

export default function TermsPage() {
  return (
    <div className="mx-auto mt-16 max-w-2xl px-6 py-8">
      <Link href="/register" className="inline-flex items-center text-sm font-medium text-accent-ink hover:underline mb-6">
        &larr; Back to sign up
      </Link>
      <h1 className="text-3xl font-bold text-zinc-100">Terms of Service</h1>
      <p className="mt-2 text-sm text-zinc-400">Last updated: October 2026</p>
      <div className="mt-6 space-y-4 text-sm text-zinc-300 leading-relaxed">
        <p>
          Welcome to LadyBug. By accessing or using our interactive code debugging platform, you agree to be bound by these Terms of Service.
        </p>
        <h2 className="text-lg font-semibold text-zinc-100 mt-6">1. Use of Service</h2>
        <p>
          LadyBug provides coding challenges and sandboxed code execution for learning and educational purposes. You agree not to attempt to circumvent sandbox restrictions or abuse platform resources.
        </p>
        <h2 className="text-lg font-semibold text-zinc-100 mt-6">2. Account Responsibility</h2>
        <p>
          You are responsible for safeguarding your login credentials and for any activity that occurs under your account.
        </p>
      </div>
    </div>
  );
}
