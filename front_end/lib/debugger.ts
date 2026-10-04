/**
 * Navigation over a recorded execution trace. The runner records every step up front, so "running" the
 * debugger is just moving an index: forwards like a normal debugger, or backwards (time travel).
 */
import type { TraceStep } from "./api";

export type Breakpoint = {
  line: number;
  enabled: boolean;
  /** Python expression; the breakpoint only pauses when it is truthy. */
  condition?: string;
  /** Only pause from the Nth time this line is hit. */
  hitCount?: number;
};
export type Breakpoints = Record<number, Breakpoint>;

export type StopReason = "entry" | "step" | "breakpoint" | "exception" | "finished";

/** Conditions are evaluated by the runner, so a change in them means the trace must be re-recorded. */
export function conditionsOf(breakpoints: Breakpoints) {
  return Object.values(breakpoints)
    .filter((b) => b.enabled && b.condition?.trim())
    .map((b) => ({ line: b.line, expr: b.condition!.trim() }))
    .sort((a, b) => a.line - b.line);
}

/** For each step, whether execution should pause there when continuing. */
export function pausePoints(steps: TraceStep[], breakpoints: Breakpoints, pauseOnExceptions: boolean): boolean[] {
  const hits = new Map<number, number>();
  return steps.map((step) => {
    if (step.event === "exception") return pauseOnExceptions;
    if (step.event !== "line") return false;
    const bp = breakpoints[step.line];
    if (!bp?.enabled) return false;
    // `cond` is only absent if the trace was recorded before this condition existed; treat it as a hit.
    if (bp.condition?.trim() && step.cond === false) return false;
    const n = (hits.get(step.line) ?? 0) + 1;
    hits.set(step.line, n);
    return !bp.hitCount || n >= bp.hitCount;
  });
}

function findForward(from: number, steps: TraceStep[], match: (s: TraceStep, i: number) => boolean) {
  for (let i = from + 1; i < steps.length; i++) if (match(steps[i], i)) return i;
  return steps.length - 1;
}

function findBackward(from: number, steps: TraceStep[], match: (s: TraceStep, i: number) => boolean) {
  for (let i = from - 1; i >= 0; i--) if (match(steps[i], i)) return i;
  return 0;
}

export const navigate = {
  /** Run to the first pause point; with none, stop at the first line so there's something to look at. */
  start: (steps: TraceStep[], pauses: boolean[]) => {
    const i = pauses.indexOf(true);
    return i === -1 ? 0 : i;
  },
  continue: (steps: TraceStep[], cur: number, pauses: boolean[]) => findForward(cur, steps, (_, i) => pauses[i]),
  reverseContinue: (steps: TraceStep[], cur: number, pauses: boolean[]) =>
    findBackward(cur, steps, (_, i) => pauses[i]),
  stepInto: (steps: TraceStep[], cur: number) => Math.min(cur + 1, steps.length - 1),
  stepBack: (_steps: TraceStep[], cur: number) => Math.max(cur - 1, 0),
  /** Next step in this frame or its caller; breakpoints inside the skipped call still pause, as in VS Code. */
  stepOver: (steps: TraceStep[], cur: number, pauses: boolean[]) =>
    findForward(cur, steps, (s, i) => s.depth <= steps[cur].depth || pauses[i]),
  stepOut: (steps: TraceStep[], cur: number, pauses: boolean[]) =>
    findForward(cur, steps, (s, i) => s.depth < steps[cur].depth || pauses[i]),
};

export function stopReason(steps: TraceStep[], index: number, pauses: boolean[], isStart: boolean): StopReason {
  const step = steps[index];
  if (step.event === "exception") return "exception";
  if (index === steps.length - 1) return "finished";
  if (pauses[index]) return "breakpoint";
  return isStart ? "entry" : "step";
}

/** Locals whose value differs from the previous step in the same frame, for highlighting. */
export function changedLocals(steps: TraceStep[], index: number, frameIndex: number): Set<string> {
  const changed = new Set<string>();
  const step = steps[index];
  const prev = steps[index - 1];
  const frame = step?.frames[frameIndex];
  if (!frame || !prev) return changed;
  // Match the same frame in the previous step by its distance from the bottom of the stack.
  const fromBottom = step.frames.length - 1 - frameIndex;
  const prevFrame = prev.frames[prev.frames.length - 1 - fromBottom];
  if (!prevFrame || prevFrame.name !== frame.name) return changed;
  for (const [name, value] of Object.entries(frame.locals)) {
    if (prevFrame.locals[name] !== value) changed.add(name);
  }
  return changed;
}

const IDENTIFIER = /[A-Za-z_][A-Za-z0-9_]*/g;
const MAX_INLINE_PER_LINE = 4;
const MAX_INLINE_VALUE = 40;

/**
 * Values to show at the end of lines already executed in the current call, like VS Code's inline values:
 * for each such line, the current value of every local it mentions.
 */
export function inlineValues(steps: TraceStep[], index: number, lineText: (line: number) => string) {
  const step = steps[index];
  const frame = step?.frames[0];
  if (!frame) return [];
  const lines = new Set<number>();
  for (let i = index; i >= 0; i--) {
    const s = steps[i];
    if (s.depth < step.depth) break; // reached the caller: this call started after here
    if (s.depth === step.depth && s.frames[0]?.name === frame.name) lines.add(s.line);
  }
  return [...lines].flatMap((line) => {
    const names = [...new Set(lineText(line).replace(/#.*/, "").match(IDENTIFIER) ?? [])].filter(
      (n) => n in frame.locals,
    );
    if (!names.length) return [];
    const text = names
      .slice(0, MAX_INLINE_PER_LINE)
      .map((n) => {
        const v = frame.locals[n];
        return `${n} = ${v.length > MAX_INLINE_VALUE ? v.slice(0, MAX_INLINE_VALUE) + "…" : v}`;
      })
      .join(", ");
    return [{ line, text }];
  });
}
