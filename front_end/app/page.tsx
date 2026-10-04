import BugTypes from "@/components/landing/BugTypes";
import { FinalCta, LandingFooter } from "@/components/landing/Closing";
import Features from "@/components/landing/Features";
import Hero from "@/components/landing/Hero";
import HowItWorks from "@/components/landing/HowItWorks";

export default function Home() {
  return (
    <div className="min-h-screen bg-canvas text-zinc-100">
      <main>
        <Hero />
        <HowItWorks />
        <Features />
        <BugTypes />
        <FinalCta />
      </main>
      <LandingFooter />
    </div>
  );
}
