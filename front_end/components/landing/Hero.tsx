import CodePreviewCard from "./CodePreviewCard";
import { PrimaryButton, SecondaryButton, container } from "./shared";

export default function Hero() {
  return (
    <section className="relative overflow-hidden py-16 sm:py-20 lg:py-24">
      <div className={`${container} grid grid-cols-1 items-center gap-12 lg:grid-cols-2 lg:gap-14`}>
        {/* Left Column */}
        <div className="flex flex-col items-start">
          {/* Main Title */}
          <h1 className="text-4xl font-extrabold tracking-tight text-foreground sm:text-5xl lg:text-[58px] lg:leading-[1.1]">
            Get better at
            <br />
            finding bugs.
          </h1>

          {/* Description */}
          <p className="mt-6 max-w-xl text-base leading-relaxed text-zinc-400 sm:text-lg">
            AI tools write code faster than ever, and the bugs come with it. LadyBug gives you realistic broken code, failing tests and a real debugger. You find the bug, fix it and explain it. No answers handed to you.
          </p>

          {/* CTA Buttons */}
          <div className="mt-8 flex flex-wrap items-center gap-4">
            <PrimaryButton href="/problems" className="h-11 px-5 text-sm">
              Solve your first bug
            </PrimaryButton>
            <SecondaryButton href="#how-it-works" className="h-11 px-5 text-sm">
              See how it works
            </SecondaryButton>
          </div>

          {/* Tagline below buttons */}
          <p className="mt-6 text-xs text-zinc-500 font-medium">
            Free · Python, JavaScript, TypeScript, Java, C, C++
          </p>
        </div>

        {/* Right Column: Code Card */}
        <div className="flex justify-center lg:justify-end">
          <CodePreviewCard />
        </div>
      </div>
    </section>
  );
}
