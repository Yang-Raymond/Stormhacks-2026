export default function FeatureList() {
  const features = [
    {
      step: "01",
      title: "Paste or import code",
      description: "From any AI assistant, a file, or a pull request.",
    },
    {
      step: "02",
      title: "See every issue, line by line",
      description: "Ranked by severity with a plain explanation.",
    },
    {
      step: "03",
      title: "Apply fixes you trust",
      description: "Review diffs and rerun tests before you ship.",
    },
  ];

  return (
    <div className="flex flex-col gap-10 w-full max-w-[420px]">
      <h1 className="text-3xl lg:text-4xl font-bold tracking-tight text-white leading-snug">
        Debug AI-generated code with confidence.
      </h1>

      <div className="flex flex-col gap-6">
        {features.map((f) => (
          <div key={f.step} className="flex items-start gap-4">
            <div className="shrink-0 flex items-center justify-center w-7 h-7 rounded-md bg-[#251d10] border border-[#594218] text-[#f2b544] font-mono text-xs font-semibold mt-0.5">
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
