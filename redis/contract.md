# Redis Contract

Redis는 schema가 없으므로 key 이름, value 형식, TTL, owner, reader를 문서로 고정합니다.

## `ad-context:{user_id}`

| Field | Value |
|---|---|
| Owner | `ad-context-projector` |
| Readers | `ad-decision-api` |
| Type | JSON string |
| TTL | 300 seconds |

Example:

```json
{
  "userId": "u_001",
  "segments": ["sports", "mobile"],
  "updatedAt": "2026-06-25T03:00:00Z"
}
```

## `decision-cache:{user_id}:{slot_id}`

| Field | Value |
|---|---|
| Owner | `ad-decision-api` |
| Readers | `ad-decision-api` |
| Type | JSON string |
| TTL | 60 seconds |

Example:

```json
{
  "campaignId": "cmp_001",
  "creativeId": "cr_001",
  "reason": "local dummy"
}
```

## `campaign-budget:{campaign_id}`

| Field | Value |
|---|---|
| Owner | `ad-decision-api` |
| Readers | `ad-decision-api`, `dashboard-api` |
| Type | JSON string |
| TTL | 3600 seconds |

Example:

```json
{
  "campaignId": "cmp_001",
  "dailyBudget": 100.0,
  "spent": 12.5,
  "currency": "USD"
}
```

