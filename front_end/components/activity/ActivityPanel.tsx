"use client";

import { useEffect, useMemo, useState } from "react";
import { api, type Activity, type ActivityDay } from "@/lib/api";

/** Sequential single-hue scale (accent), light to dark on the dark surface; level 0 is the empty surface. */
const LEVELS = ["bg-surface-2", "bg-accent/25", "bg-accent/45", "bg-accent/70", "bg-accent"];
const DAY_LABELS = ["Mon", "", "Wed", "", "Fri", "", ""];
const monthFormat = new Intl.DateTimeFormat("en", { month: "short", timeZone: "UTC" });
const dayFormat = new Intl.DateTimeFormat("en", { weekday: "short", month: "short", day: "numeric", timeZone: "UTC" });

function level(total: number, max: number) {
  if (!total) return 0;
  return Math.max(1, Math.ceil((total / max) * 4));
}

/** Streaks and a 26-week heatmap from the `daily_activity` continuous aggregate (Tiger Data). Hidden when logged out. */
export default function ActivityPanel() {
  const [activity, setActivity] = useState<Activity | null>(null);
  const [hover, setHover] = useState<{ day: ActivityDay; x: number; y: number } | null>(null);

  useEffect(() => {
    api<Activity>("/activity/me")
      .then(setActivity)
      .catch(() => setActivity(null));
  }, []);

  const weeks = useMemo(() => {
    const days = activity?.days ?? [];
    const out: ActivityDay[][] = [];
    for (let i = 0; i < days.length; i += 7) out.push(days.slice(i, i + 7));
    return out;
  }, [activity]);

  if (!activity) return null;
  const max = Math.max(1, ...activity.days.map((d) => d.total));
  const activeDays = activity.days.filter((d) => d.total > 0).length;

  return (
    <section aria-labelledby="activity-heading" className="mt-8 rounded-xl border border-line bg-surface p-5">
      <div className="flex flex-col gap-6 lg:flex-row lg:items-start">
        <div className="lg:w-56 lg:shrink-0">
          <h2 id="activity-heading" className="text-sm font-semibold text-white">Your activity</h2>
          <dl className="mt-3 grid grid-cols-3 gap-3 lg:grid-cols-1">
            <Stat label="Current streak" value={activity.streak.current} unit={activity.streak.current === 1 ? "day" : "days"} />
            <Stat label="Longest streak" value={activity.streak.longest} unit={activity.streak.longest === 1 ? "day" : "days"} />
            <Stat label="Accepted this week" value={activity.thisWeek.accepted} />
          </dl>
        </div>

        <div className="min-w-0 flex-1">
          <p className="sr-only">
            {activeDays} active days in the last {weeks.length} weeks; most in one day: {max}.
          </p>
          <div className="overflow-x-auto pb-1" aria-hidden="true">
            <div className="inline-grid grid-cols-[auto_1fr] gap-x-2">
              <span />
              <div className="flex gap-[3px] pb-1.5 text-[10px] text-zinc-500">
                {weeks.map((week, i) => {
                  const first = week[0];
                  const startsMonth = i === 0 || week.some((d) => d.date.endsWith("-01"));
                  return (
                    <span key={first.date} className="w-[11px] overflow-visible whitespace-nowrap">
                      {startsMonth && i < weeks.length - 1 ? monthFormat.format(new Date(`${week.at(-1)!.date}T00:00:00Z`)) : ""}
                    </span>
                  );
                })}
              </div>
              <div className="grid grid-rows-7 gap-[3px] text-[10px] leading-[11px] text-zinc-500">
                {DAY_LABELS.map((label, i) => (
                  <span key={i}>{label}</span>
                ))}
              </div>
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
                        className={`h-[11px] w-[11px] rounded-[3px] ${LEVELS[level(day.total, max)]} ${
                          hover?.day.date === day.date ? "ring-1 ring-zinc-300" : ""
                        }`}
                      />
                    ))}
                  </div>
                ))}
              </div>
            </div>
          </div>
          <div className="mt-2 flex items-center justify-end gap-1.5 text-[10px] text-zinc-500" aria-hidden="true">
            Less
            {LEVELS.map((c) => (
              <span key={c} className={`h-[11px] w-[11px] rounded-[3px] ${c}`} />
            ))}
            More
          </div>
        </div>
      </div>

      {hover && (
        <div
          role="tooltip"
          style={{ left: hover.x, top: hover.y - 8 }}
          className="pointer-events-none fixed z-40 -translate-x-1/2 -translate-y-full rounded-md border border-line-strong bg-surface-2 px-2.5 py-1.5 text-xs shadow-xl"
        >
          <p className="font-medium text-zinc-100">{dayFormat.format(new Date(`${hover.day.date}T00:00:00Z`))}</p>
          <p className="text-zinc-400">
            {hover.day.total ? `${hover.day.total} actions · ${hover.day.accepted} accepted` : "No activity"}
          </p>
        </div>
      )}
    </section>
  );
}

function Stat({ label, value, unit }: { label: string; value: number; unit?: string }) {
  return (
    <div className="rounded-lg border border-line bg-canvas-2/60 px-3 py-2">
      <dt className="text-[11px] text-zinc-500">{label}</dt>
      <dd className="mt-0.5 flex items-baseline gap-1">
        <span className="text-xl font-semibold tabular-nums text-white">{value}</span>
        {unit && <span className="text-xs text-zinc-500">{unit}</span>}
      </dd>
    </div>
  );
}
