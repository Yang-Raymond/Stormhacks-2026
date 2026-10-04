"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";

interface OAuthButtonsProps {
  layout: "stacked" | "inline";
  mode: "login" | "register";
  remember?: boolean;
  language?: string;
  termsAccepted?: boolean;
}

export default function OAuthButtons({
  layout,
  mode,
  remember = false,
  language,
  termsAccepted = true,
}: OAuthButtonsProps) {
  const [providers, setProviders] = useState<{ github: boolean; google: boolean }>({
    github: true,
    google: true,
  });

  useEffect(() => {
    api<{ github: boolean; google: boolean }>("/auth/providers")
      .then(setProviders)
      .catch(() => {
        // Fallback: leave them clickable, backend handles configuration errors gracefully
      });
  }, []);

  const buildUrl = (provider: "github" | "google") => {
    const params = new URLSearchParams({
      from: mode,
      remember: remember ? "1" : "0",
    });
    if (language) params.set("language", language);
    return `/api/auth/oauth/${provider}/start?${params.toString()}`;
  };

  const isSignupDisabled = mode === "register" && !termsAccepted;

  const handleOAuthClick = (e: React.MouseEvent<HTMLAnchorElement>, provider: "github" | "google") => {
    if (isSignupDisabled) {
      e.preventDefault();
      alert("Please agree to the Terms of Service and Privacy Policy first.");
      return;
    }
    if (!providers[provider]) {
      e.preventDefault();
      alert(`${provider === "github" ? "GitHub" : "Google"} OAuth is not configured yet in .env.`);
      return;
    }
  };

  const codeBracketIcon = (
    <svg className="w-4 h-4 text-zinc-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2}>
      <path strokeLinecap="round" strokeLinejoin="round" d="M8 9l-4 3 4 3m8-6l4 3-4 3" />
    </svg>
  );

  const googlePlusIcon = (
    <svg className="w-4 h-4 text-zinc-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2}>
      <circle cx="12" cy="12" r="9" />
      <path strokeLinecap="round" strokeLinejoin="round" d="M12 8v8m-4-4h8" />
    </svg>
  );

  const buttonClass =
    "flex items-center justify-center gap-2.5 h-11 rounded-lg border border-[#232730] bg-[#16181d] text-sm font-medium text-zinc-200 hover:bg-[#1c1f26] hover:border-zinc-700 transition-colors focus:outline-none focus:ring-2 focus:ring-[#f2b544]/50 disabled:opacity-50 disabled:cursor-not-allowed";

  if (layout === "inline") {
    return (
      <div className="grid grid-cols-2 gap-3 w-full">
        <a
          href={buildUrl("github")}
          onClick={(e) => handleOAuthClick(e, "github")}
          aria-disabled={isSignupDisabled || !providers.github}
          className={`${buttonClass} ${isSignupDisabled ? "opacity-60 cursor-not-allowed" : ""}`}
        >
          {codeBracketIcon}
          <span>GitHub</span>
        </a>
        <a
          href={buildUrl("google")}
          onClick={(e) => handleOAuthClick(e, "google")}
          aria-disabled={isSignupDisabled || !providers.google}
          className={`${buttonClass} ${isSignupDisabled ? "opacity-60 cursor-not-allowed" : ""}`}
        >
          {googlePlusIcon}
          <span>Google</span>
        </a>
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-2.5 w-full">
      <a
        href={buildUrl("github")}
        onClick={(e) => handleOAuthClick(e, "github")}
        aria-disabled={!providers.github}
        className={buttonClass}
      >
        {codeBracketIcon}
        <span>Continue with GitHub</span>
      </a>
      <a
        href={buildUrl("google")}
        onClick={(e) => handleOAuthClick(e, "google")}
        aria-disabled={!providers.google}
        className={buttonClass}
      >
        {googlePlusIcon}
        <span>Continue with Google</span>
      </a>
    </div>
  );
}
