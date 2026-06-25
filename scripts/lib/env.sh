#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-local}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_FILE="${ROOT_DIR}/environments/${ENVIRONMENT}.env"

if [[ ! -f "${ENV_FILE}" ]]; then
    echo "Environment file not found: ${ENV_FILE}" >&2
    exit 1
fi

set -a
source "${ENV_FILE}"
set +a

