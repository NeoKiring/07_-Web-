# AGENTS.md

## Purpose
This repository uses a human-led, multi-agent development harness for long-running software work.

The harness is designed for:
- desktop / GUI-heavy development
- Windows-first operator workflows
- mixed Claude Code + Codex usage
- explicit review / verification / handoff
- resuming work across sessions, tools, and days
- bounded parallel implementation without hidden shared state

Read `docs/harness/FOUNDATION.md` before acting.

## Core operating model

### Rule 1
One task = one task contract = one state file = one writable implementation branch = one review verdict.

### Rule 2
A task has exactly one writable code lane:
- `impl`

Other lanes:
- `review`
- `verify`
- `gui`
- `docs`

operate on a pinned implementation commit and may update task artifacts only.

### Rule 3
`docs/ai/tasks/<TASK_ID>/status.yaml` is the source of truth for task state.

## Official task states

Each task must be in exactly one of these states:
- planned
- ready-for-impl
- in-progress
- implemented
- reviewed-pass
- reviewed-wip
- verified-pass
- merge-ready
- blocked
- merged
- abandoned

## Human responsibilities

The human owner is responsible for:
- selecting priorities
- approving scope
- resolving ambiguity
- approving serial-only parallel exceptions
- deciding merge / rollback
- making final GUI acceptance decisions
- deciding whether `reviewed-wip` is acceptable
- approving tool-ownership overrides when needed

## Agent responsibilities

Agents may:
- shape issues
- create plans
- implement scoped changes
- review diffs
- run targeted verification
- produce handoff notes
- surface blockers and risks

Agents must not:
- silently broaden scope
- create a second writable lane for the same task
- rewrite unrelated areas
- guess missing product decisions
- edit secrets or machine-local settings
- self-approve dangerous changes
- claim merge readiness without required artifacts

## Standard tool ownership model

This repository uses both Claude Code and Codex.
The default split below exists to reduce operator ambiguity and prevent tool switching from becoming ad hoc.

These are default ownership rules, not absolute exclusivity rules.
A task may be reassigned only when the exception conditions in this document are met.

If this section conflicts with tool-specific guidance:
1. `AGENTS.md`
2. `CLAUDE.md` or `CODEX.md`
3. task contract
in that order controls.

### Default ownership by responsibility

#### Claude Code is the default owner for:
- parent-dispatcher work
- task shaping when scope is still ambiguous
- review lanes that require higher human-facing judgment
- GUI validation lanes
- human-approval preparation
- cross-task risk surfacing
- resume / handoff shaping when context is fragmented

#### Codex is the default owner for:
- implementation lanes
- verifier lanes
- docs lanes
- investigator work that is codebase-heavy and bounded
- artifact completion on pinned commits
- narrow patch / test / update cycles

### Default ownership by lane

- `impl` -> Codex default
- `review` -> Claude default
- `verify` -> Codex default
- `gui` -> Claude default
- `docs` -> Codex default

These defaults apply unless the task contract or `status.yaml` explicitly overrides them.

### Why this split exists

This split is intentional:
- implementation needs tight patch / test / artifact cycles
- review needs distance from implementation and stronger judgment discipline
- verification benefits from bounded command execution and explicit evidence recording
- GUI acceptance in Windows desktop workflows should not rely on shell-only confidence
- dispatcher work needs stronger ambiguity handling and cross-task coordination

## Exception conditions

A default owner may be overridden only when at least one of the following is true.

### Claude may take `impl` when:
- the task is architecture-sensitive and likely to drift without tighter judgment
- the task requires frequent contract reinterpretation with human checkpoints
- the task is small but risk-heavy around scope or protected zones
- Codex previously broadened scope or failed to stop correctly on the same task
- the human explicitly wants Claude to own the writable lane

### Codex may take `review` when:
- the review is narrowly scoped to a pinned diff
- the review criteria are already stable in the task contract
- a fresh session is used
- the reviewer is not the same live execution context that authored the diff
- no final GUI or product judgment is being delegated implicitly

