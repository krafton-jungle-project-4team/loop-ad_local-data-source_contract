#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/lib/env.sh" "$@"
source "${SCRIPT_DIR}/lib/docker.sh"
source "${SCRIPT_DIR}/lib/wait.sh"

require_docker
compose up -d postgres clickhouse redis
wait_postgres
wait_clickhouse
wait_redis

"${SCRIPT_DIR}/postgres-init.sh" "${ENVIRONMENT}"
"${SCRIPT_DIR}/clickhouse-init.sh" "${ENVIRONMENT}"
"${SCRIPT_DIR}/redis-init.sh" "${ENVIRONMENT}"
