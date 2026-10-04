export default function SessionPreview() {
  return (
    <div className="flex flex-col gap-8 w-full max-w-[440px]">
      {/* Session Preview Card */}
      <div className="rounded-xl border border-line bg-surface p-5 shadow-2xl">
        <div className="flex items-center justify-between pb-4 border-b border-line">
          <span className="font-mono text-xs text-zinc-300">
            Recent session &middot; <span className="text-zinc-400">utils.ts</span>
          </span>
          <span className="rounded bg-success-surface border border-success-line px-2 py-0.5 font-mono text-[11px] text-easy">
            resolved
          </span>
        </div>

        <div className="mt-4 flex flex-col gap-3">
          {/* Row 1 */}
          <div className="flex items-start gap-3">
            <span className="shrink-0 rounded bg-success-surface border border-success-line px-1.5 py-0.5 font-mono text-[11px] text-easy">
              fixed
            </span>
            <span className="text-xs text-zinc-200 leading-relaxed">
              Unhandled promise rejection in fetchUser when the API returns 404
            </span>
          </div>

          {/* Row 2 */}
          <div className="flex items-start gap-3">
            <span className="shrink-0 rounded bg-success-surface border border-success-line px-1.5 py-0.5 font-mono text-[11px] text-easy">
              fixed
            </span>
            <span className="text-xs text-zinc-200 leading-relaxed">
              Date parsed in local time instead of UTC
            </span>
          </div>

          {/* Row 3 */}
          <div className="flex items-start gap-3">
            <span className="shrink-0 rounded bg-surface-2 border border-line px-1.5 py-0.5 font-mono text-[11px] text-zinc-400">
              ignored
            </span>
            <span className="text-xs text-zinc-400 leading-relaxed">
              Unused import of lodash
            </span>
          </div>
        </div>
      </div>

      {/* Copy */}
      <div className="flex flex-col gap-3">
        <h2 className="text-2xl font-bold tracking-tight text-foreground">
          Every fix is a diff you approve.
        </h2>
        <p className="text-sm text-zinc-400 leading-relaxed">
          Your sessions, tests and fix history are saved, so you can come back to any bug and see exactly what changed and why.
        </p>
      </div>
    </div>
  );
}
