import { config } from "./config.js";
import { HttpError } from "./errors.js";
import type { Language, Signature } from "./languages.js";

export type TestCase = { args: unknown[]; expected: unknown };
export type TestResult = { passed: boolean; actual?: string; error?: string };
export type RunResult = {
  status: "ok" | "error" | "timeout";
  error?: string;
  results: TestResult[];
};

export type TraceFrame = { name: string; line: number; locals: Record<string, string> };
export type TraceStep = {
  line: number;
  event: "line" | "return" | "exception";
  depth: number;
  /** Length of captured stdout at this step. */
  out: number;
  frames: TraceFrame[];
  value?: string;
  exception?: string;
  cond?: boolean;
  condError?: string;
};
export type TraceResult = {
  status: "ok" | "error" | "timeout";
  steps: TraceStep[];
  stdout?: string;
  result?: string;
  /** Compile error or uncaught exception raised by the solution. */
  error?: string;
  truncated?: boolean;
};
export type EvalResult = {
  status: "ok" | "error" | "timeout";
  values?: ({ value: string } | { error: string })[];
  error?: string;
};
export type BreakpointCondition = { line: number; expr: string };

async function callRunner<T>(path: string, body: unknown, timeoutMs = 15_000): Promise<T> {
  let res: Response;
  try {
    res = await fetch(new URL(path, config.RUNNER_URL), {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify(body),
      signal: AbortSignal.timeout(timeoutMs),
    });
  } catch (err) {
    console.error("runner unreachable", err);
    throw new HttpError(503, "Code runner is unavailable");
  }
  if (!res.ok) throw new HttpError(502, `Code runner rejected the request (${res.status})`);
  return (await res.json()) as T;
}

/**
 * Executes code against test cases in the sandboxed runner service. Statically typed languages need the
 * signature so the runner can turn JSON arguments into native values.
 */
export function runTests(
  code: string,
  entryPoint: string,
  tests: TestCase[],
  language: Language = "python",
  signature?: Signature | null,
): Promise<RunResult> {
  return callRunner("/run", { code, entry_point: entryPoint, tests, language, signature: signature ?? undefined });
}

/** Compiling with debug info and stepping under gdb/JDI takes longer than a test run. */
const TRACE_TIMEOUT_MS = 30_000;

/** Records every executed line of one call so the client can step through it like a debugger. */
export function traceCode(
  code: string,
  entryPoint: string,
  args: unknown[],
  conditions: BreakpointCondition[] = [],
  language: Language = "python",
  signature?: Signature | null,
): Promise<TraceResult> {
  return callRunner(
    "/trace",
    { code, entry_point: entryPoint, args, conditions, language, signature: signature ?? undefined },
    TRACE_TIMEOUT_MS,
  );
}

/** Replays the same call up to `step` and evaluates expressions in the given stack frame (0 = innermost). */
export function evalAtStep(
  code: string,
  entryPoint: string,
  args: unknown[],
  at: { step: number; frame: number; expressions: string[]; conditions?: BreakpointCondition[] },
  language: Language = "python",
  signature?: Signature | null,
): Promise<EvalResult> {
  const { conditions = [], ...evalSpec } = at;
  return callRunner("/trace", {
    code,
    entry_point: entryPoint,
    args,
    conditions,
    eval: evalSpec,
    language,
    signature: signature ?? undefined,
  }, TRACE_TIMEOUT_MS);
}

export function allPassed(run: RunResult, total: number) {
  return run.status === "ok" && run.results.length === total && run.results.every((r) => r.passed);
}
