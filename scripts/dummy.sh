#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/lib/env.sh" "$@"

"${SCRIPT_DIR}/postgres-dummy.sh" "${ENVIRONMENT}"
"${SCRIPT_DIR}/clickhouse-dummy.sh" "${ENVIRONMENT}"
"${SCRIPT_DIR}/redis-dummy.sh" "${ENVIRONMENT}"
