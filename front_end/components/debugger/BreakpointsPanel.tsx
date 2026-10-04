"use client";

import { useState } from "react";
import type { Debugger } from "@/hooks/useDebugger";
import { XIcon } from "@/components/ui/icons";
import type { Breakpoint } from "@/lib/debugger";
import { Empty, IconButton, Section } from "./shared";

export default function BreakpointsPanel({ dbg, lineText }: { dbg: Debugger; lineText: (line: number) => string }) {
  const list = Object.values(dbg.breakpoints).sort((a, b) => a.line - b.line);
  const allEnabled = list.every((b) => b.enabled);

  return (
    <Section
      title="Breakpoints"
      actions={
        list.length > 0 && (
          <>
            <button
              type="button"
              onClick={() => dbg.breakpointOps.setAllEnabled(!allEnabled)}
              className="rounded px-1.5 py-0.5 text-[11px] text-zinc-500 hover:bg-surface-2 hover:text-zinc-200"
            >
              {allEnabled ? "Disable all" : "Enable all"}
            </button>
            <IconButton label="Remove all breakpoints" onClick={dbg.breakpointOps.clear} className="h-6 w-6">
              <XIcon className="size-3.5" />
            </IconButton>
          </>
        )
      }
    >
      <label className="flex cursor-pointer items-center gap-2 px-3 py-1.5 text-xs text-zinc-300">
        <input
          type="checkbox"
          checked={dbg.pauseOnExceptions}
          onChange={(e) => dbg.setPauseOnExceptions(e.target.checked)}
          className="accent-[#f2b544]"
        />
        Pause on exceptions
      </label>
      {list.length === 0 ? (
        <Empty>Click in the gutter left of a line number to add one. Right-click to add a condition, or press F9.</Empty>
      ) : (
        <ul className="pb-1 text-xs">
          {list.map((bp) => (
            // Keyed on the condition too, so an edit made from the editor resets the inline input.
            <BreakpointRow key={`${bp.line}:${bp.condition ?? ""}:${bp.hitCount ?? ""}`} bp={bp} dbg={dbg} code={lineText(bp.line)} />
          ))}
        </ul>
      )}
    </Section>
  );
}

function BreakpointRow({ bp, dbg, code }: { bp: Breakpoint; dbg: Debugger; code: string }) {
  const [condition, setCondition] = useState(bp.condition ?? "");
  const [hits, setHits] = useState(bp.hitCount ? String(bp.hitCount) : "");
  const { update, remove } = dbg.breakpointOps;

  const commitCondition = () => {
    if (condition.trim() !== (bp.condition ?? "")) update(bp.line, { condition: condition.trim() || undefined });
  };
  const commitHits = () => {
    const n = Number.parseInt(hits, 10);
    const hitCount = Number.isFinite(n) && n > 1 ? n : undefined;
    if (hitCount !== bp.hitCount) update(bp.line, { hitCount });
  };

  return (
    <li className="group border-t border-line/60 px-3 py-1.5 first:border-t-0">
      <div className="flex items-center gap-2">
        <input
          type="checkbox"
          checked={bp.enabled}
          onChange={(e) => update(bp.line, { enabled: e.target.checked })}
          aria-label={`Enable breakpoint on line ${bp.line}`}
          className="accent-red-500"
        />
        <span className="shrink-0 font-mono text-zinc-300">Line {bp.line}</span>
        <code className="min-w-0 flex-1 truncate font-mono text-zinc-500">{code.trim()}</code>
        <button
          type="button"
          onClick={() => remove(bp.line)}
          aria-label={`Remove breakpoint on line ${bp.line}`}
          className="text-zinc-600 opacity-0 transition-opacity hover:text-zinc-200 focus:opacity-100 group-hover:opacity-100"
        >
          <XIcon className="size-3.5" />
        </button>
      </div>
      <div className="mt-1 flex gap-2 pl-5">
        <input
          value={condition}
          onChange={(e) => setCondition(e.target.value)}
          onBlur={commitCondition}
          onKeyDown={(e) => e.key === "Enter" && e.currentTarget.blur()}
          placeholder="condition, e.g. i > 2"
          aria-label={`Condition for line ${bp.line}`}
          maxLength={200}
          className="min-w-0 flex-1 rounded border border-line bg-canvas-2 px-1.5 py-0.5 font-mono text-[11px] text-zinc-200 placeholder:text-zinc-600 focus:border-accent/50 focus:outline-none"
        />
        <input
          value={hits}
          onChange={(e) => setHits(e.target.value.replace(/\D/g, ""))}
          onBlur={commitHits}
          onKeyDown={(e) => e.key === "Enter" && e.currentTarget.blur()}
          placeholder="hit #"
          inputMode="numeric"
          title="Only pause from the Nth hit"
          aria-label={`Hit count for line ${bp.line}`}
          className="w-14 rounded border border-line bg-canvas-2 px-1.5 py-0.5 font-mono text-[11px] text-zinc-200 placeholder:text-zinc-600 focus:border-accent/50 focus:outline-none"
        />
      </div>
      {dbg.step?.line === bp.line && dbg.step.condError && (
        <p className="mt-1 pl-5 font-mono text-[11px] text-red-400">{dbg.step.condError}</p>
      )}
    </li>
  );
}
