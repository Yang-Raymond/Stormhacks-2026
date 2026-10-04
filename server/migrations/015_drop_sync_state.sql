-- sync_state held the watermark for the Snowflake event sync, which was removed.
DROP TABLE IF EXISTS sync_state;
