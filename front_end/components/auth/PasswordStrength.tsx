export function calculatePasswordStrength(pass: string): {
  score: number;
  label: string;
} {
  if (!pass) return { score: 0, label: "" };

  let score = 0;
  if (pass.length >= 8) score += 1;
  if (pass.length >= 12) score += 1;
  if (/[0-9]/.test(pass)) score += 1;
  if (/[^a-zA-Z0-9]/.test(pass)) score += 1;

  // Cap score between 1 and 4 when password has characters
  score = Math.min(4, Math.max(1, score));

  let label = "Weak";
  if (score === 1) {
    label = pass.length < 8 ? "Too short — at least 8 characters" : "Weak — add numbers or symbols";
  } else if (score === 2) {
    label = "Fair — add a number or symbol";
  } else if (score === 3) {
    label = "Good";
  } else if (score === 4) {
    label = "Strong password";
  }

  return { score, label };
}

export default function PasswordStrength({ password }: { password: string }) {
  const { score, label } = calculatePasswordStrength(password);

  if (!password) return null;

  return (
    <div className="flex flex-col gap-1.5 mt-2">
      <div className="grid grid-cols-4 gap-1.5">
        {[1, 2, 3, 4].map((step) => {
          const isActive = step <= score;
          return (
            <div
              key={step}
              className={`h-1 rounded-full transition-colors duration-200 ${
                isActive
                  ? score >= 4
                    ? "bg-emerald-400"
                    : "bg-[#f2b544]"
                  : "bg-[#232730]"
              }`}
            />
          );
        })}
      </div>
      {label && <p className="text-xs text-zinc-400">{label}</p>}
    </div>
  );
}
