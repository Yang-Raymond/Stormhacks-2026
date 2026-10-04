"use client";

import type { Debugger } from "@/hooks/useDebugger";
import { Section } from "./shared";

export default function CallStackPanel({ dbg }: { dbg: Debugger }) {
  const frames = dbg.step?.frames ?? [];
  const hidden = (dbg.step?.depth ?? 0) - frames.length;

  return (
    <Section title="Call stack">
      <ol className="py-1 text-xs">
        {frames.map((f, i) => {
          const selected = i === dbg.frameIndex;
          return (
            <li key={i}>
              <button
                type="button"
                onClick={() => dbg.selectFrame(i)}
                aria-current={selected ? "true" : undefined}
                className={`flex w-full items-center gap-2 px-3 py-1 text-left font-mono transition-colors ${
                  selected ? "bg-surface-2 text-zinc-100" : "text-zinc-400 hover:bg-surface-2/60 hover:text-zinc-200"
                }`}
              >
                <span className={`w-2 shrink-0 ${i === 0 ? "text-accent-ink" : "text-easy"}`}>{selected ? "▸" : ""}</span>
                <span className="truncate">{f.name}</span>
                <span className="ml-auto shrink-0 text-zinc-500">line {f.line}</span>
              </button>
            </li>
          );
        })}
        {hidden > 0 && <li className="px-3 py-1 font-mono text-zinc-600">… {hidden} more frames</li>}
      </ol>
    </Section>
  );
}
