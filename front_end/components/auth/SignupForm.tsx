"use client";

import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { useState } from "react";
import { api, ApiError } from "@/lib/api";
import { getAuthErrorMessage } from "@/lib/authErrors";
import Divider from "./Divider";
import Field from "./Field";
import OAuthButtons from "./OAuthButtons";
import PasswordStrength from "./PasswordStrength";

export default function SignupForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const urlError = searchParams.get("error");

  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const [pending, setPending] = useState(false);
  const [formError, setFormError] = useState("");
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});

  const activeError = formError || getAuthErrorMessage(urlError);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();

    setPending(true);
    setFormError("");
    setFieldErrors({});

    try {
      await api("/auth/register", {
        body: {
          fullName: fullName.trim() || undefined,
          email,
          password,
        },
      });
      router.push("/onboarding");
    } catch (err) {
      if (err instanceof ApiError && err.issues) {
        const mapped: Record<string, string> = {};
        for (const [key, msgs] of Object.entries(err.issues)) {
          if (msgs.length > 0) mapped[key] = msgs[0];
        }
        setFieldErrors(mapped);
      } else {
        setFormError((err as Error).message || "Registration failed");
      }
    } finally {
      setPending(false);
    }
  }

  return (
    <div className="flex flex-col w-full">
      <div className="mb-6">
        <h1 className="text-2xl font-bold tracking-tight text-white">
          Create your account
        </h1>
        <p className="mt-1 text-xs text-zinc-400">
          Free to start. No credit card required.
        </p>
      </div>

      <OAuthButtons layout="inline" mode="register" />

      <Divider text="or with email" />

      {activeError && (
        <div
          role="alert"
          className="mb-4 rounded-lg bg-red-950/40 border border-red-800/60 p-3 text-xs text-red-300 leading-relaxed"
        >
          <p>{activeError}</p>
          {urlError === "email_exists" && (
            <div className="mt-2">
              <Link href="/login" className="font-semibold text-[#f2b544] underline hover:text-[#e5a83b]">
                Go to Log in &rarr;
              </Link>
            </div>
          )}
        </div>
      )}

      <form onSubmit={handleSubmit} className="flex flex-col gap-4">
        <Field
          label="Full name"
          name="fullName"
          type="text"
          autoComplete="name"
          placeholder="Your name"
          value={fullName}
          onChange={(e) => setFullName(e.target.value)}
          error={fieldErrors.fullName}
        />

        <Field
          label="Work email"
          name="email"
          type="email"
          autoComplete="email"
          placeholder="you@company.com"
          required
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          error={fieldErrors.email}
        />

        <div className="flex flex-col">
          <Field
            label="Password"
            name="password"
            type="password"
            autoComplete="new-password"
            placeholder="At least 8 characters"
            required
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            error={fieldErrors.password}
          />
          <PasswordStrength password={password} />
        </div>

        <button
          type="submit"
          disabled={pending}
          className="mt-2 flex h-11 w-full items-center justify-center rounded-lg bg-[#f2b544] text-sm font-semibold text-zinc-950 transition-colors hover:bg-[#e5a83b] focus:outline-none focus:ring-2 focus:ring-[#f2b544]/50 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
        >
          {pending ? (
            <span className="inline-flex items-center gap-2">
              <svg className="h-4 w-4 animate-spin text-zinc-950" viewBox="0 0 24 24" fill="none">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
              </svg>
              Creating account...
            </span>
          ) : (
            "Create account"
          )}
        </button>
      </form>

      <div className="mt-8 text-center text-xs text-zinc-400">
        Already have an account?{" "}
        <Link href="/login" className="font-semibold text-[#f2b544] hover:underline">
          Log in
        </Link>
      </div>
    </div>
  );
}
