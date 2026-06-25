CREATE DATABASE IF NOT EXISTS loopad;

CREATE TABLE IF NOT EXISTS loopad.raw_events
(
    event_id String,
    user_id String,
    campaign_id String,
    creative_id String,
    event_type LowCardinality(String),
    occurred_at DateTime64(3, 'UTC'),
    request_id String,
    payload String
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(occurred_at)
ORDER BY (campaign_id, occurred_at, event_id);

CREATE TABLE IF NOT EXISTS loopad.ad_context_events
(
    user_id String,
    segment String,
    score Float64,
    updated_at DateTime64(3, 'UTC')
)
ENGINE = ReplacingMergeTree(updated_at)
ORDER BY (user_id, segment);

CREATE TABLE IF NOT EXISTS loopad.campaign_event_hourly
(
    bucket_start DateTime('UTC'),
    campaign_id String,
    event_type LowCardinality(String),
    events UInt64
)
ENGINE = SummingMergeTree
PARTITION BY toYYYYMM(bucket_start)
ORDER BY (bucket_start, campaign_id, event_type);

CREATE MATERIALIZED VIEW IF NOT EXISTS loopad.raw_events_to_campaign_event_hourly
TO loopad.campaign_event_hourly
AS
SELECT
    toStartOfHour(occurred_at) AS bucket_start,
    campaign_id,
    event_type,
    count() AS events
FROM loopad.raw_events
GROUP BY
    bucket_start,
    campaign_id,
    event_type;

