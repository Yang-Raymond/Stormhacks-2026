import type { Difficulty } from "@/lib/api";

const styles: Record<Difficulty, string> = {
  easy: "border-[#1e4a33] bg-[#12281c] text-easy",
  medium: "border-[#4a3b1e] bg-[#2a2112] text-medium",
  hard: "border-[#4a1f1f] bg-[#2a1313] text-hard",
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
