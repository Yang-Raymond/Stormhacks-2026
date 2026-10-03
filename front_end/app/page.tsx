import Link from "next/link";

export default function Home() {
  return (
    <div className="mx-auto mt-16 max-w-xl text-center">
      <h1 className="text-3xl font-bold">Debug-Code</h1>
      <p className="mt-4 text-zinc-400">Like LeetCode, but the code is already written — and it&apos;s broken. Find and fix the bugs.</p>
      <Link href="/problems" className="mt-6 inline-block rounded bg-blue-600 px-4 py-2 text-white">Browse problems</Link>
    </div>
  );
}
