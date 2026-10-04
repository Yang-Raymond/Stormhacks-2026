"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useCallback, useEffect, useState } from "react";
import DifficultyBadge from "@/components/ui/DifficultyBadge";
import { CheckIcon } from "@/components/ui/icons";
import { ApiError, api, type ChallengeKind, type ChallengesResponse, type MeResponse } from "@/lib/api";
import { LANGUAGES, type Language, languageInfo } from "@/lib/languages";
import ChallengeCard from "./ChallengeCard";

/** While a generation started elsewhere (another tab, or before navigating away) is running, check back. */
const POLL_MS = 5000;

/** Onboarding stores display names ("Python", "TypeScript"); pick the first one we can generate in. */
function preferredLanguage(me: MeResponse | null): Language {
  for (const name of me?.user?.debugLanguages ?? []) {
    const match = LANGUAGES.find((l) => l.label.toLowerCase().startsWith(name.toLowerCase()));
    if (match) return match.id;
  }
  return "python";
}

const shortDate = new Intl.DateTimeFormat("en", { month: "short", day: "numeric", timeZone: "UTC" });

export default function ChallengesSection() {
  const router = useRouter();
  const [data, setData] = useState<ChallengesResponse | null>(null);
  const [loggedIn, setLoggedIn] = useState(true);
  const [defaultLanguage, setDefaultLanguage] = useState<Language>("python");
  const [error, setError] = useState("");

  const load = useCallback(() => {
    api<ChallengesResponse>("/challenges")
      .then((d) => {
        setData(d);
        setError("");
      })
      .catch((e: Error) => {
        if (e instanceof ApiError && e.status === 401) {
          setLoggedIn(false);
          setData(placeholderSlots());
        } else {
          setError(e.message);
        }
      });
  }, []);

  useEffect(() => {
    load();
    api<MeResponse>("/auth/me")
      .then((me) => setDefaultLanguage(preferredLanguage(me)))
      .catch(() => {});
  }, [load]);

  useEffect(() => {
    if (!data || (!data.daily.starting && !data.weekly.starting)) return;
    const timer = setTimeout(load, POLL_MS);
    return () => clearTimeout(timer);
  }, [data, load]);

  async function start(kind: ChallengeKind, language: Language) {
    try {
      const { id } = await api<{ id: string }>(`/challenges/${kind}/start`, { body: { language } });
      router.push(`/problems/${id}`);
    } catch (e) {
      // Already started (e.g. in another tab): show it instead of an error.
      if (e instanceof ApiError && e.status === 409) {
        load();
        return;
      }
      throw e;
    }
  }

  return (
    <section aria-labelledby="challenges-heading" className="mt-8">
      <div className="flex flex-wrap items-baseline justify-between gap-2">
        <h2 id="challenges-heading" className="text-lg font-semibold text-white">Challenges</h2>
        <p className="text-xs text-zinc-500">A fresh problem just for you, in the language of your choice.</p>
      </div>
      {error && (
        <p role="alert" className="mt-3 rounded-lg border border-red-900/60 bg-red-950/30 px-4 py-3 text-sm text-red-300">
          {error}
        </p>
      )}
      <div className="mt-4 grid gap-4 md:grid-cols-2">
        {(["daily", "weekly"] as const).map((kind) => (
          <ChallengeCard
            key={kind}
            kind={kind}
            slot={data?.[kind] ?? null}
            loggedIn={loggedIn}
            defaultLanguage={defaultLanguage}
            onStart={start}
            onExpired={load}
          />
        ))}
      </div>

      {data && data.history.length > 0 && (
        <div className="mt-6">
          <h3 className="text-xs font-medium uppercase tracking-wider text-zinc-500">Past challenges</h3>
          <ul className="mt-2 divide-y divide-line overflow-hidden rounded-lg border border-line bg-surface">
            {data.history.map((c) => (
              <li key={c.problemId}>
                <Link
                  href={`/problems/${c.problemId}`}
                  className="flex items-center gap-3 px-4 py-2.5 text-sm transition-colors hover:bg-surface-2"
                >
                  <CheckIcon className="size-4 shrink-0 text-easy" />
                  <span
                    className={`w-14 shrink-0 font-mono text-[11px] uppercase ${c.kind === "weekly" ? "text-violet-300" : "text-accent"}`}
                  >
                    {c.kind}
                  </span>
                  <span className="min-w-0 flex-1 truncate text-zinc-200">{c.title}</span>
                  <DifficultyBadge difficulty={c.difficulty} className="hidden sm:inline-flex" />
                  <span className="hidden shrink-0 font-mono text-[11px] text-zinc-500 sm:inline">
                    {languageInfo(c.language).label}
                  </span>
                  <span className="w-20 shrink-0 text-right text-xs text-zinc-500">
                    {c.kind === "weekly" ? "wk of " : ""}
                    {shortDate.format(new Date(`${c.periodStart}T00:00:00Z`))}
                  </span>
                </Link>
              </li>
            ))}
          </ul>
        </div>
      )}
    </section>
  );
}

/** Logged-out visitors still see the cards (with a log-in prompt) and the reset countdowns. */
function placeholderSlots(): ChallengesResponse {
  const now = new Date();
  const today = Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate());
  const monday = today - ((now.getUTCDay() + 6) % 7) * 86_400_000;
  const slot = (kind: ChallengeKind, start: number, days: number) => ({
    kind,
    periodStart: new Date(start).toISOString().slice(0, 10),
    endsAt: new Date(start + days * 86_400_000).toISOString(),
    starting: false,
    challenge: null,
  });
  return { daily: slot("daily", today, 1), weekly: slot("weekly", monday, 7), history: [] };
}
