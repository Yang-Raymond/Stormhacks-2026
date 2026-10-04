"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { api, ApiError, type AuthMethod, type MeResponse, type User } from "@/lib/api";
import Logo from "@/components/auth/Logo";

const ROLES = [
  "Software engineer",
  "Student",
  "Data scientist",
  "QA / test engineer",
  "Engineering manager",
  "Other",
] as const;

const AVAILABLE_LANGS = [
  "Python",
  "TypeScript",
  "JavaScript",
  "Go",
  "Other",
] as const;

function getInitials(name?: string | null, email?: string): string {
  if (name && name.trim()) {
    const parts = name.trim().split(/\s+/);
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0].slice(0, 2).toUpperCase();
  }
  if (email) {
    return email.slice(0, 2).toUpperCase();
  }
  return "LB";
}

export default function OnboardingPage() {
  const router = useRouter();

  const [loading, setLoading] = useState(true);
  const [user, setUser] = useState<User | null>(null);
  const [authMethod, setAuthMethod] = useState<AuthMethod>("email");

  const [fullName, setFullName] = useState("");
  const [role, setRole] = useState<string>("Software engineer");
  const [selectedLangs, setSelectedLangs] = useState<string[]>(["Python"]);
  const [acceptTerms, setAcceptTerms] = useState(false);

  const [pending, setPending] = useState(false);
  const [formError, setFormError] = useState("");
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    api<MeResponse>("/auth/me")
      .then((data) => {
        if (!data.user) {
          router.replace("/login");
          return;
        }
        if (data.user.onboarded) {
          router.replace("/problems");
          return;
        }
        setUser(data.user);
        setAuthMethod(data.authMethod || "email");
        setFullName(data.user.fullName || "");
        if (data.user.role) setRole(data.user.role);
        if (data.user.debugLanguages && data.user.debugLanguages.length > 0) {
          setSelectedLangs(data.user.debugLanguages);
        }
        setLoading(false);
      })
      .catch(() => {
        router.replace("/login");
      });
  }, [router]);

  async function handleSwitchAccount() {
    await api("/auth/logout", { method: "POST" }).catch(() => {});
    router.push("/login");
  }

  function toggleLanguage(lang: string) {
    setSelectedLangs((prev) => {
      const exists = prev.includes(lang);
      if (exists) {
        return prev.filter((l) => l !== lang);
      } else {
        return [...prev, lang];
      }
    });
    setFieldErrors((prev) => {
      const next = { ...prev };
      delete next.languages;
      return next;
    });
  }

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();

    if (!acceptTerms) {
      setFieldErrors((prev) => ({
        ...prev,
        acceptTerms: "You must agree to the Terms of Service and Privacy Policy.",
      }));
      return;
    }

    if (selectedLangs.length === 0) {
      setFieldErrors((prev) => ({
        ...prev,
        languages: "Please select at least one language.",
      }));
      return;
    }

    setPending(true);
    setFormError("");
    setFieldErrors({});

    try {
      await api("/auth/onboarding", {
        body: {
          fullName: fullName.trim(),
          role,
          languages: selectedLangs,
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
        setFormError((err as Error).message || "Failed to save profile");
      }
    } finally {
      setPending(false);
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-[#0d0e12] flex items-center justify-center">
        <div className="flex items-center gap-3 text-sm text-zinc-400">
          <svg className="h-5 w-5 animate-spin text-[#f2b544]" viewBox="0 0 24 24" fill="none">
            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
          </svg>
          <span>Loading...</span>
        </div>
      </div>
    );
  }

  const firstName = fullName.trim().split(/\s+/)[0] || user?.fullName?.trim().split(/\s+/)[0] || "";
  const providerLabel =
    authMethod === "github" ? "GitHub" : authMethod === "google" ? "Google" : "email";

  return (
    <div className="min-h-screen bg-[#0d0e12] text-zinc-100 flex flex-col">
      {/* Top Header */}
      <header className="border-b border-[#1f2229] px-6 py-4 flex items-center justify-between">
        <Logo />

        {/* Stepper */}
        <div className="hidden sm:flex items-center gap-3 text-xs">
          {/* Step 1 */}
          <div className="flex items-center gap-1.5 text-emerald-400 font-medium">
            <span className="w-4 h-4 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center text-[10px]">
              ✓
            </span>
            <span>Account connected</span>
          </div>

          <div className="w-8 h-[1px] bg-zinc-800" />

          {/* Step 2 */}
          <div className="flex items-center gap-1.5 text-[#f2b544] font-medium">
            <span className="w-4 h-4 rounded-full bg-[#f2b544] text-zinc-950 flex items-center justify-center text-[10px] font-bold">
              2
            </span>
            <span>Set up profile</span>
          </div>

          <div className="w-8 h-[1px] bg-zinc-800" />

          {/* Step 3 */}
          <div className="flex items-center gap-1.5 text-zinc-500">
            <span className="w-4 h-4 rounded-full border border-zinc-700 flex items-center justify-center text-[10px]">
              3
            </span>
            <span>First session</span>
          </div>
        </div>

        <div className="w-20" />
      </header>

      {/* Main Content */}
      <main className="flex-1 flex justify-center px-4 py-10 sm:py-14">
        <div className="w-full max-w-[620px]">
          <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-white">
            Welcome to LadyBug{firstName ? `, ${firstName}` : ""}
          </h1>
          <p className="mt-2 text-sm text-zinc-400 leading-relaxed">
            {authMethod === "github" || authMethod === "google"
              ? `We pulled your details from ${providerLabel}. Check them, tell us a bit about your work, and we'll set up your first debug session.`
              : "Tell us a bit about your work, and we'll set up your first debug session."}
          </p>

          {/* Account card */}
          <div className="mt-6 rounded-xl border border-[#232730] bg-[#16181d] px-4 py-3.5 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-zinc-800 border border-zinc-700 flex items-center justify-center text-xs font-bold text-zinc-200 overflow-hidden shrink-0">
                {user?.avatarUrl ? (
                  <img
                    src={user.avatarUrl}
                    alt={user.fullName || "User"}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <span>{getInitials(user?.fullName, user?.email)}</span>
                )}
              </div>
              <div className="flex flex-col justify-center">
                <span className="text-sm font-medium text-white">
                  Signed in with {providerLabel}
                </span>
              </div>
            </div>
            <button
              type="button"
              onClick={handleSwitchAccount}
              className="text-xs text-[#f2b544] hover:underline font-medium cursor-pointer"
            >
              Not you? Switch account
            </button>
          </div>

          {formError && (
            <div
              role="alert"
              className="mt-6 rounded-lg bg-red-950/40 border border-red-800/60 p-3 text-xs text-red-300 leading-relaxed"
            >
              {formError}
            </div>
          )}

          <form onSubmit={handleSubmit} className="mt-8 flex flex-col">
            <h2 className="text-base font-semibold text-white">Your profile</h2>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mt-3">
              {/* Display name */}
              <div className="flex flex-col gap-1.5 w-full">
                <label htmlFor="fullName" className="text-xs font-medium text-zinc-300">
                  Display name
                </label>
                <input
                  id="fullName"
                  name="fullName"
                  type="text"
                  required
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  placeholder="Your name"
                  className="h-11 w-full rounded-lg border border-[#232730] bg-[#16181d] px-3.5 text-sm text-zinc-100 placeholder-zinc-500 focus:border-[#f2b544] focus:outline-none focus:ring-2 focus:ring-[#f2b544]/20 transition-colors"
                />
                {fieldErrors.fullName && (
                  <span className="text-xs text-red-400 mt-0.5">{fieldErrors.fullName}</span>
                )}
              </div>

              {/* What best describes you */}
              <div className="flex flex-col gap-1.5 w-full">
                <label htmlFor="role" className="text-xs font-medium text-zinc-300">
                  What best describes you?
                </label>
                <div className="relative">
                  <select
                    id="role"
                    name="role"
                    value={role}
                    onChange={(e) => setRole(e.target.value)}
                    className="h-11 w-full appearance-none rounded-lg border border-[#232730] bg-[#16181d] px-3.5 pr-10 text-sm text-zinc-100 focus:border-[#f2b544] focus:outline-none focus:ring-2 focus:ring-[#f2b544]/20 transition-colors cursor-pointer"
                  >
                    {ROLES.map((r) => (
                      <option key={r} value={r} className="bg-[#16181d] text-zinc-100">
                        {r}
                      </option>
                    ))}
                  </select>
                  <div className="pointer-events-none absolute inset-y-0 right-0 flex items-center px-3.5 text-zinc-400">
                    <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                    </svg>
                  </div>
                </div>
                {fieldErrors.role && (
                  <span className="text-xs text-red-400 mt-0.5">{fieldErrors.role}</span>
                )}
              </div>
            </div>

            {/* Languages you debug most */}
            <div className="mt-8">
              <h2 className="text-base font-semibold text-white">Languages you debug most</h2>
              <p className="text-xs text-zinc-400 mt-1">
                Pick any. We&apos;ll set up runtimes and test frameworks for these.
              </p>

              <div className="flex flex-wrap gap-2.5 mt-3">
                {AVAILABLE_LANGS.map((lang) => {
                  const isChecked = selectedLangs.includes(lang);
                  return (
                    <button
                      key={lang}
                      type="button"
                      onClick={() => toggleLanguage(lang)}
                      className={`inline-flex items-center gap-2 px-4 py-2 rounded-full text-xs font-medium border transition-colors cursor-pointer select-none ${
                        isChecked
                          ? "border-[#f2b544] bg-[#f2b544]/10 text-white"
                          : "border-[#232730] bg-[#16181d] text-zinc-300 hover:border-zinc-700"
                      }`}
                    >
                      <span
                        className={`w-3.5 h-3.5 rounded flex items-center justify-center text-[10px] ${
                          isChecked
                            ? "bg-[#f2b544] text-zinc-950 font-bold"
                            : "border border-zinc-600 bg-transparent"
                        }`}
                      >
                        {isChecked ? "✓" : ""}
                      </span>
                      <span>{lang}</span>
                    </button>
                  );
                })}
              </div>
              {fieldErrors.languages && (
                <span className="text-xs text-red-400 mt-1.5 block">{fieldErrors.languages}</span>
              )}
            </div>

            <div className="border-t border-[#1f2229] my-8" />

            {/* Footer row: Terms and Submit button */}
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
              <div className="flex flex-col gap-1">
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
                className="self-end sm:self-auto flex items-center justify-center px-6 h-11 rounded-lg bg-[#f2b544] text-sm font-semibold text-zinc-950 transition-colors hover:bg-[#e5a83b] focus:outline-none focus:ring-2 focus:ring-[#f2b544]/50 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
              >
                {pending ? (
                  <span className="inline-flex items-center gap-2">
                    <svg className="h-4 w-4 animate-spin text-zinc-950" viewBox="0 0 24 24" fill="none">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                    </svg>
                    Setting up...
                  </span>
                ) : (
                  "Start Debugging"
                )}
              </button>
            </div>
          </form>
        </div>
      </main>
    </div>
  );
}
