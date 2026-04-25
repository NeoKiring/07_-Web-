#!/usr/bin/env bash
set -euo pipefail

TASK_ID="${1:?task id required}"
AREA="${2:?area required}"
SLUG="${3:?slug required}"
BASE_BRANCH="${4:-main}"

BRANCH="ai/${AREA}/${TASK_ID}-${SLUG}"
WORKTREE=".worktrees/${TASK_ID}__impl"

git worktree add -b "$BRANCH" "$WORKTREE" "$BASE_BRANCH"
echo "Created writable implementation lane"
echo "branch: $BRANCH"
echo "worktree: $WORKTREE"
