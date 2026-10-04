"use client";

import { getInitials } from "@/lib/profile";

type AvatarSize = "sm" | "md" | "lg";

const sizes: Record<AvatarSize, { container: string; text: string }> = {
  sm: {
    container: "size-8 text-xs border border-accent/60",
    text: "font-semibold tracking-wide",
  },
  md: {
    container: "size-12 text-base border-2 border-accent/70",
    text: "font-bold tracking-wider",
  },
  lg: {
    container: "size-20 sm:size-22 text-2xl border-2 border-accent/80",
    text: "font-bold tracking-wider",
  },
};

export default function Avatar({
  name,
  email,
  avatarUrl,
  size = "sm",
  className = "",
}: {
  name?: string | null;
  email?: string;
  avatarUrl?: string | null;
  size?: AvatarSize;
  className?: string;
}) {
  const { container, text } = sizes[size];
  const initials = getInitials(name, email);

  if (avatarUrl) {
    return (
      <div
        className={`relative shrink-0 overflow-hidden rounded-full bg-surface-2 ${container} ${className}`}
      >
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img
          src={avatarUrl}
          alt={name || email || "User avatar"}
          className="h-full w-full object-cover"
        />
      </div>
    );
  }

  return (
    <div
      aria-hidden="true"
      className={`flex shrink-0 select-none items-center justify-center rounded-full bg-[#1c1810] text-accent ${container} ${className}`}
    >
      <span className={text}>{initials}</span>
    </div>
  );
}
