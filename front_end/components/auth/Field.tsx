import React from "react";

interface FieldProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label: string;
  error?: string;
  rightLink?: React.ReactNode;
}

export default function Field({
  label,
  error,
  rightLink,
  id,
  className = "",
  ...props
}: FieldProps) {
  const inputId = id || props.name;

  return (
    <div className="flex flex-col gap-1.5 w-full">
      <div className="flex items-center justify-between text-xs font-medium text-zinc-300">
        <label htmlFor={inputId}>{label}</label>
        {rightLink}
      </div>
      <input
        id={inputId}
        className={`h-11 w-full rounded-lg border ${
          error ? "border-red-500/80 focus:border-red-500 focus:ring-red-500/20" : "border-line focus:border-accent focus:ring-accent/20"
        } bg-surface px-3.5 text-sm text-zinc-100 placeholder-zinc-500 focus:outline-none focus:ring-2 transition-colors ${className}`}
        aria-invalid={Boolean(error)}
        aria-describedby={error ? `${inputId}-error` : undefined}
        {...props}
      />
      {error && (
        <span id={`${inputId}-error`} className="text-xs text-red-400 mt-0.5">
          {error}
        </span>
      )}
    </div>
  );
}
