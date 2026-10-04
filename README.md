# LadyBug

A LeetCode-style app where, instead of solving problems, you **fix buggy code**. Gemini generates a Python problem with injected bugs at a chosen difficulty; your fix is graded against hidden test cases in a sandboxed runner.

## Services

| Service  | Path        | Port | Notes |
|----------|-------------|------|-------|
| `db`     | —           | 5432 | Postgres + TimescaleDB (same engine as Tiger Data) |
| `runner` | `runner/`   | 8000 (internal only) | Stdlib Python service that executes untrusted code |
| `server` | `server/`   | 4000 | Express 5 + TypeScript API |
| `front_end` | `front_end/` | 3000 | Next.js + Monaco; proxies `/api/*` to the server |

## Getting started

```bash
cp .env.example .env      # fill in GEMINI_API_KEY and SESSION_SECRET (openssl rand -hex 32)
docker compose up --build
curl localhost:4000/api/health
# then open http://localhost:3000
```

To enable GitHub and Google OAuth, add to `.env`:
```env
PUBLIC_URL=http://localhost:3000
GITHUB_CLIENT_ID=...
GITHUB_CLIENT_SECRET=...
GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...
```

OAuth callback URLs to configure in GitHub & Google Developer consoles:
- GitHub: `http://localhost:3000/api/auth/oauth/github/callback`
- Google: `http://localhost:3000/api/auth/oauth/google/callback`

`server/` is bind-mounted, so edits hot-reload. After changing `server/package.json`, rebuild: `docker compose up --build server`.

Migrations in `server/migrations/*.sql` run automatically on server start (tracked in `schema_migrations`). Add new ones as `003_*.sql`, never edit an applied one.

To use Tiger Data cloud instead of the local db, set `DATABASE_URL` in `.env` (with `?sslmode=require`).

## API

All bodies are JSON. Auth uses an httpOnly session cookie (`sid`).

| Method | Path | Auth | Body / notes |
|--------|------|------|--------------|
| GET  | `/api/health` | | |
| GET  | `/api/auth/providers` | | Returns `{ github: boolean, google: boolean }` |
| POST | `/api/auth/register` | | `{email, password, fullName?, language?, acceptTerms: true}` |
| POST | `/api/auth/login` | | `{email, password, remember?: boolean}` |
| GET  | `/api/auth/oauth/:provider/start` | | Query: `from=login\|register`, `remember`, `language` |
| GET  | `/api/auth/oauth/:provider/callback` | | OAuth redirect handler with PKCE & state validation |
| POST | `/api/auth/logout` | | |
| GET  | `/api/auth/me` | | `{user: {id, email, fullName, debugLanguage}}` or `{user: null}` |
| GET  | `/api/problems` | | list with `solved` flag for the current user |
| GET  | `/api/problems/:id` | | problem, buggy code, example tests (never the fix or hidden tests) |
| POST | `/api/problems/generate` | ✓ | `{difficulty: "easy"\|"medium"\|"hard"}` → `{id}`; takes ~10–30s |
| POST | `/api/problems/:id/run` | ✓ | `{code}` → runs example tests only |
| POST | `/api/problems/:id/submit` | ✓ | `{code}` → runs all tests, records submission |

Run/submit response: `{status: "ok"|"error"|"timeout", error?, passedCount, totalCount, visibleResults: [{args, expected, passed, actual?, error?}], passed? }`.

Generated problems are only saved if the reference fix passes every test **and** the buggy code fails at least one; otherwise generation retries (up to 3 times).

## Sandbox notes

The runner applies rlimits (CPU, memory, file size, open files), a 5s timeout, an empty environment, and kills the whole process group after each run. Real isolation comes from the container settings in `docker-compose.yml`: no internet (internal network), read-only filesystem, non-root user, all capabilities dropped, memory/CPU/PID caps. Keep those settings wherever the runner is deployed. It's good enough for a hackathon, but it isn't hardened for hostile public traffic (for that, use gVisor or a per-run container).
