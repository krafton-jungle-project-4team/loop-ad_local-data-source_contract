INSERT INTO loopad.raw_events
    (event_id, user_id, campaign_id, creative_id, event_type, occurred_at, request_id, payload)
VALUES
    ('evt_001', 'u_001', 'cmp_001', 'cr_001', 'impression', '2026-06-25 03:00:00.000', 'req_001', '{"slot":"main"}'),
    ('evt_002', 'u_001', 'cmp_001', 'cr_001', 'click', '2026-06-25 03:01:00.000', 'req_001', '{"slot":"main"}'),
    ('evt_003', 'u_002', 'cmp_002', 'cr_002', 'impression', '2026-06-25 03:05:00.000', 'req_002', '{"slot":"sidebar"}');

INSERT INTO loopad.ad_context_events
    (user_id, segment, score, updated_at)
VALUES
    ('u_001', 'sports', 0.82, '2026-06-25 03:00:00.000'),
    ('u_001', 'mobile', 0.91, '2026-06-25 03:00:00.000'),
    ('u_002', 'books', 0.77, '2026-06-25 03:00:00.000');

