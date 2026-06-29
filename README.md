# loop-ad_data_contract

Postgres, ClickHouse, Redis의 로컬 개발용 데이터 계약 repo입니다.

이 repo는 운영 migration history를 관리하지 않습니다. 정확한 상태가 필요하면 DB를 지우고 다시 만듭니다.

```bash
./scripts/drop.sh local
./scripts/init.sh local
./scripts/dummy.sh local
```

macOS와 Docker Desktop만 지원합니다. DB client는 host에 설치하지 않고 Docker container 안의 client를 사용합니다.

## 팀 규칙

- 모든 script는 환경 이름을 필수 인자로 받습니다. `local` 기본값으로 fallback하지 않습니다.
- `docker-compose.yml`도 port, database, user, password 값을 fallback 없이 `environments/<environment>.env`에서 읽습니다.
- 팀 공통 로컬 endpoint는 아래 표의 값을 사용합니다.
- 개인 로컬 환경에서 port나 endpoint를 바꿔야 한다면, 바꾼 사람이 자기 `.env`와 실행 환경을 직접 맞춥니다. repo의 공통 규칙은 바꾸지 않습니다.

## 빠른 시작

```bash
./scripts/init.sh local
./scripts/dummy.sh local
```

로컬 endpoint:

| Service | URL |
|---|---|
| Postgres | `localhost:15432` |
| ClickHouse HTTP | `http://localhost:18123` |
| ClickHouse Native | `localhost:19000` |
| Redis | `localhost:16379` |

앱 repo에서 ClickHouse에 연결할 때는 아래 env를 사용합니다.

```bash
LOOPAD_CLICKHOUSE_URL=http://localhost:18123
LOOPAD_CLICKHOUSE_USERNAME=loopad_app
LOOPAD_CLICKHOUSE_PASSWORD=loopad_local_password
```

`loopad_local_password`는 로컬 개발용 dummy password입니다. 운영 secret이나 실제 password를 이 repo에 넣지 않습니다.

## 전체 명령

```bash
./scripts/init.sh local
./scripts/dummy.sh local
./scripts/drop.sh local
```

환경 이름을 빼면 실패합니다.

```bash
./scripts/init.sh
# Usage: init.sh <environment>
```

## DB별 명령

```bash
./scripts/postgres-init.sh local
./scripts/postgres-dummy.sh local
./scripts/postgres-drop.sh local

./scripts/clickhouse-init.sh local
./scripts/clickhouse-dummy.sh local
./scripts/clickhouse-drop.sh local

./scripts/redis-init.sh local
./scripts/redis-dummy.sh local
./scripts/redis-drop.sh local
```

## GA4 demo dummy data

`postgres/dummy.sql`과 `clickhouse/ga4_exports/*.csv`는 GA4 commerce sample 기반 demo dummy data입니다. CSV는 이미 `clickhouse/schema.sql`의 `events` 테이블 형태로 변환된 상태이며, DB 적재 스크립트는 이 파일들을 그대로 넣습니다.

CSV의 `event_time`은 `clickhouse/schema.sql`의 `DateTime64(3, 'UTC')`에 맞춰 UTC timestamp로 저장합니다. 한국 시간 기준 일자 집계는 ClickHouse의 `event_date` materialized column 또는 `toTimeZone(event_time, 'Asia/Seoul')` 기준으로 봅니다. CSV는 SDK/collector payload에 가까운 insert 형태를 유지하기 위해 `event_date`와 `ingested_at`을 포함하지 않고, 두 컬럼은 ClickHouse가 생성합니다.

CSV의 baseline period는 GA4 sample의 원본 commerce 맥락을 보존하고, LoopAd 개입이 붙은 intervention row는 demo seed의 세그먼트/채널 맥락에 맞게 `channel`, `category`, `product_id`, `age_group`, `gender`, `device`, `properties_json.segment_hash`, `properties_json.delivery_channel`을 정규화합니다.

PostgreSQL demo seed의 세그먼트 조건은 아래 축으로 정렬합니다.

- `event_name`: 퍼널 단계 또는 행동 이벤트입니다. 예: `product_view`, `add_to_cart`, `checkout_start`
- `category_group`: 상품군입니다. 예: `fresh_food`, `beauty`, `seasonal_gift`
- `device`: 기기입니다. 예: `mobile`, `desktop`
- `gender`: 성별 세그먼트입니다. 예: `male`, `female`, `all`
- `age_group`: 연령대입니다. 예: `30-39`, `25-34`
- `inbound_channel`: 사용자가 들어온 채널 맥락입니다. 예: `kakao`, `coupang_onsite`, `paid_search`, `push`

