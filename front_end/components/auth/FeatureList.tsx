export default function FeatureList() {
  const features = [
    {
      step: "01",
      title: "Real AI bugs",
      description: "Practice on realistic code with off-by-ones, race conditions, and tricky edge cases.",
    },
    {
      step: "02",
      title: "In-browser time-travel debugger",
      description: "Set breakpoints, step forward and back, inspect the call stack, and watch live variables.",
    },
    {
      step: "03",
      title: "Hidden test validation",
      description: "Run and submit your fixes against hidden test suites across 6 programming languages.",
    },
  ];

  return (
    <div className="flex flex-col gap-10 w-full max-w-[420px]">
      <h1 className="text-3xl lg:text-4xl font-bold tracking-tight text-foreground leading-snug">
        Debug AI-generated code with confidence.
      </h1>

      <div className="flex flex-col gap-6">
        {features.map((f) => (
          <div key={f.step} className="flex items-start gap-4">
            <div className="shrink-0 flex items-center justify-center w-7 h-7 rounded-md bg-warning-surface border border-warning-line text-accent-ink font-mono text-xs font-semibold mt-0.5">
              {f.step}
            </div>
            <div className="flex flex-col gap-0.5">
              <h3 className="font-semibold text-zinc-100 text-sm">
                {f.title}
              </h3>
              <p className="text-xs text-zinc-400 leading-relaxed">
                {f.description}
              </p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
