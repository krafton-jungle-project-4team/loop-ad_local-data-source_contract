#!/usr/bin/env bash
set -euo pipefail

COMPOSE_PROJECT_NAME="loop-ad-data-contract"

require_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo "Docker Desktop is not running or docker is unavailable." >&2
        exit 1
    fi
}

compose() {
    docker compose \
        --env-file "${ENV_FILE}" \
        --project-name "${COMPOSE_PROJECT_NAME}" \
        --file "${ROOT_DIR}/docker-compose.yml" \
        "$@"
}

remove_compose_volume() {
    local volume_name="$1"
    docker volume rm -f "${COMPOSE_PROJECT_NAME}_${volume_name}" >/dev/null 2>&1 || true
}

clickhouse_client() {
    local args=(clickhouse-client --user "${CLICKHOUSE_USER}")

    if [[ -n "${CLICKHOUSE_PASSWORD}" ]]; then
        args+=(--password "${CLICKHOUSE_PASSWORD}")
    fi

    compose exec -T clickhouse "${args[@]}" "$@"
}
