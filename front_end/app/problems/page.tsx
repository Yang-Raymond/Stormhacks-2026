"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useState } from "react";
import ChallengesSection from "@/components/challenges/ChallengesSection";
import DifficultyBadge from "@/components/ui/DifficultyBadge";
import GenerationProgress from "@/components/ui/GenerationProgress";
import { CheckIcon, ChevronRightIcon, SearchIcon, SparklesIcon } from "@/components/ui/icons";
import { api, type Difficulty, type MeResponse, type ProblemSummary } from "@/lib/api";
import { LANGUAGES, type Language, languageInfo } from "@/lib/languages";

const DIFFICULTIES: Difficulty[] = ["easy", "medium", "hard"];
const STATUSES = ["all", "unsolved", "solved"] as const;
type Status = (typeof STATUSES)[number];

const difficultyText: Record<Difficulty, string> = { easy: "text-easy", medium: "text-medium", hard: "text-hard" };
const difficultyBar: Record<Difficulty, string> = { easy: "bg-easy", medium: "bg-medium", hard: "bg-hard" };

const relativeFormat = new Intl.RelativeTimeFormat("en", { numeric: "auto" });
const units: [Intl.RelativeTimeFormatUnit, number][] = [
  ["year", 31_536_000],
  ["month", 2_592_000],
  ["week", 604_800],
  ["day", 86_400],
  ["hour", 3_600],
  ["minute", 60],
];

function relativeTime(iso: string) {
  const seconds = (Date.now() - new Date(iso).getTime()) / 1000;
  for (const [unit, size] of units) {
    if (seconds >= size) return relativeFormat.format(-Math.floor(seconds / size), unit);
  }
  return "just now";
}

