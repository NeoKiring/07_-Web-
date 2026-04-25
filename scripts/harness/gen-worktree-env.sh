#!/usr/bin/env bash
set -euo pipefail

TASK_ID="${1:?task id required}"
LANE="${2:?lane required}"
OUT="${3:-.env.worktree.local}"

mkdir -p "$(dirname "$OUT")"

JSON="$(scripts/harness/alloc-runtime.sh "$TASK_ID" "$LANE")"
APP_PORT="$(printf '%s' "$JSON" | python3 -c 'import sys,json; print(json.load(sys.stdin)["app_port"])')"
API_PORT="$(printf '%s' "$JSON" | python3 -c 'import sys,json; print(json.load(sys.stdin)["api_port"])')"
DB_PORT="$(printf '%s' "$JSON" | python3 -c 'import sys,json; print(json.load(sys.stdin)["db_port"])')"
APP_INSTANCE_ID="$(printf '%s' "$JSON" | python3 -c 'import sys,json; print(json.load(sys.stdin)["app_instance_id"])')"
USER_DATA_DIR="$(printf '%s' "$JSON" | python3 -c 'import sys,json; print(json.load(sys.stdin)["user_data_dir"])')"
LOG_DIR="$(printf '%s' "$JSON" | python3 -c 'import sys,json; print(json.load(sys.stdin)["log_dir"])')"
TMP_DIR="$(printf '%s' "$JSON" | python3 -c 'import sys,json; print(json.load(sys.stdin)["tmp_dir"])')"

cat > "$OUT" <<ENV
# Generated worktree-local overlay
TASK_ID=$TASK_ID
LANE=$LANE
APP_PORT=$APP_PORT
API_PORT=$API_PORT
DB_PORT=$DB_PORT
APP_INSTANCE_ID=$APP_INSTANCE_ID
USER_DATA_DIR=$USER_DATA_DIR
LOG_DIR=$LOG_DIR
TMP_DIR=$TMP_DIR
ENV

echo "Generated $OUT"
