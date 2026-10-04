"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { api, type EvalResult, type EvalValue, type TraceResult } from "@/lib/api";
import {
  conditionsOf,
  navigate,
  pausePoints,
  stopReason,
  type Breakpoint,
  type Breakpoints,
} from "@/lib/debugger";

type Condition = { line: number; expr: string };
type Session = { trace: TraceResult; code: string; args: unknown[]; conditions: Condition[]; conditionsKey: string };
export type ConsoleEntry = { kind: "input" | "value" | "error" | "info"; text: string };

const WATCH_DEBOUNCE_MS = 200;
const storageKey = (problemId: string) => `ladybug:breakpoints:${problemId}`;

function loadBreakpoints(problemId: string): Breakpoints {
  if (typeof window === "undefined") return {};
  try {
    const raw = window.localStorage.getItem(storageKey(problemId));
    return raw ? (JSON.parse(raw) as Breakpoints) : {};
  } catch {
    return {};
  }
}

function failureMessage(r: { status: string; error?: string }) {
  return r.status === "timeout" ? "Timed out: the code ran for too long without executing a line." : r.error;
}

export function useDebugger(problemId: string) {
  const [session, setSession] = useState<Session | null>(null);
  const [stepIndex, setStepIndex] = useState(0);
  const [frameIndex, setFrameIndex] = useState(0);
  const [isStart, setIsStart] = useState(true);
  const [starting, setStarting] = useState(false);
  const [error, setError] = useState("");
  const [breakpoints, setBreakpoints] = useState<Breakpoints>(() => loadBreakpoints(problemId));
  const [pauseOnExceptions, setPauseOnExceptions] = useState(true);
  const [watches, setWatches] = useState<string[]>([]);
  const [watchValues, setWatchValues] = useState<Record<string, EvalValue>>({});
  const [consoleEntries, setConsoleEntries] = useState<ConsoleEntry[]>([]);
  const evalSeq = useRef(0);

  useEffect(() => {
    try {
      window.localStorage.setItem(storageKey(problemId), JSON.stringify(breakpoints));
    } catch {
      // Storage unavailable (private mode etc.): breakpoints just won't survive a reload.
    }
  }, [problemId, breakpoints]);

  const conditions = useMemo(() => conditionsOf(breakpoints), [breakpoints]);
  const conditionsKey = JSON.stringify(conditions);
  const steps = useMemo(() => session?.trace.steps ?? [], [session]);
  const pauses = useMemo(() => pausePoints(steps, breakpoints, pauseOnExceptions), [steps, breakpoints, pauseOnExceptions]);

  const fetchTrace = useCallback(
    (code: string, args: unknown[], conds: Condition[]) =>
      api<TraceResult>(`/problems/${problemId}/debug`, { body: { code, args, conditions: conds } }),
    [problemId],
  );

  async function start(code: string, args: unknown[], label: string) {
    setStarting(true);
    setError("");
    try {
      const trace = await fetchTrace(code, args, conditions);
      if (!trace.steps.length) {
        setSession(null);
        setError(failureMessage(trace) ?? "The function returned without executing any lines.");
        return;
      }
      setSession({ trace, code, args, conditions, conditionsKey });
      setStepIndex(navigate.start(trace.steps, pausePoints(trace.steps, breakpoints, pauseOnExceptions)));
      setFrameIndex(0);
      setIsStart(true);
      setWatchValues({});
      setConsoleEntries([{ kind: "info", text: `Debugging ${label}` }]);
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setStarting(false);
    }
  }

  function stop() {
    setSession(null);
    setWatchValues({});
  }

  // Conditions are evaluated in the runner, so editing one mid-session re-records the same run.
  useEffect(() => {
    if (!session || session.conditionsKey === conditionsKey) return;
    let cancelled = false;
    fetchTrace(session.code, session.args, conditions)
      .then((trace) => {
        if (cancelled || !trace.steps.length) return;
        setSession((s) => s && { ...s, trace, conditions, conditionsKey });
        setStepIndex((i) => Math.min(i, trace.steps.length - 1));
      })
      .catch((e: Error) => !cancelled && setError(e.message));
    return () => {
      cancelled = true;
    };
  }, [session, conditions, conditionsKey, fetchTrace]);

  const evaluate = useCallback(
    async (expressions: string[]): Promise<EvalValue[]> => {
      if (!session) return [];
      const r = await api<EvalResult>(`/problems/${problemId}/debug/eval`, {
        body: {
          code: session.code,
          args: session.args,
          conditions: session.conditions,
          step: stepIndex,
          frame: frameIndex,
          expressions,
        },
      });
      if (r.values) return r.values;
      const message = failureMessage(r) ?? "Evaluation failed";
      return expressions.map(() => ({ error: message }));
    },
    [problemId, session, stepIndex, frameIndex],
  );

  useEffect(() => {
    if (!session || !watches.length) return;
    const id = ++evalSeq.current;
    const timer = setTimeout(() => {
      evaluate(watches)
        .catch((e: Error) => watches.map(() => ({ error: e.message })))
        .then((values) => {
          if (evalSeq.current === id) setWatchValues(Object.fromEntries(watches.map((w, i) => [w, values[i]])));
        });
    }, WATCH_DEBOUNCE_MS);
    return () => clearTimeout(timer);
  }, [session, watches, evaluate]);

  async function runInConsole(expression: string) {
    setConsoleEntries((c) => [...c, { kind: "input", text: expression }]);
    const [result] = await evaluate([expression]).catch((e: Error) => [{ error: e.message }]);
    setConsoleEntries((c) => [
      ...c,
      result && "value" in result ? { kind: "value", text: result.value } : { kind: "error", text: result?.error ?? "No result" },
    ]);
  }

  function goTo(index: number) {
    setStepIndex(Math.max(0, Math.min(index, steps.length - 1)));
    setFrameIndex(0);
    setIsStart(false);
  }

  const controls = session
    ? {
        continue: () => goTo(navigate.continue(steps, stepIndex, pauses)),
        reverseContinue: () => goTo(navigate.reverseContinue(steps, stepIndex, pauses)),
        stepOver: () => goTo(navigate.stepOver(steps, stepIndex, pauses)),
        stepInto: () => goTo(navigate.stepInto(steps, stepIndex)),
        stepOut: () => goTo(navigate.stepOut(steps, stepIndex, pauses)),
        stepBack: () => goTo(navigate.stepBack(steps, stepIndex)),
        restart: () => {
          setStepIndex(navigate.start(steps, pauses));
          setFrameIndex(0);
          setIsStart(true);
        },
        goTo,
      }
    : null;

  const breakpointOps = {
    toggle: (line: number) =>
      setBreakpoints(({ [line]: existing, ...rest }) => (existing ? rest : { ...rest, [line]: { line, enabled: true } })),
    update: (line: number, patch: Partial<Omit<Breakpoint, "line">>) =>
      setBreakpoints((b) => ({ ...b, [line]: { ...(b[line] ?? { line, enabled: true }), ...patch, line } })),
    remove: (line: number) =>
      setBreakpoints((b) => Object.fromEntries(Object.entries(b).filter(([l]) => Number(l) !== line))),
    clear: () => setBreakpoints({}),
    setAllEnabled: (enabled: boolean) =>
      setBreakpoints((b) => Object.fromEntries(Object.values(b).map((bp) => [bp.line, { ...bp, enabled }]))),
    /** Called when edits shift lines; later entries win if two breakpoints collapse onto one line. */
    move: (moves: [from: number, to: number][]) =>
      setBreakpoints((b) => {
        const next: Breakpoints = {};
        for (const [from, to] of moves) if (b[from]) next[to] = { ...b[from], line: to };
        return next;
      }),
  };

  const step = session ? steps[stepIndex] : undefined;
  return {
    active: session !== null,
    starting,
    error,
    clearError: () => setError(""),
    trace: session?.trace,
    args: session?.args,
    steps,
    pauses,
    stepIndex,
    step,
    frameIndex,
    selectFrame: setFrameIndex,
    reason: session ? stopReason(steps, stepIndex, pauses, isStart) : undefined,
    stdout: session && step ? (session.trace.stdout ?? "").slice(0, step.out) : "",
    start,
    stop,
    controls,
    breakpoints,
    breakpointOps,
    pauseOnExceptions,
    setPauseOnExceptions,
    watches,
    watchValues,
    addWatch: (expr: string) => setWatches((w) => (w.includes(expr) ? w : [...w, expr])),
    removeWatch: (expr: string) => setWatches((w) => w.filter((x) => x !== expr)),
    consoleEntries,
    runInConsole,
    clearConsole: () => setConsoleEntries([]),
  };
}

export type Debugger = ReturnType<typeof useDebugger>;
