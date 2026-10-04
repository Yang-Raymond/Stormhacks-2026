/** Parameter names of `def entryPoint(...)`, used to label test-case arguments. Empty if it can't be found. */
export function paramNames(code: string, entryPoint: string): string[] {
  const start = code.search(new RegExp(`def\\s+${entryPoint}\\s*\\(`));
  if (start === -1) return [];
  const open = code.indexOf("(", start);
  // Split on top-level commas only: annotations like dict[str, int] contain commas of their own.
  const params: string[] = [];
  let depth = 0;
  let current = "";
  for (let i = open + 1; i < code.length; i++) {
    const ch = code[i];
    if (ch === ")" && depth === 0) {
      params.push(current);
      break;
    }
    if ("([{".includes(ch)) depth++;
    if (")]}".includes(ch)) depth--;
    if (ch === "," && depth === 0) {
      params.push(current);
      current = "";
    } else {
      current += ch;
    }
  }
  return params
    .map((p) => p.split(/[:=]/)[0].trim().replace(/^\*+/, ""))
    .filter((name) => name && name !== "self");
}
