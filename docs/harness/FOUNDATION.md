# Harness v4 P0 Foundation

This file exists to keep the improvement roadmap from drifting.

## P0 design anchors

These anchors are not optional in P0.  
Any later change must explicitly state which anchor it changes and why.

### Anchor 1: Single writable lane per task
A task has exactly one writable code lane:
- `impl`

Other lanes:
- `review`
- `verify`
- `gui`
- `docs`

must operate on a **pinned implementation commit** and may update **task artifacts only**.

Reason:
- this removes the broken assumption that multiple lane worktrees can all share the same task branch safely.

### Anchor 2: Task state has one source of truth
`docs/ai/tasks/<TASK_ID>/status.yaml` is the source of truth.

Artifacts such as `handoff.md`, `review.md`, and `verify.md` support the state.  
They do not replace it.

### Anchor 3: Runtime isolation is mandatory when runtime is touched
If a task touches runtime behavior, the lane must either:
- obtain a runtime allocation, or
- explicitly record why runtime isolation is unnecessary.

Isolation must cover:
- app port
- API port
- DB port
- user data dir
- temp dir
- log dir
- GUI single-instance lock if relevant

### Anchor 4: Serial-only resources override file-level heuristics
"Not touching the same file" is not enough.

Serial-only areas include at least:
- schema / migrations
- shared DTO / IPC / API contracts
- dependency manifests and lockfiles
- app bootstrap / entrypoints
- shared test fixtures / snapshots
- generated code outputs
- global settings files

### Anchor 5: No implicit installs in bootstrap
Bootstrap may detect and report.  
Bootstrap may prepare overlays and directories.  
Bootstrap must not silently run project dependency installation unless the operator explicitly opts in.

### Anchor 6: Artifact completeness gates merge readiness
A task cannot be treated as merge-ready unless required artifacts validate cleanly.

### Anchor 7: Windows operator path is first-class
PowerShell is the primary operator path for this harness because the target environment is Windows / desktop-heavy.

## P0 non-goals

The following are intentionally not solved in P0:
- batch integration branch orchestration
- throughput metrics
- CI publication of harness packages
- automatic PR generation

## How to judge future changes

A proposed change is directionally aligned if it:
- reduces ambiguity
- reduces hidden shared state
- increases resume safety
- increases auditability
- lowers the chance of branch/worktree misuse
- does not reintroduce tool-specific asymmetry between Claude and Codex

A proposed change is directionally wrong if it:
- makes multiple lanes writable again
- pushes state back into chat-only memory
- relies on “operators will remember”
- adds large rituals without increasing enforcement
