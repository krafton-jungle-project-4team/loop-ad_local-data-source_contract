---
name: patch-local-data-source
description: Apply a small AI-generated local patch to the running loop-ad data contract Postgres, ClickHouse, or Redis service instead of rebuilding with drop, init, and dummy. Use only when the user explicitly asks for an AI/manual patch, wants to avoid resetting local data, or needs a temporary local fix for a narrow schema or dummy-data change; if the change is broad, risky, destructive, or uncertain, use refresh-changed-data-sources instead.
---

# Patch Local Data Source

## Overview

Use this skill only for narrow local fixes where a full `drop -> init -> dummy` refresh is intentionally avoided. The source-of-truth files remain `postgres/schema.sql`, `clickhouse/schema.sql`, `redis/contract.md`, and the dummy files; the patch must bring the running local service into the same meaning as those files.

## Workflow

1. Confirm the user explicitly wants an AI/manual patch rather than `$refresh-changed-data-sources`.
2. Inspect the relevant diff and identify affected sources:

```bash
git diff --name-only HEAD -- postgres clickhouse redis
git diff HEAD -- postgres clickhouse redis
```

3. Patch only narrow, locally safe changes:

- Postgres: additive columns, indexes, constraints, or dummy row updates that can be expressed with idempotent SQL.
- ClickHouse: additive table changes, materialized view adjustments, or dummy row updates that can be expressed safely for the current local state.
- Redis: dummy command changes or contract-aligned key/value adjustments.

4. Refuse the patch path and recommend `$refresh-changed-data-sources` when the change requires reordering tables, destructive column type changes, large data rewrites, unknown dependencies, or any operation whose final state cannot be confidently proven.
5. Apply the patch through the existing Docker Compose project and environment file. Keep temporary SQL or Redis command files outside the repo, for example under `/tmp`.
6. Verify the running local state after applying the patch with focused queries or reads.

## Guardrails

- State clearly that patching is local-only and the operator owns the correctness risk.
- Do not commit generated temporary patch files.
- Do not modify source-of-truth schema or dummy files unless the user asked for code changes too.
- Prefer idempotent statements such as `IF EXISTS`, `IF NOT EXISTS`, and key-specific Redis commands when the engine supports them.
- Report exactly which service was patched, which commands or files were used, and what verification passed.
