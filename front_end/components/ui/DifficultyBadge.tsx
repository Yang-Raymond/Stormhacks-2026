import type { Difficulty } from "@/lib/api";

const styles: Record<Difficulty, string> = {
  easy: "border-success-line bg-success-surface text-easy",
  medium: "border-warning-line bg-warning-surface text-medium",
  hard: "border-danger-line bg-danger-surface text-hard",
};

export default function DifficultyBadge({ difficulty, className = "" }: { difficulty: Difficulty; className?: string }) {
  return (
    <span
      className={`inline-flex shrink-0 items-center rounded border px-1.5 py-0.5 font-mono text-[11px] capitalize ${styles[difficulty]} ${className}`}
    >
      {difficulty}
    </span>
  );
}
