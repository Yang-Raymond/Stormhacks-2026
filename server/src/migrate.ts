import { readdir, readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import type { PoolClient } from "pg";
import { pool } from "./db.js";

const migrationsDir = fileURLToPath(new URL("../migrations/", import.meta.url));

/**
 * Some statements (e.g. TimescaleDB continuous aggregates) refuse to run inside a transaction. A file starting with
 * this marker runs one statement at a time instead, so it must be safe to re-run (IF NOT EXISTS etc.), and each
 * statement must end with a semicolon at the end of a line.
 */
const NO_TRANSACTION = "-- migrate:no-transaction";

async function runWithoutTransaction(client: PoolClient, sql: string) {
  // Sending several statements in one query would make Postgres wrap them in an implicit transaction.
  const statements = sql
    .split(/;\s*$/m)
    .map((s) => s.replace(/^\s*--.*$/gm, "").trim())
    .filter(Boolean);
  for (const statement of statements) await client.query(statement);
}

/** Applies each not-yet-applied migrations/*.sql file in name order, one transaction per file. */
export async function migrate() {
  const client = await pool.connect();
  try {
    // Serialise concurrent server starts so two instances never apply the same migration.
    await client.query("SELECT pg_advisory_lock(727274)");
    await client.query(
      "CREATE TABLE IF NOT EXISTS schema_migrations (name text PRIMARY KEY, applied_at timestamptz NOT NULL DEFAULT now())",
    );
    const { rows } = await client.query<{ name: string }>("SELECT name FROM schema_migrations");
    const applied = new Set(rows.map((r) => r.name));

    const files = (await readdir(migrationsDir)).filter((f) => f.endsWith(".sql")).sort();
    for (const file of files) {
      if (applied.has(file)) continue;
      const sql = await readFile(migrationsDir + file, "utf8");
      if (sql.startsWith(NO_TRANSACTION)) {
        await runWithoutTransaction(client, sql);
        await client.query("INSERT INTO schema_migrations (name) VALUES ($1)", [file]);
        console.log(`applied migration ${file} (no transaction)`);
        continue;
      }
      try {
        await client.query("BEGIN");
        await client.query(sql);
        await client.query("INSERT INTO schema_migrations (name) VALUES ($1)", [file]);
        await client.query("COMMIT");
        console.log(`applied migration ${file}`);
      } catch (err) {
        await client.query("ROLLBACK");
        throw err;
      }
    }
  } finally {
    await client.query("SELECT pg_advisory_unlock(727274)").catch(() => {});
    client.release();
  }
}
