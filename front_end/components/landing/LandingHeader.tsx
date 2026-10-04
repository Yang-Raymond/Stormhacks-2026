import Link from "next/link";
import { LogoMark, PrimaryButton, container } from "./shared";

const links = [
  { href: "#how-it-works", label: "How it works" },
  { href: "#problems", label: "Problems" },
];

export default function LandingHeader() {
  return (
    <header className="sticky top-0 z-40 w-full border-b border-line bg-canvas/90 backdrop-blur">
      <div className={`${container} flex h-[72px] items-center justify-between`}>
        {/* Left: Brand */}
        <Link href="/" className="flex items-center gap-2.5 text-base font-bold tracking-tight text-white">
          <LogoMark />
          <span>LadyBug</span>
        </Link>

        {/* Center: Nav links */}
        <nav className="hidden items-center gap-8 md:flex">
          {links.map((link) => (
            <a
              key={link.href}
              href={link.href}
              className="text-sm font-medium text-zinc-400 transition-colors hover:text-zinc-100"
            >
              {link.label}
            </a>
          ))}
        </nav>

        {/* Right: Actions */}
        <div className="flex items-center gap-5">
          <Link
            href="/login"
            className="text-sm font-medium text-zinc-300 transition-colors hover:text-white"
          >
            Log in
          </Link>
          <PrimaryButton href="/register" className="h-9 px-4 text-xs font-semibold">
            Start practicing
          </PrimaryButton>
        </div>
      </div>
    </header>
  );
}
