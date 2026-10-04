export default function SessionPreview() {
  return (
    <div className="flex flex-col gap-8 w-full max-w-[440px]">
      {/* Session Preview Card */}
      <div className="rounded-xl border border-line bg-surface p-5 shadow-2xl">
        <div className="flex items-center justify-between pb-4 border-b border-line">
          <span className="font-mono text-xs text-zinc-300">
            Recent debug session &middot; <span className="text-zinc-400">Longest Overheating Streak</span>
          </span>
          <span className="rounded bg-success-surface border border-success-line px-2 py-0.5 font-mono text-[11px] text-easy">
            accepted
          </span>
        </div>

        <div className="mt-4 flex flex-col gap-3">
          {/* Row 1 */}
          <div className="flex items-start gap-3">
            <span className="shrink-0 rounded bg-success-surface border border-success-line px-1.5 py-0.5 font-mono text-[11px] text-easy">
              passed
            </span>
            <span className="text-xs text-zinc-200 leading-relaxed font-mono">
              Case 1: readings = [70, 80, 85, 60], threshold = 80
            </span>
          </div>

          {/* Row 2 */}
          <div className="flex items-start gap-3">
            <span className="shrink-0 rounded bg-success-surface border border-success-line px-1.5 py-0.5 font-mono text-[11px] text-easy">
              passed
            </span>
            <span className="text-xs text-zinc-200 leading-relaxed font-mono">
              Case 2: readings = [40, 50], threshold = 60
            </span>
          </div>

          {/* Row 3 */}
          <div className="flex items-start gap-3">
            <span className="shrink-0 rounded bg-success-surface border border-success-line px-1.5 py-0.5 font-mono text-[11px] text-easy">
              passed
            </span>
            <span className="text-xs text-zinc-200 leading-relaxed font-mono">
              Hidden tests (4/4 passed)
            </span>
          </div>
        </div>
      </div>

      {/* Copy */}
      <div className="flex flex-col gap-3">
        <h2 className="text-2xl font-bold tracking-tight text-foreground">
          Fix buggy code with real tools.
        </h2>
        <p className="text-sm text-zinc-400 leading-relaxed">
          Step through broken code with a live debugger, watch variables evolve, and verify your fix against full test suites.
        </p>
      </div>
    </div>
  );
}
