/** Languages problems can be written in; ids match server/src/languages.ts. */
export const LANGUAGES = [
  { id: "python", label: "Python 3", monaco: "python" },
  { id: "javascript", label: "JavaScript", monaco: "javascript" },
  { id: "typescript", label: "TypeScript", monaco: "typescript" },
  { id: "java", label: "Java", monaco: "java" },
  { id: "c", label: "C", monaco: "c" },
  { id: "cpp", label: "C++", monaco: "cpp" },
  { id: "csharp", label: "C#", monaco: "csharp" },
] as const;

export type Language = (typeof LANGUAGES)[number]["id"];

export function languageInfo(id: string) {
  return LANGUAGES.find((l) => l.id === id) ?? LANGUAGES[0];
}

/** Languages the runner can trace for the time-travel debugger; matches server/src/problems.ts. */
export const DEBUGGABLE: ReadonlySet<string> = new Set(["python", "javascript", "typescript"]);

/** Read current ids and legacy display-name preferences; use the first supported selection. */
export function preferredLanguage(names: readonly string[] = []): Language {
  for (const name of names) {
    const normalized = name.toLowerCase();
    const match = LANGUAGES.find((l) => l.id === normalized || l.label.toLowerCase() === normalized);
    if (match) return match.id;
  }
  return "python";
}
