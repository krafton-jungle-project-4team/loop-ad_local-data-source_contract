#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENT="${1:-local}"

source "${SCRIPT_DIR}/lib/env.sh" "${ENVIRONMENT}"
source "${SCRIPT_DIR}/lib/docker.sh"
source "${SCRIPT_DIR}/lib/wait.sh"

require_docker
compose up -d postgres
wait_postgres

compose exec -T postgres \
    psql \
    --username "${POSTGRES_USER}" \
    --dbname "${POSTGRES_DB}" \
    --set ON_ERROR_STOP=1 \
    --file /contract/postgres/schema.sql

