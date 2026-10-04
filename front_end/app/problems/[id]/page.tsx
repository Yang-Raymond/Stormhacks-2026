"use client";

import Link from "next/link";
import { useParams, useRouter } from "next/navigation";
import { type ReactNode, useEffect, useMemo, useState } from "react";
import { Group, Panel, Separator } from "react-resizable-panels";
import CodeEditor from "@/components/CodeEditor";
import DebugPanel from "@/components/debugger/DebugPanel";
import DebugToolbar from "@/components/debugger/DebugToolbar";
import ProblemDescription from "@/components/problem/ProblemDescription";
import ResultsPanel, { type ResultState } from "@/components/problem/ResultsPanel";
import TestcasePanel, { CUSTOM_CASE, type TestcaseOption } from "@/components/problem/TestcasePanel";
import ConfirmDialog from "@/components/ui/ConfirmDialog";
import {
  BugIcon,
  LightbulbIcon,
  CheckIcon,
  FileTextIcon,
  FlaskIcon,
  PlayIcon,
  ResetIcon,
  StopIcon,
  TerminalIcon,
  UploadIcon,
} from "@/components/ui/icons";
import { useDebugger } from "@/hooks/useDebugger";
import { type SaveStatus, useDraft } from "@/hooks/useDraft";
import { useMediaQuery } from "@/hooks/useMediaQuery";
import HintCard, { type HintState } from "@/components/problem/HintCard";
import { api, type Features, type Problem, type RunResult, type TestResult } from "@/lib/api";
import { inlineValues } from "@/lib/debugger";
import { DEBUGGABLE, languageInfo } from "@/lib/languages";
import { paramNames } from "@/lib/python";

type BottomTab = "testcase" | "result" | "debug";

const show = (v: unknown) => JSON.stringify(v);

function parseCustom(values: string[]) {
  const errors = values.map((v) => {
    try {
      JSON.parse(v);
      return null;
    } catch {
      return "Not valid JSON";
    }
  });
  return { errors, args: errors.some(Boolean) ? null : values.map((v) => JSON.parse(v) as unknown) };
}

