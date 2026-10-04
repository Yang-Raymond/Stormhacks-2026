import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Reset password",
};

export default function ForgotPasswordPage() {
  return (
    <div className="mx-auto mt-20 max-w-md p-6 text-center">
      <div className="inline-flex items-center justify-center w-12 h-12 rounded-xl bg-accent/10 text-accent-ink mb-4">
        <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
        </svg>
      </div>
      <h1 className="text-2xl font-bold text-zinc-100">Reset your password</h1>
      <p className="mt-3 text-sm text-zinc-400">
        Password reset emails are coming soon. For assistance during the hackathon preview, please reach out to the LadyBug team.
      </p>
      <div className="mt-6">
        <Link href="/login" className="inline-flex items-center text-sm font-medium text-accent-ink hover:underline">
          &larr; Back to log in
        </Link>
      </div>
    </div>
  );
}
