"use client";

export type TestcaseOption = { key: string; label: string; args: unknown[]; expected?: unknown; hidden?: boolean };
export const CUSTOM_CASE = "custom";

const show = (v: unknown) => JSON.stringify(v);

export default function TestcasePanel({ cases, selected, onSelect, params, custom, onCustomChange, customErrors }: {
  cases: TestcaseOption[];
  selected: string;
  onSelect: (key: string) => void;
  /** Parameter names of the entry point, for labelling arguments. */
  params: string[];
  custom: string[];
  onCustomChange: (values: string[]) => void;
  customErrors: (string | null)[];
}) {
  const current = cases.find((c) => c.key === selected);
  const argLabel = (i: number) => params[i] ?? `arg${i + 1}`;

  return (
    <div className="flex h-full min-h-0 flex-col">
      <div role="tablist" aria-label="Test cases" className="flex shrink-0 flex-wrap gap-1.5 px-4 pt-3">
        {[...cases, { key: CUSTOM_CASE, label: "Custom", hidden: false }].map((c) => (
          <button
            key={c.key}
            role="tab"
            aria-selected={selected === c.key}
            onClick={() => onSelect(c.key)}
            className={`flex items-center gap-1.5 rounded-md px-3 py-1 text-xs transition-colors ${
              selected === c.key ? "bg-surface-2 font-medium text-zinc-100 ring-1 ring-line-strong" : "text-zinc-500 hover:bg-surface-2/60 hover:text-zinc-300"
            }`}
          >
            {c.hidden && <span className="h-1.5 w-1.5 rounded-full bg-red-400" />}
            {c.label}
          </button>
        ))}
      </div>

      <div className="min-h-0 flex-1 overflow-auto px-4 pb-4 pt-3">
        {current?.hidden && (
          <p className="mb-3 rounded-md border border-red-900/50 bg-red-950/20 px-3 py-2 text-xs text-red-300">
            A hidden test your code fails. Debug it to see where things go wrong.
          </p>
        )}
        {selected === CUSTOM_CASE ? (
          <div className="space-y-3">
            {custom.map((value, i) => (
              <label key={i} className="block">
                <span className="font-mono text-xs text-zinc-500">{argLabel(i)} =</span>
                <textarea
                  value={value}
                  onChange={(e) => onCustomChange(custom.map((v, j) => (j === i ? e.target.value : v)))}
                  rows={1}
                  spellCheck={false}
                  className={`mt-1 block w-full resize-y rounded-md border bg-canvas-2 px-3 py-2 font-mono text-sm text-zinc-100 focus:outline-none ${
                    customErrors[i] ? "border-red-800 focus:border-red-600" : "border-line focus:border-accent/50"
                  }`}
                />
                {customErrors[i] && <span className="mt-1 block text-xs text-red-400">{customErrors[i]}</span>}
              </label>
            ))}
            <p className="text-xs text-zinc-600">Each argument is a JSON value, e.g. [1, 2, 3], &quot;text&quot;, true.</p>
          </div>
        ) : current ? (
          <div className="space-y-3">
            {current.args.map((arg, i) => (
              <Field key={i} label={`${argLabel(i)} =`} value={show(arg)} />
            ))}
            <Field label="Expected" value={show(current.expected)} />
          </div>
        ) : null}
      </div>
    </div>
  );
}

export function Field({ label, value, tone = "default" }: { label: string; value: string; tone?: "default" | "pass" | "fail" }) {
  const toneClass = tone === "pass" ? "text-easy" : tone === "fail" ? "text-red-300" : "text-zinc-100";
  return (
    <div>
      <p className="font-mono text-xs text-zinc-500">{label}</p>
      <pre className={`mt-1 overflow-x-auto rounded-md border border-line bg-canvas-2 px-3 py-2 font-mono text-sm ${toneClass}`}>{value}</pre>
    </div>
  );
}
