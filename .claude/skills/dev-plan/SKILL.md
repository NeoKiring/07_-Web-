# dev-plan

## Purpose
Convert prepared issues into:
1. a wave plan
2. task contracts
3. launch notes
4. queue metadata

This skill is for orchestration planning.

## Read first
- `docs/harness/FOUNDATION.md`
- `AGENTS.md`
- `CLAUDE.md`
- relevant issue specs and stubs

## Core planning rules

### Parallel-safety
Do not parallelize tasks that:
- touch the same file
- touch serial-only areas without explicit approval
- depend on unfinished shared contract changes
- compete for the same GUI single-instance runtime

### Writable lane rule
Each task gets exactly one writable implementation lane.

### Inspection lane rule
Review / verify / gui lanes target a pinned implementation commit.
They are not separate writable feature branches.

## Output artifacts
Write or update:
- `docs/ai/plans/<BATCH_ID>/wave-plan.md`
- `docs/ai/plans/<BATCH_ID>/queue.json`
- `docs/ai/tasks/<TASK_ID>/contract.md`
- `docs/ai/tasks/<TASK_ID>/launch.md`
- `docs/ai/tasks/<TASK_ID>/status.yaml`

## Required planning checklist
For each task, decide:
- scope boundary
- touched files
- serial-only area impact
- shared runtime risk
- GUI need
- runtime isolation need
- review lane need
- verify lane need
- merge order
- blocker conditions

If any are materially unknown, stop.

## Minimum status update
Set:
- state: `ready-for-impl`
- current_lane: `parent-dispatcher`
- exact_next_action: implementation lane start instruction
