"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import DifficultyBadge from "@/components/ui/DifficultyBadge";
import { BarChartIcon } from "@/components/ui/icons";
import { api, type Difficulty, type Insights } from "@/lib/api";
import { languageInfo } from "@/lib/languages";

type Ready = Extract<Insights, { configured: true }>;
type RateRow = { label: React.ReactNode; key: string; submits: number; accepted: number };

const DIFFICULTY_ORDER = ["easy", "medium", "hard"];
const pct = (accepted: number, submits: number) => (submits ? Math.round((accepted / submits) * 100) : 0);
const fmt = new Intl.NumberFormat("en");

export default function InsightsPage() {
  const [data, setData] = useState<Insights | null>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    api<Insights>("/insights").then(setData).catch((e: Error) => setError(e.message));
  }, []);

  return (
    <div className="mx-auto w-full max-w-5xl px-4 py-8 sm:px-6 sm:py-12">
      <header>
        <p className="font-mono text-xs uppercase tracking-[0.2em] text-accent">Powered by Snowflake</p>
        <h1 className="mt-2 text-3xl font-bold tracking-tight text-white">Insights</h1>
        <p className="mt-2 max-w-2xl text-sm leading-relaxed text-zinc-400">
          Site-wide trends from every run, submission, debug session and hint. Activity is recorded in a Tiger Data
          hypertable and synced, anonymized, into a Snowflake warehouse where these numbers are computed.
        </p>
      </header>

      {error && (
        <p role="alert" className="mt-8 rounded-lg border border-red-900/60 bg-red-950/30 px-4 py-3 text-sm text-red-300">
          {error}
        </p>
      )}
      {!data && !error && <div className="mt-8 h-64 animate-pulse rounded-xl border border-line bg-surface" />}
      {data && !data.configured && <NotConfigured />}
      {data?.configured && <Dashboard data={data} />}
    </div>
  );
}

function NotConfigured() {
  return (
    <div className="mt-8 flex flex-col items-center rounded-xl border border-dashed border-line-strong px-6 py-14 text-center">
      <span className="flex h-11 w-11 items-center justify-center rounded-full border border-line-strong bg-surface text-accent">
        <BarChartIcon className="size-5" />
      </span>
      <p className="mt-4 font-medium text-zinc-200">The analytics warehouse isn&apos;t connected yet</p>
      <p className="mt-1 max-w-md text-sm text-zinc-500">
        Set the Snowflake environment variables on the server (see docs/integrations.md) and events will start syncing
        within a few minutes.
      </p>
      <Link href="/problems" className="mt-4 text-sm text-accent hover:underline">Back to problems</Link>
    </div>
  );
}

