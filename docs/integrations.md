# Sponsor integrations: Tiger Data, Snowflake, .tech

LadyBug uses three hackathon sponsors. The code is in place; this guide covers the accounts and settings only a
team member can create, and how to show each one to judges.

| Sponsor | What it powers | Status without setup |
|---|---|---|
| **Tiger Data** | Every run, submit, debug session, hint and challenge start is stored in a TimescaleDB **hypertable**. A **continuous aggregate** turns it into per-day activity for the streaks and heatmap on the Problems page. | Works on the local TimescaleDB container; move it to Tiger Cloud for the prize. |
| **Snowflake** | **Cortex** generates the AI hints ("Hint" button). The events are synced, anonymized, into a Snowflake **warehouse** that powers the **Insights** page. | Hint button hidden; Insights shows "not connected". Nothing breaks. |
| **.tech domain** | The public address of the app. | Claim now, connect when we deploy. |

---

## 1. Tiger Data (Tiger Cloud)

1. Sign up at <https://console.cloud.timescale.com> (Tiger Cloud) and create a **service**. The free tier is
   enough. Choose the region closest to us (e.g. us-west).
2. Open the service, then **Connect**, and copy the connection string. It looks like
   `postgres://tsdbadmin:<password>@<host>:<port>/tsdb?sslmode=require`.
3. Put it in `.env`:
   ```env
   DATABASE_URL=postgres://tsdbadmin:<password>@<host>:<port>/tsdb?sslmode=require
   ```
4. `docker compose up -d server`. On start the server runs every migration against Tiger Cloud, including
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

## 2. Snowflake

1. Start a free trial at <https://signup.snowflake.com>. Pick **Enterprise** and **AWS us-west-2 (Oregon)**:
   Cortex LLM functions are available there.
2. In Snowsight, open a new **SQL worksheet**, paste `server/snowflake/setup.sql`, and **Run All**. It creates:
   - the `LADYBUG_WH` warehouse (XSMALL, auto-suspends after 60s);
   - the `LADYBUG.ANALYTICS.EVENTS` table;
   - the `LADYBUG_APP` role with Cortex access;
   - the `LADYBUG_SVC` service user and its access token.
3. From the results, copy:
   - **`token_secret`** from the `ADD PROGRAMMATIC ACCESS TOKEN` statement. It's shown only once; if you lose it,
     run `ALTER USER LADYBUG_SVC REMOVE PROGRAMMATIC ACCESS TOKEN LADYBUG_SERVER;` and add it again.
   - **`SNOWFLAKE_ACCOUNT`** from the last query (format `orgname-accountname`).
4. Add to `.env`, then restart the server (`docker compose restart server`):
   ```env
   SNOWFLAKE_ACCOUNT=myorg-myaccount
   SNOWFLAKE_TOKEN=<token_secret>
   ANALYTICS_SALT=<openssl rand -hex 16>
   ```
   The warehouse, database, schema, role and model have defaults matching `setup.sql`. Override them with
   `SNOWFLAKE_*` variables if you change names.
5. Check that it works:
   - The server log no longer says `analytics sync disabled`. Within about 5 minutes it logs
     `analytics sync: shipped N events to Snowflake`.
   - In Snowflake, `SELECT COUNT(*) FROM LADYBUG.ANALYTICS.EVENTS;` returns rows.
   - On a problem page, a **Hint** button appears. Failing test cards get **Get a hint**.
   - `/insights` shows numbers instead of "not connected". The page is cached for 10 minutes.

**If something fails:**
- *"Snowflake rejected the request"* in the server log: the message after it is Snowflake's own error. The usual
  causes are a wrong account identifier, an expired or removed token, or the role missing a grant (re-run
  `setup.sql`).
- *Cortex model unavailable*: set `SNOWFLAKE_CORTEX_MODEL` to another model, e.g. `llama3.1-70b`, or confirm
  `CORTEX_ENABLED_CROSS_REGION` was set.
- *Token rejected because of network policy*: the authentication policy in `setup.sql` lifts that requirement.
  Once we have a fixed server IP, replace it with a network policy that allows only that IP.

**What to show judges:**
- Click **Hint** on a failing problem. The server sends the problem, the code and the failing case to
  `SNOWFLAKE.CORTEX.COMPLETE` through the **SQL API**, and returns a nudge, not the fix.
- Open `/insights`. Every number there is computed by SQL queries running in the Snowflake warehouse over the
  synced events.

The code is in `server/src/snowflake.ts` (SQL API client), `hints.ts`, `analyticsSync.ts` and `insights.ts`.

Hints are limited to 10 per user per hour. Every hint and sync uses warehouse credits, which the trial covers
easily.

## 3. .tech domain

1. Claim the free domain through MLH's .tech offer for StormHacks: follow the link in the hackathon's
   perks or Discord, then register the name at <https://get.tech>. Something like `ladybug-debug.tech`.
2. Nothing else is needed until we deploy. At deploy time:
   - Point an **A record** for `@` (and `www`) at the server's public IP in the get.tech DNS panel.
   - Put **Caddy** in front of the front end (port 3000). It gets HTTPS certificates automatically.
     A Caddyfile is just `ladybug-debug.tech { reverse_proxy front_end:3000 }`.
   - In `.env`, set `PUBLIC_URL=https://ladybug-debug.tech` and `NODE_ENV=production`. Production mode makes
     session cookies `secure`.
   - Update the OAuth callback URLs in the GitHub and Google consoles to `https://ladybug-debug.tech/api/auth/oauth/<provider>/callback`.
   - Lock the Snowflake token to the server's IP (see above).

**What to show judges:** the app live at the .tech address.
