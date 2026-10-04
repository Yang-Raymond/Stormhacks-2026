"use client";

import { type ReactNode, useEffect, useId, useRef } from "react";

const tones = {
  danger: {
    icon: "border-red-900/60 bg-red-950/40 text-red-400",
    confirm: "bg-red-600 text-white hover:bg-red-500",
  },
  accent: {
    icon: "border-accent/40 bg-accent/10 text-accent-ink",
    confirm: "bg-accent text-zinc-950 hover:bg-accent-hover",
  },
};

/** Modal confirmation built on <dialog>, which provides focus trapping, Escape to close and a backdrop. */
export default function ConfirmDialog({ open, title, children, confirmLabel, icon, tone = "danger", onConfirm, onCancel }: {
  open: boolean;
  title: string;
  children: ReactNode;
  confirmLabel: string;
  icon?: ReactNode;
  tone?: keyof typeof tones;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  const ref = useRef<HTMLDialogElement>(null);
  const titleId = useId();

  useEffect(() => {
    const dialog = ref.current;
    if (!dialog) return;
    if (open && !dialog.open) dialog.showModal();
    if (!open && dialog.open) dialog.close();
  }, [open]);

  return (
    <dialog
      ref={ref}
      onClose={onCancel}
      onClick={(e) => e.target === ref.current && onCancel()}
      aria-labelledby={titleId}
      className="m-auto w-[calc(100%-2rem)] max-w-md rounded-xl border border-line-strong bg-surface p-0 text-zinc-100 shadow-2xl shadow-black/60 backdrop:bg-black/60 backdrop:backdrop-blur-sm"
    >
      <div className="flex gap-4 p-5">
        {icon && (
          <span className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-full border ${tones[tone].icon}`}>
            {icon}
          </span>
        )}
        <div>
          <h2 id={titleId} className="font-semibold text-foreground">{title}</h2>
          <div className="mt-1.5 text-sm leading-relaxed text-zinc-400">{children}</div>
        </div>
      </div>
      <div className="flex justify-end gap-2 border-t border-line bg-canvas-2/50 px-5 py-3">
        <button
          type="button"
          autoFocus
          onClick={onCancel}
          className="rounded-md border border-line-strong px-3.5 py-2 text-sm text-zinc-200 transition-colors hover:bg-surface-2"
        >
          Cancel
        </button>
        <button
          type="button"
          onClick={onConfirm}
          className={`rounded-md px-3.5 py-2 text-sm font-semibold transition-colors ${tones[tone].confirm}`}
        >
          {confirmLabel}
        </button>
      </div>
    </dialog>
  );
}
