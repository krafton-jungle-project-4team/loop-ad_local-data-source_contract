# Local Development

로컬 개발은 Docker Desktop 기반으로 실행합니다.

```bash
./scripts/init.sh local
./scripts/dummy.sh local
```

환경 이름은 항상 명시합니다. 모든 script는 `local` 기본값으로 fallback하지 않습니다.

```bash
./scripts/init.sh
# Usage: init.sh <environment>
```

각 서버 repo는 `env/*.env.example` 중 자기 서비스 파일을 참고해 `.env`를 만듭니다.

팀 공통 endpoint는 아래 값입니다.

| Service | URL |
|---|---|
| Postgres | `localhost:15432` |
| ClickHouse HTTP | `http://localhost:18123` |
| ClickHouse Native | `localhost:19000` |
| Redis | `localhost:16379` |

개인 로컬 환경에서 port나 endpoint를 바꿔야 한다면, 바꾼 사람이 자기 `.env`와 실행 환경을 직접 맞춥니다. repo의 공통 endpoint 규칙은 바꾸지 않습니다.

정확한 초기 상태가 필요하면 아래 순서로 재생성합니다.

```bash
./scripts/drop.sh local
./scripts/init.sh local
./scripts/dummy.sh local
```

개별 DB만 다시 만들 수 있습니다.

```bash
./scripts/clickhouse-drop.sh local
./scripts/clickhouse-init.sh local
./scripts/clickhouse-dummy.sh local
```
