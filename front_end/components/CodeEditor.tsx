"use client";

import type { BeforeMount, Monaco, OnMount } from "@monaco-editor/react";
import dynamic from "next/dynamic";
import { type FormEvent, useEffect, useRef, useState } from "react";
import { useTheme } from "@/hooks/useTheme";
import type { Breakpoints } from "@/lib/debugger";

const MonacoEditor = dynamic(() => import("@monaco-editor/react"), {
  ssr: false,
  loading: () => <div className="h-full animate-pulse bg-surface" />,
});

type StandaloneEditor = Parameters<OnMount>[0];
type DecorationsCollection = ReturnType<StandaloneEditor["createDecorationsCollection"]>;
type Decoration = Parameters<DecorationsCollection["set"]>[0][number];
type TextModel = NonNullable<ReturnType<StandaloneEditor["getModel"]>>;
type Position = NonNullable<ReturnType<StandaloneEditor["getPosition"]>>;

export type CodeEditorProps = {
  value: string;
  /** Monaco language id. */
  language?: string;
  onChange: (v: string) => void;
  readOnly?: boolean;
  breakpoints?: Breakpoints;
  onToggleBreakpoint?: (line: number) => void;
  /** Set (or clear, with "") the condition of the breakpoint on a line, creating it if needed. */
  onEditCondition?: (line: number, condition: string) => void;
  /** Edits shifted breakpoint lines: [from, to] for every breakpoint. */
  onMoveBreakpoints?: (moves: [number, number][]) => void;
  /** Line the debugger is paused on. */
  currentLine?: number;
  currentIsException?: boolean;
  /** Line of a selected outer stack frame. */
  frameLine?: number;
  inlineValues?: { line: number; text: string }[];
  /** Variable values shown when hovering identifiers while paused. */
  hoverValues?: Record<string, string>;
  commands?: { run?: () => void; submit?: () => void };
};

const defineTheme: BeforeMount = (monaco) => {
  monaco.editor.defineTheme("ladybug-light", {
    base: "vs",
    inherit: true,
    rules: [],
    colors: {
      "editor.background": "#ffffff",
      "editorGutter.background": "#ffffff",
      "editor.lineHighlightBackground": "#f0f2f5",
      "editor.selectionBackground": "#b03e4330",
      "editorCursor.foreground": "#b03e43",
    },
  });
  monaco.editor.defineTheme("ladybug", {
    base: "vs-dark",
    inherit: true,
    rules: [],
    colors: {
      "editor.background": "#121215",
      "editorGutter.background": "#121215",
      "editor.lineHighlightBackground": "#18181c80",
      "editor.lineHighlightBorder": "#00000000",
      "editorLineNumber.foreground": "#4b5060",
      "editorLineNumber.activeForeground": "#c8ccd4",
      "editor.selectionBackground": "#b03e4335",
      "editor.inactiveSelectionBackground": "#b03e4318",
      "editorIndentGuide.background1": "#222228",
      "editorIndentGuide.activeBackground1": "#3a3f4b",
      "editorCursor.foreground": "#b03e43",
      "editorWidget.background": "#18181c",
      "editorWidget.border": "#2f3038",
      "editorHoverWidget.background": "#18181c",
      "editorHoverWidget.border": "#2f3038",
      "scrollbarSlider.background": "#2f303880",
      "scrollbarSlider.hoverBackground": "#3a3f4b",
    },
  });
};

function breakpointDecorations(monaco: Monaco, breakpoints: Breakpoints, lineCount: number): Decoration[] {
  return Object.values(breakpoints)
    .filter((b) => b.line <= lineCount)
    .map((b) => ({
      range: new monaco.Range(b.line, 1, b.line, 1),
      options: {
        glyphMarginClassName: !b.enabled ? "bp-glyph-disabled" : b.condition ? "bp-glyph-conditional" : "bp-glyph",
        glyphMarginHoverMessage: {
          value: b.condition ? `Breakpoint when \`${b.condition}\`` : "Breakpoint · right-click to add a condition",
        },
        stickiness: monaco.editor.TrackedRangeStickiness.NeverGrowsWhenTypingAtEdges,
      },
    }));
}

