"use client";

import type { ComponentType, SVGProps } from "react";
import type { Debugger } from "@/hooks/useDebugger";
import {
  ContinueIcon,
  RestartIcon,
  ReverseContinueIcon,
  StepBackIcon,
  StepIntoIcon,
  StepOutIcon,
  StepOverIcon,
  StopIcon,
} from "@/components/ui/icons";

type Control = {
  label: string;
  shortcut?: string;
  icon: ComponentType<SVGProps<SVGSVGElement>>;
  onClick: () => void;
  disabled: boolean;
  className?: string;
};

const MAX_MARKERS = 300;

export default function DebugToolbar({ dbg }: { dbg: Debugger }) {
  const c = dbg.controls;
  if (!c || !dbg.step) return null;
  const last = dbg.steps.length - 1;
  const atStart = dbg.stepIndex === 0;
  const atEnd = dbg.stepIndex === last;

  const controls: Control[] = [
    { label: "Reverse continue", icon: ReverseContinueIcon, onClick: c.reverseContinue, disabled: atStart },
    { label: "Step back", shortcut: "Shift+F10", icon: StepBackIcon, onClick: c.stepBack, disabled: atStart },
    { label: "Continue", shortcut: "F5", icon: ContinueIcon, onClick: c.continue, disabled: atEnd, className: "text-accent" },
    { label: "Step over", shortcut: "F10", icon: StepOverIcon, onClick: c.stepOver, disabled: atEnd },
    { label: "Step into", shortcut: "F11", icon: StepIntoIcon, onClick: c.stepInto, disabled: atEnd },
    { label: "Step out", shortcut: "Shift+F11", icon: StepOutIcon, onClick: c.stepOut, disabled: atEnd },
    { label: "Restart", shortcut: "Ctrl+Shift+F5", icon: RestartIcon, onClick: c.restart, disabled: false },
  ];

  const markers = dbg.pauses.flatMap((p, i) => (p ? [i] : [])).slice(0, MAX_MARKERS);
  const status = describeStop(dbg);

  return (
    <div className="border-b border-line bg-[#111317]">
      <div className="flex h-10 items-center gap-1 px-2">
        <div role="toolbar" aria-label="Debugger controls" className="flex items-center gap-0.5 rounded-md border border-line bg-canvas-2 p-0.5">
          {controls.map(({ label, shortcut, icon: Icon, onClick, disabled, className = "" }) => (
            <button
              key={label}
              type="button"
              onClick={onClick}
              disabled={disabled}
              title={shortcut ? `${label} (${shortcut})` : label}
              aria-label={label}
              className={`flex h-7 w-7 items-center justify-center rounded text-zinc-300 transition-colors hover:bg-surface-2 hover:text-white disabled:pointer-events-none disabled:opacity-30 ${className}`}
            >
              <Icon className="size-4" />
            </button>
          ))}
          <button
            type="button"
            onClick={dbg.stop}
            title="Stop (Shift+F5)"
            aria-label="Stop debugging"
            className="flex h-7 w-7 items-center justify-center rounded text-red-400 transition-colors hover:bg-red-500/10"
          >
            <StopIcon className="size-4" />
          </button>
        </div>
        <p className={`ml-2 min-w-0 truncate text-xs ${status.className}`} title={status.text}>
          <span className="font-medium">{status.text}</span>
          <span className="text-zinc-500"> · line {dbg.step.line}</span>
        </p>
      </div>
      <div className="flex h-8 items-center gap-3 px-3">
        <div className="relative flex-1">
          <input
            type="range"
            min={0}
            max={last}
            value={dbg.stepIndex}
            onChange={(e) => c.goTo(Number(e.target.value))}
            aria-label="Execution timeline"
            className="relative z-10 block w-full cursor-pointer accent-[#f2b544]"
          />
          <div aria-hidden="true" className="pointer-events-none absolute inset-x-[7px] -bottom-1 h-1">
            {last > 0 &&
              markers.map((i) => (
                <span key={i} className="absolute h-1 w-0.5 rounded-full bg-red-500/80" style={{ left: `${(i / last) * 100}%` }} />
              ))}
          </div>
        </div>
        <span className="shrink-0 font-mono text-[11px] tabular-nums text-zinc-500">
          step {dbg.stepIndex + 1} / {dbg.steps.length}
        </span>
      </div>
      {dbg.trace?.truncated && (
        <p className="border-t border-line bg-amber-500/5 px-3 py-1.5 text-xs text-amber-300">
          Recording stopped after {dbg.steps.length} steps. The code may loop forever, or this input is too large to trace.
        </p>
      )}
    </div>
  );
}

function describeStop(dbg: Debugger): { text: string; className: string } {
  switch (dbg.reason) {
    case "exception":
      return { text: dbg.step?.exception ?? "Exception", className: "text-red-400" };
    case "breakpoint":
      return { text: "Paused on breakpoint", className: "text-zinc-200" };
    case "entry":
      return { text: "Paused on entry", className: "text-zinc-200" };
    case "finished":
      if (dbg.trace?.truncated) return { text: "End of recording", className: "text-amber-300" };
      return dbg.trace?.error
        ? { text: `Raised ${dbg.trace.error}`, className: "text-red-400" }
        : { text: `Finished · returned ${dbg.trace?.result ?? "None"}`, className: "text-easy" };
    default:
      return { text: "Paused", className: "text-zinc-200" };
  }
}
