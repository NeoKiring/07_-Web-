# Launch: I-002 impl

## Lane identity
- task id: I-002
- lane: impl
- tool: Codex
- writable: yes

## Branch / commit target
- implementation branch: `ai/packages/types/I-002-packages-types-skeleton`
- target commit for inspection lanes: (to be set by impl after first commit)

## Worktree
- path: `.worktrees/I-002__impl`
- create command (Linux/mac):
  ```bash
  scripts/harness/new-impl-lane.sh I-002 packages/types packages-types-skeleton main
  ```
- create command (Windows):
  ```powershell
  pwsh scripts/harness/new-impl-lane.ps1 -TaskId I-002 -Area packages/types -Slug packages-types-skeleton -BaseBranch main
  ```

## Session name
`[I-002][impl][codex]`

## Read first
- `docs/harness/FOUNDATION.md` (Anchor 4/5)
- `AGENTS.md`, `CODEX.md`
- `docs/ai/tasks/I-002/contract.md` (finalized)
- `docs/ai/tasks/I-002/status.yaml`
- `docs/ai/tasks/I-001/handoff.md` (merged 後、I-001 の結果を参照)
- `docs/ai/plans/BATCH-WAVE0/wave-plan.md`
- `docs/ai/plans/BATCH-WAVE0/uq-decisions.md` (グループ 1, 3, 4 を特に)
- Appendix A §A.2 (Out of scope 確認用、実装禁止の型リスト)

## Start instruction

1. **前提確認**: `git log main` で I-001 が merged 済みであることを確認。
   merged でなければ `state: blocked`、`blocked_reason: "I-001 not merged"`
   で停止
2. impl worktree に cd、`status.yaml` を `state: in-progress` / `current_lane: impl`
   / `tool: codex` に更新
3. 以下のファイルを作成:
   - `packages/types/package.json`:
     - `"name": "@repo/types"` (UQ-I002-02)
     - `"version": "0.0.0"`, `"private": true`
     - `"exports": { ".": { "types": "./src/index.ts", "default": "./src/index.ts" } }`
       (barrel のみ、UQ-I002-06)
     - `"devDependencies": { "typescript": "^5.6.3" }` (**5.6 最新 patch**、
       UQ-I002-01、調査時点の実値を採用)
   - `packages/types/tsconfig.json`:
     - `"extends": "../../tsconfig.base.json"`
     - `"compilerOptions": { "composite": true, "outDir": "dist", "rootDir": "src" }`
     - `"include": ["src"]`
   - `packages/types/src/index.ts`: `export {};` 1 行のみ
   - `tsconfig.base.json` (repo root):
     ```json
     {
       "compilerOptions": {
         "strict": true,
         "noUncheckedIndexedAccess": true,
         "exactOptionalPropertyTypes": true,
         "isolatedModules": true,
         "skipLibCheck": true,
         "moduleResolution": "bundler",
         "module": "ESNext",
         "target": "ES2022",
         "esModuleInterop": true,
         "forceConsistentCasingInFileNames": true
       }
     }
     ```
   - `tsconfig.json` (repo root):
     ```json
     {
       "files": [],
       "references": [
         { "path": "packages/types" }
       ]
     }
     ```
4. root `package.json` を modify:
   - `"devDependencies": { "typescript": "^5.6.3" }` を追加
   - **`scripts` / `packageManager` / `engines.node` / `private` は触らない**
     (I-001 の内容維持)
5. **`pnpm install -w` を 1 回明示実行**し、`pnpm-lock.yaml` を初期化
   (UQ-I002-05 (b)、Anchor 5 遵守)
6. contract.md の Verification commands 1〜13 を全て実行、全 PASS を確認
7. 変更を 1 commit にまとめる。コミットメッセージ:
   `feat(types): add packages/types skeleton and tsconfig base with strict + bundler (I-002)`
8. `status.yaml` を `state: implemented`、`head_commit: <sha>`、
   `exact_next_action: "start review lane for I-002"` に更新
9. `handoff.md` を記入 (TypeScript 版、`@repo/types` 採用、install 実行ログ、
   `tsconfig.base.json` 全文要旨、次タスク I-003 への引き継ぎ)
10. review lane 起動を待機

## Stop conditions

- I-001 が merged でない (blocked に倒す)
- Appendix A §A.2 のドメイン型を書きたくなった (`Amount` / `YearMonth` 等)
  → 即 stop (Wave 1 の仕事)
- Prisma 依存を追加したくなった (Wave 2 の仕事)
- `pnpm install -w` が 2 回以上必要になった (lockfile 不整合、planning 差し戻し)
- `tsconfig.base.json` に `baseUrl` / `paths` を足したくなった (stop + review)
- root `package.json` の `scripts` を書き換えたくなった (I-006 の領分)
- `packages/types/src/index.ts` に placeholder 以上の内容を書きたくなった
- Verification commands のいずれかが PASS しない、かつ 2 回の serious attempt
  でも解消できない

停止時は `handoff.md` を作成し `status.yaml` を `blocked` に更新。
