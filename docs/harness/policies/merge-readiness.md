# Merge Readiness Policy

A task is a merge-ready candidate only when:
- `status.yaml` exists and is current
- `contract.md` exists
- `handoff.md` exists
- `review.md` verdict is `PASS` or `PASS-WITH-NOTES`
- no `Must Fix` items remain
- `verify.md` records commands and outcomes
- GUI verification is recorded if required, or explicitly deferred by human decision
- the exact next action is not empty
- the rollback path is obvious from the handoff and touched files

The validator scripts enforce only the structural part.  
Human judgment still decides whether the remaining risk is acceptable.
