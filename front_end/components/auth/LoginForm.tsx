"use client";

import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { useState } from "react";
import { api, ApiError, type User } from "@/lib/api";
import { getAuthErrorMessage } from "@/lib/authErrors";
import Divider from "./Divider";
import Field from "./Field";
import OAuthButtons from "./OAuthButtons";

export default function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const urlError = searchParams.get("error");

  const [remember, setRemember] = useState(false);
  const [pending, setPending] = useState(false);
  const [formError, setFormError] = useState("");
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});

  const activeError = formError || getAuthErrorMessage(urlError);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const form = new FormData(e.currentTarget);
    const email = form.get("email") as string;
    const password = form.get("password") as string;

    setPending(true);
    setFormError("");
    setFieldErrors({});

    try {
      const { user } = await api<{ user: User }>("/auth/login", {
        body: {
          email,
          password,
          remember,
        },
      });
      router.push(user.onboarded ? "/problems" : "/onboarding");
    } catch (err) {
      if (err instanceof ApiError && err.issues) {
        const mapped: Record<string, string> = {};
        for (const [key, msgs] of Object.entries(err.issues)) {
          if (msgs.length > 0) mapped[key] = msgs[0];
        }
        setFieldErrors(mapped);
      } else {
        setFormError((err as Error).message || "Invalid email or password");
      }
    } finally {
      setPending(false);
    }
  }

  return (
    <div className="flex flex-col w-full">
      <div className="mb-6">
        <h1 className="text-2xl font-bold tracking-tight text-foreground">
          Welcome back
        </h1>
        <p className="mt-1 text-xs text-zinc-400">
          Log in to pick up where you left off.
        </p>
      </div>

      <OAuthButtons
        layout="stacked"
        mode="login"
        remember={remember}
      />

      <Divider text="or with email" />

      {activeError && (
        <div
          role="alert"
          className="mb-4 rounded-lg bg-red-950/40 border border-red-800/60 p-3 text-xs text-red-300 leading-relaxed"
        >
          {activeError}
        </div>
      )}

      <form onSubmit={handleSubmit} className="flex flex-col gap-4">
        <Field
          label="Email"
          name="email"
          type="email"
          autoComplete="email"
          placeholder="you@company.com"
          required
          error={fieldErrors.email}
        />

        <Field
          label="Password"
          name="password"
          type="password"
          autoComplete="current-password"
          placeholder="••••••••"
          required
          error={fieldErrors.password}
          rightLink={
            <Link
              href="/forgot-password"
              className="text-xs text-accent-ink hover:underline"
            >
              Forgot password?
            </Link>
          }
        />

        <div className="flex items-center gap-2.5 mt-0.5">
          <input
            id="remember"
            name="remember"
            type="checkbox"
            checked={remember}
            onChange={(e) => setRemember(e.target.checked)}
            className="w-4 h-4 rounded border-line-strong bg-surface text-accent-ink focus:ring-1 focus:ring-accent focus:ring-offset-0 focus:outline-none accent-accent cursor-pointer"
          />
          <label htmlFor="remember" className="text-xs text-zinc-300 cursor-pointer select-none">
            Keep me logged in
          </label>
        </div>

        <button
          type="submit"
          disabled={pending}
          className="mt-2 flex h-11 w-full items-center justify-center rounded-lg bg-accent text-sm font-semibold text-zinc-950 transition-colors hover:bg-accent-hover focus:outline-none focus:ring-2 focus:ring-accent/50 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
        >
          {pending ? (
            <span className="inline-flex items-center gap-2">
              <svg className="h-4 w-4 animate-spin text-zinc-950" viewBox="0 0 24 24" fill="none">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
              </svg>
              Logging in...
            </span>
          ) : (
            "Log in"
          )}
        </button>
      </form>

      <div className="mt-8 text-center text-xs text-zinc-400">
        New to LadyBug?{" "}
        <Link href="/register" className="font-semibold text-accent-ink hover:underline">
          Create an account
        </Link>
      </div>
    </div>
  );
}
