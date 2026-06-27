-- clickhouse-init.sql
-- 테이블 생성 전용. seed 이벤트는 넣지 않는다.
--
-- 설계 원칙:
-- 1. ClickHouse는 사용자 행동 로그와 보상 계산 원천 데이터를 저장한다.
-- 2. 톰슨 샘플링의 alpha/beta 현재 상태는 PostgreSQL bandit_arms에 저장한다.
-- 3. ClickHouse events에는 어떤 bandit arm/decision/action에서 발생한 이벤트인지 추적할 수 있는 식별자를 남긴다.
-- 4. reward update worker는 ClickHouse events를 집계해서 PostgreSQL bandit_arms를 업데이트한다.

-- =========================================================
-- 1. Raw Events
-- 모든 사용자 행동 이벤트의 원천 테이블.
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

    -- 실험/액션/광고 추적
    experiment_id String DEFAULT '',
    variant_id LowCardinality(String) DEFAULT '',
    action_id String DEFAULT '',
    mapping_id String DEFAULT '',
    ad_id String DEFAULT '',
    creative_id String DEFAULT '',

    -- 톰슨 샘플링 추적
    bandit_policy_id String DEFAULT '',
    bandit_arm_id String DEFAULT '',
    bandit_decision_id String DEFAULT '',

    -- reward_value는 구매/전환 이벤트에서 보상값을 명시적으로 넣고 싶을 때 사용.
    -- Bernoulli reward면 purchase 이벤트에 1, 실패는 impression 대비 미구매로 worker가 계산해도 된다.
    reward_value Float64 DEFAULT 0,

    properties_json String DEFAULT '',

    ingested_at DateTime64(3, 'Asia/Seoul') DEFAULT now64(3, 'Asia/Seoul'),

    INDEX idx_event_id event_id TYPE bloom_filter(0.01) GRANULARITY 4,
    INDEX idx_user_id user_id TYPE bloom_filter(0.01) GRANULARITY 4,
    INDEX idx_session_id session_id TYPE bloom_filter(0.01) GRANULARITY 4,
    INDEX idx_product_id product_id TYPE bloom_filter(0.01) GRANULARITY 4,
    INDEX idx_experiment_id experiment_id TYPE bloom_filter(0.01) GRANULARITY 4,
    INDEX idx_bandit_arm_id bandit_arm_id TYPE bloom_filter(0.01) GRANULARITY 4,
    INDEX idx_bandit_decision_id bandit_decision_id TYPE bloom_filter(0.01) GRANULARITY 4
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