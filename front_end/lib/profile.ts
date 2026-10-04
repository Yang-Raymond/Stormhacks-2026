export const ROLES = [
  "Software engineer",
  "Student",
  "Data scientist",
  "QA / test engineer",
  "Engineering manager",
  "Other",
] as const;

export type Role = (typeof ROLES)[number];

export function getInitials(name?: string | null, email?: string): string {
  if (name && name.trim()) {
    const parts = name.trim().split(/\s+/);
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0].slice(0, 2).toUpperCase();
  }
  if (email) {
    return email.slice(0, 2).toUpperCase();
  }
  return "LB";
}

export function formatDuration(seconds: number | null | undefined): string {
  if (seconds === null || seconds === undefined || seconds < 0) return "—";
  const hours = Math.floor(seconds / 3600);
  const mins = Math.floor((seconds % 3600) / 60);
  const secs = Math.floor(seconds % 60);

  if (hours > 0) {
    return `${hours}:${String(mins).padStart(2, "0")}:${String(secs).padStart(2, "0")}`;
  }
  return `${String(mins).padStart(2, "0")}:${String(secs).padStart(2, "0")}`;
}

export function formatMedianDuration(seconds: number | null | undefined): { value: string; unit: string } {
  if (seconds === null || seconds === undefined || seconds < 0) {
    return { value: "—", unit: "" };
  }
  if (seconds < 60) {
    return { value: `${Math.round(seconds)}`, unit: "sec" };
  }
  if (seconds < 3600) {
    return { value: `${Math.round(seconds / 60)}`, unit: "min" };
  }
  const hours = (seconds / 3600).toFixed(1);
  return { value: hours.endsWith(".0") ? hours.slice(0, -2) : hours, unit: "hr" };
}

export function formatJoined(iso?: string | null): string {
  if (!iso) return "Joined recently";
  const date = new Date(iso);
  if (isNaN(date.getTime())) return "Joined recently";
  const monthName = date.toLocaleString("en-US", { month: "long" });
  return `Joined ${monthName} ${date.getFullYear()}`;
}

export function relativeDay(iso: string): string {
  const date = new Date(iso);
  if (isNaN(date.getTime())) return "—";
  const now = new Date();
  const dateMidnight = new Date(date.getFullYear(), date.getMonth(), date.getDate()).getTime();
  const nowMidnight = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime();
  const dayDiff = Math.round((nowMidnight - dateMidnight) / 86_400_000);

  if (dayDiff <= 0) return "Today";
  if (dayDiff === 1) return "Yesterday";
  if (dayDiff < 7) return `${dayDiff} days ago`;
  if (dayDiff < 30) return `${Math.floor(dayDiff / 7)}w ago`;
  return date.toLocaleDateString("en-US", { month: "short", day: "numeric" });
}
