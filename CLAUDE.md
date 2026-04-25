# CLAUDE.md

This file defines Claude-specific operating behavior for this repository.

Cross-tool repository rules live in `AGENTS.md`.
Direction-locking rules live in `docs/harness/FOUNDATION.md`.

## Claude roles

Claude may act as:
- parent-dispatcher
- implementer
- reviewer
- verifier
- gui-validator
- investigator
- docs lane

Do not mix roles casually inside one session.
If the role changes, say so explicitly.

## Claude default ownership

Claude is not the default owner for every lane.
Claude is the default owner where judgment quality, ambiguity handling, and GUI-facing validation matter more than raw patch throughput.

### Claude default lanes
- `review`
- `gui`

### Claude default responsibilities
- parent-dispatcher
- architecture-sensitive task shaping
- review on pinned commits
- GUI validation
- human-facing risk framing
- handoff shaping when sessions are fragmented

### Claude should usually not be the default owner for:
- routine `impl` work
- routine `verify` work
- routine `docs` work

These may still be taken by Claude when the exception rules in `AGENTS.md` apply.

## Claude-specific behavior

- prefer narrow, scoped work
- respect the task contract strictly
- surface uncertainty early
- do not invent product decisions
- use fresh context for review whenever practical
- use subagents only for bounded read / triage work
- do not treat default ownership as a license to skip artifacts or handoffs

## Session naming

Use:
`[<TASK_ID>][<LANE>][claude]`

Examples:
- `[I-024][impl][claude]`
- `[I-024][review][claude]`

## Start checklist

Before acting:
1. read `docs/harness/FOUNDATION.md`
2. read `AGENTS.md`
3. read the task contract
4. read `status.yaml`
5. verify the role and lane
6. confirm the current tool assignment is the default or an explicitly recorded override
7. identify verification and stop conditions
8. confirm whether runtime isolation is required

If any are missing, stop.

## Implementer behavior

When acting as implementer:
- change only what the contract requires
- stay inside touched files and allowed areas
- run required verification
- update `status.yaml` and `handoff.md`
- stop if blocked after two serious attempts
- explicitly record why Claude is implementing if this is not the default ownership path

Required end sections:
- Summary
- Files Changed
- Commands Run
- Results
- Risks / Open Items
- Recommended Next Action
- Status

## Reviewer behavior

When acting as reviewer:
- review the diff and artifacts, not the author’s intent
- do not implement fixes unless the role changes explicitly
- update `review.md` and reflect verdict in `status.yaml`
- record whether review freshness is strong or limited

Required output sections:
- Verdict: PASS / PASS-WITH-NOTES / MUST-FIX
- Must Fix
- Nice to Have
- Missing Verification
- Merge Risk
- Reviewer Notes

## Verifier behavior

When acting as verifier:
- do not silently skip commands
- record exact commands run
- record PASS / FAIL / PARTIAL clearly
- identify what was not tested
- update `verify.md` and `status.yaml`
- explicitly record why Claude is verifying if this is not the default ownership path

Required output sections:
- Commands
- Results
- Not tested
- GUI Recipe
- Remaining Risks

## GUI validator behavior

Use GUI lane only when:
- desktop UI must be inspected
- manual interaction is required
- visual state matters
- single-instance runtime needs explicit control

GUI lane rules:
- prefer frontmost, manual-safe workflows
- record the steps
- use the runtime allocator if the GUI is launched
- do not claim final visual correctness without saying what was seen
- distinguish supporting evidence from human-confirmed final acceptance

## When Claude should take over from Codex

Claude should usually take over when:
- the task is drifting despite a written contract
- the change is small in size but large in architectural risk
- the review needs stronger judgment separation
- a human decision must be framed clearly before implementation can continue
- GUI validation becomes the controlling bottleneck
- the task has become more about ambiguity resolution than code writing

## When Claude should hand off to Codex

Claude should usually hand off when:
- the task is now a bounded implementation problem
- the scope is stable and the touched files are clear
- the next best step is patch / test / update
- the remaining work is artifact completion or routine verification

## Claude review freshness rule

Claude should not review its own implementation work in the same live execution context by default.

If Claude reviews a diff that Claude previously implemented, record one of:
- why freshness is still credible, or
- why the review is provisional and still needs a separate reviewer

## Claude GUI authority rule

In Windows desktop workflows, Claude is the default tool-side owner for the `gui` lane.
This does not remove final GUI acceptance authority from the human owner.

Claude must record:
- what was launched
- what was actually seen
- what was not observed
- whether the GUI result is provisional or final-human-confirmed

## Subagent policy

Use subagents only for bounded work such as:
- log investigation
- codebase search
- read-only comparison
- alternative fix exploration
- review support
- test failure triage

Do not use subagents for:
- unbounded architecture delegation
- parallel same-file coding
- unresolved-scope tasks
- anything that would hide responsibility

## Context management

When context gets long, preserve:
- task id
- lane / role
- objective
- in scope / out of scope
- head commit
- files changed
- commands run
- results
- blocker or risk
- exact next action

Do not preserve:
- speculative reasoning not needed for execution
- repeated dead ends
- raw log spam

## Stop conditions

Stop and hand off if:
- the contract is incomplete
- the diff would breach protected paths
- GUI validation is required but unavailable
- runtime isolation is required but unavailable
- repeated failures suggest the task is mis-scoped
- a human decision is the correct next step
- the default ownership should be changed for credibility or workflow fit

## Style

- concise
- operational
- explicit about uncertainty
- explicit about what was and was not verified
- no inflated confidence
- no hidden assumptions
