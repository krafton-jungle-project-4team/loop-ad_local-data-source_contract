INSERT INTO advertisers (id, name, status)
VALUES
    ('adv_001', 'Loop Coffee', 'active'),
    ('adv_002', 'Jungle Books', 'active')
ON CONFLICT (id) DO NOTHING;

INSERT INTO campaigns (id, advertiser_id, name, status, bid_cpm, daily_budget, starts_at, ends_at)
VALUES
    ('cmp_001', 'adv_001', 'Morning Coffee Push', 'active', 2.5000, 100.00, '2026-06-01T00:00:00Z', NULL),
    ('cmp_002', 'adv_002', 'Summer Reading', 'active', 1.7500, 80.00, '2026-06-01T00:00:00Z', NULL)
ON CONFLICT (id) DO NOTHING;

INSERT INTO creatives (id, campaign_id, title, image_url, landing_url, status)
VALUES
    ('cr_001', 'cmp_001', 'Start with Loop Coffee', 'https://static.dev.loop-ad.org/creatives/cr_001.png', 'https://example.com/coffee', 'active'),
    ('cr_002', 'cmp_002', 'Read More This Summer', 'https://static.dev.loop-ad.org/creatives/cr_002.png', 'https://example.com/books', 'active')
ON CONFLICT (id) DO NOTHING;

INSERT INTO user_profiles (id, external_user_id, age_band, country, device_type)
VALUES
    ('usr_001', 'u_001', '25-34', 'KR', 'mobile'),
    ('usr_002', 'u_002', '18-24', 'KR', 'desktop')
ON CONFLICT (id) DO NOTHING;

