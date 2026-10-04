import Link from "next/link";

export default function Home() {
  return (
    <div className="mx-auto mt-16 max-w-xl text-center px-4">
      <h1 className="text-3xl font-bold flex items-center justify-center gap-3">
        <span className="inline-flex items-center justify-center w-9 h-9 rounded-lg bg-[#f2b544] text-zinc-950 font-mono text-base font-bold">
          &gt;_
        </span>
        LadyBug
      </h1>
      <p className="mt-4 text-zinc-400">
        Debug AI-generated code with confidence. Find and fix bugs, run test suites, and review every diff you approve.
      </p>
      <div className="mt-6 flex justify-center gap-4">
        <Link href="/problems" className="rounded bg-[#f2b544] px-5 py-2.5 font-medium text-zinc-950 hover:bg-[#e5a83b] transition-colors">
          Browse problems
        </Link>
        <Link href="/login" className="rounded border border-zinc-700 bg-zinc-800/80 px-5 py-2.5 font-medium text-zinc-200 hover:bg-zinc-800 transition-colors">
          Log in
        </Link>
      </div>
    </div>
  );
}
