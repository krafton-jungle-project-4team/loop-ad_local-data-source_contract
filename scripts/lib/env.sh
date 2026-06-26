#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || -z "$1" ]]; then
    echo "Usage: $(basename "$0") <environment>" >&2
    echo "Example: $(basename "$0") local" >&2
    exit 1
fi

ENVIRONMENT="$1"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_FILE="${ROOT_DIR}/environments/${ENVIRONMENT}.env"

if [[ ! -f "${ENV_FILE}" ]]; then
    echo "Environment file not found: ${ENV_FILE}" >&2
    exit 1
fi

set -a
source "${ENV_FILE}"
set +a
