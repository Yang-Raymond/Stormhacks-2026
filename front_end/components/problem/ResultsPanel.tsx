"use client";

import { BugIcon, CheckIcon, XIcon } from "@/components/ui/icons";
import type { RunResult, TestResult } from "@/lib/api";
import { Field } from "./TestcasePanel";

export type ResultState = RunResult & { kind: "run" | "submit" };

const show = (v: unknown) => JSON.stringify(v);

function verdict(r: ResultState) {
  if (r.status === "timeout") return "Time Limit Exceeded";
  if (r.status === "error") return r.kind === "submit" ? "Runtime Error" : "Error";
  if (r.kind === "submit") return r.passed ? "Accepted" : "Wrong Answer";
  return r.passed ? "All tests passed" : "Tests failing";
}

export default function ResultsPanel({ result, pending, params, onDebug }: {
  result: ResultState | null;
  pending: "run" | "submit" | null;
  params: string[];
  /** Debug a failing case: "case-<index>" for visible tests, "hidden" for the revealed hidden one. */
  onDebug: (caseKey: string) => void;
}) {
  if (pending) {
    return (
      <div className="flex h-full items-center justify-center gap-3 text-sm text-zinc-400">
        <span className="h-4 w-4 animate-spin rounded-full border-2 border-line-strong border-t-accent" />
        {pending === "submit" ? "Submitting against all tests…" : "Running all tests…"}
      </div>
    );
  }
  if (!result) {
    return (
      <div className="flex h-full flex-col items-center justify-center px-6 text-center text-sm text-zinc-500">
        <p>Run your code to see results here.</p>
        <p className="mt-1 text-xs text-zinc-600">
          <kbd className="rounded border border-line px-1 font-mono">Ctrl</kbd> + <kbd className="rounded border border-line px-1 font-mono">&apos;</kbd> run ·{" "}
          <kbd className="rounded border border-line px-1 font-mono">Ctrl</kbd> + <kbd className="rounded border border-line px-1 font-mono">Enter</kbd> submit
        </p>
      </div>
    );
  }

  const ok = result.passed;
  const pct = result.totalCount ? (result.passedCount / result.totalCount) * 100 : 0;

  return (
    <div className="h-full overflow-auto px-4 py-4">
      <div className="flex flex-wrap items-baseline gap-x-3 gap-y-1">
        <h3 className={`text-lg font-semibold ${ok ? "text-easy" : "text-red-400"}`}>{verdict(result)}</h3>
        <span className="text-sm tabular-nums text-zinc-400">
          {result.passedCount} / {result.totalCount} tests passed
        </span>
      </div>
      <div className="mt-2 h-1.5 overflow-hidden rounded-full bg-red-500/25">
        <div className="h-full rounded-full bg-easy transition-[width] duration-500" style={{ width: `${pct}%` }} />
      </div>

      {result.error && (
        <pre className="mt-4 whitespace-pre-wrap rounded-md border border-red-900/60 bg-red-950/30 p-3 font-mono text-xs text-red-300">
          {result.error}
        </pre>
      )}

      <ul className="mt-4 space-y-3">
        {result.visibleResults.map((r, i) => (
          <TestCard key={i} title={`Case ${i + 1}`} result={r} params={params} onDebug={() => onDebug(`case-${i}`)} />
        ))}
        {result.hiddenFailure && (
          <TestCard
            title={`Hidden test #${result.hiddenFailure.testNumber}`}
            result={result.hiddenFailure}
            params={params}
            onDebug={() => onDebug("hidden")}
          />
        )}
      </ul>
      {result.hiddenFailureCount > 1 && (
        <p className="mt-3 text-xs text-red-400">
          +{result.hiddenFailureCount - 1} more hidden test{result.hiddenFailureCount > 2 ? "s" : ""} failing
        </p>
      )}
    </div>
  );
}

function TestCard({ title, result: r, params, onDebug }: {
  title: string;
  result: TestResult;
  params: string[];
  onDebug: () => void;
}) {
  const input = r.args.map((a, i) => `${params[i] ?? `arg${i + 1}`} = ${show(a)}`).join("\n");
  return (
    <li className={`rounded-lg border ${r.passed ? "border-line" : "border-red-900/50"} bg-surface-2/40`}>
      <div className="flex items-center gap-2 border-b border-line/70 px-3 py-2">
        <span
          className={`flex h-5 w-5 items-center justify-center rounded-full ${
            r.passed ? "bg-[#12281c] text-easy" : "bg-red-500/15 text-red-400"
          }`}
        >
          {r.passed ? <CheckIcon className="size-3" /> : <XIcon className="size-3" />}
        </span>
        <span className="text-sm font-medium text-zinc-200">{title}</span>
        {!r.passed && (
          <button
            type="button"
            onClick={onDebug}
            className="ml-auto flex items-center gap-1.5 rounded-md border border-accent/30 px-2 py-1 text-xs text-accent transition-colors hover:bg-accent/10"
          >
            <BugIcon className="size-3.5" />
            Debug this case
          </button>
        )}
      </div>
      <div className="grid gap-3 p-3 sm:grid-cols-3">
        <Field label="Input" value={input} />
        <Field label="Expected" value={show(r.expected)} />
        <Field label="Output" value={r.error ?? r.actual ?? "—"} tone={r.passed ? "pass" : "fail"} />
      </div>
    </li>
  );
}
