import {
  BarChartIcon,
  CalendarIcon,
  CodeIcon,
  CrosshairIcon,
  LightbulbIcon,
  MessageSquareIcon,
} from "@/components/ui/icons";
import { Eyebrow, container } from "./shared";

const features = [
  {
    icon: CodeIcon,
    title: "Realistic broken code",
    description:
      "Bugs taken from the mistakes AI assistants actually make: off-by-ones, shared state, wrong edge cases, async mix-ups.",
  },
  {
    icon: CrosshairIcon,
    title: "A real debugger",
    description:
      "Breakpoints, step over and into, a call stack and live variables, right in the browser. Learn the tools, not just the answer.",
  },
  {
    icon: LightbulbIcon,
    title: "Hints, not answers",
    description:
      "Three levels of hints nudge you toward where to look. The solution stays locked until you solve it or give up.",
  },
  {
    icon: BarChartIcon,
    title: "Track your weak spots",
    description:
      "See which kinds of bugs you catch fast and which ones slow you down, then practice exactly those.",
  },
  {
    icon: CalendarIcon,
    title: "Daily bug",
    description:
      "One new problem every day. Keep your streak going and compare your time with everyone else who solved it.",
  },
  {
    icon: MessageSquareIcon,
    title: "Explain the root cause",
    description:
      "Every submission asks why the bug happened. Writing it down is how the lesson sticks, and it's great interview practice.",
  },
];

export default function Features() {
  return (
    <section className="border-t border-line/60 py-20 sm:py-24">
      <div className={container}>
        {/* Header */}
        <Eyebrow>WHY LADYBUG</Eyebrow>
        <h2 className="mt-4 text-3xl font-extrabold tracking-tight text-foreground sm:text-4xl">
          Build the skill AI can&apos;t do for you
        </h2>

        {/* 4-column card grid */}
        <div className="mt-12 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
          {features.map((feat) => {
            const Icon = feat.icon;
            return (
              <div
                key={feat.title}
                className="flex flex-col rounded-xl border border-line-strong/80 bg-surface p-6 transition-colors hover:border-zinc-700/80 sm:p-7"
              >
                <div className="mb-5 inline-flex text-accent-ink">
                  <Icon className="size-5" />
                </div>
                <h3 className="text-base font-bold tracking-tight text-zinc-100">
                  {feat.title}
                </h3>
                <p className="mt-2.5 text-xs leading-relaxed text-zinc-400">
                  {feat.description}
                </p>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
