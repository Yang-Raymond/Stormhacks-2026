"use client";

import { useSyncExternalStore } from "react";
import type { ThemePreference } from "@/lib/theme";

function subscribe(onChange: () => void) {
  const observer = new MutationObserver(onChange);
  observer.observe(document.documentElement, { attributes: true, attributeFilter: ["data-theme", "data-theme-preference"] });
  return () => observer.disconnect();
}

function snapshot() {
  const { themePreference = "system", theme = "dark" } = document.documentElement.dataset;
  return `${themePreference}:${theme}`;
}

export function useTheme() {
  const state = useSyncExternalStore(subscribe, snapshot, () => "system:dark");
  const [preference, resolved] = state.split(":");
  return { preference: preference as ThemePreference, resolved: resolved as "light" | "dark" };
}
