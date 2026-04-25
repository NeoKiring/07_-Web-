# Runtime Isolation Policy

Worktree separation prevents code collisions.  
It does not prevent runtime collisions.

## Required runtime fields

The allocator must produce:
- `APP_PORT`
- `API_PORT`
- `DB_PORT`
- `APP_INSTANCE_ID`
- `USER_DATA_DIR`
- `TMP_DIR`
- `LOG_DIR`

## GUI rule

When the app or shell is single-instance:
- only one `gui` lane may hold the GUI lock at a time
- implementation lanes should update recipes, not claim final frontmost validation

## If runtime isolation is not needed

The lane must state one of:
- pure docs task
- pure review task
- pure static analysis
- no runtime process started

This must be reflected in `status.yaml` or `handoff.md`.
