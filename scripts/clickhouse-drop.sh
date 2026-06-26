#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/lib/env.sh" "$@"
source "${SCRIPT_DIR}/lib/docker.sh"

require_docker
compose stop clickhouse >/dev/null 2>&1 || true
compose rm --force clickhouse >/dev/null 2>&1 || true
remove_compose_volume clickhouse-data
