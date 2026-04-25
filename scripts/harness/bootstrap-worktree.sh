#!/usr/bin/env bash
set -euo pipefail

TASK_ID="${1:?task id required}"
LANE="${2:?lane required}"
PREPARE_RUNTIME="${3:-false}"

stacks=()
[ -f package.json ] && stacks+=("node")
[ -f pyproject.toml ] || [ -f requirements.txt ] && stacks+=("python")
[ -f Cargo.toml ] && stacks+=("rust")
find . -maxdepth 2 \( -name "*.sln" -o -name "*.csproj" \) | grep -q . && stacks+=("dotnet") || true
[ "${#stacks[@]}" -eq 0 ] && stacks=("unknown")

echo "[bootstrap] task=$TASK_ID lane=$LANE"
echo "[bootstrap] detected stacks: ${stacks[*]}"

if [ "$PREPARE_RUNTIME" = "true" ]; then
  scripts/harness/gen-worktree-env.sh "$TASK_ID" "$LANE" ".env.worktree.local"
else
  echo "[bootstrap] runtime overlay not created (pass true as 3rd arg if needed)"
fi

echo "[bootstrap] no dependency installation performed"
echo "[bootstrap] run install/restore/build explicitly according to project policy"
