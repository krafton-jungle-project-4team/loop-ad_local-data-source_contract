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

## 원칙

- 기준 파일은 `postgres/schema.sql`, `clickhouse/schema.sql`, `redis/contract.md`입니다.
- dummy data 기준 파일은 `postgres/dummy.sql`, `clickhouse/dummy.sql`, `redis/dummy.redis`입니다.
- schema 변경이 꼬이면 patch를 누적하지 말고 `drop -> init -> dummy`로 돌아갑니다.
