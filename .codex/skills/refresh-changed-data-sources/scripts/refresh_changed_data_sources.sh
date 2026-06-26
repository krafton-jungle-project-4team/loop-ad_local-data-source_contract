#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'USAGE'
Usage:
  refresh_changed_data_sources.sh <environment> [options]

Options:
  --base <git-ref>        Compare changes against this ref. Defaults to HEAD.
  --dry-run               Print selected data sources and commands without running them.
  --with-dummy            Run <source>-dummy.sh after init for each selected source.
  --only <sources>        Override detection. Comma-separated: postgres,clickhouse,redis.
  --no-untracked          Ignore untracked files when detecting local changes.
  -h, --help              Show this help.

Examples:
  refresh_changed_data_sources.sh local --dry-run
  refresh_changed_data_sources.sh local
  refresh_changed_data_sources.sh local --base main --with-dummy
  refresh_changed_data_sources.sh local --only postgres --dry-run
USAGE
}

ENVIRONMENT=""
BASE_REF="HEAD"
DRY_RUN=0
WITH_DUMMY=0
INCLUDE_UNTRACKED=1
ONLY_SOURCES=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --base)
            [[ $# -ge 2 ]] || { echo "--base requires a git ref" >&2; exit 2; }
            BASE_REF="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --with-dummy)
            WITH_DUMMY=1
            shift
            ;;
        --only)
            [[ $# -ge 2 ]] || { echo "--only requires a source list" >&2; exit 2; }
            ONLY_SOURCES="$2"
            shift 2
            ;;
        --no-untracked)
            INCLUDE_UNTRACKED=0
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
        *)
            if [[ -n "${ENVIRONMENT}" ]]; then
                echo "Unexpected argument: $1" >&2
                usage >&2
                exit 2
            fi
            ENVIRONMENT="$1"
            shift
            ;;
    esac
done

if [[ -z "${ENVIRONMENT}" ]]; then
    usage >&2
    exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"

cd "${ROOT_DIR}"

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
    echo "This script must run inside a git repository." >&2
    exit 1
fi

if [[ ! -f "environments/${ENVIRONMENT}.env" ]]; then
    echo "Environment file not found: environments/${ENVIRONMENT}.env" >&2
    exit 1
fi

SELECT_POSTGRES=0
SELECT_CLICKHOUSE=0
SELECT_REDIS=0

select_source() {
    case "$1" in
        postgres)
            SELECT_POSTGRES=1
            ;;
        clickhouse)
            SELECT_CLICKHOUSE=1
            ;;
        redis)
            SELECT_REDIS=1
            ;;
        all)
            SELECT_POSTGRES=1
            SELECT_CLICKHOUSE=1
            SELECT_REDIS=1
            ;;
        "")
            ;;
        *)
            echo "Unknown data source: $1" >&2
            exit 2
            ;;
    esac
}

source_for_path() {
    case "$1" in
        postgres/*|scripts/postgres-*)
            echo "postgres"
            ;;
        clickhouse/*|scripts/clickhouse-*)
            echo "clickhouse"
            ;;
        redis/*|scripts/redis-*)
            echo "redis"
            ;;
        docker-compose.yml|scripts/lib/*|scripts/init.sh|scripts/drop.sh|scripts/dummy.sh|environments/*.env)
            echo "all"
            ;;
        *)
            echo ""
            ;;
    esac
}

if [[ -n "${ONLY_SOURCES}" ]]; then
    IFS=',' read -r -a requested_sources <<< "${ONLY_SOURCES}"
    for source in "${requested_sources[@]}"; do
        source="${source#"${source%%[![:space:]]*}"}"
        source="${source%"${source##*[![:space:]]}"}"
        select_source "${source}"
    done
else
    if ! git rev-parse --verify "${BASE_REF}^{commit}" >/dev/null 2>&1; then
        echo "Base ref is not a commit: ${BASE_REF}" >&2
        exit 1
    fi

    changed_files="$(git diff --name-only "${BASE_REF}" --)"

    if [[ "${INCLUDE_UNTRACKED}" -eq 1 ]]; then
        untracked_files="$(git ls-files --others --exclude-standard)"
        if [[ -n "${untracked_files}" ]]; then
            changed_files="${changed_files}"$'\n'"${untracked_files}"
        fi
    fi

    while IFS= read -r path; do
        [[ -n "${path}" ]] || continue
        select_source "$(source_for_path "${path}")"
    done <<< "${changed_files}"
fi

selected_sources=()
[[ "${SELECT_POSTGRES}" -eq 1 ]] && selected_sources+=("postgres")
[[ "${SELECT_CLICKHOUSE}" -eq 1 ]] && selected_sources+=("clickhouse")
[[ "${SELECT_REDIS}" -eq 1 ]] && selected_sources+=("redis")

if [[ "${#selected_sources[@]}" -eq 0 ]]; then
    echo "No changed data source files detected. Nothing to refresh."
    exit 0
fi

echo "Environment: ${ENVIRONMENT}"
echo "Selected data sources: ${selected_sources[*]}"

run_command() {
    if [[ "${DRY_RUN}" -eq 1 ]]; then
        printf '+'
        printf ' %q' "$@"
        printf '\n'
    else
        "$@"
    fi
}

for source in "${selected_sources[@]}"; do
    run_command "./scripts/${source}-drop.sh" "${ENVIRONMENT}"
    run_command "./scripts/${source}-init.sh" "${ENVIRONMENT}"
    if [[ "${WITH_DUMMY}" -eq 1 ]]; then
        run_command "./scripts/${source}-dummy.sh" "${ENVIRONMENT}"
    fi
done
