#!/usr/bin/env bash
set -euo pipefail

TASK_ID="${1:?task id required}"
MODE="${2:-normal}"

TASK_DIR="docs/ai/tasks/${TASK_ID}"
STATUS="${TASK_DIR}/status.yaml"
CONTRACT="${TASK_DIR}/contract.md"
HANDOFF="${TASK_DIR}/handoff.md"
REVIEW="${TASK_DIR}/review.md"
VERIFY="${TASK_DIR}/verify.md"
GUI="${TASK_DIR}/gui.md"

errors=()

for path in "$STATUS" "$CONTRACT" "$HANDOFF"; do
  [ -f "$path" ] || errors+=("Missing required artifact: $path")
done

if [ -f "$STATUS" ]; then
  for field in "task_id:" "state:" "current_lane:" "implementation_branch:" "head_commit:" "exact_next_action:" "last_updated:"; do
    grep -q "^${field}" "$STATUS" || errors+=("status.yaml missing field: ${field}")
  done
  state="$(grep '^state:' "$STATUS" | sed 's/^state:[[:space:]]*//')"
  review_verdict="$(grep '^review_verdict:' "$STATUS" | sed 's/^review_verdict:[[:space:]]*//')"
  verify_status="$(grep '^verify_status:' "$STATUS" | sed 's/^verify_status:[[:space:]]*//')"
  gui_status="$(grep '^gui_status:' "$STATUS" | sed 's/^gui_status:[[:space:]]*//')"

  if [ "$MODE" = "merge-ready" ] || [ "$state" = "merge-ready" ]; then
    [ -f "$REVIEW" ] || errors+=("merge-ready requires review.md")
    [ -f "$VERIFY" ] || errors+=("merge-ready requires verify.md")
    [[ "$review_verdict" == "PASS" || "$review_verdict" == "PASS-WITH-NOTES" ]] || errors+=("merge-ready requires review_verdict PASS or PASS-WITH-NOTES")
    [[ "$verify_status" == "pass" || "$verify_status" == "partial-pass" || "$verify_status" == "verified-pass" ]] || errors+=("merge-ready requires verify_status pass-like value")
    if [ "$gui_status" = "required" ] && [ ! -f "$GUI" ]; then
      errors+=("merge-ready with gui_status=required requires gui.md or explicit defer")
    fi
  fi
fi

if [ -f "$CONTRACT" ]; then
  for section in \
    "## Objective" \
    "## In scope" \
    "## Out of scope" \
    "## Touched files" \
    "## Forbidden files" \
    "## Verification commands" \
    "## GUI verification" \
    "## Runtime isolation" \
    "## Done definition"; do
    grep -qF "$section" "$CONTRACT" || errors+=("contract.md missing section: $section")
  done
fi

if [ "${#errors[@]}" -gt 0 ]; then
  echo "Artifact validation FAILED for $TASK_ID"
  for e in "${errors[@]}"; do
    echo "- $e"
  done
  exit 1
fi

echo "Artifact validation PASSED for $TASK_ID"
