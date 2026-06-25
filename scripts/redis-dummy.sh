#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENT="${1:-local}"

source "${SCRIPT_DIR}/lib/env.sh" "${ENVIRONMENT}"
source "${SCRIPT_DIR}/lib/docker.sh"
source "${SCRIPT_DIR}/lib/wait.sh"

require_docker
compose up -d redis
wait_redis

compose exec -T redis redis-cli < "${ROOT_DIR}/redis/dummy.redis"

