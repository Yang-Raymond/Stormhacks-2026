"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { api } from "@/lib/api";

export type SaveStatus = "idle" | "saved" | "unsaved" | "saving" | "error";

const AUTOSAVE_DELAY_MS = 800;

/**
 * Keeps the user's code for a problem saved on the server: autosaves shortly after typing stops, and
 * flushes any pending change when the page is hidden, closed, or navigated away from.
 */
export function useDraft(problemId: string, code: string) {
  /** Code known to be stored on the server; null until the problem has loaded. */
  const [savedCode, setSavedCode] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [failed, setFailed] = useState(false);
  const latest = useRef({ code, savedCode });
  const revision = useRef(0);
  const pendingSaves = useRef(0);
  const timer = useRef<ReturnType<typeof setTimeout> | undefined>(undefined);

  useEffect(() => {
    latest.current = { code, savedCode };
  });

  const save = useCallback(
    async (value: string) => {
      const atRevision = revision.current;
      pendingSaves.current += 1;
      setSaving(true);
      try {
        await api(`/problems/${problemId}/draft`, { method: "PUT", body: { code: value } });
        if (atRevision !== revision.current) return;
        setSavedCode(value);
        setFailed(false);
      } catch {
        if (atRevision === revision.current) setFailed(true);
      } finally {
        pendingSaves.current -= 1;
        setSaving(pendingSaves.current > 0);
      }
    },
    [problemId],
  );

  useEffect(() => {
    if (savedCode === null || code === savedCode) return;
    timer.current = setTimeout(() => void save(code), AUTOSAVE_DELAY_MS);
    return () => clearTimeout(timer.current);
  }, [code, savedCode, save]);

  useEffect(() => {
    const flush = () => {
      const { code, savedCode } = latest.current;
      if (savedCode === null || (code === savedCode && pendingSaves.current === 0)) return;
      latest.current.savedCode = code;
      api(`/problems/${problemId}/draft`, { method: "PUT", body: { code }, keepalive: true }).catch(() => {});
    };
    const onVisibility = () => document.visibilityState === "hidden" && flush();
    window.addEventListener("pagehide", flush);
    document.addEventListener("visibilitychange", onVisibility);
    return () => {
      window.removeEventListener("pagehide", flush);
      document.removeEventListener("visibilitychange", onVisibility);
      flush(); // leaving the problem through in-app navigation, e.g. back to the list
    };
  }, [problemId]);

  const status: SaveStatus =
    savedCode === null ? "idle" : saving ? "saving" : code === savedCode ? "saved" : failed ? "error" : "unsaved";

  return {
    status,
    /** Record code the server already has (the loaded draft, or code just sent with Run/Submit). */
    markSaved: (value: string) => {
      latest.current.savedCode = value;
      setSavedCode(value);
      setFailed(false);
    },
    /** Delete the saved draft so the problem opens with its original code again. */
    discard: async (original: string) => {
      clearTimeout(timer.current);
      revision.current += 1;
      latest.current = { code: original, savedCode: original };
      setSavedCode(original);
      await api(`/problems/${problemId}/draft`, { method: "DELETE" });
    },
  };
}
