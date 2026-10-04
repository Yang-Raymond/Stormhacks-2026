"use client";

import { useEffect, useId, useRef, useState } from "react";
import { useTheme } from "@/hooks/useTheme";
import { setTheme, type ThemePreference } from "@/lib/theme";

const options: { value: ThemePreference; label: string }[] = [
  { value: "light", label: "Light" },
  { value: "dark", label: "Dark" },
  { value: "system", label: "System default" },
];

export default function ThemeMenu() {
  const { preference } = useTheme();
  const [open, setOpen] = useState(false);
  const root = useRef<HTMLDivElement>(null);
  const trigger = useRef<HTMLButtonElement>(null);
  const menu = useRef<HTMLDivElement>(null);
  const id = useId();

  useEffect(() => {
    if (!open) return;
    menu.current?.querySelector<HTMLElement>('[aria-checked="true"]')?.focus();
    function outside(event: PointerEvent) {
      if (!root.current?.contains(event.target as Node)) setOpen(false);
    }
    document.addEventListener("pointerdown", outside);
    return () => document.removeEventListener("pointerdown", outside);
  }, [open]);

  return (
    <div ref={root} className="relative shrink-0" onBlur={(event) => {
      if (!event.currentTarget.contains(event.relatedTarget)) setOpen(false);
    }}>
      <button
        ref={trigger}
        type="button"
        aria-label="Choose theme"
        title="Choose theme"
        aria-haspopup="menu"
        aria-expanded={open}
        aria-controls={open ? id : undefined}
        onClick={() => setOpen(!open)}
        onKeyDown={(event) => {
          if (event.key === "ArrowDown" || event.key === "ArrowUp") {
            event.preventDefault();
            setOpen(true);
          }
        }}
        className="flex size-9 items-center justify-center rounded-lg border border-line text-zinc-400 hover:bg-surface-2 hover:text-foreground focus-visible:outline-2 focus-visible:outline-accent"
      >
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7" aria-hidden="true">
          <circle cx="12" cy="12" r="4" />
          <path d="M12 2v2m0 16v2M2 12h2m16 0h2M5 5l1.5 1.5m11 11L19 19M5 19l1.5-1.5m11-11L19 5" />
        </svg>
      </button>
      {open && (
        <div ref={menu} id={id} role="menu" aria-label="Theme" className="absolute right-0 top-full z-50 mt-2 w-44 rounded-xl border border-line-strong bg-surface p-1 shadow-lg" onKeyDown={(event) => {
          if (event.key === "Escape") {
            event.preventDefault();
            setOpen(false);
            trigger.current?.focus();
          }
          const items = Array.from(menu.current?.querySelectorAll<HTMLButtonElement>('button') ?? []);
          const index = items.indexOf(document.activeElement as HTMLButtonElement);
          const next = event.key === "Home" ? 0 : event.key === "End" ? items.length - 1 : event.key === "ArrowDown" ? (index + 1) % items.length : event.key === "ArrowUp" ? (index - 1 + items.length) % items.length : -1;
          if (next >= 0) { event.preventDefault(); items[next]?.focus(); }
        }}>
          {options.map(({ value, label }) => (
            <button key={value} type="button" role="menuitemradio" aria-checked={preference === value} tabIndex={preference === value ? 0 : -1}
              className="flex w-full items-center justify-between rounded-lg px-3 py-2 text-sm text-zinc-200 hover:bg-surface-2 focus:bg-surface-2 focus:outline-none"
              onClick={() => { setTheme(value); setOpen(false); trigger.current?.focus(); }}>
              {label}<span aria-hidden="true">{preference === value ? "✓" : ""}</span>
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
