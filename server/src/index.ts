import connectPgSimple from "connect-pg-simple";
import express, { type ErrorRequestHandler } from "express";
import session from "express-session";
import { z } from "zod";
import { authRouter } from "./auth.js";
import { challengesRouter } from "./challenges.js";
import { oauthRouter } from "./oauth.js";
import { config, isProduction } from "./config.js";
import { pool } from "./db.js";
import { HttpError } from "./errors.js";
import { migrate } from "./migrate.js";
import { problemsRouter } from "./problems.js";

await migrate();

const PgStore = connectPgSimple(session);
const app = express();

app.set("trust proxy", 1);
app.use(express.json({ limit: "100kb" }));
app.use(
  session({
    name: "sid",
    store: new PgStore({ pool, tableName: "session" }),
    secret: config.SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    cookie: { httpOnly: true, sameSite: "lax", secure: isProduction, maxAge: 7 * 24 * 60 * 60_000 },
  }),
);

app.get("/api/health", async (_req, res) => {
  await pool.query("SELECT 1");
  res.json({ ok: true });
});
app.use("/api/auth/oauth", oauthRouter);
app.use("/api/auth", authRouter);
app.use("/api/problems", problemsRouter);
app.use("/api/challenges", challengesRouter);

app.use((_req, _res, next) => next(new HttpError(404, "Not found")));

const errorHandler: ErrorRequestHandler = (err, _req, res, _next) => {
  if (err instanceof z.ZodError) {
    return void res.status(400).json({ error: "Invalid request", issues: z.flattenError(err).fieldErrors });
  }
  if (err instanceof HttpError) return void res.status(err.status).json({ error: err.message });
  // Body-parser errors (malformed JSON, payload too large) carry a client status code.
  if (typeof err?.status === "number" && err.status < 500) {
    return void res.status(err.status).json({ error: err.expose ? err.message : "Bad request" });
  }
  console.error(err);
  res.status(500).json({ error: "Internal server error" });
};
app.use(errorHandler);

app.listen(config.PORT, () => console.log(`server listening on :${config.PORT}`));