function Dashboard({ data }: { data: Ready }) {
  const t = data.totals;
  const byDifficulty = [...data.byDifficulty].sort(
    (a, b) => DIFFICULTY_ORDER.indexOf(a.difficulty) - DIFFICULTY_ORDER.indexOf(b.difficulty),
  );
  return (
    <>
      <dl className="mt-8 grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-5">
        <Kpi label="Learners" value={fmt.format(t.users)} />
        <Kpi label="Submissions" value={fmt.format(t.submits)} />
        <Kpi label="Acceptance rate" value={`${pct(t.accepted, t.submits)}%`} />
        <Kpi label="Debug sessions" value={fmt.format(t.debugs)} />
        <Kpi label="AI hints given" value={fmt.format(t.hints)} />
      </dl>

      <div className="mt-6 grid gap-4 lg:grid-cols-2">
        <Panel title="Acceptance rate by language" caption="Share of submissions that passed every test">
          <RateTable
            rows={data.byLanguage.map((r) => ({ ...r, key: r.language, label: languageInfo(r.language).label }))}
            header="Language"
          />
        </Panel>
        <Panel title="Acceptance rate by difficulty" caption="Harder problems should sit lower">
          <RateTable
            rows={byDifficulty.map((r) => ({
              ...r,
              key: r.difficulty,
              label: <DifficultyBadge difficulty={r.difficulty as Difficulty} />,
            }))}
            header="Difficulty"
          />
        </Panel>
      </div>

      <Panel title="When people practice" caption="Activity by hour of day, UTC" className="mt-4">
        <HourChart byHour={data.byHour} />
      </Panel>

      <Panel title="Hardest practice problems" caption="Lowest acceptance, at least 2 submissions" className="mt-4">
        {data.hardest.length === 0 ? (
          <p className="py-6 text-center text-sm text-zinc-500">Not enough submissions yet.</p>
        ) : (
          <table className="w-full text-left text-sm">
            <thead className="text-xs text-zinc-500">
              <tr>
                <th className="py-2 pr-3 font-medium">Problem</th>
                <th className="hidden py-2 pr-3 font-medium sm:table-cell">Difficulty</th>
                <th className="hidden py-2 pr-3 font-medium sm:table-cell">Language</th>
                <th className="py-2 text-right font-medium">Accepted</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-line">
              {data.hardest.map((p) => (
                <tr key={p.problem_id}>
                  <td className="py-2 pr-3">
                    <Link href={`/problems/${p.problem_id}`} className="text-zinc-200 hover:text-accent">{p.title}</Link>
                  </td>
                  <td className="hidden py-2 pr-3 sm:table-cell">
                    <DifficultyBadge difficulty={p.difficulty as Difficulty} />
                  </td>
                  <td className="hidden py-2 pr-3 text-zinc-400 sm:table-cell">{languageInfo(p.language).label}</td>
                  <td className="py-2 text-right tabular-nums text-zinc-300">
                    {pct(p.accepted, p.submits)}% <span className="text-zinc-500">({p.accepted}/{p.submits})</span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </Panel>

      <p className="mt-6 text-xs text-zinc-600">
        Computed in Snowflake · updated {new Date(data.generatedAt).toLocaleString()} · refreshes every 10 minutes
      </p>
    </>
  );
}

function Kpi({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl border border-line bg-surface p-4">
      <dt className="text-xs font-medium uppercase tracking-wider text-zinc-500">{label}</dt>
      <dd className="mt-2 text-2xl font-semibold tabular-nums text-white">{value}</dd>
    </div>
  );
}

function Panel({ title, caption, className = "", children }: {
  title: string;
  caption: string;
  className?: string;
  children: React.ReactNode;
}) {
  return (
    <section className={`rounded-xl border border-line bg-surface p-5 ${className}`}>
      <h2 className="text-sm font-semibold text-white">{title}</h2>
      <p className="mt-0.5 text-xs text-zinc-500">{caption}</p>
      <div className="mt-4">{children}</div>
    </section>
  );
}

/** Bar rows that are also a real table: one hue, value text in ink colors, bars on a shared 0-100% scale. */
function RateTable({ rows, header }: { rows: RateRow[]; header: string }) {
  if (!rows.length) return <p className="py-6 text-center text-sm text-zinc-500">No submissions yet.</p>;
  return (
    <table className="w-full text-sm">
      <thead className="sr-only">
        <tr>
          <th>{header}</th>
          <th>Acceptance rate</th>
          <th>Accepted / submitted</th>
        </tr>
      </thead>
      <tbody>
        {rows.map((r) => {
          const rate = pct(r.accepted, r.submits);
          return (
            <tr key={r.key} title={`${rate}% accepted (${r.accepted} of ${r.submits} submissions)`}>
              <td className="w-28 py-1.5 pr-3 text-zinc-300">{r.label}</td>
              <td className="py-1.5">
                <div className="h-2 rounded-full bg-surface-2">
                  <div className="h-full rounded-full bg-accent" style={{ width: `${Math.max(rate, 1)}%` }} />
                </div>
              </td>
              <td className="w-28 py-1.5 pl-3 text-right tabular-nums text-zinc-300">
                {rate}% <span className="text-xs text-zinc-500">{r.accepted}/{r.submits}</span>
              </td>
            </tr>
          );
        })}
      </tbody>
    </table>
  );
}

function HourChart({ byHour }: { byHour: Ready["byHour"] }) {
  const [hover, setHover] = useState<number | null>(null);
  const counts = Array.from({ length: 24 }, (_, h) => byHour.find((r) => r.hour === h)?.events ?? 0);
  const max = Math.max(1, ...counts);
  const peak = counts.indexOf(Math.max(...counts));
  return (
    <div>
      <p className="sr-only">
        Busiest hour: {peak}:00 UTC with {counts[peak]} events. Hourly counts: {counts.map((c, h) => `${h}:00 ${c}`).join(", ")}.
      </p>
      <div className="relative" aria-hidden="true" onMouseLeave={() => setHover(null)}>
        {hover !== null && (
          <div
            className="pointer-events-none absolute -top-2 z-10 -translate-x-1/2 -translate-y-full rounded-md border border-line-strong bg-surface-2 px-2.5 py-1.5 text-xs shadow-xl"
            style={{ left: `${((hover + 0.5) / 24) * 100}%` }}
          >
            <span className="font-medium text-zinc-100">{String(hover).padStart(2, "0")}:00 UTC</span>
            <span className="text-zinc-400"> · {fmt.format(counts[hover])} events</span>
          </div>
        )}
        <div className="flex h-32 items-end gap-[2px] border-b border-line">
          {counts.map((c, h) => (
            <div key={h} className="flex h-full flex-1 items-end" onMouseEnter={() => setHover(h)}>
              <div
                className={`w-full rounded-t-[4px] transition-colors ${hover === h ? "bg-accent" : "bg-accent/70"}`}
                style={{ height: c ? `${Math.max((c / max) * 100, 3)}%` : "0%" }}
              />
            </div>
          ))}
        </div>
        <div className="mt-1.5 flex text-[10px] text-zinc-500">
          {counts.map((_, h) => (
            <span key={h} className="flex-1 text-center">
              {h % 6 === 0 ? `${String(h).padStart(2, "0")}h` : ""}
            </span>
          ))}
        </div>
      </div>
    </div>
  );
}
