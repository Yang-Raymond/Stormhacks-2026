import type { ReactNode } from "react";

export function Section({ title, actions, children, className = "" }: {
  title: string;
  actions?: ReactNode;
  children: ReactNode;
  className?: string;
}) {
  return (
    <section className={`flex min-h-0 flex-col ${className}`}>
      <header className="flex h-8 shrink-0 items-center justify-between gap-2 border-b border-line px-3">
        <h3 className="text-[11px] font-semibold uppercase tracking-wider text-zinc-500">{title}</h3>
        {actions && <div className="flex items-center gap-1">{actions}</div>}
      </header>
      <div className="min-h-0 flex-1 overflow-auto">{children}</div>
    </section>
  );
}

export function IconButton({ label, onClick, disabled, children, className = "" }: {
  label: string;
  onClick: () => void;
  disabled?: boolean;
  children: ReactNode;
  className?: string;
}) {
  return (
    <button
      type="button"
      title={label}
      aria-label={label}
      onClick={onClick}
      disabled={disabled}
      className={`flex h-7 w-7 items-center justify-center rounded-md text-zinc-400 transition-colors hover:bg-surface-2 hover:text-zinc-100 disabled:pointer-events-none disabled:opacity-35 ${className}`}
    >
      {children}
    </button>
  );
}

/** Colors a Python repr by its leading token, like a debugger's variables view. */
export function ValueText({ value, className = "" }: { value: string; className?: string }) {
  const color = /^-?\d/.test(value)
    ? "text-sky-300"
    : /^['"]/.test(value)
      ? "text-emerald-300"
      : /^(True|False|None)$/.test(value)
        ? "text-violet-300"
        : "text-zinc-200";
  return <span className={`whitespace-pre-wrap break-all font-mono ${color} ${className}`}>{value}</span>;
}

export function Empty({ children }: { children: ReactNode }) {
  return <p className="px-3 py-3 text-xs text-zinc-500">{children}</p>;
}
