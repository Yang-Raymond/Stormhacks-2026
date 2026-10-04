"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import ConfirmDialog from "@/components/ui/ConfirmDialog";
import DifficultyBadge from "@/components/ui/DifficultyBadge";
import GenerationProgress from "@/components/ui/GenerationProgress";
import { CalendarIcon, CheckIcon, ChevronRightIcon, ClockIcon, LockIcon, TrophyIcon } from "@/components/ui/icons";
import { formatRemaining, useNow } from "@/hooks/useNow";
import type { ChallengeKind, ChallengeSlot } from "@/lib/api";
import { LANGUAGES, type Language, languageInfo } from "@/lib/languages";

const KIND = {
  daily: {
    title: "Daily challenge",
    difficulty: "Easy or Medium",
    reset: "every day at 00:00 UTC",
    icon: CalendarIcon,
    glow: "bg-accent/10",
    iconClass: "border-accent/30 bg-accent/10 text-accent-ink",
  },
  weekly: {
    title: "Weekly challenge",
    difficulty: "Hard",
    reset: "every Monday at 00:00 UTC",
    icon: TrophyIcon,
    glow: "bg-violet-500/10",
    iconClass: "border-violet-400/30 bg-violet-500/10 text-violet-300",
  },
} satisfies Record<ChallengeKind, unknown>;