### Codex may take `gui` only when:
- the human explicitly approves it
- the workflow is not relying on shell success as a proxy for GUI correctness
- the runtime isolation and GUI recipe are already defined
- the result is treated as supporting evidence unless the human explicitly accepts it as final evidence

### Claude may take `verify` when:
- the verification requires more interpretive judgment than command execution
- the verifier must reconcile ambiguous or partially failing evidence
- the task is blocked on unclear verification meaning rather than command mechanics

### Either tool may take `docs` when:
- the scope is artifact-only
- no product decision is being changed
- no hidden implementation change is being smuggled through docs edits

## Reassignment rules

Tool switching is allowed, but must be explicit.

A switch must update:
- `status.yaml`
- `handoff.md`

The handoff must state:
- previous tool
- next tool
- previous lane
- next lane
- reason for switch
- pinned commit if non-impl
- exact next action
- risks or unresolved ambiguity

### Valid switch triggers

Switch tools when:
- the current tool has failed twice seriously
- credibility requires a fresh reviewer
- the task moves from implementation to GUI validation
- the task moves from ambiguous shaping to bounded execution
- the current tool is blocked by missing context or wrong workflow fit
- the human explicitly requests reassignment

### Invalid switch reasons

Do not switch tools just because:
- the current answer format was annoying
- the operator wants a second opinion without updating artifacts
- the current tool produced uncomfortable but valid findings
- the team wants to bypass a `blocked` or `reviewed-wip` state

## Anti-patterns

The following are prohibited:
- Claude implements and reviews the same diff in the same live context without an explicit freshness decision
- Codex is treated as final GUI authority by default in Windows desktop tasks
- tool switching without updating `status.yaml`
- using tool switching to bypass `Must Fix`
- using docs lane to smuggle scope expansion

## Human override

The human owner may override the default ownership split.
When doing so, the override should be recorded in either:
- the task contract, or
- `status.yaml`

The override should include:
- which default was overridden
- why
- whether the override is temporary or task-wide

## Non-negotiable rules

1. Do not broaden scope without explicit approval.
2. Do not parallelize serial-only areas casually.
3. Do not touch protected files unless the contract allows it.
4. Do not edit `.env*`, secrets, release artifacts, or machine-local config unless explicitly asked.
5. If blocked after two serious attempts, stop and write a handoff.
6. Prefer the smallest safe diff over a broad refactor.
7. Treat every change as if it will be reviewed by someone with zero chat context.
8. Always report commands run, results, risks, and exact next action.
9. Verification is mandatory.
10. `status.yaml` must be updated when state materially changes.
11. Runtime isolation is mandatory when a task uses local runtime.
12. “It seems fine” is not a valid completion reason.
13. Default tool ownership is guidance, not a loophole to avoid artifacts or gates.

## Parallelism policy

### Allowed parallelism
Parallel work is allowed when tasks are separated by:
- stable feature boundary
- stable layer boundary
- stable interface boundary
- docs-only boundary
- review / verify boundary on a pinned commit

### Disallowed parallelism
Do not parallelize if tasks:
- touch the same file
- touch serial-only areas
- depend on unfinished shared contract changes
- require the same single-instance GUI runtime at the same time
- depend on unresolved product decisions

### Serial-only override
See:
- `docs/harness/policies/serial-only-areas.md`

## Lane model

### `impl`
- writable lane
- owns the task branch
- produces code diff and initial verification
- updates task artifacts
- defaults to Codex unless reassigned explicitly

### `review`
- read-mostly lane
- operates on a pinned implementation commit
- reviews diff and updates `review.md` plus `status.yaml`
- defaults to Claude unless reassigned explicitly

### `verify`
- read-mostly lane
- operates on a pinned implementation commit
- runs required commands and updates `verify.md` plus `status.yaml`
- defaults to Codex unless reassigned explicitly

### `gui`
- read-mostly lane
- operates on a pinned implementation commit
- performs frontmost/manual-safe validation
- updates `gui.md` plus `status.yaml`
- defaults to Claude unless reassigned explicitly

