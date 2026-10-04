"use client";

import { type FormEvent, useState } from "react";
import type { Debugger } from "@/hooks/useDebugger";
import { XIcon } from "@/components/ui/icons";
import { Section, ValueText } from "./shared";

export default function WatchPanel({ dbg }: { dbg: Debugger }) {
  const [draft, setDraft] = useState("");

  function add(e: FormEvent) {
    e.preventDefault();
    const expr = draft.trim();
    if (!expr) return;
    dbg.addWatch(expr);
    setDraft("");
  }

  return (
    <Section title="Watch">
      <ul className="py-1 text-xs">
        {dbg.watches.map((w) => {
          const v = dbg.watchValues[w];
          return (
            <li key={w} className="group flex items-start gap-2 px-3 py-1">
              <span className="shrink-0 font-mono text-zinc-400">{w}</span>
              <span className="text-zinc-600">=</span>
              <span className="min-w-0 flex-1">
                {!v || !dbg.active ? (
                  <span className="text-zinc-600">—</span>
                ) : "value" in v ? (
                  <ValueText value={v.value} />
                ) : (
                  <span className="break-all font-mono text-red-400/90">{v.error}</span>
                )}
              </span>
              <button
                type="button"
                onClick={() => dbg.removeWatch(w)}
                aria-label={`Remove watch ${w}`}
                className="text-zinc-600 opacity-0 transition-opacity hover:text-zinc-200 focus:opacity-100 group-hover:opacity-100"
              >
                <XIcon className="size-3.5" />
              </button>
            </li>
          );
        })}
      </ul>
      <form onSubmit={add} className="px-3 pb-2">
        <input
          value={draft}
          onChange={(e) => setDraft(e.target.value)}
          placeholder="+ Add expression, e.g. arr[i]"
          aria-label="Add watch expression"
          maxLength={200}
          className="w-full rounded border border-transparent bg-transparent px-1.5 py-1 font-mono text-xs text-zinc-200 placeholder:text-zinc-600 hover:border-line focus:border-accent/50 focus:bg-canvas-2 focus:outline-none"
        />
      </form>
    </Section>
  );
}
