"use client";

import { type FormEvent, type KeyboardEvent, useEffect, useRef, useState } from "react";
import type { Debugger } from "@/hooks/useDebugger";
import { IconButton, Section, ValueText } from "./shared";
import { XIcon } from "@/components/ui/icons";

export default function DebugConsole({ dbg }: { dbg: Debugger }) {
  const [draft, setDraft] = useState("");
  const [history, setHistory] = useState<string[]>([]);
  const [historyIndex, setHistoryIndex] = useState(-1);
  const [busy, setBusy] = useState(false);
  const bottom = useRef<HTMLDivElement>(null);

  useEffect(() => {
    bottom.current?.scrollIntoView({ block: "nearest" });
  }, [dbg.consoleEntries, dbg.stdout]);

  async function submit(e: FormEvent) {
    e.preventDefault();
    const expr = draft.trim();
    if (!expr || busy) return;
    setHistory((h) => [expr, ...h.filter((x) => x !== expr)].slice(0, 50));
    setHistoryIndex(-1);
    setDraft("");
    setBusy(true);
    await dbg.runInConsole(expr);
    setBusy(false);
  }

  function browseHistory(e: KeyboardEvent<HTMLInputElement>) {
    if (e.key !== "ArrowUp" && e.key !== "ArrowDown") return;
    e.preventDefault();
    const next = Math.max(-1, Math.min(history.length - 1, historyIndex + (e.key === "ArrowUp" ? 1 : -1)));
    setHistoryIndex(next);
    setDraft(next === -1 ? "" : history[next]);
  }

  return (
    <Section
      title="Debug console"
      actions={
        <IconButton label="Clear console" onClick={dbg.clearConsole} className="h-6 w-6">
          <XIcon className="size-3.5" />
        </IconButton>
      }
    >
      <div className="flex min-h-full flex-col font-mono text-xs">
        <div className="flex-1 px-3 py-2">
          {dbg.consoleEntries.map((entry, i) => (
            <div key={i} className="py-0.5">
              {entry.kind === "input" ? (
                <span className="text-zinc-400">
                  <span className="mr-2 text-accent-ink">›</span>
                  {entry.text}
                </span>
              ) : entry.kind === "value" ? (
                <span className="block pl-4"><ValueText value={entry.text} /></span>
              ) : entry.kind === "error" ? (
                <span className="block whitespace-pre-wrap pl-4 text-red-400">{entry.text}</span>
              ) : (
                <span className="text-zinc-500">{entry.text}</span>
              )}
            </div>
          ))}
          {dbg.stdout && (
            <div className="mt-1 border-l-2 border-line-strong pl-2">
              <p className="text-[10px] uppercase tracking-wider text-zinc-600">Program output so far</p>
              <pre className="whitespace-pre-wrap break-all text-zinc-300">{dbg.stdout}</pre>
            </div>
          )}
          <div ref={bottom} />
        </div>
        <form onSubmit={submit} className="sticky bottom-0 flex items-center gap-2 border-t border-line bg-surface px-3 py-1.5">
          <span className="text-accent-ink">›</span>
          <input
            value={draft}
            onChange={(e) => setDraft(e.target.value)}
            onKeyDown={browseHistory}
            disabled={!dbg.active}
            placeholder={dbg.active ? "Evaluate in the selected frame, e.g. arr[:i]" : "Start debugging to evaluate expressions"}
            aria-label="Debug console input"
            maxLength={200}
            className="flex-1 bg-transparent text-zinc-100 placeholder:text-zinc-600 focus:outline-none disabled:cursor-not-allowed"
          />
          {busy && <span className="h-1.5 w-1.5 animate-pulse rounded-full bg-accent" />}
        </form>
      </div>
    </Section>
  );
}
