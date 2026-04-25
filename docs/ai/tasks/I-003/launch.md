# Launch: I-003 impl

## Lane identity
- task id: I-003
- lane: impl
- tool: Codex
- writable: yes

## Branch / commit target
- implementation branch: `ai/packages/I-003-packages-rest-skeleton`
- target commit for inspection lanes: (to be set by impl after first commit)

## Worktree
- path: `.worktrees/I-003__impl`
- create command (Linux/mac):
  ```bash
  scripts/harness/new-impl-lane.sh I-003 packages packages-rest-skeleton main
  ```
- create command (Windows):
  ```powershell
  pwsh scripts/harness/new-impl-lane.ps1 -TaskId I-003 -Area packages -Slug packages-rest-skeleton -BaseBranch main
  ```

## Session name
`[I-003][impl][codex]`

## Read first
- `docs/harness/FOUNDATION.md` (Anchor 4/5)
- `AGENTS.md`, `CODEX.md`
- `docs/ai/tasks/I-003/contract.md` (finalized)
- `docs/ai/tasks/I-003/status.yaml`
- `docs/ai/tasks/I-002/handoff.md` (merged 後、tsconfig.base.json 全文と
  `@repo/*` 命名規約を確認)
- `docs/ai/plans/BATCH-WAVE0/wave-plan.md`
- `docs/ai/plans/BATCH-WAVE0/uq-decisions.md` (グループ 2, 5 を特に)
- 要件 v0.2 §15.1, §15.4, §15.5, §15.6, NFR-004 (`packages/core` UI/DB 非依存)

## Start instruction

1. **前提確認**: I-002 が merged 済みを `git log main` で確認。未 merge なら blocked
2. impl worktree に cd、`status.yaml` を `state: in-progress` に更新
3. 4 パッケージを一括作成 (for ループで統一)。各 `<p>` in `core`, `db`, `ingestion`, `ui`:
   - `packages/<p>/package.json`:
     ```json
     {
       "name": "@repo/<p>",
       "version": "0.0.0",
       "private": true,
       "exports": {
         ".": { "types": "./src/index.ts", "default": "./src/index.ts" }
       },
       "dependencies": {},
       "devDependencies": {}
     }
     ```
     - `packages/core/package.json` は特に **`@repo/db` / `@repo/ui` /
       `@repo/ingestion` を deps に入れない** (NFR-004)
   - `packages/<p>/tsconfig.json`:
     ```json
     {
       "extends": "../../tsconfig.base.json",
       "compilerOptions": {
         "composite": true,
         "outDir": "dist",
         "rootDir": "src"
       },
       "include": ["src"]
     }
     ```
   - `packages/<p>/src/index.ts`: `export {};` 1 行のみ
4. root `tsconfig.json` を modify: `references` に 4 エントリ追加
   (既存の `packages/types` は維持):
   ```json
   {
     "files": [],
     "references": [
       { "path": "packages/types" },
       { "path": "packages/core" },
       { "path": "packages/db" },
       { "path": "packages/ingestion" },
       { "path": "packages/ui" }
     ]
   }
   ```
5. root `package.json` は基本触らない (必要があれば devDep のみ最小追加、
   **`scripts` は絶対に触らない**)
6. `pnpm install -w` を 1 回実行し `pnpm-lock.yaml` を更新 (新 workspace 追加)
7. contract.md の Verification commands 1〜11 を全て実行、全 PASS を確認
8. 変更を 1 commit にまとめる。コミットメッセージ:
   `feat(types,core,db,ingestion,ui): add rest of workspace package skeletons (I-003)`
   (または最大の影響 scope に絞って `feat(core): ...` でも可。commitlint は
   I-006 まで未導入なので flexibility あり)
9. `status.yaml` を `state: implemented`、`exact_next_action` 更新
10. `handoff.md` 記入: 4 パッケージの name 最終形、依存ゼロ確認、
    UQ-I003-05 (b) 遵守メモ (packages/ui に shadcn プリミティブ無し)、
    次タスク I-004 への参照方法

## Stop conditions

- I-002 が merged でない
- いずれかの `src/index.ts` に `export {};` 以外を書きたくなった
- Prisma / React / shadcn / Tremor / Tailwind の記述が入った
- `packages/ui/src/components/` を作りたくなった (UQ-I003-05 (b) 違反)
- `packages/ui/tailwind.config.ts` を置きたくなった (UQ-I003-04、I-005 の領分)
- `packages/core/package.json` に `@repo/db|ui|ingestion` を入れたくなった
  (NFR-004 違反)
- `packages/*/test/` を作りたくなった (UQ-I003-03 で skeleton 段階では作らない)
- 各 package の `dependencies` を埋めたくなった (Wave 1 の仕事)
- root `package.json` の `scripts` を書き換えたくなった
- Verification commands のいずれかが PASS しない、かつ 2 回の serious attempt
  でも解消できない

停止時は `handoff.md` を作成し `status.yaml` を `blocked` に更新。
