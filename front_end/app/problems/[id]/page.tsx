"use client";

import { useParams } from "next/navigation";
import { useEffect, useState } from "react";
import CodeEditor from "@/components/CodeEditor";
import { api, type Problem, type RunResult } from "@/lib/api";

const show = (v: unknown) => JSON.stringify(v);

export default function ProblemPage() {
  const { id } = useParams<{ id: string }>();
  const [problem, setProblem] = useState<Problem | null>(null);
  const [code, setCode] = useState("");
  const [result, setResult] = useState<(RunResult & { kind: "run" | "submit" }) | null>(null);
  const [pending, setPending] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    api<{ problem: Problem }>(`/problems/${id}`)
      .then(({ problem }) => {
        setProblem(problem);
        setCode(problem.buggyCode);
      })
      .catch((e: Error) => setError(e.message));
  }, [id]);

  async function execute(kind: "run" | "submit") {
    setPending(true);
    setError("");
    try {
      const r = await api<RunResult>(`/problems/${id}/${kind}`, { body: { code } });
      setResult({ ...r, kind });
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setPending(false);
    }
  }

  if (!problem) return <p className={error ? "text-red-400" : ""}>{error || "Loading…"}</p>;

  return (
    <div className="grid gap-6 lg:grid-cols-2">
      <section>
        <h1 className="text-2xl font-bold">{problem.title}</h1>
        <p className="mb-4 capitalize text-zinc-400">{problem.difficulty} · {problem.totalTests} tests</p>
        <div className="whitespace-pre-wrap">{problem.description}</div>
        <h2 className="mt-6 font-bold">Examples</h2>
        <ul className="font-mono text-sm">
          {problem.examples.map((t, i) => (
            <li key={i}>{problem.entryPoint}({t.args.map(show).join(", ")}) → {show(t.expected)}</li>
          ))}
        </ul>
      </section>

      <section className="flex flex-col gap-3">
        <CodeEditor value={code} onChange={setCode} />
        <div className="flex gap-2">
          <button onClick={() => setCode(problem.buggyCode)} disabled={pending} className="rounded border border-zinc-600 px-4 py-2">Reset</button>
          <button onClick={() => execute("run")} disabled={pending} className="ml-auto rounded bg-zinc-700 px-4 py-2 disabled:opacity-50">Run</button>
          <button onClick={() => execute("submit")} disabled={pending} className="rounded bg-green-600 px-4 py-2 text-white disabled:opacity-50">Submit</button>
        </div>
        {error && <p role="alert" className="text-red-400">{error}</p>}
        {pending && <p>Running…</p>}
        {result && !pending && (
          <div className="rounded border border-zinc-700 p-3">
            {result.kind === "submit" && (
              <p className={`text-lg font-bold ${result.passed ? "text-green-400" : "text-red-400"}`}>
                {result.passed ? "Accepted" : "Wrong answer"}
              </p>
            )}
            <p>{result.status === "timeout" ? "Time limit exceeded" : `${result.passedCount}/${result.totalCount} tests passed`}</p>
            {result.error && <pre className="mt-2 whitespace-pre-wrap text-sm text-red-400">{result.error}</pre>}
            <ul className="mt-2 font-mono text-sm">
              {result.visibleResults.map((r, i) => (
                <li key={i} className={r.passed ? "text-green-400" : "text-red-400"}>
                  {r.passed ? "✓" : "✗"} {problem.entryPoint}({r.args.map(show).join(", ")}) expected {show(r.expected)}, got {r.error ?? r.actual}
                </li>
              ))}
            </ul>
          </div>
        )}
      </section>
    </div>
  );
}
