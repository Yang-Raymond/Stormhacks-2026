import { Router, type RequestHandler } from "express";
import { rateLimit } from "express-rate-limit";
import { z } from "zod";
import { config } from "./config.js";
import { pool } from "./db.js";
import { HttpError } from "./errors.js";
import { hashPassword, verifyPassword } from "./password.js";

export const ROLES = [
  "Software engineer",
  "Student",
  "Data scientist",
  "QA / test engineer",
  "Engineering manager",
  "Other",
] as const;

export const LANGS = [
  "Python",
  "TypeScript",
  "JavaScript",
  "Go",
  "Other",
] as const;

const registerSchema = z.object({
  fullName: z.string().trim().max(100).optional(),
  email: z.string().email().max(254),
  password: z.string().min(8).max(128),
});

const loginSchema = z.object({
  email: z.string().email().max(254),
  password: z.string().min(1).max(128),
  remember: z.boolean().optional().default(false),
});

const onboardingSchema = z.object({
  fullName: z.string().trim().min(1, "Display name is required").max(100),
  role: z.enum(ROLES, { message: "Please select a valid role" }),
  languages: z.array(z.enum(LANGS)).min(1, "Pick at least one language"),
  acceptTerms: z.literal(true, {
    message: "You must accept the terms of service to continue",
  }),
});

const profileSchema = z.object({
  fullName: z.string().trim().min(1, "Display name is required").max(100),
  role: z.enum(ROLES, { message: "Please select a valid role" }),
  languages: z.array(z.enum(LANGS)).min(1, "Pick at least one language"),
});

export type UserRow = {
  id: string;
  email: string;
  full_name: string | null;
  role: string | null;
  debug_languages: string[] | null;
  avatar_url: string | null;
  onboarded_at: Date | string | null;
  created_at?: Date | string | null;
};

export function toUser(row: UserRow) {
  return {
    id: row.id,
    email: row.email,
    fullName: row.full_name,
    role: row.role,
    debugLanguages: row.debug_languages ?? [],
    avatarUrl: row.avatar_url,
    onboarded: Boolean(row.onboarded_at),
    createdAt: row.created_at ? new Date(row.created_at).toISOString() : undefined,
  };
}

// Compared against when the email is unknown so login timing doesn't reveal which emails exist.
const dummyHash = await hashPassword("timing-equaliser");

export const requireAuth: RequestHandler = (req, _res, next) => {
  if (!req.session.userId) return next(new HttpError(401, "Not logged in"));
  next();
};

export function startSession(
  req: Parameters<RequestHandler>[0],
  userId: string,
  remember = true,
  authMethod: "email" | "github" | "google" = "email",
) {
  // Regenerate the session id on login to prevent session fixation.
  return new Promise<void>((resolve, reject) =>
    req.session.regenerate((err) => {
      if (err) return reject(err);
      req.session.userId = userId;
      req.session.authMethod = authMethod;
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
  const { fullName, email, password } = registerSchema.parse(req.body);
  const { rows } = await pool.query<UserRow>(
    `INSERT INTO users (email, password_hash, full_name, terms_accepted_at)
     VALUES ($1, $2, $3, NULL)
     ON CONFLICT (email) DO NOTHING
     RETURNING id, email, full_name, role, debug_languages, avatar_url, onboarded_at, created_at`,
    [email, await hashPassword(password), fullName || null],
  );
  if (rows.length === 0) {
    throw new HttpError(409, "An account with this email already exists. Log in instead.");
  }
  await startSession(req, rows[0].id, true, "email");
  res.status(201).json({
    user: toUser(rows[0]),
  });
});

authRouter.post("/login", async (req, res) => {
  const { email, password, remember } = loginSchema.parse(req.body);
  const { rows } = await pool.query<UserRow & { password_hash: string | null }>(
    "SELECT id, email, password_hash, full_name, role, debug_languages, avatar_url, onboarded_at, created_at FROM users WHERE email = $1",
    [email],
  );
  const user = rows[0];
  const ok = await verifyPassword(password, user?.password_hash ?? dummyHash);
  if (!user || !user.password_hash || !ok) throw new HttpError(401, "Invalid email or password");
  await startSession(req, user.id, remember, "email");
  res.json({
    user: toUser(user),
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
  const { rows } = await pool.query<UserRow>(
    "SELECT id, email, full_name, role, debug_languages, avatar_url, onboarded_at, created_at FROM users WHERE id = $1",
    [req.session.userId],
  );
  if (!rows[0]) return void res.json({ user: null });
  res.json({
    user: toUser(rows[0]),
    authMethod: req.session.authMethod ?? "email",
  });
});

authRouter.post("/onboarding", requireAuth, async (req, res) => {
  const { fullName, role, languages } = onboardingSchema.parse(req.body);
  const { rows } = await pool.query<UserRow>(
    `UPDATE users
     SET full_name = $1, role = $2, debug_languages = $3, terms_accepted_at = now(), onboarded_at = now()
     WHERE id = $4
     RETURNING id, email, full_name, role, debug_languages, avatar_url, onboarded_at, created_at`,
    [fullName, role, languages, req.session.userId],
  );
  if (rows.length === 0) throw new HttpError(404, "User not found");
  res.json({
    user: toUser(rows[0]),
  });
});

authRouter.patch("/profile", requireAuth, async (req, res) => {
  const { fullName, role, languages } = profileSchema.parse(req.body);
  const { rows } = await pool.query<UserRow>(
    `UPDATE users
     SET full_name = $1, role = $2, debug_languages = $3
     WHERE id = $4
     RETURNING id, email, full_name, role, debug_languages, avatar_url, onboarded_at, created_at`,
    [fullName, role, languages, req.session.userId],
  );
  if (rows.length === 0) throw new HttpError(404, "User not found");
  res.json({
    user: toUser(rows[0]),
  });
});
