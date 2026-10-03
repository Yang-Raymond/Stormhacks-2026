export type User = { id: string; email: string };
export type Difficulty = "easy" | "medium" | "hard";
export type ProblemSummary = { id: string; title: string; difficulty: Difficulty; solved: boolean };
export type TestCase = { args: unknown[]; expected: unknown };
export type Problem = {
  id: string;
  title: string;
  description: string;
  difficulty: Difficulty;
  entryPoint: string;
  buggyCode: string;
  examples: TestCase[];
  totalTests: number;
};
export type RunResult = {
  status: "ok" | "error" | "timeout";
  error?: string;
  passedCount: number;
  totalCount: number;
  visibleResults: (TestCase & { passed: boolean; actual?: string; error?: string })[];
  passed?: boolean;
};

export async function api<T>(path: string, options: { method?: string; body?: unknown } = {}): Promise<T> {
  const res = await fetch(`/api${path}`, {
    method: options.method ?? (options.body ? "POST" : "GET"),
    headers: options.body ? { "content-type": "application/json" } : undefined,
    body: options.body ? JSON.stringify(options.body) : undefined,
  });
  if (res.status === 204) return undefined as T;
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.error ?? `Request failed (${res.status})`);
  return data as T;
}
