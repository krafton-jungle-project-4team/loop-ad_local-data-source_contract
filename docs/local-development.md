# Local Development

로컬 개발은 Docker Desktop 기반으로 실행합니다.

```bash
./scripts/init.sh local
./scripts/dummy.sh local
```

각 서버 repo는 `env/*.env.example` 중 자기 서비스 파일을 참고해 `.env`를 만듭니다.

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

