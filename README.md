# loop-ad_data_contract

Postgres, ClickHouse, Redis의 로컬 개발용 데이터 계약 repo입니다.

이 repo는 운영 migration history를 관리하지 않습니다. 정확한 상태가 필요하면 DB를 지우고 다시 만듭니다.

```bash
./scripts/drop.sh local
./scripts/init.sh local
./scripts/dummy.sh local
```

macOS와 Docker Desktop만 지원합니다. DB client는 host에 설치하지 않고 Docker container 안의 client를 사용합니다.

## 빠른 시작

```bash
./scripts/init.sh local
./scripts/dummy.sh local
```

로컬 endpoint:

| Service | URL |
|---|---|
| Postgres | `localhost:5432` |
| ClickHouse HTTP | `http://localhost:8123` |
| ClickHouse Native | `localhost:9000` |
| Redis | `localhost:6379` |

## 전체 명령

```bash
./scripts/init.sh local
./scripts/dummy.sh local
./scripts/drop.sh local
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
- 빠른 로컬 보완만 필요할 때는 `docs/ai-patch-guide.md`를 보고 임시 patch를 만들 수 있습니다.

## 서버 repo 연동

각 서버 repo는 `env/*.env.example` 중 자기 서비스 파일을 참고해 `.env`를 구성합니다. AWS dev 환경에서는 CDK가 같은 env 이름을 ECS task definition에 주입합니다.

