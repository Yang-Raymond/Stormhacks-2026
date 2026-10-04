import crypto from "node:crypto";
import { Router } from "express";
import { config } from "./config.js";
import { pool } from "./db.js";
import { startSession } from "./auth.js";

export const oauthRouter = Router();

type Provider = "github" | "google";

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

oauthRouter.get("/:provider/start", async (req, res) => {
  const provider = req.params.provider as Provider;
  const from = req.query.from === "register" ? "register" : "login";
  const remember = req.query.remember === "true" || req.query.remember === "1";
  const language = typeof req.query.language === "string" ? req.query.language : undefined;

  if (provider === "github") {
    if (!config.GITHUB_CLIENT_ID || !config.GITHUB_CLIENT_SECRET) {
      return void res.redirect(`${config.PUBLIC_URL}/login?error=not_configured`);
    }

    const state = crypto.randomBytes(24).toString("hex");
    req.session.oauth = {
      provider: "github",
      state,
      verifier: "",
      remember,
      language,
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
      return void res.redirect(`${config.PUBLIC_URL}/login?error=not_configured`);
    }

    const state = crypto.randomBytes(24).toString("hex");
    const verifier = generateCodeVerifier();
    const challenge = generateCodeChallenge(verifier);

    req.session.oauth = {
      provider: "google",
      state,
      verifier,
      remember,
      language,
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

  res.redirect(`${config.PUBLIC_URL}/login?error=not_configured`);
});

oauthRouter.get("/:provider/callback", async (req, res) => {
  const provider = req.params.provider as Provider;
  const { code, state, error } = req.query;

  const returnError = (code: string) => {
    res.redirect(`${config.PUBLIC_URL}/login?error=${encodeURIComponent(code)}`);
  };

  if (error || !code || !state || typeof code !== "string" || typeof state !== "string") {
    return void returnError("oauth_failed");
  }

  const oauthSession = req.session.oauth;
  if (!oauthSession || oauthSession.provider !== provider || oauthSession.state !== state) {
    return void returnError("oauth_failed");
  }

  const { remember, language, from, verifier } = oauthSession;
  delete req.session.oauth;

  try {
    let providerUserId = "";
    let email = "";
    let fullName = "";

    if (provider === "github") {
      if (!config.GITHUB_CLIENT_ID || !config.GITHUB_CLIENT_SECRET) {
        return void returnError("not_configured");
      }

      const tokenRes = await fetch("https://github.com/login/oauth/access_token", {
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

      const tokenData = (await tokenRes.json()) as { access_token?: string; error?: string };
      if (!tokenData.access_token) {
        console.error("GitHub token exchange error:", tokenData);
        return void returnError("oauth_failed");
      }

      const userRes = await fetch("https://api.github.com/user", {
        headers: {
          Authorization: `Bearer ${tokenData.access_token}`,
          "User-Agent": "LadyBug-App",
        },
      });
      const userData = (await userRes.json()) as { id: number; name?: string; login: string };
      providerUserId = String(userData.id);
      fullName = userData.name || userData.login || "";

      // Fetch verified emails
      const emailsRes = await fetch("https://api.github.com/user/emails", {
        headers: {
          Authorization: `Bearer ${tokenData.access_token}`,
          "User-Agent": "LadyBug-App",
        },
      });
      const emailsData = (await emailsRes.json()) as Array<{
        email: string;
        primary: boolean;
        verified: boolean;
      }>;

      const verifiedEmailObj =
        emailsData.find((e) => e.primary && e.verified) ?? emailsData.find((e) => e.verified);

      if (!verifiedEmailObj?.email) {
        return void returnError("email_unverified");
      }
      email = verifiedEmailObj.email;
    } else if (provider === "google") {
      if (!config.GOOGLE_CLIENT_ID || !config.GOOGLE_CLIENT_SECRET) {
        return void returnError("not_configured");
      }

      const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
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

      const tokenData = (await tokenRes.json()) as { access_token?: string; error?: string };
      if (!tokenData.access_token) {
        console.error("Google token exchange error:", tokenData);
        return void returnError("oauth_failed");
      }

      const userRes = await fetch("https://openidconnect.googleapis.com/v1/userinfo", {
        headers: {
          Authorization: `Bearer ${tokenData.access_token}`,
        },
      });
      const userData = (await userRes.json()) as {
        sub: string;
        email: string;
        email_verified?: boolean;
        name?: string;
      };

      if (!userData.email_verified || !userData.email) {
        return void returnError("email_unverified");
      }

      providerUserId = userData.sub;
      email = userData.email;
      fullName = userData.name || "";
    } else {
      return void returnError("not_configured");
    }

    // Now resolve or create user in DB transaction
    const client = await pool.connect();
    let userId: string | null = null;

    try {
      await client.query("BEGIN");

      // 1. Check if oauth_accounts has this provider + provider_user_id
      const oauthQuery = await client.query<{ user_id: string }>(
        "SELECT user_id FROM oauth_accounts WHERE provider = $1 AND provider_user_id = $2",
        [provider, providerUserId],
      );

      if (oauthQuery.rows.length > 0) {
        userId = oauthQuery.rows[0].user_id;
      } else {
        // 2. Check if user with verified email exists
        const userQuery = await client.query<{ id: string }>(
          "SELECT id FROM users WHERE email = $1",
          [email],
        );

        if (userQuery.rows.length > 0) {
          // Link existing user
          userId = userQuery.rows[0].id;
          await client.query(
            "INSERT INTO oauth_accounts (provider, provider_user_id, user_id) VALUES ($1, $2, $3)",
            [provider, providerUserId, userId],
          );
        } else {
          // User doesn't exist
          if (from === "login") {
            await client.query("ROLLBACK");
            return void returnError("account_not_found");
          }

          // Register new user
          const insertUser = await client.query<{ id: string }>(
            `INSERT INTO users (email, full_name, debug_language, terms_accepted_at)
             VALUES ($1, $2, $3, now()) RETURNING id`,
            [email, fullName || null, language || null],
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
      await client.query("ROLLBACK");
      throw dbErr;
    } finally {
      client.release();
    }

    if (!userId) {
      return void returnError("oauth_failed");
    }

    await startSession(req, userId, remember);
    res.redirect(`${config.PUBLIC_URL}/problems`);
  } catch (err) {
    console.error("OAuth callback error:", err);
    returnError("oauth_failed");
  }
});