export default function ProblemPage() {
  const { id } = useParams<{ id: string }>();
  const router = useRouter();
  const [problem, setProblem] = useState<Problem | null>(null);
  const [code, setCode] = useState("");
  const [result, setResult] = useState<ResultState | null>(null);
  const [pending, setPending] = useState<"run" | "submit" | null>(null);
  const [error, setError] = useState("");
  const [tab, setTab] = useState<BottomTab>("testcase");
  const [caseKey, setCaseKey] = useState("case-0");
  const [customValues, setCustomValues] = useState<string[] | null>(null);
  const [confirmingReset, setConfirmingReset] = useState(false);
  const [features, setFeatures] = useState<Features>({ hints: false, insights: false });
  const [hint, setHint] = useState<HintState | null>(null);

  useEffect(() => {
    api<Features>("/features").then(setFeatures).catch(() => {});
  }, []);
  const dbg = useDebugger(id);
  const draft = useDraft(id, code);
  const isDesktop = useMediaQuery("(min-width: 1024px)");

  useEffect(() => {
    api<{ problem: Problem }>(`/problems/${id}`)
      .then(({ problem }) => {
        const initial = problem.savedCode ?? problem.buggyCode;
        setProblem(problem);
        setCode(initial);
        draft.markSaved(initial);
      })
      .catch((e: Error) => setError(e.message));
    // markSaved is a fresh function every render; this should only run when the problem changes.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  const params = useMemo(
    () => (problem ? (problem.signature?.params.map((p) => p.name) ?? paramNames(problem.buggyCode, problem.entryPoint)) : []),
    [problem],
  );
  const canDebug = problem ? DEBUGGABLE.has(problem.language) : false;
  const lines = useMemo(() => code.split("\n"), [code]);
  const lineText = (line: number) => lines[line - 1] ?? "";

  const cases = useMemo<TestcaseOption[]>(() => {
    if (!problem) return [];
    const examples = problem.examples.map((t, i) => ({ key: `case-${i}`, label: `Case ${i + 1}`, args: t.args, expected: t.expected }));
    const hidden = result?.hiddenFailure;
    return hidden
      ? [...examples, { key: "hidden", label: `Hidden #${hidden.testNumber}`, args: hidden.args, expected: hidden.expected, hidden: true }]
      : examples;
  }, [problem, result]);

  const custom = customValues ?? problem?.examples[0]?.args.map(show) ?? params.map(() => "");
  const parsedCustom = useMemo(() => parseCustom(custom), [custom]);
  const selectedCase = caseKey === CUSTOM_CASE ? undefined : (cases.find((c) => c.key === caseKey) ?? cases[0]);
  const debugArgs = caseKey === CUSTOM_CASE ? parsedCustom.args : selectedCase?.args;
  const caseLabel = caseKey === CUSTOM_CASE ? "custom input" : (selectedCase?.label ?? "");

  /** Asks Snowflake Cortex for a nudge; uses the given failing case, or the first one from the last run. */
  async function requestHint(failing?: TestResult) {
    const fromResult = result?.visibleResults.find((r) => !r.passed) ?? result?.hiddenFailure;
    const target = failing ?? fromResult;
    setTab("result");
    setHint({ status: "loading" });
    try {
      const { hint: text } = await api<{ hint: string }>(`/problems/${id}/hint`, {
        body: {
          code,
          failing: target && { args: target.args, expected: target.expected, actual: target.actual, error: target.error },
        },
      });
      setHint({ status: "done", text });
    } catch (e) {
      setHint({ status: "error", message: (e as Error).message });
    }
  }

  async function execute(kind: "run" | "submit") {
    setPending(kind);
    setError("");
    setTab("result");
    try {
      const sent = code;
      const r = await api<RunResult>(`/problems/${id}/${kind}`, { body: { code: sent } });
      draft.markSaved(sent); // the server stores run/submitted code as the draft
      setResult({ ...r, kind });
      if (kind === "submit" && r.passed) setProblem((p) => p && { ...p, solved: true });
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setPending(null);
    }
  }

  async function resetCode() {
    if (!problem) return;
    setConfirmingReset(false);
    setCode(problem.buggyCode);
    setResult(null);
    try {
      await draft.discard(problem.buggyCode);
    } catch (e) {
      setError(`Code was reset here, but the saved copy could not be deleted: ${(e as Error).message}`);
    }
  }

  async function startDebug(key = caseKey) {
    if (!problem || !canDebug) return;
    const args = key === CUSTOM_CASE ? parsedCustom.args : (cases.find((c) => c.key === key) ?? cases[0])?.args;
    if (!args) {
      setTab("testcase");
      return;
    }
    setCaseKey(key);
    setTab("debug");
    await dbg.start(code, args, `${problem.entryPoint}(${args.map(show).join(", ")})`);
  }

  // VS Code-style debugger shortcuts. F5 starts a session when none is running.
  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      const c = dbg.controls;
      const key = `${e.ctrlKey || e.metaKey ? "Ctrl+" : ""}${e.shiftKey ? "Shift+" : ""}${e.key}`;
      const actions: Record<string, (() => void) | undefined> = c
        ? {
            F5: c.continue,
            "Shift+F5": dbg.stop,
            "Ctrl+Shift+F5": c.restart,
            F10: c.stepOver,
            "Shift+F10": c.stepBack,
            F11: c.stepInto,
            "Shift+F11": c.stepOut,
          }
        : { F5: canDebug ? () => void startDebug() : undefined };
      const action = actions[key];
      if (!action) return;
      e.preventDefault();
      action();
    }
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  });

  const inline = useMemo(
    () => (dbg.active && dbg.frameIndex === 0 ? inlineValues(dbg.steps, dbg.stepIndex, (l) => lines[l - 1] ?? "") : []),
    [dbg.active, dbg.frameIndex, dbg.steps, dbg.stepIndex, lines],
  );

  if (!problem) {
    return (
      <div className="flex flex-1 items-center justify-center p-6">
        {error ? (
          <div className="text-center">
            <p className="text-red-400">{error}</p>
            <Link href="/problems" className="mt-3 inline-block text-sm text-accent hover:underline">Back to problems</Link>
          </div>
        ) : (
          <span className="h-5 w-5 animate-spin rounded-full border-2 border-line-strong border-t-accent" aria-label="Loading" />
        )}
      </div>
    );
  }

  const frame = dbg.step?.frames[dbg.frameIndex];
  const language = languageInfo(problem.language);

  const descriptionCard = (
    <Card>
      <CardTabs>
        <CardTab active icon={<FileTextIcon className="size-3.5" />}>Description</CardTab>
      </CardTabs>
      <div className="min-h-0 flex-1 overflow-auto">
        <ProblemDescription problem={problem} />
      </div>
    </Card>
  );

  const editorCard = (
    <Card>
      <div className="flex h-10 shrink-0 items-center gap-2 border-b border-line bg-[#111317] px-2">
        <span className="flex items-center gap-2 px-2 text-xs font-medium text-zinc-300">
          Code
          {problem.variants.length > 1 ? (
            <select
              aria-label="Language"
              value={problem.id}
              onChange={(e) => router.push(`/problems/${e.target.value}`)}
              className="rounded border border-line bg-surface-2 px-1 py-0.5 font-mono text-[10px] text-zinc-300 outline-none hover:border-line-strong focus:border-accent"
            >
              {problem.variants
                .map((v) => ({ id: v.id, label: languageInfo(v.language).label }))
                .sort((a, b) => a.label.localeCompare(b.label))
                .map((v) => (
                  <option key={v.id} value={v.id}>{v.label}</option>
                ))}
            </select>
          ) : (
            <span className="rounded border border-line bg-surface-2 px-1.5 py-0.5 font-mono text-[10px] text-zinc-500">{language.label}</span>
          )}
        </span>
        {!dbg.active && <SaveIndicator status={draft.status} />}
        {dbg.active && (
          <span className="flex items-center gap-1.5 rounded-full border border-accent/30 bg-accent/10 px-2 py-0.5 text-[11px] text-accent">
            <span className="h-1.5 w-1.5 animate-pulse rounded-full bg-accent" />
            Debugging {caseLabel} · read-only
          </span>
        )}
        <div className="ml-auto flex items-center gap-1.5">
          {!dbg.active && (
            <ToolbarButton
              onClick={() => setConfirmingReset(true)}
              disabled={pending !== null || code === problem.buggyCode}
              title={code === problem.buggyCode ? "Already the original code" : "Reset to the original buggy code"}
              className="text-zinc-400 hover:bg-surface-2 hover:text-zinc-100"
            >
              <ResetIcon className="size-3.5" /> Reset
            </ToolbarButton>
          )}
          {dbg.active ? (
            <ToolbarButton onClick={dbg.stop} title="Stop debugging (Shift+F5)" className="border border-red-500/30 text-red-400 hover:bg-red-500/10">
              <StopIcon className="size-3.5" /> Stop
            </ToolbarButton>
          ) : (
            <ToolbarButton
              onClick={() => void startDebug()}
              disabled={dbg.starting || !debugArgs || !canDebug}
              title={canDebug ? `Debug ${caseLabel} (F5)` : "The debugger supports Python for now"}
              className="border border-accent/40 text-accent hover:bg-accent/10"
            >
              <BugIcon className="size-3.5" /> {dbg.starting ? "Recording…" : "Debug"}
            </ToolbarButton>
          )}
          {features.hints && !dbg.active && (
            <ToolbarButton
              onClick={() => void requestHint()}
              disabled={hint?.status === "loading"}
              title="Get an AI hint about your current code (Snowflake Cortex)"
              className="text-zinc-300 hover:bg-surface-2 hover:text-zinc-100"
            >
              <LightbulbIcon className="size-3.5" /> Hint
            </ToolbarButton>
          )}
          <ToolbarButton
            onClick={() => execute("run")}
            disabled={pending !== null}
            title="Run all tests (Ctrl+')"
            className="bg-surface-2 text-zinc-100 hover:bg-line-strong"
          >
            <PlayIcon className="size-3.5" /> Run
          </ToolbarButton>
          <ToolbarButton
            onClick={() => execute("submit")}
            disabled={pending !== null}
            title="Submit (Ctrl+Enter)"
            className="bg-green-600 font-semibold text-white hover:bg-green-500"
          >
            <UploadIcon className="size-3.5" /> Submit
          </ToolbarButton>
        </div>
      </div>
      {dbg.active && <DebugToolbar dbg={dbg} />}
      <div className="min-h-0 flex-1">
        <CodeEditor
          language={language.monaco}
          value={code}
          onChange={setCode}
          readOnly={dbg.active}
          breakpoints={dbg.breakpoints}
          onToggleBreakpoint={dbg.breakpointOps.toggle}
          onEditCondition={(line, condition) => dbg.breakpointOps.update(line, { condition: condition || undefined, enabled: true })}
          onMoveBreakpoints={dbg.breakpointOps.move}
          currentLine={dbg.step?.line}
          currentIsException={dbg.step?.event === "exception"}
          frameLine={dbg.frameIndex > 0 ? frame?.line : undefined}
          inlineValues={inline}
          hoverValues={frame?.locals}
          commands={{ run: () => execute("run"), submit: () => execute("submit") }}
        />
      </div>
    </Card>
  );

  const bottomCard = (
    <Card>
      <CardTabs>
        <CardTab active={tab === "testcase"} onClick={() => setTab("testcase")} icon={<FlaskIcon className="size-3.5" />}>
          Testcase
        </CardTab>
        <CardTab active={tab === "result"} onClick={() => setTab("result")} icon={<TerminalIcon className="size-3.5" />}>
          Result
          {result && !pending && <span className={`h-1.5 w-1.5 rounded-full ${result.passed ? "bg-easy" : "bg-red-400"}`} />}
        </CardTab>
        <CardTab active={tab === "debug"} onClick={() => setTab("debug")} icon={<BugIcon className="size-3.5" />}>
          Debug
          {dbg.active && <span className="h-1.5 w-1.5 animate-pulse rounded-full bg-accent" />}
        </CardTab>
      </CardTabs>
      {error && (
        <p role="alert" className="border-b border-red-900/50 bg-red-950/30 px-4 py-2 text-xs text-red-300">
          {error}
        </p>
      )}
      <div className="min-h-0 flex-1">
        {tab === "testcase" && (
          <TestcasePanel
            cases={cases}
            selected={selectedCase?.key ?? caseKey}
            onSelect={setCaseKey}
            params={params}
            custom={custom}
            onCustomChange={setCustomValues}
            customErrors={parsedCustom.errors}
          />
        )}
        {tab === "result" && (
          <div className="flex h-full min-h-0 flex-col">
            {hint && <HintCard hint={hint} onClose={() => setHint(null)} />}
            <div className="min-h-0 flex-1">
              <ResultsPanel
                result={result}
                pending={pending}
                params={params}
                onDebug={canDebug ? (key) => void startDebug(key) : undefined}
                onHint={features.hints ? (failing) => void requestHint(failing) : undefined}
              />
            </div>
          </div>
        )}
        {tab === "debug" && (
          canDebug ? (
            <DebugPanel dbg={dbg} lineText={lineText} caseLabel={caseLabel} onStart={() => void startDebug()} />
          ) : (
            <div className="flex h-full flex-col items-center justify-center px-6 text-center">
              <BugIcon className="size-6 text-zinc-600" />
              <p className="mt-3 text-sm text-zinc-300">The time-travel debugger supports Python for now.</p>
              <p className="mt-1 text-xs text-zinc-500">
                This problem is in {language.label}. Use Run to check your fix against every test.
              </p>
            </div>
          )
        )}
      </div>
    </Card>
  );

  const resetDialog = (
    <ConfirmDialog
      open={confirmingReset}
      title="Reset your code?"
      confirmLabel="Reset code"
      icon={<ResetIcon className="size-5" />}
      onConfirm={() => void resetCode()}
      onCancel={() => setConfirmingReset(false)}
    >
      Your changes to this problem will be replaced with the original buggy code, and your saved copy will be
      deleted. <span className="font-medium text-zinc-200">This can&apos;t be undone.</span>
    </ConfirmDialog>
  );

  if (!isDesktop) {
    return (
      <div className="flex flex-col gap-2 bg-canvas-2 p-2">
        <div className="h-[60vh]">{descriptionCard}</div>
        <div className="h-[65vh]">{editorCard}</div>
        <div className="h-[75vh]">{bottomCard}</div>
        {resetDialog}
      </div>
    );
  }

  return (
    <div className="h-[calc(100dvh-3.5rem)] bg-canvas-2 p-2">
      {resetDialog}
      <Group orientation="horizontal" className="h-full">
        <Panel defaultSize="40%" minSize="22%">
          {descriptionCard}
        </Panel>
        <ResizeHandle direction="vertical" />
        <Panel minSize="35%">
          <Group orientation="vertical" className="h-full">
            <Panel defaultSize="60%" minSize="20%">
              {editorCard}
            </Panel>
            <ResizeHandle direction="horizontal" />
            <Panel minSize="15%">{bottomCard}</Panel>
          </Group>
        </Panel>
      </Group>
    </div>
  );
}