추천 액션은 같은 세그먼트 안에서 하나의 실행 채널을 공유합니다. 예를 들어 `inbound_channel = kakao`인 fresh food 이탈 세그먼트에서는 재입고 알림, 쿠폰, 대체 상품 추천 후보가 모두 `delivery_channel = kakao`로 기록됩니다. `delivery_channel`은 `recommendation_actions.execution_hint_json`, `bandit_policies.config_json`, `bandit_decisions.sampled_values_json`, `ad_creatives.payload_json`, `segment_ad_mappings.execution_hint_json`에 명시됩니다.

채널 관련 필드는 아래처럼 구분합니다.

- `inbound_channel`: 분석/세그먼트 기준의 유입 채널 맥락입니다.
- `delivery_channel`: 추천 액션을 실제로 전달하거나 노출하는 실행 채널입니다.
- `placement`: 실행 채널 안의 구체적인 노출 위치입니다. 예: `kakao_message`, `category_banner`, `search_results`
- `creative_type`: 콘텐츠 형식입니다. 예: `message`, `banner`, `search_ad`, `push_message`

- baseline period: `toTimeZone(event_time, 'Asia/Seoul') < '2021-01-04 00:00:00'`
  - LoopAd 개입 전 과거 로그입니다.
  - `experiment_id`, `variant_id`, `action_id`, `mapping_id`, `ad_id`, `creative_id`, `bandit_policy_id`, `bandit_arm_id`, `bandit_decision_id`, `coupon_id`는 비웁니다.
- intervention period: `toTimeZone(event_time, 'Asia/Seoul') >= '2021-01-04 00:00:00'`
  - PostgreSQL seed의 `experiments`, `segment_ad_mappings`, `ad_creatives`, `bandit_*` numeric id를 ClickHouse 문자열 id로 참조합니다.
  - `ad_id`는 대응 PostgreSQL 테이블이 없으므로 기본적으로 비워 두고 FK 검증 대상에서 제외합니다.
- non-purchase 이벤트의 `revenue`는 항상 `0`입니다.
  - 기대값은 `properties_json.expected_event_value`에만 저장합니다.
- event-level `reward_value`는 관측된 funnel 단계 점수입니다.
  - `ad_impression`, `coupon_shown`, `action_exposed`: `0.0`
  - `product_view`: `0.2`
  - `add_to_cart`: `0.5`
  - `checkout_start`: `0.7`
  - `purchase`: `1.0`
- bandit posterior는 exposure event의 reward가 아니라 exposure 이후 24시간 attribution window 안의 `max_reward_per_impression`으로 업데이트합니다.
  - exposure 생성 기준은 `session_id + mapping_id + bandit_arm_id`당 최대 1개입니다.
  - attribution은 같은 `session_id`를 우선 사용하고, 세션이 없을 때 같은 `user_id`를 fallback 기준으로 봅니다.
  - demo bandit objective는 `graded_funnel_reward`이며 `bandit_policies.reward_event_name`은 `funnel_progress`입니다.
  - `bandit_arms.alpha/beta`는 binary conversion count가 아니라 graded reward를 반영한 soft posterior parameter입니다.

PostgreSQL seed와 ClickHouse events를 로컬 DB에 넣으려면:

```bash
./scripts/postgres-init.sh local
./scripts/postgres-dummy.sh local

./scripts/clickhouse-init.sh local
./scripts/clickhouse-dummy.sh local
```

ClickHouse schema init은 `clickhouse/schema.sql`을 기본 database에서 실행하므로 events 테이블은 기본적으로 `default.events`에 생성됩니다. `scripts/clickhouse-dummy.sh`는 생성된 GA4 CSV를 같은 `default.events`에 적재합니다.

ClickHouse 중복 적재를 피하고 새로 넣고 싶으면 `events` 테이블을 먼저 비우도록 실행합니다.

```bash
TRUNCATE_EVENTS=1 ./scripts/clickhouse-dummy.sh local
```

## 원칙

- 기준 파일은 `postgres/schema.sql`, `clickhouse/schema.sql`, `redis/contract.md`입니다.
- dummy data 기준 파일은 `postgres/dummy.sql`, `clickhouse/dummy.sql`, `redis/dummy.redis`입니다.
- schema 수정 후에는 기본적으로 `drop -> init -> dummy` 순서로 재생성해야 합니다.
- 작은 변경은 AI가 만든 patch나 수작업으로 로컬 schema를 맞출 수 있습니다.
  - 단, 이 방식은 작업자가 기준 파일과 같은 상태가 되었는지 직접 보장해야 합니다. 데이터 불일치, 누락, 로컬 상태 꼬임에 대한 책임도 작업자 본인에게 있습니다.
- Codex로 변경된 data source만 재생성할 때는 프로젝트 스킬 `$refresh-changed-data-sources`를 사용합니다.
- Codex가 작은 로컬 변경을 직접 patch할 때는 프로젝트 스킬 `$patch-local-data-source`를 사용합니다.
