  -- One-time Snowflake setup for LadyBug. Run in a Snowsight worksheet as ACCOUNTADMIN.
  -- Creates the warehouse, the analytics table the server syncs into, a least-privilege role with Cortex access,
  -- and a service user whose programmatic access token goes into the server's SNOWFLAKE_TOKEN.
  USE ROLE ACCOUNTADMIN;

  -- Compute: smallest size, suspends after 60s idle so a trial's credits last.
  CREATE WAREHOUSE IF NOT EXISTS LADYBUG_WH
    WAREHOUSE_SIZE = XSMALL AUTO_SUSPEND = 60 AUTO_RESUME = TRUE INITIALLY_SUSPENDED = TRUE;

  CREATE DATABASE IF NOT EXISTS LADYBUG;
  CREATE SCHEMA IF NOT EXISTS LADYBUG.ANALYTICS;

  -- Mirrors the Tiger Data `events` hypertable; user ids arrive as salted one-way hashes.
  CREATE TABLE IF NOT EXISTS LADYBUG.ANALYTICS.EVENTS (
    EVENT_ID      NUMBER        NOT NULL,
    AT            TIMESTAMP_TZ  NOT NULL,
    USER_HASH     STRING        NOT NULL,
    PROBLEM_ID    NUMBER,
    PROBLEM_TITLE STRING,
    IS_CHALLENGE  BOOLEAN,
    KIND          STRING        NOT NULL,
    LANGUAGE      STRING,
    DIFFICULTY    STRING,
    PASSED        BOOLEAN,
    PASSED_COUNT  NUMBER,
    TOTAL_COUNT   NUMBER,
    SYNCED_AT     TIMESTAMP_TZ  DEFAULT CURRENT_TIMESTAMP()
  );

  -- The app's role: only what the server needs.
  CREATE ROLE IF NOT EXISTS LADYBUG_APP;
  GRANT USAGE ON WAREHOUSE LADYBUG_WH TO ROLE LADYBUG_APP;
  GRANT USAGE ON DATABASE LADYBUG TO ROLE LADYBUG_APP;
  GRANT USAGE ON SCHEMA LADYBUG.ANALYTICS TO ROLE LADYBUG_APP;
  GRANT SELECT, INSERT, DELETE ON TABLE LADYBUG.ANALYTICS.EVENTS TO ROLE LADYBUG_APP;
  -- Cortex LLM functions (SNOWFLAKE.CORTEX.COMPLETE) for AI hints.
  GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE LADYBUG_APP;
  -- Lets Cortex use a model hosted in another region if yours doesn't serve it (e.g. mistral-large2).
  ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION';

  -- A service user for the server (no password; authenticates with a programmatic access token).
  CREATE USER IF NOT EXISTS LADYBUG_SVC
    TYPE = SERVICE DEFAULT_ROLE = LADYBUG_APP DEFAULT_WAREHOUSE = LADYBUG_WH
    COMMENT = 'LadyBug server (SQL API)';
  GRANT ROLE LADYBUG_APP TO USER LADYBUG_SVC;

  -- Tokens normally require the user to be under a network policy. Until the app has a fixed server IP, allow the
  -- token from anywhere. Once hosted, replace this with a network policy listing the server's IP.
  CREATE AUTHENTICATION POLICY IF NOT EXISTS LADYBUG.ANALYTICS.LADYBUG_PAT_POLICY
    PAT_POLICY = (NETWORK_POLICY_EVALUATION = ENFORCED_NOT_REQUIRED);
  -- FORCE replaces a policy attached by an earlier run, so the script can be run again safely.
  ALTER USER LADYBUG_SVC SET AUTHENTICATION POLICY LADYBUG.ANALYTICS.LADYBUG_PAT_POLICY FORCE;

  -- Copy the token_secret from the result into SNOWFLAKE_TOKEN. It is shown only once.
  ALTER USER LADYBUG_SVC ADD PROGRAMMATIC ACCESS TOKEN LADYBUG_SERVER
    ROLE_RESTRICTION = 'LADYBUG_APP' DAYS_TO_EXPIRY = 30 COMMENT = 'LadyBug server';

  -- Your account identifier for SNOWFLAKE_ACCOUNT (orgname-accountname):
  SELECT CURRENT_ORGANIZATION_NAME() || '-' || CURRENT_ACCOUNT_NAME() AS SNOWFLAKE_ACCOUNT;
