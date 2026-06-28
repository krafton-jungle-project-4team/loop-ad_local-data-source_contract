#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/lib/env.sh" "$@"
source "${SCRIPT_DIR}/lib/docker.sh"
source "${SCRIPT_DIR}/lib/wait.sh"

EXPORTS_DIR="${ROOT_DIR}/clickhouse/ga4_exports"
CLICKHOUSE_EVENTS_DATABASE="${CLICKHOUSE_EVENTS_DATABASE:-default}"

require_docker
compose up -d clickhouse
wait_clickhouse

clickhouse_client \
    --database "${CLICKHOUSE_EVENTS_DATABASE}" \
    --multiquery \
    --queries-file /contract/clickhouse/dummy.sql

if [[ ! -d "${EXPORTS_DIR}" ]]; then
    echo "GA4 exports directory not found: ${EXPORTS_DIR}" >&2
    exit 1
fi

shopt -s nullglob
CSV_FILES=("${EXPORTS_DIR}"/*.csv)
shopt -u nullglob

if [[ ${#CSV_FILES[@]} -eq 0 ]]; then
    echo "No CSV files found under: ${EXPORTS_DIR}" >&2
    exit 1
fi

TABLE_EXISTS="$(
    clickhouse_client \
        --database "${CLICKHOUSE_EVENTS_DATABASE}" \
        --query "EXISTS TABLE events" \
        2>/dev/null || true
)"

if [[ "${TABLE_EXISTS}" != "1" ]]; then
    echo "ClickHouse table not found: ${CLICKHOUSE_EVENTS_DATABASE}.events" >&2
    echo "Run ./scripts/clickhouse-init.sh ${ENVIRONMENT} first." >&2
    exit 1
fi

if [[ "${TRUNCATE_EVENTS:-0}" == "1" ]]; then
    clickhouse_client \
        --database "${CLICKHOUSE_EVENTS_DATABASE}" \
        --query "TRUNCATE TABLE events"
fi

for csv_file in "${CSV_FILES[@]}"; do
    row_count="$(wc -l < "${csv_file}")"
    row_count="$((row_count - 1))"
    echo "Loading ${csv_file} (${row_count} rows)"

    clickhouse_client \
        --database "${CLICKHOUSE_EVENTS_DATABASE}" \
        --date_time_input_format=best_effort \
        --input_format_csv_empty_as_default=1 \
        --input_format_defaults_for_omitted_fields=1 \
        --query "INSERT INTO events FORMAT CSVWithNames" \
        < "${csv_file}"
done

echo "GA4 events load complete."
