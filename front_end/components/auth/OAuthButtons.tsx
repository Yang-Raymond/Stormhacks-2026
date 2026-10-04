"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";

interface OAuthButtonsProps {
  layout: "stacked" | "inline";
  mode: "login" | "register";
  remember?: boolean;
}

export default function OAuthButtons({
  layout,
  mode,
  remember = false,
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
    return `/api/auth/oauth/${provider}/start?${params.toString()}`;
  };

  const handleOAuthClick = (e: React.MouseEvent<HTMLAnchorElement>, provider: "github" | "google") => {
    if (!providers[provider]) {
      e.preventDefault();
      alert(`${provider === "github" ? "GitHub" : "Google"} OAuth is not configured yet in .env.`);
      return;
    }
  };

  const githubIcon = (
    <img src="/GitHub_Invertocat_Black.svg" alt="GitHub Logo" className="w-4 h-4 dark:invert" />
  );

  const googleIcon = (
    <img src="/Google_Favicon_2025.svg" alt="Google Logo" className="w-4 h-4" />
  );

  const buttonClass =
    "flex items-center justify-center gap-2.5 h-11 rounded-lg border border-line bg-surface text-sm font-medium text-zinc-200 hover:bg-surface-2 hover:border-zinc-700 transition-colors focus:outline-none focus:ring-2 focus:ring-accent/50 disabled:opacity-50 disabled:cursor-not-allowed";

  if (layout === "inline") {
    return (
      <div className="grid grid-cols-2 gap-3 w-full">
        <a
          href={buildUrl("github")}
          onClick={(e) => handleOAuthClick(e, "github")}
          aria-disabled={!providers.github}
          className={buttonClass}
        >
          {githubIcon}
          <span>GitHub</span>
        </a>
        <a
          href={buildUrl("google")}
          onClick={(e) => handleOAuthClick(e, "google")}
          aria-disabled={!providers.google}
          className={buttonClass}
        >
          {googleIcon}
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
        {githubIcon}
        <span>Continue with GitHub</span>
      </a>
      <a
        href={buildUrl("google")}
        onClick={(e) => handleOAuthClick(e, "google")}
        aria-disabled={!providers.google}
        className={buttonClass}
      >
        {googleIcon}
        <span>Continue with Google</span>
      </a>
    </div>
  );
}
