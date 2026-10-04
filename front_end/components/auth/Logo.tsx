import Link from "next/link";

export default function Logo({ href = "/" }: { href?: string }) {
  return (
    <Link href={href} className="inline-flex items-center gap-2.5 group">
      <div className="flex items-center justify-center w-7 h-7 rounded-md bg-accent text-white font-mono text-xs font-bold shadow-sm transition-transform group-hover:scale-105">
        &gt;_
      </div>
      <span className="font-semibold text-lg tracking-tight text-foreground">
        LadyBug
      </span>
    </Link>
  );
}
