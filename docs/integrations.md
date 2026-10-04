# Sponsor integrations: Tiger Data, .tech

LadyBug uses two hackathon sponsors. The code is in place; this guide covers the accounts and settings only a
team member can create, and how to show each one to judges.

| Sponsor | What it powers | Status without setup |
|---|---|---|
| **Tiger Data** | Every run, submit, debug session, hint and challenge start is stored in a TimescaleDB **hypertable**. A **continuous aggregate** turns it into per-day activity for the streaks and heatmap on the Problems page. | Works on the local TimescaleDB container; move it to Tiger Cloud for the prize. |
| **.tech domain** | The public address of the app. | Claim now, connect when we deploy. |

---

## 1. Tiger Data (Tiger Cloud)

1. Sign up at <https://console.cloud.timescale.com> (Tiger Cloud) and create a **service**. The free tier is
   enough. Choose the region closest to us (e.g. us-west).
2. Open the service, then **Connect**, and copy the connection string. It looks like
   `postgres://tsdbadmin:<password>@<host>:<port>/tsdb?sslmode=require`.
3. Put it in `.env`, adding `uselibpqcompat=true&` before `sslmode`:
   ```env
   DATABASE_URL=postgres://tsdbadmin:<password>@<host>:<port>/tsdb?uselibpqcompat=true&sslmode=require
   ```
   Without it, node-pg treats `sslmode=require` as full certificate verification and fails with
   *"self-signed certificate in certificate chain"*. With it, the connection is still encrypted, the same as
   `psql` behaves.
4. Run `docker compose up -d server`. Use `up -d`, not `restart`, so the container picks up the new value. On start the server runs every migration against Tiger Cloud, including
   `013_activity_events.sql`, which creates the hypertable, the columnstore (compression) policy and the
   `daily_activity` continuous aggregate. Existing local data isn't copied; it's a fresh database.
5. Check in the Tiger Cloud SQL editor:
   ```sql
   SELECT hypertable_name, compression_enabled FROM timescaledb_information.hypertables;   -- events
   SELECT view_name FROM timescaledb_information.continuous_aggregates;                     -- daily_activity
   SELECT application_name, schedule_interval FROM timescaledb_information.jobs;            -- both policies
   ```

**What to show judges:** the activity heatmap and streaks on `/problems` (from `daily_activity`). Run some code,
and the event lands in the hypertable immediately. The aggregate is real-time, so it shows up without waiting
for a refresh. The code is in `server/src/activity.ts` and `server/migrations/013_activity_events.sql`.

## 2. .tech domain

1. Claim the free domain through MLH's .tech offer for StormHacks: follow the link in the hackathon's
   perks or Discord, then register the name at <https://get.tech>. Something like `ladybug-debug.tech`.
2. Nothing else is needed until we deploy. At deploy time:
   - Point an **A record** for `@` (and `www`) at the server's public IP in the get.tech DNS panel.
   - Put **Caddy** in front of the front end (port 3000). It gets HTTPS certificates automatically.
     A Caddyfile is just `ladybug-debug.tech { reverse_proxy front_end:3000 }`. Caddy also replaces any
     `X-Forwarded-For` header a client sends with the real client IP, which the API's rate limits rely on. Only
     Caddy's ports (80/443) should be public: the API (4000) and database (5432) stay bound to localhost.
   - In `.env`, set `PUBLIC_URL=https://ladybug-debug.tech` and `NODE_ENV=production`. Production mode makes
     session cookies `secure`.
   - Update the OAuth callback URLs in the GitHub and Google consoles to `https://ladybug-debug.tech/api/auth/oauth/<provider>/callback`.

**What to show judges:** the app live at the .tech address.
