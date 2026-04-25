# gtr-workflow

## Purpose
Create the correct kind of execution lane for a task:
- writable implementation lane, or
- detached inspection lane

## Read first
- `docs/harness/FOUNDATION.md`
- `AGENTS.md`
- `CLAUDE.md`
- `docs/ai/tasks/<TASK_ID>/contract.md`
- `docs/ai/tasks/<TASK_ID>/status.yaml`

## Inputs
Required:
- task id
- lane type (`impl`, `review`, `verify`, `gui`, `docs`)
- contract path

Optional:
- preferred AI tool
- preferred editor
- explicit target commit for inspection lanes

## Preconditions
Before creating anything, confirm:
1. task contract exists
2. out-of-scope is written
3. forbidden files are written
4. verification commands exist
5. GUI verification status exists
6. serial-only risk is understood
7. base branch or target commit is correct

If any are missing, stop.

## Lane creation rule

### Writable implementation lane
Use either:
- `git gtr new <branch-name>` after renaming `.gtrconfig.v4` to `.gtrconfig`, or
- `scripts/harness/new-impl-lane.ps1`
- `scripts/harness/new-impl-lane.sh`

### Inspection lanes
Use:
- `scripts/harness/new-inspection-worktree.ps1`
- `scripts/harness/new-inspection-worktree.sh`

Inspection lanes must target a pinned implementation commit and use a detached worktree.

## Runtime rule
If runtime isolation is required:
- allocate runtime
- generate `.env.worktree.local`
- record the allocation in the task artifacts

Do not claim readiness if runtime-critical setup is missing.

## Required handoff setup
Ensure these exist:
- `status.yaml`
- `launch.md`
- `handoff.md`

## Required final response
Return:
- lane type
- branch or target commit
- worktree path
- runtime setup status
- exact next command
- ready / blocked
