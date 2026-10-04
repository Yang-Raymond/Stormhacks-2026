import { Router, type RequestHandler } from "express";
import { rateLimit } from "express-rate-limit";
import { z } from "zod";
import { config } from "./config.js";
import { pool } from "./db.js";
import { HttpError } from "./errors.js";
import { hashPassword, verifyPassword } from "./password.js";

const registerSchema = z.object({
  fullName: z.string().trim().max(100).optional(),
  email: z.string().email().max(254),
  password: z.string().min(8).max(128),
  language: z.string().max(50).optional(),
  acceptTerms: z.literal(true, {
    message: "You must accept the terms of service to continue",
  }),
});

const loginSchema = z.object({
  email: z.string().email().max(254),
  password: z.string().min(1).max(128),
  remember: z.boolean().optional().default(false),
});

// Compared against when the email is unknown so login timing doesn't reveal which emails exist.
const dummyHash = await hashPassword("timing-equaliser");

export const requireAuth: RequestHandler = (req, _res, next) => {
  if (!req.session.userId) return next(new HttpError(401, "Not logged in"));
  next();
};

export function startSession(req: Parameters<RequestHandler>[0], userId: string, remember = true) {
  // Regenerate the session id on login to prevent session fixation.
  return new Promise<void>((resolve, reject) =>
    req.session.regenerate((err) => {
      if (err) return reject(err);
      req.session.userId = userId;
      if (!remember) {
        req.session.cookie.maxAge = null as unknown as number;
      } else {
        req.session.cookie.maxAge = 7 * 24 * 60 * 60_000;
      }
      req.session.save((saveErr) => (saveErr ? reject(saveErr) : resolve()));
    }),
  );
}

export const authRouter = Router();

authRouter.use(["/register", "/login"], rateLimit({ windowMs: 15 * 60_000, limit: 20 }));

authRouter.get("/providers", (_req, res) => {
  res.json({
    github: Boolean(config.GITHUB_CLIENT_ID && config.GITHUB_CLIENT_SECRET),
    google: Boolean(config.GOOGLE_CLIENT_ID && config.GOOGLE_CLIENT_SECRET),
  });
});

authRouter.post("/register", async (req, res) => {
  const { fullName, email, password, language } = registerSchema.parse(req.body);
  const { rows } = await pool.query<{
    id: string;
    email: string;
    full_name: string | null;
    debug_language: string | null;
  }>(
    `INSERT INTO users (email, password_hash, full_name, debug_language, terms_accepted_at)
     VALUES ($1, $2, $3, $4, now())
     ON CONFLICT (email) DO NOTHING
     RETURNING id, email, full_name, debug_language`,
    [email, await hashPassword(password), fullName || null, language || null],
  );
  if (rows.length === 0) throw new HttpError(409, "Email already registered");
  await startSession(req, rows[0].id, true);
  res.status(201).json({
    user: {
      id: rows[0].id,
      email: rows[0].email,
      fullName: rows[0].full_name,
      debugLanguage: rows[0].debug_language,
    },
  });
});

authRouter.post("/login", async (req, res) => {
  const { email, password, remember } = loginSchema.parse(req.body);
  const { rows } = await pool.query<{
    id: string;
    email: string;
    password_hash: string | null;
    full_name: string | null;
    debug_language: string | null;
  }>(
    "SELECT id, email, password_hash, full_name, debug_language FROM users WHERE email = $1",
    [email],
  );
  const user = rows[0];
  const ok = await verifyPassword(password, user?.password_hash ?? dummyHash);
  if (!user || !user.password_hash || !ok) throw new HttpError(401, "Invalid email or password");
  await startSession(req, user.id, remember);
  res.json({
    user: {
      id: user.id,
      email: user.email,
      fullName: user.full_name,
      debugLanguage: user.debug_language,
    },
  });
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
  const { rows } = await pool.query<{
    id: string;
    email: string;
    full_name: string | null;
    debug_language: string | null;
  }>("SELECT id, email, full_name, debug_language FROM users WHERE id = $1", [req.session.userId]);
  if (!rows[0]) return void res.json({ user: null });
  res.json({
    user: {
      id: rows[0].id,
      email: rows[0].email,
      fullName: rows[0].full_name,
      debugLanguage: rows[0].debug_language,
    },
  });
});
