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

/** The time-travel debugger relies on Python's tracing hooks. */
export const DEBUGGABLE: ReadonlySet<string> = new Set(["python"]);