export default function ProblemsPage() {
  const router = useRouter();
  const [problems, setProblems] = useState<ProblemSummary[] | null>(null);
  const [difficulty, setDifficulty] = useState<Difficulty>("easy");
  const [generating, setGenerating] = useState(false);
  const [error, setError] = useState("");
  const [query, setQuery] = useState("");
  const [difficultyFilter, setDifficultyFilter] = useState<Difficulty | "all">("all");
  const [languageFilter, setLanguageFilter] = useState<Language | "all">("all");
  const [status, setStatus] = useState<Status>("all");
  const [preferred, setPreferred] = useState<Language>("python");

  useEffect(() => {
    api<{ problems: ProblemSummary[] }>("/problems")
      .then((d) => setProblems(d.problems))
      .catch((e: Error) => {
        setError(e.message);
        setProblems([]);
      });

    api<MeResponse>("/auth/me")
      .then((res) => {
        const pref = res.user?.debugLanguages?.[0];
        if (pref && LANGUAGES.some((l) => l.id === pref)) {
          setLanguageFilter(pref as Language);
          setPreferred(pref as Language);
        }
      })
      .catch(() => {});
  }, []);

  async function generate() {
    setGenerating(true);
    setError("");
    try {
      const { id } = await api<{ id: string }>("/problems/generate", { body: { difficulty } });
      router.push(`/problems/${id}`);
    } catch (e) {
      setError((e as Error).message);
      setGenerating(false);
    }
  }

  // Each language version of a problem is its own row sharing the title; list each problem once and open
  // the filtered language, else the user's preferred one, else whichever exists.
  const list = useMemo(() => {
    const groups = new Map<string, ProblemSummary[]>();
    for (const p of problems ?? []) groups.set(p.title, [...(groups.get(p.title) ?? []), p]);
    const want = languageFilter === "all" ? preferred : languageFilter;
    return [...groups.values()]
      .filter((g) => languageFilter === "all" || g.some((p) => p.language === languageFilter))
      .map((g) => {
        const pick = g.find((p) => p.language === want) ?? g.find((p) => p.language === "python") ?? g[0];
        return { ...pick, solved: g.some((p) => p.solved) };
      });
  }, [problems, languageFilter, preferred]);

  const visible = useMemo(() => {
    const q = query.trim().toLowerCase();
    return list.filter(
      (p) =>
        (!q || p.title.toLowerCase().includes(q)) &&
        (difficultyFilter === "all" || p.difficulty === difficultyFilter) &&
        (status === "all" || (status === "solved") === p.solved),
    );
  }, [list, query, difficultyFilter, status]);

  const solvedCount = list.filter((p) => p.solved).length;

  return (
    <div className="mx-auto w-full max-w-5xl px-4 py-8 sm:px-6 sm:py-12">
      <header>
        <p className="font-mono text-xs uppercase tracking-[0.2em] text-accent">Debug practice</p>
        <h1 className="mt-2 text-3xl font-bold tracking-tight text-white">Problems</h1>
        <p className="mt-2 max-w-2xl text-sm leading-relaxed text-zinc-400">
          Each problem is a real solution with bugs slipped in. Read the spec, step through the code with the
          debugger, and fix it until every hidden test passes.
        </p>
      </header>

      <ChallengesSection />

      <div className="mt-12 flex flex-wrap items-baseline justify-between gap-2 border-t border-line pt-8">
        <h2 className="text-lg font-semibold text-white">Practice</h2>
        <p className="text-xs text-zinc-500">Problems in every language, come back any time.</p>
      </div>

      <section aria-label="Practice progress" className="mt-4 grid grid-cols-2 gap-3 lg:grid-cols-4">
        <StatTile label="Solved" solved={solvedCount} total={list.length} barClass="bg-accent" valueClass="text-white" />
        {DIFFICULTIES.map((d) => {
          const ofDifficulty = list.filter((p) => p.difficulty === d);
          return (
            <StatTile
              key={d}
              label={d}
              solved={ofDifficulty.filter((p) => p.solved).length}
              total={ofDifficulty.length}
              barClass={difficultyBar[d]}
              valueClass={difficultyText[d]}
            />
          );
        })}
      </section>

      <GenerateCard difficulty={difficulty} onDifficulty={setDifficulty} generating={generating} onGenerate={generate} />

      {error && (
        <p role="alert" className="mt-4 rounded-lg border border-red-900/60 bg-red-950/30 px-4 py-3 text-sm text-red-300">
          {error}
        </p>
      )}

      <section aria-label="Problem list" className="mt-10">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
          <label className="relative flex-1">
            <span className="sr-only">Search problems</span>
            <SearchIcon className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-zinc-500" />
            <input
              type="search"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search problems"
              className="w-full rounded-lg border border-line bg-surface py-2 pl-9 pr-3 text-sm text-zinc-100 placeholder:text-zinc-500 focus:border-accent/60 focus:outline-none focus:ring-2 focus:ring-accent/20"
            />
          </label>
          <div className="flex flex-wrap items-center gap-2">
            <div className="flex items-center gap-1.5 rounded-lg border border-line bg-surface px-2.5 py-1.5 text-xs text-zinc-300">
              <label htmlFor="language-filter" className="text-zinc-500">
                Language:
              </label>
              <select
                id="language-filter"
                value={languageFilter}
                onChange={(e) => setLanguageFilter(e.target.value as Language | "all")}
                className="cursor-pointer bg-transparent text-xs text-zinc-200 focus:outline-none"
              >
                <option value="all" className="bg-surface text-zinc-200">
                  All
                </option>
                {LANGUAGES.map((l) => (
                  <option key={l.id} value={l.id} className="bg-surface text-zinc-200">
                    {l.label}
                  </option>
                ))}
              </select>
            </div>
            <Segmented
              label="Difficulty"
              options={["all", ...DIFFICULTIES] as const}
              value={difficultyFilter}
              onChange={setDifficultyFilter}
            />
            <Segmented label="Status" options={STATUSES} value={status} onChange={setStatus} />
          </div>
        </div>

        <ul className="mt-4 flex flex-col gap-2">
          {problems === null &&
            Array.from({ length: 4 }, (_, i) => (
              <li key={i} className="h-[62px] animate-pulse rounded-lg border border-line bg-surface" />
            ))}

          {visible.map((p) => (
            <li key={p.id}>
              <Link
                href={`/problems/${p.id}`}
                className="group flex items-center gap-4 rounded-lg border border-line bg-surface px-4 py-3 transition-colors hover:border-line-strong hover:bg-surface-2 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent/40"
              >
                <SolvedMark solved={p.solved} />
                <div className="min-w-0 flex-1">
                  <p className="truncate font-medium text-zinc-100 group-hover:text-white">{p.title}</p>
                  <div className="mt-0.5 flex items-center gap-2">
                    <span className="font-mono text-xs text-zinc-500">
                      #{p.id} · {relativeTime(p.created_at)}
                    </span>
                    <span className="rounded border border-line bg-surface-2 px-1.5 py-0.5 font-mono text-[10px] text-zinc-400">
                      {languageInfo(p.language).label}
                    </span>
                  </div>
                </div>
                <DifficultyBadge difficulty={p.difficulty} />
                <ChevronRightIcon className="size-4 text-zinc-600 transition group-hover:translate-x-0.5 group-hover:text-accent" />
              </Link>
            </li>
          ))}
        </ul>

        {problems !== null && visible.length === 0 && (
          <div className="mt-2 flex flex-col items-center rounded-lg border border-dashed border-line-strong px-6 py-14 text-center">
            <span className="flex h-11 w-11 items-center justify-center rounded-full border border-line-strong bg-surface text-accent">
              <SparklesIcon className="size-5" />
            </span>
            {list.length === 0 ? (
              <>
                <p className="mt-4 font-medium text-zinc-200">No problems yet</p>
                <p className="mt-1 text-sm text-zinc-500">Generate your first one above, it takes about 30 seconds.</p>
              </>
            ) : (
              <>
                <p className="mt-4 font-medium text-zinc-200">No problems match these filters</p>
                <button
                  onClick={() => {
                    setQuery("");
                    setLanguageFilter("all");
                    setDifficultyFilter("all");
                    setStatus("all");
                  }}
                  className="mt-2 text-sm text-accent hover:underline"
                >
                  Clear filters
                </button>
              </>
            )}
          </div>
        )}
      </section>
    </div>
  );
}

