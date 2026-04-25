# Harness v4 P0 Bundle

This bundle is the **P0 redesign** of the earlier harness.
It is intentionally narrower and stricter than v3.

## What changed in v4 P0

The redesign locks in these non-negotiable decisions:

1. **One task has one writable implementation branch/worktree**
   - `impl` is the only code-writing lane.
   - `review`, `verify`, `gui`, and `docs` operate on a pinned commit and may update task artifacts only.

2. **`docs/ai/tasks/<TASK_ID>/status.yaml` is the source of truth**
   - State, branch, head commit, review verdict, verification status, and next action live there.

3. **Runtime isolation is explicit**
   - Ports, user-data, log directories, temp directories, and GUI single-instance constraints are tracked through `.runtime/allocations.json`.

4. **Implicit dependency install is forbidden**
   - Bootstrap scripts detect the stack and prepare overlays, but they do not silently run `npm install`, `pip install`, `cargo build`, or similar unless explicitly requested by the operator.

5. **Merge readiness is validated**
   - The validator scripts check required artifacts before a task may be treated as `merge-ready`.

6. **Windows / PowerShell is first-class**
   - PowerShell scripts are included for the main operator path. Shell versions are kept for parity.

## Adopt first

1. Read `docs/harness/FOUNDATION.md`
2. Read `AGENTS.md`
3. Read `CLAUDE.md` and `CODEX.md`
4. Rename `.gtrconfig.v4` to `.gtrconfig` if you use git-worktree-runner
5. Run one small task through:
   - issue shaping
   - planning
   - implementation lane
   - review lane
   - verification lane
   - artifact validation

## Included P0 scope

Included:
- branch / worktree model repair
- Codex operating contract
- task state source of truth
- runtime allocator
- PowerShell-first bootstrap
- task artifact templates
- validator scripts
- serial-only area policy

Not included yet:
- batch integration branch flow
- throughput metrics
- harness CI package publishing
- advanced dashboarding

## Primary directories

- `docs/harness/` : design anchors, policies, templates, changelog
- `docs/ai/tasks/<TASK_ID>/` : task audit trail
- `scripts/harness/` : allocator, bootstrap, validation, task helpers
- `.runtime/` : runtime allocation registry and lane-local directories


## v4.1 update

This bundle updates `AGENTS.md`, `CLAUDE.md`, and `CODEX.md` to add:
- standard Claude Code / Codex ownership defaults
- exception conditions
- explicit reassignment rules
- anti-patterns and human override recording
