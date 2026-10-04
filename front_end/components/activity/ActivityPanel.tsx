"use client";

import { useEffect, useState } from "react";
import { api, type Activity } from "@/lib/api";
import ActivityHeatmap from "./ActivityHeatmap";

/** Streaks and a 26-week heatmap from the `daily_activity` continuous aggregate (Tiger Data). Hidden when logged out. */
export default function ActivityPanel() {
  const [activity, setActivity] = useState<Activity | null>(null);

  useEffect(() => {
    api<Activity>("/activity/me")
      .then(setActivity)
      .catch(() => setActivity(null));
  }, []);

  if (!activity) return null;

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
          <ActivityHeatmap days={activity.days} showDayLabels={true} showMonthLabels={true} />
        </div>
      </div>
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