function StatTile({ label, solved, total, barClass, valueClass }: {
  label: string;
  solved: number;
  total: number;
  barClass: string;
  valueClass: string;
}) {
  const pct = total ? Math.round((solved / total) * 100) : 0;
  return (
    <div className="rounded-xl border border-line bg-surface p-4">
      <p className="text-xs font-medium uppercase tracking-wider text-zinc-500">{label}</p>
      <p className="mt-2 flex items-baseline gap-1.5">
        <span className={`text-2xl font-semibold tabular-nums ${valueClass}`}>{solved}</span>
        <span className="text-sm tabular-nums text-zinc-500">/ {total}</span>
      </p>
      <div
        className="mt-3 h-1 overflow-hidden rounded-full bg-line"
        role="progressbar"
        aria-label={`${label} solved`}
        aria-valuenow={pct}
        aria-valuemin={0}
        aria-valuemax={100}
      >
        <div className={`h-full rounded-full transition-[width] duration-500 ${barClass}`} style={{ width: `${pct}%` }} />
      </div>
    </div>
  );
}

function GenerateCard({ difficulty, onDifficulty, generating, onGenerate }: {
  difficulty: Difficulty;
  onDifficulty: (d: Difficulty) => void;
  generating: boolean;
  onGenerate: () => void;
}) {
  return (
    <section className="relative mt-6 overflow-hidden rounded-xl border border-line bg-surface">
      <div className="pointer-events-none absolute -right-24 -top-24 h-56 w-56 rounded-full bg-accent/10 blur-3xl" />
      <div className="relative flex flex-col gap-5 p-5 sm:p-6 lg:flex-row lg:items-center">
        <div className="flex-1">
          <h2 className="flex items-center gap-2 font-semibold text-white">
            <SparklesIcon className="size-4 text-accent" />
            Generate a practice problem
          </h2>
          <p className="mt-1 text-sm text-zinc-400">
            A fresh algorithm problem, a buggy solution to fix, and a hidden test suite to prove it.
          </p>
        </div>
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
          <div role="radiogroup" aria-label="Difficulty" className="flex rounded-lg border border-line bg-canvas-2 p-1">
            {DIFFICULTIES.map((d) => (
              <button
                key={d}
                role="radio"
                aria-checked={difficulty === d}
                disabled={generating}
                onClick={() => onDifficulty(d)}
                className={`flex-1 rounded-md px-3.5 py-1.5 text-sm capitalize transition-colors disabled:cursor-not-allowed ${
                  difficulty === d ? `bg-surface-2 font-medium shadow-sm ${difficultyText[d]}` : "text-zinc-400 hover:text-zinc-200"
                }`}
              >
                {d}
              </button>
            ))}
          </div>
          <button
            onClick={onGenerate}
            disabled={generating}
            className="rounded-lg bg-accent px-5 py-2.5 text-sm font-semibold text-zinc-950 transition-colors hover:bg-accent-hover disabled:cursor-wait disabled:opacity-70"
          >
            {generating ? "Generating…" : "Generate problem"}
          </button>
        </div>
      </div>

      {generating && <GenerationProgress className="relative border-t border-line px-5 py-4 sm:px-6" />}
    </section>
  );
}

function Segmented<T extends string>({ label, options, value, onChange }: {
  label: string;
  options: readonly T[];
  value: T;
  onChange: (v: T) => void;
}) {
  return (
    <div role="group" aria-label={label} className="flex rounded-lg border border-line bg-surface p-0.5">
      {options.map((o) => (
        <button
          key={o}
          aria-pressed={value === o}
          onClick={() => onChange(o)}
          className={`rounded-md px-2.5 py-1.5 text-xs capitalize transition-colors ${
            value === o ? "bg-surface-2 font-medium text-zinc-100" : "text-zinc-500 hover:text-zinc-300"
          }`}
        >
          {o}
        </button>
      ))}
    </div>
  );
}

function SolvedMark({ solved }: { solved: boolean }) {
  return solved ? (
    <span
      title="Solved"
      className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full border border-[#1e4a33] bg-[#12281c] text-easy"
    >
      <CheckIcon className="size-3.5" />
      <span className="sr-only">Solved</span>
    </span>
  ) : (
    <span title="Not solved yet" className="h-6 w-6 shrink-0 rounded-full border border-dashed border-line-strong" />
  );
}
