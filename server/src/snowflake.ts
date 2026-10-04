import { randomUUID } from "node:crypto";
import { config } from "./config.js";
import { HttpError } from "./errors.js";

/**
 * Minimal client for the Snowflake SQL API (https://docs.snowflake.com/en/developer-guide/sql-api/intro),
 * authenticated with a programmatic access token. Used for Cortex hints and the analytics warehouse.
 */
export const snowflakeEnabled = Boolean(config.SNOWFLAKE_ACCOUNT && config.SNOWFLAKE_TOKEN);

const POLL_MS = 500;

/** A bind value; arrays bind one value per row for bulk INSERTs. */
export type Bind = string | number | boolean | null | (string | number | boolean | null)[];

type RowType = { name: string; type: string };
type StatementResponse = {
  statementHandle: string;
  message?: string;
  code?: string;
  resultSetMetaData?: { rowType: RowType[]; partitionInfo?: unknown[] };
  data?: (string | null)[][];
};

function baseUrl() {
  return `https://${config.SNOWFLAKE_ACCOUNT}.snowflakecomputing.com/api/v2/statements`;
}

function headers() {
  return {
    Authorization: `Bearer ${config.SNOWFLAKE_TOKEN}`,
    "X-Snowflake-Authorization-Token-Type": "PROGRAMMATIC_ACCESS_TOKEN",
    "Content-Type": "application/json",
    Accept: "application/json",
    "User-Agent": "ladybug/1.0",
  };
}

function bindType(values: unknown[]) {
  const v = values.find((x) => x !== null);
  return typeof v === "number" ? (Number.isInteger(v) ? "FIXED" : "REAL") : typeof v === "boolean" ? "BOOLEAN" : "TEXT";
}

function toBinding(value: Bind) {
  const values = Array.isArray(value) ? value : [value];
  const asText = values.map((v) => (v === null ? null : String(v)));
  return { type: bindType(values), value: Array.isArray(value) ? asText : asText[0] };
}

async function send(url: string, init: RequestInit): Promise<{ status: number; body: StatementResponse }> {
  let res: Response;
  try {
    res = await fetch(url, { ...init, headers: headers(), signal: AbortSignal.timeout(60_000) });
  } catch (err) {
    console.error("snowflake unreachable", err);
    throw new HttpError(503, "Snowflake is unreachable");
  }
  const body = (await res.json().catch(() => ({}))) as StatementResponse;
  if (res.status >= 400) {
    console.error(`snowflake error ${res.status}`, body.code, body.message);
    throw new HttpError(502, `Snowflake rejected the request${body.message ? `: ${body.message}` : ""}`);
  }
  return { status: res.status, body };
}

/** Converts Snowflake's all-string JSON rows into objects with numbers/booleans where the column type says so. */
function rowsOf<T>(meta: RowType[], data: (string | null)[][]): T[] {
  return data.map((row) => {
    const out: Record<string, unknown> = {};
    meta.forEach((col, i) => {
      const raw = row[i];
      const type = col.type.toLowerCase();
      out[col.name.toLowerCase()] =
        raw === null ? null : type === "fixed" || type === "real" ? Number(raw) : type === "boolean" ? raw === "true" : raw;
    });
    return out as T;
  });
}

/** Runs one SQL statement with `?` bind variables and returns its rows (column names lower-cased). */
export async function snowflakeQuery<T = Record<string, unknown>>(statement: string, binds: Bind[] = []): Promise<T[]> {
  if (!snowflakeEnabled) throw new HttpError(503, "Snowflake isn't configured");
  const body = {
    statement,
    timeout: 60,
    warehouse: config.SNOWFLAKE_WAREHOUSE,
    database: config.SNOWFLAKE_DATABASE,
    schema: config.SNOWFLAKE_SCHEMA,
    role: config.SNOWFLAKE_ROLE,
    bindings: binds.length ? Object.fromEntries(binds.map((b, i) => [String(i + 1), toBinding(b)])) : undefined,
  };
  let { status, body: result } = await send(`${baseUrl()}?requestId=${randomUUID()}`, {
    method: "POST",
    body: JSON.stringify(body),
  });
  // 202: still running; poll the statement until it finishes.
  while (status === 202) {
    await new Promise((r) => setTimeout(r, POLL_MS));
    ({ status, body: result } = await send(`${baseUrl()}/${result.statementHandle}`, { method: "GET" }));
  }
  const meta = result.resultSetMetaData?.rowType ?? [];
  const data = [...(result.data ?? [])];
  // Large results come back in partitions; fetch the rest.
  for (let p = 1; p < (result.resultSetMetaData?.partitionInfo?.length ?? 1); p++) {
    const next = await send(`${baseUrl()}/${result.statementHandle}?partition=${p}`, { method: "GET" });
    data.push(...(next.body.data ?? []));
  }
  return rowsOf<T>(meta, data);
}
