import { config } from "./config.js";
import { HttpError } from "./errors.js";

export type TestCase = { args: unknown[]; expected: unknown };
export type TestResult = { passed: boolean; actual?: string; error?: string };
export type RunResult = {
  status: "ok" | "error" | "timeout";
  error?: string;
  results: TestResult[];
};

/** Executes Python code against test cases in the sandboxed runner service. */
export async function runTests(code: string, entryPoint: string, tests: TestCase[]): Promise<RunResult> {
  let res: Response;
  try {
    res = await fetch(new URL("/run", config.RUNNER_URL), {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ code, entry_point: entryPoint, tests }),
      signal: AbortSignal.timeout(15_000),
    });
  } catch (err) {
    console.error("runner unreachable", err);
    throw new HttpError(503, "Code runner is unavailable");
  }
  if (!res.ok) throw new HttpError(502, `Code runner rejected the request (${res.status})`);
  return (await res.json()) as RunResult;
}

export function allPassed(run: RunResult, total: number) {
  return run.status === "ok" && run.results.length === total && run.results.every((r) => r.passed);
}
