import Link from "next/link";

export default function Logo({ href = "/" }: { href?: string }) {
  return (
    <Link href={href} className="inline-flex items-center gap-2.5 group">
      <div className="flex items-center justify-center w-7 h-7 rounded-md bg-[#f2b544] text-[#0d0e12] font-mono text-xs font-bold shadow-sm transition-transform group-hover:scale-105">
        &gt;_
      </div>
      <span className="font-semibold text-lg tracking-tight text-white">
        LadyBug
      </span>
    </Link>
  );
}
