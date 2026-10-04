"use client";

import { useEffect, useId, useRef, useState } from "react";
import { api, ApiError, type User } from "@/lib/api";
import { AVAILABLE_LANGS, ROLES, type AvailableLang, type Role } from "@/lib/profile";
import { CheckIcon, XIcon } from "@/components/ui/icons";

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
  const [languages, setLanguages] = useState<AvailableLang[]>(
    user.debugLanguages.length > 0
      ? (user.debugLanguages.filter((l) =>
          AVAILABLE_LANGS.includes(l as AvailableLang),
        ) as AvailableLang[])
      : ["Python"],
  );

  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState("");
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});

  function toggleLanguage(lang: AvailableLang) {
    if (languages.includes(lang)) {
      if (languages.length === 1) return; // Must have at least one
      setLanguages(languages.filter((l) => l !== lang));
    } else {
      setLanguages([...languages, lang]);
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!fullName.trim()) {
      setFieldErrors({ fullName: "Display name cannot be empty" });
      return;
    }
    if (languages.length === 0) {
      setFieldErrors({ languages: "Pick at least one language" });
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
          languages,
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
        <h2 id={titleId} className="text-base font-semibold text-white">
          Edit profile
        </h2>
        <button
          type="button"
          onClick={onClose}
          className="rounded-md p-1 text-zinc-400 transition-colors hover:bg-surface-2 hover:text-white"
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
            className="mt-1.5 w-full rounded-lg border border-line-strong bg-canvas px-3.5 py-2 text-sm text-white placeholder-zinc-500 focus:border-accent focus:outline-none"
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
            className="mt-1.5 w-full rounded-lg border border-line-strong bg-canvas px-3.5 py-2 text-sm text-white focus:border-accent focus:outline-none"
          >
            {ROLES.map((r) => (
              <option key={r} value={r} className="bg-surface text-white">
                {r}
              </option>
            ))}
          </select>
          {fieldErrors.role && (
            <p className="mt-1 text-xs text-red-400">{fieldErrors.role}</p>
          )}
        </div>

        <div>
          <label className="block text-xs font-medium text-zinc-300">
            Practicing languages
          </label>
          <p className="mt-0.5 text-[11px] text-zinc-400">
            Pick at least one language you want to practice.
          </p>
          <div className="mt-2.5 flex flex-wrap gap-2">
            {AVAILABLE_LANGS.map((lang) => {
              const selected = languages.includes(lang);
              return (
                <button
                  key={lang}
                  type="button"
                  onClick={() => toggleLanguage(lang)}
                  className={`flex items-center gap-1.5 rounded-lg border px-3 py-1.5 text-xs font-medium transition-colors ${
                    selected
                      ? "border-accent bg-accent/10 text-accent"
                      : "border-line-strong bg-canvas text-zinc-400 hover:border-zinc-500 hover:text-zinc-200"
                  }`}
                >
                  {selected && <CheckIcon className="size-3" />}
                  {lang}
                </button>
              );
            })}
          </div>
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
