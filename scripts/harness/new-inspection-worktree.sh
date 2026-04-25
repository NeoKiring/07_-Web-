#!/usr/bin/env bash
set -euo pipefail

TASK_ID="${1:?task id required}"
LANE="${2:?lane required}"
COMMIT="${3:?commit required}"

SHORT="$(printf '%s' "$COMMIT" | cut -c1-7)"
WORKTREE=".worktrees/${TASK_ID}__${LANE}__${SHORT}"

git worktree add --detach "$WORKTREE" "$COMMIT"
echo "Created detached inspection lane"
echo "lane: $LANE"
echo "target commit: $COMMIT"
echo "worktree: $WORKTREE"
