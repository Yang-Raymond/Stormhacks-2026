import Link from "next/link";

export default function PrivacyPage() {
  return (
    <div className="mx-auto mt-16 max-w-2xl px-6 py-8">
      <Link href="/register" className="inline-flex items-center text-sm font-medium text-accent-ink hover:underline mb-6">
        &larr; Back to sign up
      </Link>
      <h1 className="text-3xl font-bold text-zinc-100">Privacy Policy</h1>
      <p className="mt-2 text-sm text-zinc-400">Last updated: October 2026</p>
      <div className="mt-6 space-y-4 text-sm text-zinc-300 leading-relaxed">
        <p>
          At LadyBug, we take your privacy seriously. This policy explains what information we collect and how we use it.
        </p>
        <h2 className="text-lg font-semibold text-zinc-100 mt-6">1. Information We Collect</h2>
        <p>
          We collect your email address, name, preferred debugging language, and session submission history to personalize your learning experience.
        </p>
        <h2 className="text-lg font-semibold text-zinc-100 mt-6">2. Third-Party Authentication</h2>
        <p>
          When you log in via GitHub or Google OAuth, we receive your verified email address and basic profile identifier. We do not access your private repositories or Google Drive files.
        </p>
      </div>
    </div>
  );
}
