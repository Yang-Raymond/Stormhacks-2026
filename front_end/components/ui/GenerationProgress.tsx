"use client";

import { useEffect, useState } from "react";
import { CheckIcon } from "@/components/ui/icons";

/** Generation is one ~30s request; these stages just give a sense of progress while it runs. */
const STAGES = ["Writing the problem", "Injecting bugs", "Verifying the test suite", "Almost there"];
const SECONDS_PER_STAGE = 8;
const EXPECTED_SECONDS = 30;

export default function GenerationProgress({ className = "" }: { className?: string }) {
  const [elapsed, setElapsed] = useState(0);

  useEffect(() => {
    const started = Date.now();
    const timer = setInterval(() => setElapsed((Date.now() - started) / 1000), 250);
    return () => clearInterval(timer);
  }, []);

  const stage = Math.min(Math.floor(elapsed / SECONDS_PER_STAGE), STAGES.length - 1);
  const progress = Math.min(95, (elapsed / EXPECTED_SECONDS) * 100);

  return (
    <div className={className} aria-live="polite">
      <div className="h-1 overflow-hidden rounded-full bg-line">
        <div className="h-full rounded-full bg-accent transition-[width] duration-300" style={{ width: `${progress}%` }} />
      </div>
      <ol className="mt-3 flex flex-wrap gap-x-6 gap-y-2 text-sm">
        {STAGES.map((label, i) => (
          <li
            key={label}
            className={`flex items-center gap-2 ${i < stage ? "text-zinc-400" : i === stage ? "text-zinc-100" : "text-zinc-600"}`}
          >
            {i < stage ? (
              <CheckIcon className="size-3.5 text-easy" />
            ) : i === stage ? (
              <span className="h-2 w-2 animate-pulse rounded-full bg-accent" />
            ) : (
              <span className="h-2 w-2 rounded-full bg-line-strong" />
            )}
            {label}
          </li>
        ))}
      </ol>
    </div>
  );
}
