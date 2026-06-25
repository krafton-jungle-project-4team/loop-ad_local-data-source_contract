CREATE TABLE IF NOT EXISTS advertisers (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('active', 'paused')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS campaigns (
    id TEXT PRIMARY KEY,
    advertiser_id TEXT NOT NULL REFERENCES advertisers(id),
    name TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('active', 'paused')),
    bid_cpm NUMERIC(12, 4) NOT NULL,
    daily_budget NUMERIC(12, 2) NOT NULL,
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS creatives (
    id TEXT PRIMARY KEY,
    campaign_id TEXT NOT NULL REFERENCES campaigns(id),
    title TEXT NOT NULL,
    image_url TEXT NOT NULL,
    landing_url TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('active', 'paused')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_profiles (
    id TEXT PRIMARY KEY,
    external_user_id TEXT NOT NULL UNIQUE,
    age_band TEXT,
    country TEXT NOT NULL,
    device_type TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS campaigns_advertiser_id_idx ON campaigns(advertiser_id);
CREATE INDEX IF NOT EXISTS creatives_campaign_id_idx ON creatives(campaign_id);
CREATE INDEX IF NOT EXISTS user_profiles_external_user_id_idx ON user_profiles(external_user_id);