function SaveIndicator({ status }: { status: SaveStatus }) {
  if (status === "idle") return null;
  const view = {
    saved: { text: "Saved", className: "text-zinc-500", mark: <CheckIcon className="size-3" /> },
    saving: { text: "Saving…", className: "text-zinc-500", mark: <span className="h-1.5 w-1.5 animate-pulse rounded-full bg-zinc-500" /> },
    unsaved: { text: "Unsaved", className: "text-zinc-500", mark: <span className="h-1.5 w-1.5 rounded-full bg-accent" /> },
    error: { text: "Not saved", className: "text-red-400", mark: <span className="h-1.5 w-1.5 rounded-full bg-red-400" /> },
  }[status];
  return (
    <span
      role="status"
      title={status === "error" ? "Couldn't save your code. Check that you're logged in; it will retry when you keep typing." : undefined}
      className={`flex items-center gap-1.5 text-[11px] ${view.className}`}
    >
      {view.mark}
      {view.text}
    </span>
  );
}

function Card({ children }: { children: ReactNode }) {
  return <div className="flex h-full min-h-0 flex-col overflow-hidden rounded-lg border border-line bg-surface">{children}</div>;
}

function CardTabs({ children }: { children: ReactNode }) {
  return (
    <div role="tablist" className="flex h-10 shrink-0 items-center gap-1 border-b border-line bg-[#111317] px-2">
      {children}
    </div>
  );
}

