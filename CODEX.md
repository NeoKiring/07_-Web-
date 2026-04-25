# CODEX.md

This file defines Codex-specific operating behavior for this repository.

Cross-tool repository rules live in `AGENTS.md`.
Direction-locking rules live in `docs/harness/FOUNDATION.md`.

## Codex roles

Codex may act as:
- implementer
- reviewer
- verifier
- investigator
- docs lane

Codex should not be used as the final GUI acceptance authority in a Windows desktop workflow unless the human explicitly chooses that path.

## Codex default ownership

Codex is the default owner where the work is bounded, artifact-backed, and benefits from tight execution loops.

### Codex default lanes
- `impl`
- `verify`
- `docs`

### Codex default responsibilities
- scoped implementation on the single writable lane
- command-based verification
- artifact updates on pinned commits
- bounded codebase investigation
- small patch / test / update cycles

### Codex should usually not be the default owner for:
- parent-dispatcher work
- final GUI authority in Windows desktop workflows
- review that depends heavily on ambiguous product or architecture judgment

These may still be taken by Codex when the exception rules in `AGENTS.md` apply.

## Codex-specific rules

- read `docs/harness/FOUNDATION.md`, `AGENTS.md`, the task contract, and `status.yaml` before acting
- do not assume shell setup equals Windows desktop runtime readiness
- do not use repository write access as an excuse to broaden scope
- prefer small patch / test / update cycles
- record exact commands and outcomes
- update task artifacts before stopping
- do not treat default ownership as permission to bypass review independence

## Session naming

Use:
`[<TASK_ID>][<LANE>][codex]`

## Implementer behavior

When acting as implementer:
- operate only on the writable implementation branch
- do not create sibling writable branches for the same task
- stop after two serious failed attempts and write a handoff
- update:
  - `status.yaml`
  - `handoff.md`

Required completion sections:
- Summary
- Files Changed
- Commands Run
- Results
- Risks / Open Items
- Recommended Next Action
- Status

## Reviewer behavior

When acting as reviewer:
- do not patch code unless the role changes explicitly
- review the pinned commit and diff
- update `review.md` and `status.yaml`
- explicitly state why Codex review is credible if this is not the default ownership path

Required output sections:
- Verdict: PASS / PASS-WITH-NOTES / MUST-FIX
- Must Fix
- Nice to Have
- Missing Verification
- Merge Risk
- Reviewer Notes

## Verifier behavior

When acting as verifier:
- run only the requested commands unless you identify a clearly necessary omission
- separate verified facts from assumptions
- update `verify.md` and `status.yaml`

Required output sections:
- Commands
- Results
- Not tested
- GUI Recipe
- Remaining Risks

## When Codex should take over from Claude

Codex should usually take over when:
- the task contract is stable
- touched files and verification commands are already clear
- the next step is direct implementation
- the next step is routine verification
- the next step is docs or artifact completion without product ambiguity

## When Codex should hand off to Claude

Codex should usually hand off when:
- the task begins to drift beyond the contract
- repeated failures indicate a scoping or architecture issue
- the next step requires stronger review independence
- GUI validation becomes the key unresolved step
- the unresolved problem is no longer “how to patch” but “what should be decided”

## Codex bounded execution rule

Codex must treat default ownership of `impl` as a bounded execution responsibility, not as a license to redesign nearby areas.

Codex must stop and hand off when:
- protected zones would be crossed
- serial-only areas are implicated without approval
- the task contract no longer describes the real work
- runtime isolation is required but not ready
- the most credible next step is human or Claude judgment

## Codex review independence rule

If Codex acts as reviewer, it should be on a pinned commit with fresh context.
Codex must not treat prior implementation familiarity as review sufficiency.

If Codex previously implemented the diff, it must record:
- why the review is still credible, or
- why a separate review is still recommended

## Codex GUI restriction rule

Codex is not the default GUI owner in Windows desktop workflows.

If Codex is assigned to `gui`, it must explicitly record:
- why Codex is being used instead of Claude
- how GUI runtime readiness was confirmed
- what was actually observed
- whether the result is supporting evidence only or human-accepted final evidence

## Stop conditions

Stop and hand off if:
- the contract is incomplete
- runtime isolation is required but not configured
- the correct next step is a human decision
- the task has drifted beyond the contract
- review or verification requires a fresh session for credibility
- the default ownership should be changed for credibility or workflow fit

## What Codex must not do

- do not self-declare merge readiness without artifacts
- do not silently change `.env*`, secrets, or machine-local config
- do not conflate “tests passed” with “GUI accepted”
- do not treat `reviewed-wip` as permission to merge
- do not use `docs` lane to hide implementation or scope expansion
