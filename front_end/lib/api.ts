export type User = {
  id: string;
  email: string;
  fullName?: string | null;
  role?: string | null;
  debugLanguages: string[];
  avatarUrl?: string | null;
  onboarded: boolean;
};

export type AuthMethod = "email" | "github" | "google";

export type MeResponse = {
  user: User | null;
  authMethod?: AuthMethod;
};

export type Difficulty = "easy" | "medium" | "hard";
export type ProblemSummary = {
  id: string;
  title: string;
  difficulty: Difficulty;
  language: string;
  solved: boolean;
  created_at: string;
};
export type TestCase = { args: unknown[]; expected: unknown };
export type Signature = { params: { name: string; type: string }[]; returns: string };
export type ChallengeKind = "daily" | "weekly";
export type Problem = {
  id: string;
  title: string;
  description: string;
  difficulty: Difficulty;
  entryPoint: string;
  buggyCode: string;
  examples: TestCase[];
  totalTests: number;
  solved: boolean;
  /** The user's saved work on this problem, if any. */
  savedCode: string | null;
  language: string;
  /** Typed parameters/return, present on problems generated with language support. */
  signature: Signature | null;
  challenge: { kind: ChallengeKind; endsAt: string } | null;
};

export type ChallengeSummary = {
  kind: ChallengeKind;
  periodStart: string;
  problemId: string;
  title: string;
  difficulty: Difficulty;
  language: string;
  solved: boolean;
};
export type ChallengeSlot = {
  kind: ChallengeKind;
  periodStart: string;
  endsAt: string;
  /** A generation for this slot is already running on the server. */
  starting: boolean;
  challenge: ChallengeSummary | null;
};
export type ChallengesResponse = { daily: ChallengeSlot; weekly: ChallengeSlot; history: ChallengeSummary[] };

export type TraceFrame = { name: string; line: number; locals: Record<string, string> };
export type TraceStep = {
  line: number;
  event: "line" | "return" | "exception";
  depth: number;
  /** Length of captured stdout at this step. */
  out: number;
  /** Innermost frame first. */
  frames: TraceFrame[];
  value?: string;
  exception?: string;
  /** Present when this line has a conditional breakpoint: whether the condition held. */
  cond?: boolean;
  condError?: string;
};
export type TraceResult = {
  status: "ok" | "error" | "timeout";
  steps: TraceStep[];
  stdout?: string;
  result?: string;
  error?: string;
  truncated?: boolean;
};
export type EvalValue = { value: string } | { error: string };
export type EvalResult = { status: "ok" | "error" | "timeout"; values?: EvalValue[]; error?: string };
export type TestResult = TestCase & { passed: boolean; actual?: string; error?: string };
export type RunResult = {
  status: "ok" | "error" | "timeout";
  error?: string;
  passed: boolean;
  passedCount: number;
  totalCount: number;
  visibleResults: TestResult[];
  /** First failing hidden test, revealed so there's something to debug. */
  hiddenFailure?: TestResult & { testNumber: number };
  hiddenFailureCount: number;
};

export class ApiError extends Error {
  constructor(
    message: string,
    public status: number,
    public issues?: Record<string, string[]>,
  ) {
    super(message);
    this.name = "ApiError";
  }
}

export async function api<T>(
  path: string,
  options: { method?: string; body?: unknown; keepalive?: boolean } = {},
): Promise<T> {
  const res = await fetch(`/api${path}`, {
    method: options.method ?? (options.body ? "POST" : "GET"),
    headers: options.body ? { "content-type": "application/json" } : undefined,
    body: options.body ? JSON.stringify(options.body) : undefined,
    // Lets a request finish while the page is being closed or navigated away from.
    keepalive: options.keepalive,
  });
  if (res.status === 204) return undefined as T;
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new ApiError(data.error ?? `Request failed (${res.status})`, res.status, data.issues);
  }
  return data as T;
}

export type ActivityDay = { date: string; total: number; accepted: number };
export type Activity = {
  streak: { current: number; longest: number };
  thisWeek: { runs: number; submits: number; accepted: number };
  allTime: { activeDays: number; accepted: number; hints: number };
  /** Consecutive UTC days, Monday-aligned, ending today. */
  days: ActivityDay[];
};

export type Features = { hints: boolean; insights: boolean };

type Rate = { submits: number; accepted: number };
export type Insights =
  | { configured: false }
  | {
      configured: true;
      generatedAt: string;
      model: string;
      totals: { events: number; users: number; submits: number; accepted: number; hints: number; debugs: number };
      byLanguage: (Rate & { language: string })[];
      byDifficulty: (Rate & { difficulty: string })[];
      hardest: (Rate & { problem_id: number; title: string; difficulty: string; language: string })[];
      byHour: { hour: number; events: number }[];
    };
