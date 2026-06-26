-- clickhouse-init.sql
-- 테이블 생성 전용. seed 이벤트는 넣지 않는다.

-- =========================================================
-- 1. Raw Events
-- =========================================================

CREATE TABLE IF NOT EXISTS events
(
    project_id LowCardinality(String),

    event_id String,
    user_id String,
    session_id String,

    event_time DateTime64(3, 'Asia/Seoul'),

    event_name LowCardinality(String),

    channel LowCardinality(String) DEFAULT '',
    campaign_id String DEFAULT '',

    age_group LowCardinality(String) DEFAULT '',
    gender LowCardinality(String) DEFAULT '',
    device LowCardinality(String) DEFAULT '',

    category String DEFAULT '',
    product_id String DEFAULT '',
    inventory_status LowCardinality(String) DEFAULT '',

    price Decimal(18, 2) DEFAULT 0,
    quantity UInt32 DEFAULT 0,
    revenue Decimal(18, 2) DEFAULT 0,

    coupon_id String DEFAULT '',
    order_id String DEFAULT '',

    experiment_id String DEFAULT '',
    variant_id LowCardinality(String) DEFAULT '',
    action_id String DEFAULT '',
    mapping_id String DEFAULT '',
    ad_id String DEFAULT '',
    creative_id String DEFAULT '',

    properties_json String DEFAULT '',

    ingested_at DateTime64(3, 'Asia/Seoul') DEFAULT now64(3, 'Asia/Seoul'),

    INDEX idx_event_id event_id TYPE bloom_filter(0.01) GRANULARITY 4,
    INDEX idx_user_id user_id TYPE bloom_filter(0.01) GRANULARITY 4,
    INDEX idx_session_id session_id TYPE bloom_filter(0.01) GRANULARITY 4,
    INDEX idx_product_id product_id TYPE bloom_filter(0.01) GRANULARITY 4,
    INDEX idx_experiment_id experiment_id TYPE bloom_filter(0.01) GRANULARITY 4
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_time)
ORDER BY (
    project_id,
    event_time,
    event_name,
    session_id,
    user_id,
    product_id
);