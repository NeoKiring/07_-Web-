#!/usr/bin/env bash
set -euo pipefail

TASK_ID="${1:?task id required}"
STATE="${2:-planned}"
LANE="${3:-}"
TOOL="${4:-}"
BRANCH="${5:-}"
IMPL_WORKTREE="${6:-}"
HEAD_COMMIT="${7:-}"
NEXT_ACTION="${8:-}"

OUT_DIR="docs/ai/tasks/${TASK_ID}"
OUT_FILE="${OUT_DIR}/status.yaml"
mkdir -p "$OUT_DIR"

if [ ! -f "$OUT_FILE" ]; then
cat > "$OUT_FILE" <<EOF
task_id: $TASK_ID
title: ""
area: ""
slug: ""
batch_id: ""
state: $STATE
harness_version: 4.0.0-p0

tool: $TOOL
current_lane: $LANE
owner: ""

implementation_branch: $BRANCH
impl_worktree: $IMPL_WORKTREE
inspection_worktree: ""
head_commit: $HEAD_COMMIT

review_verdict: pending
verify_status: pending
gui_status: not-required
runtime_status: not-started

blocked_reason: ""
exact_next_action: $NEXT_ACTION
last_updated: $(date +"%Y-%m-%dT%H:%M:%S")
EOF
else
python3 - "$OUT_FILE" "$STATE" "$LANE" "$TOOL" "$BRANCH" "$IMPL_WORKTREE" "$HEAD_COMMIT" "$NEXT_ACTION" <<'PY'
import re, sys, pathlib, datetime
path, state, lane, tool, branch, impl_worktree, head_commit, next_action = sys.argv[1:]
text = pathlib.Path(path).read_text(encoding='utf-8')
pairs = {
    r'^state: .*': f'state: {state}',
    r'^tool: .*': f'tool: {tool}',
    r'^current_lane: .*': f'current_lane: {lane}',
    r'^implementation_branch: .*': f'implementation_branch: {branch}',
    r'^impl_worktree: .*': f'impl_worktree: {impl_worktree}',
    r'^head_commit: .*': f'head_commit: {head_commit}',
    r'^exact_next_action: .*': f'exact_next_action: {next_action}',
    r'^last_updated: .*': f'last_updated: {datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S")}',
}
for pattern, repl in pairs.items():
    text = re.sub(pattern, repl, text, flags=re.MULTILINE)
pathlib.Path(path).write_text(text, encoding='utf-8')
PY
fi

echo "Updated $OUT_FILE"
