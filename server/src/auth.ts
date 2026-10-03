import { Router, type RequestHandler } from "express";
import { rateLimit } from "express-rate-limit";
import { z } from "zod";
import { pool } from "./db.js";
import { HttpError } from "./errors.js";
import { hashPassword, verifyPassword } from "./password.js";

const credentials = z.object({
  email: z.email().max(254),
  password: z.string().min(8).max(128),
});

// Compared against when the email is unknown so login timing doesn't reveal which emails exist.
const dummyHash = await hashPassword("timing-equaliser");

export const requireAuth: RequestHandler = (req, _res, next) => {
  if (!req.session.userId) return next(new HttpError(401, "Not logged in"));
  next();
};

function startSession(req: Parameters<RequestHandler>[0], userId: string) {
  // Regenerate the session id on login to prevent session fixation.
  return new Promise<void>((resolve, reject) =>
    req.session.regenerate((err) => {
      if (err) return reject(err);
      req.session.userId = userId;
      req.session.save((saveErr) => (saveErr ? reject(saveErr) : resolve()));
    }),
  );
}

export const authRouter = Router();

authRouter.use(["/register", "/login"], rateLimit({ windowMs: 15 * 60_000, limit: 20 }));

authRouter.post("/register", async (req, res) => {
  const { email, password } = credentials.parse(req.body);
  const { rows } = await pool.query<{ id: string; email: string }>(
    `INSERT INTO users (email, password_hash) VALUES ($1, $2)
     ON CONFLICT (email) DO NOTHING RETURNING id, email`,
    [email, await hashPassword(password)],
  );
  if (rows.length === 0) throw new HttpError(409, "Email already registered");
  await startSession(req, rows[0].id);
  res.status(201).json({ user: rows[0] });
});

authRouter.post("/login", async (req, res) => {
  const { email, password } = credentials.parse(req.body);
  const { rows } = await pool.query<{ id: string; email: string; password_hash: string }>(
    "SELECT id, email, password_hash FROM users WHERE email = $1",
    [email],
  );
  const user = rows[0];
  const ok = await verifyPassword(password, user?.password_hash ?? dummyHash);
  if (!user || !ok) throw new HttpError(401, "Invalid email or password");
  await startSession(req, user.id);
  res.json({ user: { id: user.id, email: user.email } });
});

authRouter.post("/logout", (req, res, next) => {
  req.session.destroy((err) => {
    if (err) return next(err);
    res.clearCookie("sid");
    res.status(204).end();
  });
});

authRouter.get("/me", async (req, res) => {
  if (!req.session.userId) return void res.json({ user: null });
  const { rows } = await pool.query("SELECT id, email FROM users WHERE id = $1", [req.session.userId]);
  res.json({ user: rows[0] ?? null });
});
