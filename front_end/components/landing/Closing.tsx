import Link from "next/link";
import { PrimaryButton, container } from "./shared";

export function FinalCta() {
  return (
    <section className="border-t border-line/60 py-20 sm:py-24">
      <div className={`${container} flex flex-col items-start justify-between gap-8 md:flex-row md:items-center`}>
        <div>
          <h2 className="text-3xl font-extrabold tracking-tight text-white sm:text-4xl">
            Today&apos;s bug is waiting.
          </h2>
          <p className="mt-3 text-sm sm:text-base text-zinc-400">
            Create a free account and solve your first problem in a few minutes.
          </p>
        </div>
        <PrimaryButton href="/register" className="h-11 shrink-0 px-6 text-sm">
          Create free account
        </PrimaryButton>
      </div>
    </section>
  );
}

const footerLinks = [
  { href: "/problems", label: "Problems" },
  { href: "#", label: "Blog" },
  { href: "/privacy", label: "Privacy" },
  { href: "/terms", label: "Terms" },
];

export function LandingFooter() {
  return (
    <footer className="border-t border-line py-10">
      <div className={`${container} flex flex-col items-center justify-between gap-6 sm:flex-row`}>
        {/* Left: Brand */}
        <span className="text-sm font-bold tracking-tight text-white">LadyBug</span>

        {/* Center: Links */}
        <nav className="flex items-center gap-6 sm:gap-8">
          {footerLinks.map((link) => (
            <Link
              key={link.label}
              href={link.href}
              className="text-xs text-zinc-400 transition-colors hover:text-zinc-200"
            >
              {link.label}
            </Link>
          ))}
        </nav>

        {/* Right: Copyright */}
        <span className="text-xs text-zinc-500">
          © 2026 LadyBug
        </span>
      </div>
    </footer>
  );
}
