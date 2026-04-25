#!/usr/bin/env bash
set -euo pipefail

TASK_ID="${1:?task id required}"
LANE="${2:?lane required}"
TOOL="${3:-}"
HEAD_COMMIT="${4:-}"

OUT_DIR="docs/ai/tasks/${TASK_ID}"
OUT_FILE="${OUT_DIR}/handoff.md"
mkdir -p "$OUT_DIR"

if [ ! -f "$OUT_FILE" ]; then
cat > "$OUT_FILE" <<EOF
# Handoff: ${TASK_ID}

## Status snapshot
- state:
- current lane: ${LANE}
- tool: ${TOOL}
- head commit: ${HEAD_COMMIT}
- safe to merge now: no

## Objective

## Changed files
- none yet

## Commands run
- ...

## Results
- ...

## Current blocker / remaining work
- ...

## Exact next action
- ...

## Merge safety
- rollback path:
- serial-only concern:
- runtime concern:
EOF
fi

echo "Ensured $OUT_FILE"
