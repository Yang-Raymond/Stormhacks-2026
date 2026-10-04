import crypto from "node:crypto";
import { Router, type Response } from "express";
import { z } from "zod";
import { config } from "./config.js";
import { pool } from "./db.js";
import { startSession } from "./auth.js";

export const oauthRouter = Router();

type Provider = "github" | "google";
export type AuthErrorCode =
  | "email_exists"
  | "account_not_found"
  | "oauth_cancelled"
  | "oauth_state_invalid"
  | "provider_error"
  | "email_unverified"
  | "not_configured"
  | "oauth_failed";

function getCallbackUrl(provider: Provider): string {
  return `${config.PUBLIC_URL}/api/auth/oauth/${provider}/callback`;
}

function base64url(buf: Buffer): string {
  return buf
    .toString("base64")
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=/g, "");
}

function generateCodeVerifier(): string {
  return base64url(crypto.randomBytes(32));
}

function generateCodeChallenge(verifier: string): string {
  return base64url(crypto.createHash("sha256").update(verifier).digest());
}

function makeState(from: "login" | "register"): string {
  return `${from}.${crypto.randomBytes(24).toString("hex")}`;
}

function parseStateFrom(state: string | undefined): "login" | "register" {
  if (typeof state === "string" && state.startsWith("register.")) {
    return "register";
  }
  return "login";
}

function redirectToCallback(
  res: Response,
  params: { error?: AuthErrorCode; from: "login" | "register" },
) {
  const query = new URLSearchParams();
  if (params.error) query.set("error", params.error);
  query.set("from", params.from);
  return res.redirect(`${config.PUBLIC_URL}/auth/callback?${query.toString()}`);
}

async function providerFetch(url: string, options: RequestInit = {}) {
  const res = await fetch(url, {
    ...options,
    signal: AbortSignal.timeout(10_000),
  });
  if (!res.ok) {
    throw new Error(`Provider HTTP error: ${res.status}`);
  }
  return res.json();
}

const githubTokenSchema = z.object({
  access_token: z.string().optional(),
  error: z.string().optional(),
});

const githubUserSchema = z.object({
  id: z.number(),
  name: z.string().nullish(),
  login: z.string(),
  avatar_url: z.string().nullish(),
});

const githubEmailListSchema = z.array(
  z.object({
    email: z.string(),
    primary: z.boolean(),
    verified: z.boolean(),
  }),
);

const googleTokenSchema = z.object({
  access_token: z.string().optional(),
  error: z.string().optional(),
});

const googleUserSchema = z.object({
  sub: z.string(),
  email: z.string().email(),
  email_verified: z.boolean().optional(),
  name: z.string().nullish(),
  picture: z.string().nullish(),
});

oauthRouter.get("/:provider/start", async (req, res) => {
  const providerParam = req.params.provider;
  const from = req.query.from === "register" ? "register" : "login";
  const remember = req.query.remember === "true" || req.query.remember === "1";

  if (providerParam !== "github" && providerParam !== "google") {
    return void redirectToCallback(res, { error: "not_configured", from });
  }

  const provider = providerParam as Provider;

  if (provider === "github") {
    if (!config.GITHUB_CLIENT_ID || !config.GITHUB_CLIENT_SECRET) {
      return void redirectToCallback(res, { error: "not_configured", from });
    }

    const state = makeState(from);
    req.session.oauth = {
      provider: "github",
      state,
      verifier: "",
      remember,
      from,
    };

    await new Promise<void>((resolve, reject) =>
      req.session.save((err) => (err ? reject(err) : resolve())),
    );

    const redirectUri = getCallbackUrl("github");
    const authUrl = new URL("https://github.com/login/oauth/authorize");
    authUrl.searchParams.set("client_id", config.GITHUB_CLIENT_ID);
    authUrl.searchParams.set("redirect_uri", redirectUri);
    authUrl.searchParams.set("scope", "read:user user:email");
    authUrl.searchParams.set("state", state);

    return void res.redirect(authUrl.toString());
  }

  if (provider === "google") {
    if (!config.GOOGLE_CLIENT_ID || !config.GOOGLE_CLIENT_SECRET) {
      return void redirectToCallback(res, { error: "not_configured", from });
    }

    const state = makeState(from);
    const verifier = generateCodeVerifier();
    const challenge = generateCodeChallenge(verifier);

    req.session.oauth = {
      provider: "google",
      state,
      verifier,
      remember,
      from,
    };

    await new Promise<void>((resolve, reject) =>
      req.session.save((err) => (err ? reject(err) : resolve())),
    );

    const redirectUri = getCallbackUrl("google");
    const authUrl = new URL("https://accounts.google.com/o/oauth2/v2/auth");
    authUrl.searchParams.set("client_id", config.GOOGLE_CLIENT_ID);
    authUrl.searchParams.set("redirect_uri", redirectUri);
    authUrl.searchParams.set("response_type", "code");
    authUrl.searchParams.set("scope", "openid email profile");
    authUrl.searchParams.set("state", state);
    authUrl.searchParams.set("code_challenge", challenge);
    authUrl.searchParams.set("code_challenge_method", "S256");

    return void res.redirect(authUrl.toString());
  }
});

