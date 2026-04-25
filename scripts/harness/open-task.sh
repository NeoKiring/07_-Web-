#!/usr/bin/env bash
set -euo pipefail

TASK_ID="${1:?task id required}"
TASK_DIR="docs/ai/tasks/${TASK_ID}"

echo "Task bundle: ${TASK_ID}"
for path in \
  "${TASK_DIR}/status.yaml" \
  "${TASK_DIR}/handoff.md" \
  "${TASK_DIR}/review.md" \
  "${TASK_DIR}/verify.md"; do
  if [ -f "$path" ]; then
    echo "- present: $path"
  else
    echo "- missing: $path"
  fi
done

[ -f "${TASK_DIR}/status.yaml" ] && sed -n '1,40p' "${TASK_DIR}/status.yaml"