export default function CodeEditor(props: CodeEditorProps) {
  const { resolved } = useTheme();
  const { value, onChange, readOnly, breakpoints, currentLine, currentIsException, frameLine, inlineValues } = props;
  const editorRef = useRef<StandaloneEditor | null>(null);
  const monacoRef = useRef<Monaco | null>(null);
  const breakpointCollection = useRef<DecorationsCollection | null>(null);
  const debugCollection = useRef<DecorationsCollection | null>(null);
  const previewCollection = useRef<DecorationsCollection | null>(null);
  /** Breakpoint lines in the order their decorations were set, to map tracked ranges back after edits. */
  const decoratedLines = useRef<number[]>([]);
  // Monaco listeners are registered once on mount, so they read the latest props through this ref.
  const latest = useRef(props);
  const [mounted, setMounted] = useState(false);
  const [conditionEditor, setConditionEditor] = useState<{ line: number; top: number; value: string } | null>(null);

  useEffect(() => {
    latest.current = props;
  });

  function applyBreakpoints() {
    const editor = editorRef.current;
    const monaco = monacoRef.current;
    const model = editor?.getModel();
    if (!monaco || !model || !breakpointCollection.current) return;
    const decorations = breakpointDecorations(monaco, latest.current.breakpoints ?? {}, model.getLineCount());
    decoratedLines.current = decorations.map((d) => d.range.startLineNumber);
    breakpointCollection.current.set(decorations);
  }

  useEffect(() => {
    if (mounted) applyBreakpoints();
  }, [mounted, breakpoints]);

  useEffect(() => {
    const editor = editorRef.current;
    const monaco = monacoRef.current;
    const model = editor?.getModel();
    if (!mounted || !editor || !monaco || !model || !debugCollection.current) return;
    const decorations: Decoration[] = [];
    const whole = (line: number, className: string, extra = {}): Decoration => ({
      range: new monaco.Range(line, 1, line, 1),
      options: { isWholeLine: true, className, ...extra },
    });
    if (frameLine && frameLine !== currentLine) decorations.push(whole(frameLine, "debug-frame-line"));
    if (currentLine) {
      decorations.push(
        whole(currentLine, currentIsException ? "debug-exception-line" : "debug-current-line", {
          linesDecorationsClassName: "debug-current-arrow",
        }),
      );
    }
    for (const { line, text } of inlineValues ?? []) {
      if (line > model.getLineCount()) continue;
      const end = model.getLineMaxColumn(line);
      decorations.push({
        range: new monaco.Range(line, end, line, end),
        options: { after: { content: `   ${text}`, inlineClassName: "debug-inline-value" } },
      });
    }
    debugCollection.current.set(decorations);
    const focusLine = frameLine ?? currentLine;
    if (focusLine) editor.revealLineInCenterIfOutsideViewport(focusLine);
  }, [mounted, currentLine, currentIsException, frameLine, inlineValues]);

  function openConditionEditor(line: number) {
    const editor = editorRef.current;
    const monaco = monacoRef.current;
    if (!editor || !monaco) return;
    const lineHeight = editor.getOption(monaco.editor.EditorOption.lineHeight);
    setConditionEditor({
      line,
      top: editor.getTopForLineNumber(line) - editor.getScrollTop() + lineHeight + 4,
      value: latest.current.breakpoints?.[line]?.condition ?? "",
    });
  }

  function saveCondition(e: FormEvent) {
    e.preventDefault();
    if (!conditionEditor) return;
    props.onEditCondition?.(conditionEditor.line, conditionEditor.value.trim());
    setConditionEditor(null);
    editorRef.current?.focus();
  }

  const handleMount: OnMount = (editor, monaco) => {
    editorRef.current = editor;
    monacoRef.current = monaco;
    breakpointCollection.current = editor.createDecorationsCollection();
    debugCollection.current = editor.createDecorationsCollection();
    previewCollection.current = editor.createDecorationsCollection();
    const { MouseTargetType } = monaco.editor;

    editor.onMouseDown((e) => {
      const line = e.target.position?.lineNumber;
      if (e.target.type !== MouseTargetType.GUTTER_GLYPH_MARGIN || !line || e.event.rightButton) return;
      latest.current.onToggleBreakpoint?.(line);
    });
    editor.onContextMenu((e) => {
      const line = e.target.position?.lineNumber;
      if (e.target.type !== MouseTargetType.GUTTER_GLYPH_MARGIN || !line || !latest.current.onEditCondition) return;
      e.event.preventDefault();
      openConditionEditor(line);
    });
    editor.onMouseMove((e) => {
      const line = e.target.type === MouseTargetType.GUTTER_GLYPH_MARGIN ? e.target.position?.lineNumber : undefined;
      const show = line && latest.current.onToggleBreakpoint && !latest.current.breakpoints?.[line];
      previewCollection.current?.set(
        show ? [{ range: new monaco.Range(line, 1, line, 1), options: { glyphMarginClassName: "bp-glyph-preview" } }] : [],
      );
    });
    editor.onMouseLeave(() => previewCollection.current?.clear());
    editor.onDidScrollChange(() => setConditionEditor(null));

    editor.onDidChangeModelContent((e) => {
      const model = editor.getModel();
      if (!model) return;
      // Reset / prop-driven value changes replace the whole text and would collapse every breakpoint onto
      // line 1, so keep breakpoints where they were instead of following the tracked ranges.
      if (e.isFlush || (e.changes.length === 1 && e.changes[0].text === model.getValue())) {
        applyBreakpoints();
        return;
      }
      const ranges = breakpointCollection.current?.getRanges() ?? [];
      const moves = decoratedLines.current.map((from, i): [number, number] => [from, ranges[i]?.startLineNumber ?? from]);
      if (moves.some(([from, to]) => from !== to)) latest.current.onMoveBreakpoints?.(moves);
    });

    editor.addCommand(monaco.KeyCode.F9, () => {
      const line = editor.getPosition()?.lineNumber;
      if (line) latest.current.onToggleBreakpoint?.(line);
    });
    editor.addCommand(monaco.KeyMod.CtrlCmd | monaco.KeyCode.Enter, () => latest.current.commands?.submit?.());
    editor.addCommand(monaco.KeyMod.CtrlCmd | monaco.KeyCode.Quote, () => latest.current.commands?.run?.());

    const hover = monaco.languages.registerHoverProvider(latest.current.language ?? "python", {
      provideHover(model: TextModel, position: Position) {
        const values = latest.current.hoverValues;
        const word = model === editor.getModel() ? model.getWordAtPosition(position) : null;
        if (!values || !word || !(word.word in values)) return null;
        return {
          range: new monaco.Range(position.lineNumber, word.startColumn, position.lineNumber, word.endColumn),
          contents: [{ value: "```python\n" + `${word.word} = ${values[word.word]}` + "\n```" }],
        };
      },
    });
    editor.onDidDispose(() => hover.dispose());
    setMounted(true);
  };

  return (
    <div className="relative h-full">
      <MonacoEditor
        height="100%"
        language={props.language ?? "python"}
        theme={resolved === "light" ? "ladybug-light" : "ladybug"}
        value={value}
        beforeMount={defineTheme}
        onMount={handleMount}
        onChange={(v) => onChange(v ?? "")}
        options={{
          minimap: { enabled: false },
          fontSize: 14,
          lineHeight: 22,
          fontFamily: "var(--font-geist-mono), ui-monospace, SFMono-Regular, Menlo, monospace",
          tabSize: 4,
          glyphMargin: true,
          lineDecorationsWidth: 14,
          lineNumbersMinChars: 3,
          scrollBeyondLastLine: false,
          padding: { top: 12, bottom: 12 },
          smoothScrolling: true,
          automaticLayout: true,
          contextmenu: false,
          overviewRulerLanes: 0,
          hideCursorInOverviewRuler: true,
          scrollbar: { verticalScrollbarSize: 10, horizontalScrollbarSize: 10 },
          readOnly,
          readOnlyMessage: { value: "Stop debugging to edit the code" },
        }}
      />
      {conditionEditor && (
        <form
          onSubmit={saveCondition}
          style={{ top: Math.max(4, conditionEditor.top) }}
          className="absolute left-12 right-4 z-10 flex flex-wrap items-center gap-2 rounded-md border border-accent/40 bg-surface-2 p-2 shadow-2xl shadow-black/50"
        >
          <label htmlFor="bp-condition" className="font-mono text-xs text-zinc-400">
            Line {conditionEditor.line} · pause when
          </label>
          <input
            id="bp-condition"
            autoFocus
            value={conditionEditor.value}
            onChange={(e) => setConditionEditor({ ...conditionEditor, value: e.target.value })}
            onKeyDown={(e) => e.key === "Escape" && setConditionEditor(null)}
            placeholder="Python expression, e.g. i == 3 (empty = always)"
            className="min-w-40 flex-1 rounded border border-line bg-canvas-2 px-2 py-1 font-mono text-xs text-zinc-100 placeholder:text-zinc-600 focus:border-accent/60 focus:outline-none"
          />
          <button type="submit" className="rounded bg-accent px-2.5 py-1 text-xs font-semibold text-white hover:bg-accent-hover">
            Save
          </button>
          <button type="button" onClick={() => setConditionEditor(null)} className="rounded px-2 py-1 text-xs text-zinc-400 hover:text-zinc-100">
            Cancel
          </button>
        </form>
      )}
    </div>
  );
}
