import Link from "next/link";
import { Eyebrow, container } from "./shared";

const bugCategories = [
  "Off-by-one and loops",
  "Null and missing data",
  "Shared and mutable state",
  "Async and race conditions",
  "Types and conversions",
  "Dates and time zones",
  "API and error handling",
  "Performance",
];

export default function BugTypes() {
  return (
    <section id="problems" className="border-t border-line/60 py-20 sm:py-24">
      <div className={container}>
        {/* Header */}
        <Eyebrow>PROBLEMS</Eyebrow>
        <div className="mt-4 flex flex-col items-start justify-between gap-4 sm:flex-row sm:items-end">
          <h2 className="text-3xl font-extrabold tracking-tight text-foreground sm:text-4xl">
            Practice by bug type
          </h2>
          <Link
            href="/problems"
            className="flex items-center gap-1.5 text-sm font-semibold text-accent-ink transition-colors hover:text-accent-ink"
          >
            <span>Browse all problems</span>
            <span aria-hidden="true">→</span>
          </Link>
        </div>

        {/* 4x2 Grid of Bug Types */}
        <div className="mt-12 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {bugCategories.map((category) => (
            <Link
              key={category}
              href="/problems"
              className="group flex flex-col justify-center rounded-xl border border-line-strong/80 bg-surface p-6 transition-all hover:border-zinc-600 hover:bg-surface-2"
            >
              <h3 className="text-sm font-bold text-zinc-100 transition-colors group-hover:text-accent-ink sm:text-[15px]">
                {category}
              </h3>
            </Link>
          ))}
        </div>
      </div>
    </section>
  );
}
