"use client";

import { useMemo, useState } from "react";
import type { ActivityDay } from "@/lib/api";

const LEVELS = ["bg-surface-2", "bg-accent/25", "bg-accent/45", "bg-accent/70", "bg-accent"];
const DAY_LABELS = ["Mon", "", "Wed", "", "Fri", "", ""];
const monthFormat = new Intl.DateTimeFormat("en", { month: "short", timeZone: "UTC" });
const dayFormat = new Intl.DateTimeFormat("en", {
  weekday: "short",
  month: "short",
  day: "numeric",
  timeZone: "UTC",
});

function level(total: number, max: number) {
  if (!total) return 0;
  return Math.max(1, Math.ceil((total / max) * 4));
}

export default function ActivityHeatmap({
  days,
  showDayLabels = true,
  showMonthLabels = true,
  className = "",
}: {
  days: ActivityDay[];
  showDayLabels?: boolean;
  showMonthLabels?: boolean;
  className?: string;
}) {
  const [hover, setHover] = useState<{ day: ActivityDay; x: number; y: number } | null>(null);

  const weeks = useMemo(() => {
    const out: ActivityDay[][] = [];
    for (let i = 0; i < days.length; i += 7) out.push(days.slice(i, i + 7));
    return out;
  }, [days]);

  if (!days.length) return null;

  const max = Math.max(1, ...days.map((d) => d.total));
  const activeDays = days.filter((d) => d.total > 0).length;

  return (
    <div className={`min-w-0 ${className}`}>
      <p className="sr-only">
        {activeDays} active days in the last {weeks.length} weeks; most in one day: {max}.
      </p>
      <div className="overflow-x-auto pb-1" aria-hidden="true">
        <div
          className={`inline-grid gap-x-2 ${
            showDayLabels ? "grid-cols-[auto_1fr]" : "grid-cols-1"
          }`}
        >
          {showDayLabels && <span />}

          {showMonthLabels && (
            <div className="flex gap-[3px] pb-1.5 text-[10px] text-zinc-500">
              {weeks.map((week, i) => {
                const first = week[0];
                const startsMonth = i === 0 || week.some((d) => d.date.endsWith("-01"));
                return (
                  <span
                    key={first.date}
                    className="w-[11px] overflow-visible whitespace-nowrap"
                  >
                    {startsMonth && i < weeks.length - 1
                      ? monthFormat.format(new Date(`${week.at(-1)!.date}T00:00:00Z`))
                      : ""}
                  </span>
                );
              })}
            </div>
          )}

          {showDayLabels && (
            <div className="grid grid-rows-7 gap-[3px] text-[10px] leading-[11px] text-zinc-500">
              {DAY_LABELS.map((label, i) => (
                <span key={i}>{label}</span>
              ))}
            </div>
          )}

          <div className="flex gap-[3px]" onMouseLeave={() => setHover(null)}>
            {weeks.map((week) => (
              <div key={week[0].date} className="grid grid-rows-7 gap-[3px]">
                {week.map((day) => (
                  <span
                    key={day.date}
                    onMouseEnter={(e) => {
                      const r = e.currentTarget.getBoundingClientRect();
                      setHover({ day, x: r.left + r.width / 2, y: r.top });
                    }}
                    className={`h-[11px] w-[11px] rounded-[3px] ${
                      LEVELS[level(day.total, max)]
                    } ${hover?.day.date === day.date ? "ring-1 ring-zinc-300" : ""}`}
                  />
                ))}
              </div>
            ))}
          </div>
        </div>
      </div>

      <div
        className="mt-2 flex items-center justify-end gap-1.5 text-[10px] text-zinc-500"
        aria-hidden="true"
      >
        Less
        {LEVELS.map((c) => (
          <span key={c} className={`h-[11px] w-[11px] rounded-[3px] ${c}`} />
        ))}
        More
      </div>

      {hover && (
        <div
          role="tooltip"
          style={{ left: hover.x, top: hover.y - 8 }}
          className="pointer-events-none fixed z-40 -translate-x-1/2 -translate-y-full rounded-md border border-line-strong bg-surface-2 px-2.5 py-1.5 text-xs shadow-xl"
        >
          <p className="font-medium text-zinc-100">
            {dayFormat.format(new Date(`${hover.day.date}T00:00:00Z`))}
          </p>
          <p className="text-zinc-400">
            {hover.day.total
              ? `${hover.day.total} actions · ${hover.day.accepted} accepted`
              : "No activity"}
          </p>
        </div>
      )}
    </div>
  );
}
