"use client";

import { useEffect, useId, useRef, useState } from "react";
import { api, ApiError, type User } from "@/lib/api";
import { ROLES, type Role } from "@/lib/profile";
import { LANGUAGES, preferredLanguage, type Language } from "@/lib/languages";
import { XIcon } from "@/components/ui/icons";

function EditProfileForm({
  user,
  onClose,
  onSuccess,
}: {
  user: User;
  onClose: () => void;
  onSuccess: (updatedUser: User) => void;
}) {
  const titleId = useId();

  const [fullName, setFullName] = useState(user.fullName || "");
  const [role, setRole] = useState<Role>((user.role as Role) || "Software engineer");
  const [language, setLanguage] = useState<Language>(preferredLanguage(user.debugLanguages));

  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState("");
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!fullName.trim()) {
      setFieldErrors({ fullName: "Display name cannot be empty" });
      return;
    }


    setSaving(true);
    setFormError("");
    setFieldErrors({});

    try {
      const res = await api<{ user: User }>("/auth/profile", {
        method: "PATCH",
        body: {
          fullName: fullName.trim(),
          role,
          languages: [language],
        },
      });

      if (typeof window !== "undefined") {
        window.dispatchEvent(
          new CustomEvent("ladybug:user-updated", { detail: { user: res.user } }),
        );
      }

      onSuccess(res.user);
      onClose();
    } catch (err) {
      if (err instanceof ApiError) {
        setFormError(err.message);
        if (err.issues) {
          const map: Record<string, string> = {};
          for (const [key, msgs] of Object.entries(err.issues)) {
            map[key] = msgs[0];
          }
          setFieldErrors(map);
        }
      } else {
        setFormError("Failed to update profile. Please try again.");
      }
    } finally {
      setSaving(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} aria-labelledby={titleId}>
      <div className="flex items-center justify-between border-b border-line px-6 py-4">
        <h2 id={titleId} className="text-base font-semibold text-foreground">
          Edit profile
        </h2>
        <button
          type="button"
          onClick={onClose}
          className="rounded-md p-1 text-zinc-400 transition-colors hover:bg-surface-2 hover:text-foreground"
        >
          <XIcon className="size-4" />
        </button>
      </div>

      <div className="space-y-5 px-6 py-5">
        {formError && (
          <div className="rounded-lg border border-red-900/50 bg-red-950/30 px-3.5 py-2.5 text-xs text-red-300">
            {formError}
          </div>
        )}

        <div>
          <label
            htmlFor="edit-fullName"
            className="block text-xs font-medium text-zinc-300"
          >
            Display name
          </label>
          <input
            id="edit-fullName"
            type="text"
            value={fullName}
            onChange={(e) => setFullName(e.target.value)}
            maxLength={100}
            required
            className="mt-1.5 w-full rounded-lg border border-line-strong bg-canvas px-3.5 py-2 text-sm text-foreground placeholder-zinc-500 focus:border-accent focus:outline-none"
          />
          {fieldErrors.fullName && (
            <p className="mt-1 text-xs text-red-400">{fieldErrors.fullName}</p>
          )}
        </div>

        <div>
          <label
            htmlFor="edit-role"
            className="block text-xs font-medium text-zinc-300"
          >
            Role
          </label>
          <select
            id="edit-role"
            value={role}
            onChange={(e) => setRole(e.target.value as Role)}
            className="mt-1.5 w-full rounded-lg border border-line-strong bg-canvas px-3.5 py-2 text-sm text-foreground focus:border-accent focus:outline-none"
          >
            {ROLES.map((r) => (
              <option key={r} value={r} className="bg-surface text-foreground">
                {r}
              </option>
            ))}
          </select>
          {fieldErrors.role && (
            <p className="mt-1 text-xs text-red-400">{fieldErrors.role}</p>
          )}
        </div>

        <div>
          <label htmlFor="edit-language" className="block text-xs font-medium text-zinc-300">
            Preferred language
          </label>
          <p className="mt-0.5 text-[11px] text-zinc-400">
            Problems open in this language when available.
          </p>
          <select
            id="edit-language"
            value={language}
            onChange={(e) => setLanguage(e.target.value as Language)}
            required
            className="mt-1.5 w-full rounded-lg border border-line-strong bg-canvas px-3.5 py-2 text-sm text-foreground focus:border-accent focus:outline-none"
          >
            {LANGUAGES.map((lang) => (
              <option key={lang.id} value={lang.id}>{lang.label}</option>
            ))}
          </select>
          {fieldErrors.languages && (
            <p className="mt-1 text-xs text-red-400">{fieldErrors.languages}</p>
          )}
        </div>
      </div>

      <div className="flex justify-end gap-2.5 border-t border-line bg-canvas-2/50 px-6 py-3.5">
        <button
          type="button"
          onClick={onClose}
          className="rounded-lg border border-line-strong px-4 py-2 text-xs font-medium text-zinc-300 transition-colors hover:bg-surface-2"
        >
          Cancel
        </button>
        <button
          type="submit"
          disabled={saving}
          className="rounded-lg bg-accent px-4 py-2 text-xs font-semibold text-zinc-950 transition-colors hover:bg-accent-hover disabled:opacity-50"
        >
          {saving ? "Saving..." : "Save changes"}
        </button>
      </div>
    </form>
  );
}

export default function EditProfileDialog({
  open,
  user,
  onClose,
  onSuccess,
}: {
  open: boolean;
  user: User;
  onClose: () => void;
  onSuccess: (updatedUser: User) => void;
}) {
  const dialogRef = useRef<HTMLDialogElement>(null);

  useEffect(() => {
    const dialog = dialogRef.current;
    if (!dialog) return;
    if (open && !dialog.open) dialog.showModal();
    if (!open && dialog.open) dialog.close();
  }, [open]);

  return (
    <dialog
      ref={dialogRef}
      onClose={onClose}
      onClick={(e) => e.target === dialogRef.current && onClose()}
      className="m-auto w-[calc(100%-2rem)] max-w-lg rounded-xl border border-line-strong bg-surface p-0 text-zinc-100 shadow-2xl shadow-black/80 backdrop:bg-black/60 backdrop:backdrop-blur-sm"
    >
      {open && (
        <EditProfileForm
          user={user}
          onClose={onClose}
          onSuccess={onSuccess}
        />
      )}
    </dialog>
  );
}
