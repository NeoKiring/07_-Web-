# review-gate

## Purpose
Apply the repository review gate and produce a merge-readiness judgment.

## Read first
- `docs/harness/FOUNDATION.md`
- `AGENTS.md`
- `CLAUDE.md`
- `docs/ai/tasks/<TASK_ID>/contract.md`
- `docs/ai/tasks/<TASK_ID>/status.yaml`
- current diff
- `verify.md` if present
- `gui.md` if present

## Review priorities
1. correctness
2. regressions
3. scope violations
4. serial-only area misuse
5. missing verification
6. risky assumptions
7. maintainability

## Gate checklist
A task may be merge-ready only if:
- contract objective is met
- out-of-scope items were not changed
- Must Fix count is zero
- required verification is recorded
- GUI verification is recorded if required, or explicitly deferred by human decision
- rollback path is obvious
- validator passes

## Required output
- Verdict: PASS / PASS-WITH-NOTES / MUST-FIX
- Must Fix
- Nice to Have
- Missing Verification
- Merge Risk
- Reviewer Notes
