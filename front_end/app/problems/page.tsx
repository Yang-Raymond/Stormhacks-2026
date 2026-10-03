"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { api, type Difficulty, type ProblemSummary } from "@/lib/api";

export default function ProblemsPage() {
  const router = useRouter();
  const [problems, setProblems] = useState<ProblemSummary[]>([]);
  const [difficulty, setDifficulty] = useState<Difficulty>("easy");
  const [generating, setGenerating] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    api<{ problems: ProblemSummary[] }>("/problems")
      .then((d) => setProblems(d.problems))
      .catch((e: Error) => setError(e.message));
  }, []);

  async function generate() {
    setGenerating(true);
    setError("");
    try {
      const { id } = await api<{ id: string }>("/problems/generate", { body: { difficulty } });
      router.push(`/problems/${id}`);
    } catch (e) {
      setError((e as Error).message);
      setGenerating(false);
    }
  }

  return (
    <div className="mx-auto max-w-3xl">
      <div className="mb-6 flex items-center gap-3">
        <h1 className="text-2xl font-bold">Problems</h1>
        <div className="ml-auto flex gap-2">
          <select value={difficulty} onChange={(e) => setDifficulty(e.target.value as Difficulty)}
            className="rounded border border-zinc-600 bg-zinc-800 p-2">
            <option value="easy">Easy</option>
            <option value="medium">Medium</option>
            <option value="hard">Hard</option>
          </select>
          <button onClick={generate} disabled={generating} className="rounded bg-blue-600 px-4 py-2 text-white disabled:opacity-50">
            {generating ? "Generating… (~30s)" : "Generate problem"}
          </button>
        </div>
      </div>
      {error && <p role="alert" className="mb-4 text-red-400">{error}</p>}
      <table className="w-full text-left">
        <thead className="text-zinc-400">
          <tr><th className="p-2">Title</th><th className="p-2">Difficulty</th><th className="p-2">Solved</th></tr>
        </thead>
        <tbody>
          {problems.map((p) => (
            <tr key={p.id} className="border-t border-zinc-700">
              <td className="p-2"><Link href={`/problems/${p.id}`} className="text-blue-400 hover:underline">{p.title}</Link></td>
              <td className="p-2 capitalize">{p.difficulty}</td>
              <td className="p-2">{p.solved ? "✓" : ""}</td>
            </tr>
          ))}
          {problems.length === 0 && (
            <tr><td colSpan={3} className="p-2 text-zinc-500">No problems yet — generate one.</td></tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
