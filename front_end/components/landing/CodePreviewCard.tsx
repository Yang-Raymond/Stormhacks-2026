export default function CodePreviewCard() {
  return (
    <div className="w-full max-w-[540px] overflow-hidden rounded-xl border border-line-strong bg-surface shadow-2xl shadow-black/60">
      {/* Top Header */}
      <div className="flex items-center justify-between border-b border-line bg-surface-2 px-5 py-3">
        <div className="flex items-center gap-2.5">
          <span className="font-mono text-xs text-zinc-500">#142</span>
          <span className="text-sm font-semibold text-zinc-100">Cart total is wrong</span>
          <span className="rounded bg-accent px-1.5 py-0.5 font-mono text-[10px] font-bold uppercase tracking-wide text-white">
            MEDIUM
          </span>
        </div>
        <span className="font-mono text-xs text-zinc-500">2 bugs hidden</span>
      </div>

      {/* Bug Report description */}
      <div className="border-b border-line/60 bg-surface px-5 py-3 text-xs leading-relaxed text-zinc-400">
        <span className="font-medium text-zinc-300">Bug report:</span> Customers with a single item in their cart are charged $0.
      </div>

      {/* Code Editor body */}
      <div className="bg-canvas-2 p-5 font-mono text-[13px] leading-6">
        <div className="space-y-1">
          {/* Line 1 */}
          <div className="flex items-center">
            <span className="w-8 shrink-0 select-none text-right font-mono text-xs text-zinc-600">1</span>
            <div className="ml-4 text-zinc-200">
              <span className="text-blue-400">def</span> <span className="text-zinc-100">cart_total</span>(items, discounts=[]):
            </div>
          </div>

          {/* Line 2 */}
          <div className="flex items-center">
            <span className="w-8 shrink-0 select-none text-right font-mono text-xs text-zinc-600">2</span>
            <div className="ml-4 text-zinc-200">
              {"    "}total = <span className="text-accent-ink font-semibold">0</span>
            </div>
          </div>

          {/* Line 3 - Active breakpoint line */}
          <div className="flex items-center rounded-sm bg-accent/10 -mx-2 px-2 py-0.5">
            <span className="w-8 shrink-0 select-none text-right font-mono text-xs text-accent-ink flex items-center justify-end gap-1">
              <span className="text-[10px] text-accent-ink">●</span>
              <span>3</span>
            </span>
            <div className="ml-4 text-zinc-200 font-medium">
              {"    "}<span className="text-blue-400">for</span> i <span className="text-blue-400">in</span> range(<span className="text-accent-ink font-semibold">1</span>, len(items)):
            </div>
          </div>

          {/* Line 4 */}
          <div className="flex items-center">
            <span className="w-8 shrink-0 select-none text-right font-mono text-xs text-zinc-600">4</span>
            <div className="ml-4 text-zinc-200">
              {"        "}total += items[i][<span className="text-emerald-400">&quot;price&quot;</span>]
            </div>
          </div>

          {/* Line 5 */}
          <div className="flex items-center">
            <span className="w-8 shrink-0 select-none text-right font-mono text-xs text-zinc-600">5</span>
            <div className="ml-4 text-zinc-200">
              {"    "}<span className="text-blue-400">return</span> total
            </div>
          </div>
        </div>

        {/* Bottom Inspection Panels: Variables & Test cases */}
        <div className="mt-5 grid grid-cols-1 gap-3 sm:grid-cols-2">
          {/* Variables Panel */}
          <div className="rounded-lg border border-line-strong/80 bg-surface p-3 text-xs">
            <div className="mb-2 text-[11px] font-medium text-zinc-400">Paused at line 3</div>
            <div className="space-y-1 font-mono text-zinc-300">
              <div>
                i = <span className="text-accent-ink font-semibold">1</span>
              </div>
              <div>
                total = <span className="text-accent-ink font-semibold">0</span>
              </div>
              <div>
                len(items) = <span className="text-accent-ink font-semibold">1</span>
              </div>
            </div>
          </div>

          {/* Tests Panel */}
          <div className="rounded-lg border border-line-strong/80 bg-surface p-3 text-xs">
            <div className="space-y-1.5 font-mono">
              <div className="flex items-center gap-2 text-zinc-300">
                <span className="font-bold text-rose-500">✕</span>
                <span className="text-zinc-300">test_single_item</span>
              </div>
              <div className="flex items-center gap-2 text-zinc-300">
                <span className="font-bold text-rose-500">✕</span>
                <span className="text-zinc-300">test_repeat_calls</span>
              </div>
              <div className="flex items-center gap-2 text-zinc-300">
                <span className="font-bold text-emerald-400">✓</span>
                <span className="text-zinc-300">test_empty_cart</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
