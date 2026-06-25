#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENT="${1:-local}"

source "${SCRIPT_DIR}/lib/env.sh" "${ENVIRONMENT}"
source "${SCRIPT_DIR}/lib/docker.sh"

require_docker
compose down --volumes --remove-orphans

