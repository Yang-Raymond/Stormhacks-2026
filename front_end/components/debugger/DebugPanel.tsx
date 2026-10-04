"use client";

import type { Debugger } from "@/hooks/useDebugger";
import { BugIcon } from "@/components/ui/icons";
import BreakpointsPanel from "./BreakpointsPanel";
import CallStackPanel from "./CallStackPanel";
import DebugConsole from "./DebugConsole";
import VariablesPanel from "./VariablesPanel";
import WatchPanel from "./WatchPanel";

const steps = [
  <>Click in the gutter left of a line number to set a <b className="text-red-400">breakpoint</b>. Right-click it to add a condition.</>,
  <>Choose the input to debug in the <b className="text-zinc-200">Test cases</b> tab, or write your own.</>,
  <>Press <b className="text-accent-ink">Debug</b> (F5), then step forwards <i>and backwards</i> through every line.</>,
];

export default function DebugPanel({ dbg, lineText, caseLabel, onStart }: {
  dbg: Debugger;
  lineText: (line: number) => string;
  caseLabel: string;
  onStart: () => void;
}) {
  if (!dbg.active) {
    return (
      <div className="grid h-full min-h-0 md:grid-cols-[1.2fr_1fr]">
        <div className="overflow-auto p-5">
          <div className="flex items-center gap-3">
            <span className="flex h-9 w-9 items-center justify-center rounded-lg border border-line-strong bg-surface-2 text-accent-ink">
              <BugIcon className="size-5" />
            </span>
            <div>
              <h3 className="font-semibold text-zinc-100">Time-travel debugger</h3>
              <p className="text-xs text-zinc-500">Every step of the run is recorded, so you can rewind as well as step.</p>
            </div>
          </div>
          <ol className="mt-4 space-y-2 text-sm text-zinc-400">
            {steps.map((s, i) => (
              <li key={i} className="flex gap-3">
                <span className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full border border-line-strong font-mono text-[11px] text-zinc-500">
                  {i + 1}
                </span>
                <span>{s}</span>
              </li>
            ))}
          </ol>
          {dbg.error && (
            <pre role="alert" className="mt-4 whitespace-pre-wrap rounded-md border border-red-900/60 bg-red-950/30 p-3 font-mono text-xs text-red-300">
              {dbg.error}
            </pre>
          )}
          <button
            type="button"
            onClick={onStart}
            disabled={dbg.starting}
            className="mt-5 flex items-center gap-2 rounded-md border border-accent/40 bg-accent/10 px-4 py-2 text-sm font-medium text-accent-ink transition-colors hover:bg-accent/20 disabled:opacity-60"
          >
            <BugIcon className="size-4" />
            {dbg.starting ? "Recording…" : `Debug ${caseLabel}`}
          </button>
        </div>
        <div className="min-h-0 border-t border-line md:border-l md:border-t-0">
          <BreakpointsPanel dbg={dbg} lineText={lineText} />
        </div>
      </div>
    );
  }

  return (
    <div className="grid h-full min-h-0 grid-cols-1 overflow-auto md:grid-cols-3 md:overflow-hidden">
      <div className="grid min-h-0 grid-rows-[minmax(0,3fr)_minmax(0,2fr)] border-line md:border-r">
        <VariablesPanel dbg={dbg} />
        <div className="min-h-0 border-t border-line">
          <WatchPanel dbg={dbg} />
        </div>
      </div>
      <div className="grid min-h-0 grid-rows-[minmax(0,2fr)_minmax(0,3fr)] border-line md:border-r">
        <CallStackPanel dbg={dbg} />
        <div className="min-h-0 border-t border-line">
          <BreakpointsPanel dbg={dbg} lineText={lineText} />
        </div>
      </div>
      <div className="min-h-64 md:min-h-0">
        <DebugConsole dbg={dbg} />
      </div>
    </div>
  );
}
