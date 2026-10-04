import Markdown from "react-markdown";
import remarkGfm from "remark-gfm";
import DifficultyBadge from "@/components/ui/DifficultyBadge";
import { CheckIcon } from "@/components/ui/icons";
import type { Problem } from "@/lib/api";

const prose = [
  "problem-prose prose prose-invert prose-sm max-w-none",
  "prose-headings:font-semibold prose-headings:tracking-tight prose-headings:text-zinc-100",
  "prose-h2:mt-6 prose-h2:text-base",
  "prose-h3:mt-6 prose-h3:mb-2 prose-h3:text-xs prose-h3:uppercase prose-h3:tracking-wider prose-h3:text-zinc-400",
  "prose-p:leading-relaxed prose-p:text-zinc-300 prose-li:text-zinc-300 prose-li:marker:text-zinc-600",
  "prose-strong:text-zinc-100 prose-a:text-accent",
  "prose-code:rounded prose-code:border prose-code:border-line prose-code:bg-surface-2 prose-code:px-1.5 prose-code:py-0.5",
  "prose-code:text-[0.85em] prose-code:font-normal prose-code:text-zinc-200 prose-code:before:content-none prose-code:after:content-none",
  "prose-pre:my-3 prose-pre:rounded-lg prose-pre:border prose-pre:border-line prose-pre:bg-canvas-2 prose-pre:px-4 prose-pre:py-3",
  "prose-pre:text-[0.85em] prose-pre:leading-relaxed prose-pre:text-zinc-300",
].join(" ");

/** The model often repeats the title as a leading `# heading`; the page already shows it. */
const withoutLeadingTitle = (markdown: string) => markdown.replace(/^\s*#\s+[^\n]*\n/, "");

export default function ProblemDescription({ problem }: { problem: Problem }) {
  return (
    <article className="px-5 py-5 sm:px-6">
      <h1 className="text-xl font-bold tracking-tight text-white">{problem.title}</h1>
      <div className="mt-2.5 flex flex-wrap items-center gap-2 text-xs text-zinc-500">
        <DifficultyBadge difficulty={problem.difficulty} />
        <span className="rounded border border-line bg-surface-2 px-1.5 py-0.5 font-mono text-[11px] text-zinc-400">
          {problem.totalTests} tests · {problem.examples.length} visible
        </span>
        {problem.solved && (
          <span className="flex items-center gap-1 rounded border border-[#1e4a33] bg-[#12281c] px-1.5 py-0.5 font-mono text-[11px] text-easy">
            <CheckIcon className="size-3" /> solved
          </span>
        )}
      </div>
      <div className={`mt-5 ${prose}`}>
        <Markdown remarkPlugins={[remarkGfm]}>{withoutLeadingTitle(problem.description)}</Markdown>
      </div>
    </article>
  );
}
