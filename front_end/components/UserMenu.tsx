"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useRef, useState } from "react";
import Avatar from "@/components/ui/Avatar";
import { ChevronDownIcon, LogOutIcon, UserIcon } from "@/components/ui/icons";
import type { User } from "@/lib/api";

export default function UserMenu({
  user,
  onLogout,
  className = "",
}: {
  user: User;
  onLogout: () => void | Promise<void>;
  className?: string;
}) {
  const [isOpen, setIsOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);
  const triggerRef = useRef<HTMLButtonElement>(null);
  const pathname = usePathname();

  const [prevPathname, setPrevPathname] = useState(pathname);
  if (prevPathname !== pathname) {
    setPrevPathname(pathname);
    setIsOpen(false);
  }

  // Click outside to close
  useEffect(() => {
    if (!isOpen) return;

    function handleClickOutside(e: MouseEvent) {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) {
        setIsOpen(false);
      }
    }

    function handleKeyDown(e: KeyboardEvent) {
      if (e.key === "Escape") {
        setIsOpen(false);
        triggerRef.current?.focus();
      }
    }

    document.addEventListener("mousedown", handleClickOutside);
    document.addEventListener("keydown", handleKeyDown);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
      document.removeEventListener("keydown", handleKeyDown);
    };
  }, [isOpen]);

  const displayName = user.fullName || user.email.split("@")[0];

  return (
    <div ref={menuRef} className={`relative inline-block text-left ${className}`}>
      <button
        ref={triggerRef}
        type="button"
        onClick={() => setIsOpen((prev) => !prev)}
        aria-haspopup="menu"
        aria-expanded={isOpen}
        className="group flex items-center gap-2.5 rounded-full py-1 pl-1 pr-2 text-sm transition-colors hover:bg-surface-2/80 focus:outline-none focus-visible:ring-2 focus-visible:ring-accent"
      >
        <Avatar
          size="sm"
          name={user.fullName}
          email={user.email}
          avatarUrl={user.avatarUrl}
        />
        <span className="hidden max-w-44 truncate font-medium text-zinc-300 group-hover:text-white sm:inline">
          {displayName}
        </span>
        <ChevronDownIcon
          className={`size-3.5 text-zinc-400 transition-transform duration-200 group-hover:text-zinc-200 ${
            isOpen ? "rotate-180" : ""
          }`}
        />
      </button>

      {isOpen && (
        <div
          role="menu"
          aria-orientation="vertical"
          className="absolute right-0 top-full mt-2 w-56 origin-top-right rounded-xl border border-line-strong bg-surface p-1.5 shadow-2xl shadow-black/80 z-50 focus:outline-none animate-in fade-in-0 zoom-in-95 duration-100"
        >
          <div className="border-b border-line px-3 py-2">
            <p className="truncate text-xs font-semibold text-white">
              {user.fullName || "User"}
            </p>
            <p className="truncate font-mono text-[11px] text-zinc-400">
              {user.email}
            </p>
          </div>

          <div className="py-1">
            <Link
              href="/profile"
              onClick={() => setIsOpen(false)}
              role="menuitem"
              className="flex items-center gap-2.5 rounded-lg px-3 py-2 text-xs font-medium text-zinc-200 transition-colors hover:bg-surface-2 hover:text-white"
            >
              <UserIcon className="size-4 text-zinc-400" />
              Profile
            </Link>
          </div>

          <div className="border-t border-line pt-1">
            <button
              type="button"
              onClick={async () => {
                setIsOpen(false);
                await onLogout();
              }}
              role="menuitem"
              className="flex w-full items-center gap-2.5 rounded-lg px-3 py-2 text-xs font-medium text-zinc-400 transition-colors hover:bg-surface-2 hover:text-zinc-100"
            >
              <LogOutIcon className="size-4" />
              Log out
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
