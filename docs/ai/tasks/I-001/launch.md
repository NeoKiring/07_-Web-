# Launch: I-001 impl

## Lane identity
- task id: I-001
- lane: impl
- tool: Codex
- writable: yes

## Branch / commit target
- implementation branch: `ai/infra/monorepo/I-001-monorepo-skeleton`
- target commit for inspection lanes: (to be set by impl after first commit)

## Worktree
- path: `.worktrees/I-001__impl`
- create command (Linux/mac):
  ```bash
  scripts/harness/new-impl-lane.sh I-001 infra/monorepo monorepo-skeleton main
  ```
- create command (Windows):
  ```powershell
  pwsh scripts/harness/new-impl-lane.ps1 -TaskId I-001 -Area infra/monorepo -Slug monorepo-skeleton -BaseBranch main
  ```

## Session name
`[I-001][impl][codex]`

## Read first
- `docs/harness/FOUNDATION.md` (Anchors 1-8、特に Anchor 4/5)
- `AGENTS.md` (Lane model, Parallelism policy)
- `CODEX.md` (impl role, stop conditions)
- `docs/ai/tasks/I-001/contract.md` (本タスク contract、finalized)
- `docs/ai/tasks/I-001/status.yaml`
- `docs/ai/plans/BATCH-WAVE0/wave-plan.md` (Wave 0 全体像)
- `docs/ai/plans/BATCH-WAVE0/uq-decisions.md` (UQ 確定値、グループ 1+4 を特に)
- `requirements_v0.2.md` §11, §15.1, §15.2, NFR-003, NFR-005, NFR-008

## Start instruction

1. impl worktree (`.worktrees/I-001__impl`) に cd する
2. `status.yaml` の `state` を `in-progress`、`current_lane: impl`、`tool: codex` に更新
3. 以下 7 ファイルを contract.md の In scope どおり作成する:
   - `pnpm-workspace.yaml`: `packages` に `apps/*`, `packages/*` を含める
   - `package.json`: `private: true` / `packageManager: "pnpm@9.x.y"` (最新 patch) /
     `engines.node: ">=22.0.0 <23.0.0"` / `scripts`: `build`/`test`/`lint`/`typecheck`
     の no-op stub (例: `"lint": "echo 'lint stub, implemented in I-006'"`)
   - `.nvmrc`: Node 22 LTS の最新 patch (例: `22.11.0`)
   - `.gitignore`: 
     - `node_modules/`, `.pnpm-store/`, `.next/`, `dist/`, `build/`, `coverage/`
     - `.env`, `.env.*.local`, `.env.local`
     - `prisma/dev.db`, `prisma/*.db-journal`
     - `backups/`, `logs/`
     - `.runtime/`, `.worktrees/`
     - `.DS_Store`, `Thumbs.db`
     - `.vscode/` (I-006 で `!.vscode/extensions.json` が追加される)
   - `.editorconfig`: UTF-8 / LF / `insert_final_newline = true` /
     `trim_trailing_whitespace = true`
   - `.env.example`: `ESTAT_API_KEY=`, `DATABASE_URL=` の placeholder (値は空)
   - `README.md`: 日本語、プロジェクト名 + Phase A/B 概要 1 段落 + pnpm setup
     の短い案内 + 要件定義 / Appendix A / Appendix B への相対リンク
4. **`pnpm install` を実行しない**。`pnpm-lock.yaml` を作らない (UQ-I001-03 確定)
5. ハーネス同梱ファイル (`docs/harness/**`, AGENTS.md, CLAUDE.md, CODEX.md,
   `.gtrconfig*`, `.claude/**`, `.codex/**`, `.agents/**`, `scripts/harness/**`)
   を一切 touch しない
6. contract.md の Verification commands 1〜10 を全て実行し、全 PASS を確認
7. 変更を 1 commit にまとめる。コミットメッセージ例:
   `chore(infra): add pnpm monorepo skeleton and root configs (I-001)`
   - scope は `infra` (I-006 で commitlint 有効化後も通る、先取りで conventional commit を踏襲)
8. `status.yaml` を `state: implemented`、`head_commit: <sha>`、
   `exact_next_action: "start review lane for I-001"` に更新
9. `handoff.md` を contract.md の Done definition の handoff 項目に沿って記入
10. review lane 起動を待機 (Claude が担当)

## Stop conditions

以下が発生したら停止し handoff を書く:

- 7 ファイル以外を touch する必要が出た
- `pnpm install` を走らせたくなった、または `pnpm-lock.yaml` が生成された
- ハーネス同梱ファイルを編集する必要が出た
- `scripts` stub の中身を書きたくなった (I-006 の領分)
- `tsconfig.base.json` を作りたくなった (I-002 の領分)
- UQ-I001-01 の pnpm 9 最新 patch、または UQ-I001-02 の Node 22 LTS 安定 patch が
  当該週の NPM / Node リリースで判然としない
- Verification commands のいずれかが PASS しない、かつ 2 回の serious attempt
  でも解消できない

停止時は `handoff.md` を作成し、`status.yaml` の `state` を `blocked` に
更新、`blocked_reason` を記載する。
