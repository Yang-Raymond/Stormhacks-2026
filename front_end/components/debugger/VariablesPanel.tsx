"use client";

import { useMemo } from "react";
import type { Debugger } from "@/hooks/useDebugger";
import { changedLocals } from "@/lib/debugger";
import { Empty, Section, ValueText } from "./shared";

export default function VariablesPanel({ dbg }: { dbg: Debugger }) {
  const { steps, stepIndex, frameIndex, step } = dbg;
  const changed = useMemo(() => changedLocals(steps, stepIndex, frameIndex), [steps, stepIndex, frameIndex]);
  const frame = step?.frames[frameIndex];
  const locals = Object.entries(frame?.locals ?? {});
  const innermost = frameIndex === 0;

  return (
    <Section title={frame ? `Variables · ${frame.name}` : "Variables"}>
      <dl className="py-1 text-xs">
        {innermost && step?.event === "return" && (
          <Row name="↩ return" nameClass="text-accent-ink">
            <ValueText value={step.value ?? "None"} />
          </Row>
        )}
        {innermost && step?.event === "exception" && (
          <Row name="⚠ raised" nameClass="text-red-400">
            <span className="whitespace-pre-wrap break-all font-mono text-red-300">{step.exception}</span>
          </Row>
        )}
        {locals.map(([name, value]) => (
          <Row key={name} name={name} highlight={changed.has(name)}>
            <ValueText value={value} />
          </Row>
        ))}
      </dl>
      {!locals.length && step?.event === "line" && <Empty>No local variables yet.</Empty>}
    </Section>
  );
}

function Row({ name, nameClass = "text-zinc-400", highlight, children }: {
  name: string;
  nameClass?: string;
  highlight?: boolean;
  children: React.ReactNode;
}) {
  return (
    <div
      className={`grid grid-cols-[minmax(4rem,max-content)_1fr] gap-x-3 px-3 py-1 ${highlight ? "bg-accent/10" : ""}`}
      title={highlight ? "Changed on this step" : undefined}
    >
      <dt className={`font-mono ${nameClass}`}>
        {name}
        {highlight && <span className="ml-1 text-accent-ink">•</span>}
      </dt>
      <dd className="min-w-0">{children}</dd>
    </div>
  );
}
