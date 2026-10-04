import { Eyebrow, container } from "./shared";

const steps = [
  {
    number: "01",
    title: "Reproduce it",
    description:
      "Read the bug report, run the failing tests, and write your own test cases until you can trigger the problem.",
    active: true,
  },
  {
    number: "02",
    title: "Investigate",
    description:
      "Set breakpoints, step through execution, and watch variables live. Request an AI hint if you get stuck.",
    active: false,
  },
  {
    number: "03",
    title: "Fix and verify",
    description:
      "Submit a fix that passes all hidden tests. Once accepted, review your solution and keep your streak going.",
    active: false,
  },
];

export default function HowItWorks() {
  return (
    <section id="how-it-works" className="border-t border-line/60 py-20 sm:py-24">
      <div className={container}>
        {/* Header */}
        <Eyebrow>HOW IT WORKS</Eyebrow>
        <h2 className="mt-4 text-3xl font-extrabold tracking-tight text-foreground sm:text-4xl max-w-xl">
          Practice the way real debugging happens
        </h2>
        <p className="mt-4 max-w-2xl text-base leading-relaxed text-zinc-400">
          Every problem starts with a bug report and code that almost works, just like the code you get back from an AI assistant.
        </p>

        {/* 3 Step Columns */}
        <div className="mt-14 grid grid-cols-1 gap-8 md:grid-cols-3 md:gap-10">
          {steps.map((step) => (
            <div
              key={step.number}
              className={`pt-6 border-t-2 ${
                step.active ? "border-accent" : "border-line-strong"
              }`}
            >
              <span
                className={`font-mono text-sm font-semibold ${
                  step.active ? "text-accent-ink" : "text-zinc-500"
                }`}
              >
                {step.number}
              </span>
              <h3 className="mt-3 text-xl font-bold tracking-tight text-foreground">
                {step.title}
              </h3>
              <p className="mt-3 text-sm leading-relaxed text-zinc-400">
                {step.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
