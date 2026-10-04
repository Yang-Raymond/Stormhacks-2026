import Link from "next/link";

export const container = "mx-auto w-full max-w-[1200px] px-6 sm:px-8";

export function Eyebrow({ children, className = "" }: { children: React.ReactNode; className?: string }) {
  return (
    <p className={`font-mono text-xs font-semibold uppercase tracking-[0.14em] text-accent-ink ${className}`}>
      {children}
    </p>
  );
}

export function LogoMark({ className = "" }: { className?: string }) {
  return (
    <span
      className={`inline-flex h-7 w-7 items-center justify-center rounded-md border border-accent bg-surface font-mono text-xs font-bold text-accent-ink shadow-sm ${className}`}
    >
      &gt;_
    </span>
  );
}

const btnBase =
  "inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-accent";

export function PrimaryButton({
  href,
  children,
  className = "",
}: {
  href: string;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <Link
      href={href}
      className={`${btnBase} bg-accent font-semibold text-zinc-950 hover:bg-accent-hover shadow-sm ${className}`}
    >
      {children}
    </Link>
  );
}

export function SecondaryButton({
  href,
  children,
  className = "",
}: {
  href: string;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <Link
      href={href}
      className={`${btnBase} border border-line-strong bg-surface text-foreground hover:border-zinc-500 hover:bg-surface-2 ${className}`}
    >
      {children}
    </Link>
  );
}
