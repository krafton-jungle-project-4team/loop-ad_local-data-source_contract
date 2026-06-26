---
name: refresh-changed-data-sources
description: Detect changed data source files in this loop-ad data contract repository and refresh only the affected local Postgres, ClickHouse, or Redis Docker services. Use when schema files, dummy data files, Redis contract files, datasource-specific scripts, or shared local datasource configuration changed and the local environment should be brought back in sync without running a full global drop/init.
---

# Refresh Changed Data Sources

## Overview

Use this skill to keep the local data contract environment aligned with the current git changes while avoiding unnecessary resets. The bundled script maps changed files to Postgres, ClickHouse, and Redis, then runs `drop -> init` only for the affected data sources.

## Workflow

1. Confirm the repository is `loop-ad_local-data-source_contract` and the target environment is explicit, usually `local`.
2. Inspect `git status --short` when the requested scope is unclear.
3. Run a dry run first:

```bash
.codex/skills/refresh-changed-data-sources/scripts/refresh_changed_data_sources.sh local --dry-run
```

4. If the selected data sources match the user's intent, run without `--dry-run`:

```bash
.codex/skills/refresh-changed-data-sources/scripts/refresh_changed_data_sources.sh local
```

5. Add `--with-dummy` only when dummy data should also be reapplied:

```bash
.codex/skills/refresh-changed-data-sources/scripts/refresh_changed_data_sources.sh local --with-dummy
```

## Change Mapping

- `postgres/**` and `scripts/postgres-*` refresh Postgres.
- `clickhouse/**` and `scripts/clickhouse-*` refresh ClickHouse.
- `redis/**` and `scripts/redis-*` refresh Redis.
- `docker-compose.yml`, `scripts/lib/**`, top-level datasource scripts, and `environments/*.env` refresh all three data sources because the blast radius is shared.

The script compares local changes against `HEAD` by default, including untracked files. If the working tree is clean but the branch contains committed datasource changes, compare against a branch or ref:

```bash
.codex/skills/refresh-changed-data-sources/scripts/refresh_changed_data_sources.sh local --base main --dry-run
```

Use `--only postgres`, `--only clickhouse`, `--only redis`, or a comma-separated list only when the user explicitly wants to override detection.

## Guardrails

- Treat execution as destructive to the selected local data source volumes.
- Do not run global `scripts/drop.sh` or `scripts/init.sh` unless the user asks for a full reset.
- If no data source changes are detected, stop and report that nothing was refreshed.
- Keep the environment argument explicit; do not assume `local` when running commands.
