#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENT="${1:-local}"

source "${SCRIPT_DIR}/lib/env.sh" "${ENVIRONMENT}"
source "${SCRIPT_DIR}/lib/docker.sh"

require_docker
compose stop redis >/dev/null 2>&1 || true
compose rm --force redis >/dev/null 2>&1 || true
remove_compose_volume redis-data