### `docs`
- artifact-only lane
- may update planning / task artifacts
- must not silently change product or implementation scope
- defaults to Codex unless reassigned explicitly

## Task contract requirement

No implementation may start without:
- `docs/ai/tasks/<TASK_ID>/contract.md`
- `docs/ai/tasks/<TASK_ID>/status.yaml`
- `docs/ai/tasks/<TASK_ID>/launch.md`

A valid task contract must contain:
- identity
- objective
- in scope
- out of scope
- touched files
- forbidden files
- serial-only area note
- verification commands
- GUI verification requirement
- runtime isolation requirement
- done definition
- blocked conditions
- review focus
- merge order if relevant

A task contract may also record tool ownership preferences, including:
- default tool owner
- allowed alternate tool
- review tool requirement
- GUI tool requirement
- switch trigger notes

## Source-of-truth task file

The source of truth is:
`docs/ai/tasks/<TASK_ID>/status.yaml`

Minimum required fields:
- task id
- state
- tool
- current lane
- implementation branch
- impl worktree
- head commit
- review verdict
- verify status
- gui status
- exact next action
- last updated

Recommended additional fields:
- default tool owner
- allowed alternate tool
- switch reason
- pinned review commit
- pinned verify commit

If `status.yaml` is missing or stale, implementation or merge evaluation must stop.

## Done definition

A task is done only when all are true:
1. The contract objective is met.
2. The change stays within scope.
3. Required verification commands were run.
4. Results are recorded.
5. Review findings marked `Must Fix` are zero.
6. GUI verification is recorded if required, or explicitly deferred by human decision.
7. Rollback path is obvious.
8. `status.yaml`, `handoff.md`, and required artifacts are updated.

## Verification baseline

Always run the smallest relevant verification set.

Minimum expectation:
- targeted tests for the changed area
- lint if the area normally uses lint
- typecheck if the area normally uses typecheck
- startup / smoke if runtime behavior changed

When UI or desktop behavior changes:
- update the GUI recipe
- record whether final frontmost validation is still pending
- do not claim `verified-pass` without listing commands and outcomes

## Review gate

A task may become `merge-ready` only if:
- reviewer verdict is `PASS` or `PASS-WITH-NOTES`
- `Must Fix` count is zero
- verification is recorded
- remaining risks are explicitly accepted
- rollback path exists
- validator passes

A task becomes `reviewed-wip` when:
- review is mostly complete
- the diff is worth preserving
- something still blocks merge
- the exact next action is known

A task becomes `blocked` when:
- critical ambiguity remains
- required dependency is missing
- repeated failure indicates a deeper issue
- human product / architecture judgment is required

## Handoff artifacts

Each task keeps artifacts under:
`docs/ai/tasks/<TASK_ID>/`

Recommended files:
- contract.md
- status.yaml
- launch.md
- handoff.md
- review.md
- verify.md
- gui.md
- decisions.md
- failures.md

Minimum required when stopping:
- current state
- current lane
- current tool
- head commit
- files changed
- commands run
- results
- blocker or remaining work
- exact next action
- merge safety
- whether a tool switch is recommended

Store operationally useful information only.  
Do not store private chain-of-thought.

## Worktree policy

### Writable implementation lane
Naming:
- branch: `ai/<area>/<task-id>-<slug>`
- worktree: `.worktrees/<task-id>__impl`

Only `impl` owns the writable task branch.

### Inspection lanes
Inspection lanes use a pinned implementation commit and detached worktrees.

Naming:
- `.worktrees/<task-id>__review__<shortsha>`
- `.worktrees/<task-id>__verify__<shortsha>`
- `.worktrees/<task-id>__gui__<shortsha>`

These lanes must not create or use their own writable feature branches for the same task.

### Runtime assumptions
Do not assume:
- ports are free
- local DB names are unique
- user data directories are isolated
- build outputs are isolated
- GUI runtime is available

Use the allocator and record the result.