export default function ChallengeCard({ kind, slot, loggedIn, defaultLanguage, onStart, onExpired }: {
  kind: ChallengeKind;
  /** null while loading */
  slot: ChallengeSlot | null;
  loggedIn: boolean;
  defaultLanguage: Language;
  /** Generates the challenge; resolves once it exists (the parent navigates to it). */
  onStart: (kind: ChallengeKind, language: Language) => Promise<void>;
  /** The period ended while the page was open. */
  onExpired: () => void;
}) {
  const meta = KIND[kind];
  const now = useNow();
  // Only the user's explicit pick is state; until then follow their preferred language (it may load later).
  const [chosen, setChosen] = useState<Language | null>(null);
  const language = chosen ?? defaultLanguage;
  const [confirming, setConfirming] = useState(false);
  const [starting, setStarting] = useState(false);
  const [error, setError] = useState("");
  const remaining = slot ? Date.parse(slot.endsAt) - now : Infinity;

  useEffect(() => {
    if (remaining <= 0) onExpired();
  }, [remaining, onExpired]);

  async function start() {
    setConfirming(false);
    setStarting(true);
    setError("");
    try {
      await onStart(kind, language);
    } catch (e) {
      setError((e as Error).message);
      setStarting(false);
    }
  }

  const challenge = slot?.challenge;
  const generating = starting || (slot?.starting ?? false);
  const Icon = meta.icon;

  return (
    <article className="relative flex min-h-56 flex-col overflow-hidden rounded-xl border border-line bg-surface p-5">
      <div className={`pointer-events-none absolute -right-20 -top-20 h-48 w-48 rounded-full blur-3xl ${meta.glow}`} />

      <header className="relative flex items-start gap-3">
        <span className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-lg border ${meta.iconClass}`}>
          <Icon className="size-4.5" />
        </span>
        <div className="min-w-0 flex-1">
          <h3 className="font-semibold text-foreground">{meta.title}</h3>
          <p className="mt-0.5 text-xs text-zinc-500">
            {challenge ? <DifficultyBadge difficulty={challenge.difficulty} /> : meta.difficulty} · resets {meta.reset}
          </p>
        </div>
        {slot && (
          <span
            className="flex shrink-0 items-center gap-1 rounded-full border border-line bg-canvas-2 px-2 py-0.5 font-mono text-[11px] tabular-nums text-zinc-400"
            title={`Ends ${new Date(slot.endsAt).toLocaleString()}`}
          >
            <ClockIcon className="size-3" />
            {formatRemaining(remaining)}
          </span>
        )}
      </header>

      <div className="relative mt-5 flex flex-1 flex-col">
        {!slot ? (
          <div className="flex-1 animate-pulse rounded-lg bg-surface-2" />
        ) : !loggedIn ? (
          <p className="text-sm text-zinc-400">
            <Link href="/login" className="text-accent-ink hover:underline">Log in</Link> to take on {kind} challenges.
          </p>
        ) : generating ? (
          <>
            <p className="text-sm text-zinc-300">
              Generating your {kind} challenge{starting ? ` in ${languageInfo(language).label}` : ""}…
            </p>
            <GenerationProgress className="mt-4" />
          </>
        ) : challenge ? (
          <>
            <Link
              href={`/problems/${challenge.problemId}`}
              className="group flex items-center gap-3 rounded-lg border border-line bg-canvas-2/60 px-3 py-2.5 transition-colors hover:border-line-strong"
            >
              {challenge.solved ? (
                <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full border border-success-line bg-success-surface text-easy">
                  <CheckIcon className="size-3.5" />
                </span>
              ) : (
                <span className="h-6 w-6 shrink-0 rounded-full border border-dashed border-line-strong" />
              )}
              <span className="min-w-0 flex-1 truncate font-medium text-zinc-100">{challenge.title}</span>
              <span className="shrink-0 rounded border border-line bg-surface-2 px-1.5 py-0.5 font-mono text-[11px] text-zinc-400">
                {languageInfo(challenge.language).label}
              </span>
              <ChevronRightIcon className="size-4 shrink-0 text-zinc-600 transition group-hover:translate-x-0.5 group-hover:text-accent-ink" />
            </Link>
            <p className={`mt-3 text-xs ${challenge.solved ? "text-easy" : "text-zinc-500"}`}>
              {challenge.solved
                ? `Solved! It stays in your history. A new ${kind} challenge unlocks in ${formatRemaining(remaining)}.`
                : `Unsolved progress is lost when this ${kind === "daily" ? "day" : "week"} ends.`}
            </p>
            <Link
              href={`/problems/${challenge.problemId}`}
              className={`mt-auto self-start rounded-lg px-4 py-2 text-sm font-semibold transition-colors ${
                challenge.solved
                  ? "border border-line-strong text-zinc-200 hover:bg-surface-2"
                  : "bg-accent text-white hover:bg-accent-hover"
              }`}
            >
              {challenge.solved ? "Review solution" : "Continue"}
            </Link>
          </>
        ) : (
          <>
            <label className="text-xs font-medium text-zinc-400" htmlFor={`${kind}-language`}>
              Language
            </label>
            <select
              id={`${kind}-language`}
              value={language}
              onChange={(e) => setChosen(e.target.value as Language)}
              className="mt-1.5 w-full rounded-lg border border-line bg-canvas-2 px-3 py-2 text-sm text-zinc-100 focus:border-accent/60 focus:outline-none focus:ring-2 focus:ring-accent/20"
            >
              {LANGUAGES.map((l) => (
                <option key={l.id} value={l.id}>
                  {l.label}
                </option>
              ))}
            </select>
            <p className="mt-2 flex items-start gap-1.5 text-xs text-zinc-500">
              <LockIcon className="mt-px size-3.5 shrink-0 text-accent-ink" />
              The language is locked once the challenge is generated.
            </p>
            {error && <p role="alert" className="mt-3 text-xs text-red-400">{error}</p>}
            <button
              type="button"
              onClick={() => setConfirming(true)}
              className="mt-auto self-start rounded-lg bg-accent px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-accent-hover"
            >
              Start {kind} challenge
            </button>
          </>
        )}
      </div>

      <ConfirmDialog
        open={confirming}
        tone="accent"
        icon={<LockIcon className="size-5" />}
        title={`Start your ${kind} challenge in ${languageInfo(language).label}?`}
        confirmLabel="Generate challenge"
        onConfirm={() => void start()}
        onCancel={() => setConfirming(false)}
      >
        We&apos;ll generate a fresh {meta.difficulty.toLowerCase()} problem in{" "}
        <span className="font-medium text-zinc-200">{languageInfo(language).label}</span>.{" "}
        <span className="font-medium text-zinc-200">You can&apos;t change the language once it&apos;s created.</span> If
        it isn&apos;t solved before it resets ({meta.reset}), it&apos;s replaced by a new one.
      </ConfirmDialog>
    </article>
  );
}