oauthRouter.get("/:provider/callback", async (req, res) => {
  const providerParam = req.params.provider;
  const { code, state, error } = req.query;

  const fallbackFrom = parseStateFrom(typeof state === "string" ? state : undefined);

  if (error === "access_denied") {
    return void redirectToCallback(res, { error: "oauth_cancelled", from: fallbackFrom });
  }

  if (error || !code || !state || typeof code !== "string" || typeof state !== "string") {
    return void redirectToCallback(res, { error: "oauth_failed", from: fallbackFrom });
  }

  if (providerParam !== "github" && providerParam !== "google") {
    return void redirectToCallback(res, { error: "not_configured", from: fallbackFrom });
  }

  const provider = providerParam as Provider;
  const oauthSession = req.session.oauth;

  if (!oauthSession || oauthSession.provider !== provider || oauthSession.state !== state) {
    return void redirectToCallback(res, { error: "oauth_state_invalid", from: fallbackFrom });
  }

  const { remember, from, verifier } = oauthSession;

  // Single-use: delete state and persist immediately before token exchange
  delete req.session.oauth;
  await new Promise<void>((resolve) => req.session.save(() => resolve()));

  let providerUserId = "";
  let email = "";
  let fullName = "";
  let avatarUrl: string | null = null;

  try {
    if (provider === "github") {
      if (!config.GITHUB_CLIENT_ID || !config.GITHUB_CLIENT_SECRET) {
        return void redirectToCallback(res, { error: "not_configured", from });
      }

      const tokenRaw = await providerFetch("https://github.com/login/oauth/access_token", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
        },
        body: JSON.stringify({
          client_id: config.GITHUB_CLIENT_ID,
          client_secret: config.GITHUB_CLIENT_SECRET,
          code,
          redirect_uri: getCallbackUrl("github"),
        }),
      });

      const tokenData = githubTokenSchema.parse(tokenRaw);
      if (!tokenData.access_token) {
        console.error("GitHub token exchange error:", tokenData);
        return void redirectToCallback(res, { error: "provider_error", from });
      }

      const userRaw = await providerFetch("https://api.github.com/user", {
        headers: {
          Authorization: `Bearer ${tokenData.access_token}`,
          "User-Agent": "LadyBug-App",
        },
      });
      const userData = githubUserSchema.parse(userRaw);
      providerUserId = String(userData.id);
      fullName = userData.name?.trim() || userData.login;
      avatarUrl = userData.avatar_url ?? null;

      // Fetch emails
      const emailsRaw = await providerFetch("https://api.github.com/user/emails", {
        headers: {
          Authorization: `Bearer ${tokenData.access_token}`,
          "User-Agent": "LadyBug-App",
        },
      });
      const emailsData = githubEmailListSchema.parse(emailsRaw);
      const verifiedEmailObj =
        emailsData.find((e) => e.primary && e.verified) ?? emailsData.find((e) => e.verified);

      if (!verifiedEmailObj?.email) {
        return void redirectToCallback(res, { error: "email_unverified", from });
      }
      email = verifiedEmailObj.email;
    } else if (provider === "google") {
      if (!config.GOOGLE_CLIENT_ID || !config.GOOGLE_CLIENT_SECRET) {
        return void redirectToCallback(res, { error: "not_configured", from });
      }

      const tokenRaw = await providerFetch("https://oauth2.googleapis.com/token", {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: new URLSearchParams({
          client_id: config.GOOGLE_CLIENT_ID,
          client_secret: config.GOOGLE_CLIENT_SECRET,
          code,
          code_verifier: verifier,
          grant_type: "authorization_code",
          redirect_uri: getCallbackUrl("google"),
        }),
      });

      const tokenData = googleTokenSchema.parse(tokenRaw);
      if (!tokenData.access_token) {
        console.error("Google token exchange error:", tokenData);
        return void redirectToCallback(res, { error: "provider_error", from });
      }

      const userRaw = await providerFetch("https://openidconnect.googleapis.com/v1/userinfo", {
        headers: {
          Authorization: `Bearer ${tokenData.access_token}`,
        },
      });
      const userData = googleUserSchema.parse(userRaw);

      if (!userData.email_verified || !userData.email) {
        return void redirectToCallback(res, { error: "email_unverified", from });
      }

      providerUserId = userData.sub;
      email = userData.email;
      fullName = userData.name?.trim() || email.split("@")[0];
      avatarUrl = userData.picture ?? null;
    }
  } catch (providerErr) {
    console.error("OAuth provider fetch error:", providerErr);
    return void redirectToCallback(res, { error: "provider_error", from });
  }

  // Resolve or create user in DB transaction
  const client = await pool.connect();
  let userId: string | null = null;

  try {
    await client.query("BEGIN");

    // 1. Check if oauth_accounts already has this provider + provider_user_id
    const oauthQuery = await client.query<{ user_id: string }>(
      "SELECT user_id FROM oauth_accounts WHERE provider = $1 AND provider_user_id = $2",
      [provider, providerUserId],
    );

    if (oauthQuery.rows.length > 0) {
      userId = oauthQuery.rows[0].user_id;
      if (avatarUrl) {
        await client.query("UPDATE users SET avatar_url = COALESCE(avatar_url, $1) WHERE id = $2", [
          avatarUrl,
          userId,
        ]);
      }
    } else {
      // 2. Check if user with verified email exists
      const userQuery = await client.query<{ id: string; has_password: boolean }>(
        "SELECT id, password_hash IS NOT NULL AS has_password FROM users WHERE email = $1",
        [email],
      );

      if (userQuery.rows.length > 0) {
        // Email already registered: check origin
        if (from === "register") {
          await client.query("ROLLBACK");
          return void redirectToCallback(res, { error: "email_exists", from: "register" });
        }

        // Registration never verifies the email, so an account with a password may have been created by someone
        // else using this address. Linking it would hand the provider's (verified) owner an account that stranger
        // can still log into, so password accounts keep using their password.
        if (userQuery.rows[0].has_password) {
          await client.query("ROLLBACK");
          return void redirectToCallback(res, { error: "email_exists", from: "login" });
        }

        // From login: link to the existing OAuth-only account
        userId = userQuery.rows[0].id;
        await client.query(
          "INSERT INTO oauth_accounts (provider, provider_user_id, user_id) VALUES ($1, $2, $3)",
          [provider, providerUserId, userId],
        );
        if (avatarUrl) {
          await client.query("UPDATE users SET avatar_url = COALESCE(avatar_url, $1) WHERE id = $2", [
            avatarUrl,
            userId,
          ]);
        }
      } else {
        // User does not exist
        if (from === "login") {
          await client.query("ROLLBACK");
          return void redirectToCallback(res, { error: "account_not_found", from: "login" });
        }

        // Register new user (terms accepted at onboarding)
        const insertUser = await client.query<{ id: string }>(
          `INSERT INTO users (email, full_name, avatar_url, terms_accepted_at)
           VALUES ($1, $2, $3, NULL) RETURNING id`,
          [email, fullName || null, avatarUrl || null],
        );
        userId = insertUser.rows[0].id;

        await client.query(
          "INSERT INTO oauth_accounts (provider, provider_user_id, user_id) VALUES ($1, $2, $3)",
          [provider, providerUserId, userId],
        );
      }
    }

    await client.query("COMMIT");
  } catch (dbErr) {
    await client.query("ROLLBACK").catch(() => {});
    console.error("OAuth database transaction error:", dbErr);
    return void redirectToCallback(res, { error: "oauth_failed", from });
  } finally {
    client.release();
  }

  if (!userId) {
    return void redirectToCallback(res, { error: "oauth_failed", from });
  }

  await startSession(req, userId, remember, provider);
  return void redirectToCallback(res, { from });
});
