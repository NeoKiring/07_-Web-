# Harness Changelog

## 4.0.0-p0
- repaired the lane model:
  - only `impl` has a writable branch/worktree
  - `review` / `verify` / `gui` / `docs` use pinned detached worktrees
- introduced `CODEX.md`
- introduced `docs/ai/tasks/<TASK_ID>/status.yaml` as task state source of truth
- introduced runtime allocation registry under `.runtime/allocations.json`
- replaced implicit `npm install` style bootstrap with stack detection and explicit opt-in install
- added artifact templates
- added validator scripts
- added serial-only area policy
- elevated PowerShell support to first-class operator path
