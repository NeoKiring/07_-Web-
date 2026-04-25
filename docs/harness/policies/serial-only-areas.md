# Serial-only Areas

These areas must not be parallelized merely because they are in different files.

## Serial-only by default

- DB schema, migrations, migration ordering
- shared API / IPC / RPC / DTO / JSON schema contracts
- app entrypoint, shell bootstrap, plugin bootstrap
- package manifests and lockfiles
  - `package.json`
  - `package-lock.json`
  - `pnpm-lock.yaml`
  - `poetry.lock`
  - `uv.lock`
  - `Cargo.lock`
  - `.csproj` package graphs
- generated code outputs
- localization key registries
- shared global settings
- snapshot baselines shared across multiple areas
- cross-cutting logging / tracing initialization

## Parallel only with explicit human approval

The parent dispatcher may allow parallel work only when:
- the ordering dependency is documented
- the merge order is explicit
- the fallback / rollback path is explicit

## Required contract behavior

If a task touches a serial-only area, the contract must state:
- why the task is isolated enough
- what other tasks must wait
- what merge order applies