function CardTab({ active, onClick, icon, children }: {
  active: boolean;
  onClick?: () => void;
  icon: ReactNode;
  children: ReactNode;
}) {
  return (
    <button
      type="button"
      role="tab"
      aria-selected={active}
      onClick={onClick}
      className={`flex items-center gap-1.5 rounded-md px-2.5 py-1.5 text-xs transition-colors ${
        active ? "bg-surface-2 font-medium text-zinc-100" : "text-zinc-500 hover:text-zinc-300"
      }`}
    >
      <span className={active ? "text-accent" : ""}>{icon}</span>
      {children}
    </button>
  );
}

function ToolbarButton({ onClick, disabled, title, className, children }: {
  onClick: () => void;
  disabled?: boolean;
  title: string;
  className: string;
  children: ReactNode;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      disabled={disabled}
      title={title}
      className={`flex h-8 items-center gap-1.5 rounded-md px-3 text-xs font-medium transition-colors disabled:cursor-not-allowed disabled:opacity-50 ${className}`}
    >
      {children}
    </button>
  );
}

/** `direction` is the orientation of the visible grip line. */
function ResizeHandle({ direction }: { direction: "vertical" | "horizontal" }) {
  const grip =
    direction === "vertical"
      ? "w-2 before:h-10 before:w-0.5"
      : "h-2 before:h-0.5 before:w-10";
  return (
    <Separator
      className={`group flex items-center justify-center outline-none before:rounded-full before:bg-line-strong before:transition-colors data-[separator=active]:before:bg-accent data-[separator=focus]:before:bg-accent data-[separator=hover]:before:bg-accent/70 ${grip}`}
    />
  );
}
