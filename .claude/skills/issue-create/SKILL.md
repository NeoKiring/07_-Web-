# issue-create

## Purpose
Convert rough requirements into:
1. an issue specification
2. a task contract stub
3. an unresolved-questions file
4. an initial `status.yaml`

This skill shapes work.  
It does not start implementation.

## Read first
- `docs/harness/FOUNDATION.md`
- `AGENTS.md`
- `CLAUDE.md`

## Required outputs
Create or update:
- `docs/ai/issues/<TASK_ID>/issue-spec.md`
- `docs/ai/issues/<TASK_ID>/unresolved.md`
- `docs/ai/tasks/<TASK_ID>/contract.stub.md`
- `docs/ai/tasks/<TASK_ID>/status.yaml`

Use the templates under:
- `docs/harness/templates/`

## Required principles
- preserve out-of-scope aggressively
- do not guess missing product behavior
- mark GUI/manual verification need explicitly
- mark runtime isolation need explicitly
- mark serial-only area risk explicitly
- do not create a branch or worktree
- do not start coding

## Completion criteria
This skill is complete only when:
- the issue is specific enough for planning
- unresolved questions are explicit
- the contract stub exists
- `status.yaml` exists in `planned`
- GUI/manual verification has a status
- out-of-scope boundaries are written
