#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/lib/env.sh" "$@"
source "${SCRIPT_DIR}/lib/docker.sh"
source "${SCRIPT_DIR}/lib/wait.sh"

require_docker
compose up -d clickhouse
wait_clickhouse

clickhouse_client \
    --multiquery \
    --queries-file /contract/clickhouse/schema.sql
