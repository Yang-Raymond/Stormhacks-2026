import { z } from "zod";

const schema = z.object({
  NODE_ENV: z.string().default("development"),
  PORT: z.coerce.number().int().default(4000),
  DATABASE_URL: z.string().min(1),
  SESSION_SECRET: z.string().min(32, "SESSION_SECRET must be at least 32 characters"),
  GEMINI_API_KEY: z.string().min(1),
  GEMINI_MODEL: z.string().default("gemini-2.5-flash"),
  RUNNER_URL: z.url().default("http://localhost:8000"),
  PUBLIC_URL: z.string().default("http://localhost:3000"),
  GITHUB_CLIENT_ID: z.string().optional(),
  GITHUB_CLIENT_SECRET: z.string().optional(),
  GOOGLE_CLIENT_ID: z.string().optional(),
  GOOGLE_CLIENT_SECRET: z.string().optional(),
  // Snowflake (optional): AI hints via Cortex and the analytics warehouse. See docs/integrations.md.
  SNOWFLAKE_ACCOUNT: z.string().optional(), // account identifier, e.g. "myorg-myaccount"
  SNOWFLAKE_TOKEN: z.string().optional(), // programmatic access token
  SNOWFLAKE_WAREHOUSE: z.string().default("LADYBUG_WH"),
  SNOWFLAKE_DATABASE: z.string().default("LADYBUG"),
  SNOWFLAKE_SCHEMA: z.string().default("ANALYTICS"),
  SNOWFLAKE_ROLE: z.string().default("LADYBUG_APP"),
  SNOWFLAKE_CORTEX_MODEL: z.string().default("mistral-large2"),
  // Salt for the one-way user ids sent to the warehouse; required for the sync to run.
  ANALYTICS_SALT: z.preprocess((v) => (v === "" ? undefined : v), z.string().min(16).optional()),
});

const parsed = schema.safeParse(process.env);
if (!parsed.success) {
  console.error("Invalid environment:\n" + z.prettifyError(parsed.error));
  process.exit(1);
}

export const config = parsed.data;
export const isProduction = config.NODE_ENV === "production";
