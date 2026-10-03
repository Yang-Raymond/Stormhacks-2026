"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import { api } from "@/lib/api";

export default function AuthForm({ mode }: { mode: "login" | "register" }) {
  const router = useRouter();
  const [error, setError] = useState("");
  const [pending, setPending] = useState(false);

  async function onSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const form = new FormData(e.currentTarget);
    setPending(true);
    setError("");
    try {
      await api(`/auth/${mode}`, { body: { email: form.get("email"), password: form.get("password") } });
      router.push("/problems");
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setPending(false);
    }
  }

  return (
    <form onSubmit={onSubmit} className="mx-auto mt-16 flex w-80 flex-col gap-3">
      <h1 className="text-2xl font-bold">{mode === "login" ? "Login" : "Register"}</h1>
      <label className="flex flex-col gap-1">
        Email
        <input name="email" type="email" required className="rounded border border-zinc-600 bg-transparent p-2" />
      </label>
      <label className="flex flex-col gap-1">
        Password
        <input name="password" type="password" required minLength={8}
          autoComplete={mode === "login" ? "current-password" : "new-password"}
          className="rounded border border-zinc-600 bg-transparent p-2" />
      </label>
      {error && <p role="alert" className="text-red-400">{error}</p>}
      <button disabled={pending} className="rounded bg-blue-600 p-2 text-white disabled:opacity-50">
        {pending ? "..." : mode === "login" ? "Login" : "Create account"}
      </button>
    </form>
  );
}
