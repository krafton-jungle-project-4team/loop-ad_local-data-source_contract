#!/usr/bin/env bash
set -euo pipefail

wait_postgres() {
    for _ in {1..60}; do
        if compose exec -T postgres pg_isready --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
    done

    echo "Postgres did not become ready in time." >&2
    exit 1
}

wait_clickhouse() {
    for _ in {1..60}; do
        if clickhouse_client --query "SELECT 1" >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
    done

    echo "ClickHouse did not become ready in time." >&2
    exit 1
}

wait_redis() {
    for _ in {1..60}; do
        if compose exec -T redis redis-cli ping >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
    done

    echo "Redis did not become ready in time." >&2
    exit 1
}

