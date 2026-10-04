"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import ActivityHeatmap from "@/components/activity/ActivityHeatmap";
import EditProfileDialog from "@/components/profile/EditProfileDialog";
import Avatar from "@/components/ui/Avatar";
import { CalendarIcon, CheckIcon, XIcon } from "@/components/ui/icons";
import {
  api,
  type Activity,
  type ProfileResponse,
  type User,
} from "@/lib/api";
import {
  formatDuration,
  formatJoined,
  formatMedianDuration,
  relativeDay,
} from "@/lib/profile";

export default function ProfilePage() {
  const router = useRouter();

  const [profileData, setProfileData] = useState<ProfileResponse | null>(null);
  const [activityData, setActivityData] = useState<Activity | null>(null);
  const [loading, setLoading] = useState(true);
  const [isEditOpen, setIsEditOpen] = useState(false);
  const [showAllSubmissions, setShowAllSubmissions] = useState(false);

  useEffect(() => {
    Promise.all([
      api<ProfileResponse>("/profile/me"),
      api<Activity>("/activity/me").catch(() => null),
    ])
      .then(([prof, act]) => {
        setProfileData(prof);
        setActivityData(act);
        setLoading(false);
      })
      .catch(() => {
        router.replace("/login");
      });
  }, [router]);

  function handleUserUpdated(updatedUser: User) {
    if (!profileData) return;
    setProfileData({
      ...profileData,
      user: {
        ...profileData.user,
        ...updatedUser,
      },
    });
  }

  if (loading || !profileData) {
    return (
      <div className="mx-auto w-full max-w-6xl px-4 py-8 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 gap-6 lg:grid-cols-[280px_1fr]">
          {/* Left skeleton */}
          <div className="space-y-6">
            <div className="h-56 animate-pulse rounded-xl border border-line bg-surface" />
            <div className="h-44 animate-pulse rounded-xl border border-line bg-surface" />
          </div>

          {/* Right skeleton */}
          <div className="space-y-6">
            <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
              {[0, 1, 2, 3].map((i) => (
                <div
                  key={i}
                  className="h-24 animate-pulse rounded-xl border border-line bg-surface"
                />
              ))}
            </div>
            <div className="h-44 animate-pulse rounded-xl border border-line bg-surface" />
            <div className="h-48 animate-pulse rounded-xl border border-line bg-surface" />
            <div className="h-64 animate-pulse rounded-xl border border-line bg-surface" />
          </div>
        </div>
      </div>
    );
  }

  const { user, stats, byDifficulty, languages, recent } = profileData;

  const medianTime = formatMedianDuration(stats.medianSolveSeconds);
  const noHintPercent =
    stats.noHintRate !== null ? `${Math.round(stats.noHintRate * 100)}` : "—";

  const streakDays = activityData?.streak.current ?? 0;
  const bestStreak = activityData?.streak.longest ?? 0;

  const submissionsToShow = showAllSubmissions ? recent : recent.slice(0, 5);

  return (
    <div className="mx-auto w-full max-w-6xl px-4 py-8 sm:px-6 lg:px-8">
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-[280px_1fr]">
        {/* Left Column: Identity & Languages */}
        <div className="flex flex-col gap-6">
          {/* Identity Card */}
          <div className="rounded-xl border border-line bg-surface p-5">
            <div className="flex items-center gap-4">
              <Avatar
                size="md"
                name={user.fullName}
                email={user.email}
                avatarUrl={user.avatarUrl}
              />
              <div className="min-w-0 flex-1">
                <h1 className="truncate text-lg font-bold text-white">
                  {user.fullName || "User"}
                </h1>
                <p className="truncate font-mono text-xs text-zinc-400">
                  {user.email}
                </p>
              </div>
            </div>

            <button
              type="button"
              onClick={() => setIsEditOpen(true)}
              className="mt-5 w-full rounded-lg border border-line-strong bg-surface-2 px-3 py-2 text-center text-xs font-semibold text-zinc-200 transition-colors hover:bg-zinc-800 hover:text-white"
            >
              Edit profile
            </button>

            <div className="mt-5 flex items-center gap-2 text-xs text-zinc-400">
              <CalendarIcon className="size-4 shrink-0 text-zinc-500" />
              <span>{formatJoined(user.createdAt)}</span>
            </div>
          </div>

          {/* Languages Card */}
          <div className="rounded-xl border border-line bg-surface p-5">
            <h2 className="text-sm font-semibold text-white">Languages</h2>
            {languages.length > 0 ? (
              <div className="mt-4 space-y-3">
                {languages.map((l) => (
                  <div
                    key={l.language}
                    className="flex items-center justify-between text-xs"
                  >
                    <span className="font-medium text-zinc-200 capitalize">
                      {l.language}
                    </span>
                    <span className="font-mono text-zinc-400">
                      {l.solved} solved
                    </span>
                  </div>
                ))}
              </div>
            ) : (
              <p className="mt-3 text-xs text-zinc-500">
                No solved problems yet.
              </p>
            )}
          </div>
        </div>

        {/* Right Column: Stats, Breakdown, Activity, Submissions */}
        <div className="flex flex-col gap-6">
          {/* 4 Stat Cards */}
          <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
            {/* Bugs solved */}
            <div className="rounded-xl border border-line bg-surface p-4">
              <p className="text-xs font-medium text-zinc-400">Bugs solved</p>
              <div className="mt-2 flex items-baseline">
                <span className="text-2xl font-bold tabular-nums text-white sm:text-3xl">
                  {stats.solved}
                </span>
                <span className="ml-1.5 text-xs font-medium text-zinc-500 sm:text-sm">
                  / {stats.total}
                </span>
              </div>
            </div>

            {/* Current streak */}
            <div className="rounded-xl border border-line bg-surface p-4">
              <p className="text-xs font-medium text-zinc-400">Current streak</p>
              <div className="mt-2 flex items-baseline">
                <span className="text-2xl font-bold tabular-nums text-white sm:text-3xl">
                  {streakDays}
                </span>
                <span className="ml-1.5 text-xs font-medium text-zinc-500 sm:text-sm">
                  {streakDays === 1 ? "day" : "days"} · best {bestStreak}
                </span>
              </div>
            </div>

            {/* Median solve time */}
            <div className="rounded-xl border border-line bg-surface p-4">
              <p className="text-xs font-medium text-zinc-400">Median solve time</p>
              <div className="mt-2 flex items-baseline">
                <span className="text-2xl font-bold tabular-nums text-white sm:text-3xl">
                  {medianTime.value}
                </span>
                {medianTime.unit && (
                  <span className="ml-1 text-xs font-medium text-zinc-400 sm:text-sm">
                    {medianTime.unit}
                  </span>
                )}
              </div>
            </div>

            {/* Solved without hints */}
            <div className="rounded-xl border border-line bg-surface p-4">
              <p className="text-xs font-medium text-zinc-400">
                Solved without hints
              </p>
              <div className="mt-2 flex items-baseline">
                <span className="text-2xl font-bold tabular-nums text-white sm:text-3xl">
                  {noHintPercent}
                </span>
                {stats.noHintRate !== null && (
                  <span className="ml-0.5 text-base font-bold text-zinc-400 sm:text-lg">
                    %
                  </span>
                )}
              </div>
            </div>
          </div>

          {/* Solved by difficulty */}
          <div className="rounded-xl border border-line bg-surface p-5">
            <h2 className="text-sm font-semibold text-white">
              Solved by difficulty
            </h2>
            <div className="mt-4 space-y-4">
              {byDifficulty.map((d) => {
                const percent =
                  d.total > 0 ? Math.min(100, Math.round((d.solved / d.total) * 100)) : 0;
                return (
                  <div key={d.difficulty} className="space-y-1.5">
                    <div className="flex items-center justify-between text-xs">
                      <span className="font-medium capitalize text-zinc-200">
                        {d.difficulty}
                      </span>
                      <span className="font-mono text-zinc-400">
                        {d.solved} / {d.total}
                      </span>
                    </div>
                    <div className="h-1.5 w-full overflow-hidden rounded-full bg-surface-2">
                      <div
                        className="h-full rounded-full bg-accent transition-all duration-300"
                        style={{ width: `${percent}%` }}
                      />
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Activity Heatmap */}
          <div className="rounded-xl border border-line bg-surface p-5">
            <div className="flex flex-wrap items-center justify-between gap-2">
              <h2 className="text-sm font-semibold text-white">Activity</h2>
              <p className="text-xs text-zinc-400">
                Problems attempted per day, last 26 weeks
              </p>
            </div>
            <div className="mt-4">
              {activityData?.days && activityData.days.length > 0 ? (
                <ActivityHeatmap
                  days={activityData.days}
                  showDayLabels={false}
                  showMonthLabels={false}
                />
              ) : (
                <p className="text-xs text-zinc-500">No activity recorded yet.</p>
              )}
            </div>
          </div>

          {/* Recent submissions */}
          <div className="rounded-xl border border-line bg-surface p-5">
            <div className="flex items-center justify-between">
              <h2 className="text-sm font-semibold text-white">
                Recent submissions
              </h2>
              {recent.length > 5 && (
                <button
                  type="button"
                  onClick={() => setShowAllSubmissions((prev) => !prev)}
                  className="text-xs font-semibold text-accent transition-colors hover:text-accent-hover"
                >
                  {showAllSubmissions ? "Show less" : "View all"}
                </button>
              )}
            </div>

            {submissionsToShow.length > 0 ? (
              <div className="mt-4 overflow-x-auto">
                <table className="w-full text-left text-xs">
                  <thead>
                    <tr className="border-b border-line text-[11px] font-semibold uppercase tracking-wider text-zinc-500">
                      <th className="pb-2.5 font-medium">Problem</th>
                      <th className="pb-2.5 font-medium">Difficulty</th>
                      <th className="pb-2.5 font-medium">Result</th>
                      <th className="pb-2.5 font-medium">Time</th>
                      <th className="pb-2.5 text-right font-medium">When</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-line/60">
                    {submissionsToShow.map((sub) => (
                      <tr
                        key={sub.id}
                        className="transition-colors hover:bg-surface-2/40"
                      >
                        <td className="py-3 pr-4 font-medium">
                          <Link
                            href={`/problems/${sub.problemId}`}
                            className="text-zinc-200 transition-colors hover:text-white"
                          >
                            {sub.title}
                          </Link>
                        </td>
                        <td className="py-3 pr-4 capitalize text-zinc-400">
                          {sub.difficulty}
                        </td>
                        <td className="py-3 pr-4">
                          {sub.passed ? (
                            <span className="flex items-center gap-1.5 font-medium text-easy">
                              <CheckIcon className="size-3.5" />
                              Accepted
                            </span>
                          ) : (
                            <span className="flex items-center gap-1.5 font-medium text-red-400">
                              <XIcon className="size-3.5" />
                              {sub.passedCount < sub.totalCount
                                ? `Hidden test failed`
                                : `Failed`}
                            </span>
                          )}
                        </td>
                        <td className="py-3 pr-4 font-mono tabular-nums text-zinc-400">
                          {formatDuration(sub.elapsedSeconds)}
                        </td>
                        <td className="py-3 text-right text-zinc-400">
                          {relativeDay(sub.createdAt)}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ) : (
              <div className="mt-4 py-8 text-center text-xs text-zinc-500">
                <p>No submissions yet.</p>
                <Link
                  href="/problems"
                  className="mt-2 inline-block font-semibold text-accent hover:underline"
                >
                  Start solving problems &rarr;
                </Link>
              </div>
            )}
          </div>
        </div>
      </div>

      <EditProfileDialog
        open={isEditOpen}
        user={user}
        onClose={() => setIsEditOpen(false)}
        onSuccess={handleUserUpdated}
      />
    </div>
  );
}
