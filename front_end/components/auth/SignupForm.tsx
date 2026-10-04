"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { api, ApiError } from "@/lib/api";
import Divider from "./Divider";
import Field from "./Field";
import OAuthButtons from "./OAuthButtons";
import PasswordStrength from "./PasswordStrength";

const LANGUAGES = [
  "Python",
  "C",
  "C++",
  "C#",
  "JavaScript",
  "TypeScript",
  "Java",
  "Go",
  "Rust",
  "Other",
];

export default function SignupForm() {
  const router = useRouter();

  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [language, setLanguage] = useState("Python");
  const [acceptTerms, setAcceptTerms] = useState(false);

  const [pending, setPending] = useState(false);
  const [formError, setFormError] = useState("");
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();

    if (!acceptTerms) {
      setFieldErrors((prev) => ({
        ...prev,
        acceptTerms: "You must agree to the Terms of Service and Privacy Policy.",
      }));
      return;
    }

    setPending(true);
    setFormError("");
    setFieldErrors({});

    try {
      await api("/auth/register", {
        body: {
          fullName: fullName.trim() || undefined,
          email,
          password,
          language,
          acceptTerms: true,
        },
      });
      router.push("/problems");
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

      <OAuthButtons
        layout="inline"
        mode="register"
        termsAccepted={acceptTerms}
        language={language}
      />

      <Divider text="or with email" />

      {formError && (
        <div
          role="alert"
          className="mb-4 rounded-lg bg-red-950/40 border border-red-800/60 p-3 text-xs text-red-300 leading-relaxed"
        >
          {formError}
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
            placeholder="At least 12 characters"
            required
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            error={fieldErrors.password}
          />
          <PasswordStrength password={password} />
        </div>

        <div className="flex flex-col gap-1.5 w-full">
          <label htmlFor="language" className="text-xs font-medium text-zinc-300">
            Main language you debug
          </label>
          <div className="relative">
            <select
              id="language"
              name="language"
              value={language}
              onChange={(e) => setLanguage(e.target.value)}
              className="h-11 w-full appearance-none rounded-lg border border-[#232730] bg-[#16181d] px-3.5 pr-10 text-sm text-zinc-100 focus:border-[#f2b544] focus:outline-none focus:ring-2 focus:ring-[#f2b544]/20 transition-colors cursor-pointer"
            >
              {LANGUAGES.map((lang) => (
                <option key={lang} value={lang} className="bg-[#16181d] text-zinc-100">
                  {lang}
                </option>
              ))}
            </select>
            <div className="pointer-events-none absolute inset-y-0 right-0 flex items-center px-3.5 text-zinc-400">
              <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
              </svg>
            </div>
          </div>
          {fieldErrors.language && (
            <span className="text-xs text-red-400 mt-0.5">{fieldErrors.language}</span>
          )}
        </div>

        <div className="flex flex-col gap-1 mt-1">
          <div className="flex items-start gap-2.5">
            <input
              id="acceptTerms"
              name="acceptTerms"
              type="checkbox"
              checked={acceptTerms}
              onChange={(e) => {
                setAcceptTerms(e.target.checked);
                if (e.target.checked) {
                  setFieldErrors((prev) => {
                    const next = { ...prev };
                    delete next.acceptTerms;
                    return next;
                  });
                }
              }}
              className="mt-0.5 w-4 h-4 rounded border-[#2a2d34] bg-[#16181d] text-[#f2b544] focus:ring-1 focus:ring-[#f2b544] focus:ring-offset-0 focus:outline-none accent-[#f2b544] cursor-pointer"
            />
            <label htmlFor="acceptTerms" className="text-xs text-zinc-300 leading-normal cursor-pointer select-none">
              I agree to the{" "}
              <Link href="/terms" target="_blank" className="text-[#f2b544] hover:underline">
                Terms of Service
              </Link>{" "}
              and{" "}
              <Link href="/privacy" target="_blank" className="text-[#f2b544] hover:underline">
                Privacy Policy
              </Link>
            </label>
          </div>
          {fieldErrors.acceptTerms && (
            <span className="text-xs text-red-400 pl-6.5">{fieldErrors.acceptTerms}</span>
          )}
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
