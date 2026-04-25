# Task Contract: I-001

本ファイルは **stub**（planning 前のたたき台）である。
`dev-plan` skill による planning 完了時に `contract.md`（finalized）へ昇格する。
stub と finalized の差分は、unresolved.md の各 UQ が解消されているか否かである。

特記:
  Verification commands / Touched files / Forbidden files は
  要件 v0.2 + Appendix A/B の「レビュー済み前提」に基づく推定記述である。
  planning 時にオペレータが再確認することを前提とする。

## Identity
- task id: I-001
- title: monorepo skeleton (pnpm workspace + root configs)
- area: infra/monorepo
- slug: monorepo-skeleton
- batch id: BATCH-WAVE0

## Objective

pnpm monorepo の root レイヤに、以降の全 Wave タスクが依存してよい
「空の workspace 骨格」を 1 commit で確定する。対象は `pnpm-workspace.yaml`、
root `package.json`、`.gitignore`、`.editorconfig`、`.nvmrc`、`.env.example`、
`README.md` の 7 ファイル。`apps/` / `packages/` の中身は本タスクで作らない。

## Business / user value

Wave 1 以降のすべての実装・レビュー・検証・GUI lane が、同じ pnpm workspace
前提・同じ Node バージョン前提・同じ `.gitignore` 前提で動ける状態になる。
これが無いと、AI 主体開発下で各 impl lane が個別に root manifest を触り
serial-only area を事故で壊すリスクが高い。

## In scope

- `pnpm-workspace.yaml` の新規作成（`apps/*`, `packages/*` を含める）
- 以下の root 直下ファイルの新規作成:
  - `package.json`（private:true、`packageManager`、`engines.node`、空または stub の scripts）
  - `.nvmrc`
  - `.gitignore`（NFR-003 の最小セット + ハーネス生成物）
  - `.editorconfig`（UTF-8 / LF / 末尾改行）
  - `.env.example`（`ESTAT_API_KEY=` / `DATABASE_URL=` の placeholder、値は空）
  - `README.md`（プロジェクト navigational、v0.2 と Appendix A/B への相対リンク）
- 上記 7 ファイルに閉じた commit 1 本

## Out of scope

- `apps/web` 配下のいかなる変更（→ I-004）
- `packages/*` 配下のいかなる変更（→ I-002, I-003）
- `tsconfig.base.json` / TypeScript project references（→ I-002）
- ESLint / Prettier / husky / lint-staged / commitlint（→ I-006）
- GitHub Actions workflow / CI（→ I-007）
- Prisma / SQLite / `prisma/schema.prisma` 生成（→ Wave 2）
- shadcn/ui 初期化 / Tailwind v4 導入（→ I-005）
- 依存パッケージの実 install および `pnpm-lock.yaml` の生成
  （Anchor 5 により本タスクでは実行しない、UQ-I001-03 参照）
- プロジェクト固有 supplement（`docs/ai/project/CLAUDE.project.md`）（→ I-008）
- ハーネス同梱ファイル（`docs/harness/**`, `AGENTS.md`, `CLAUDE.md`, `CODEX.md`,
  `.gtrconfig.v4`, `.claude/**`, `.codex/**`, `.agents/**`）の改変

## Touched files

以下 7 ファイルのみ。それ以外への touch は Out of scope 違反と扱う。

- `pnpm-workspace.yaml` (new)
- `package.json` (new)
- `.nvmrc` (new)
- `.gitignore` (new)
- `.editorconfig` (new)
- `.env.example` (new)
- `README.md` (new or minimal init)

## Forbidden files

以下は本タスクで編集してはならない。編集が必要と感じた時点で stop し、
scope 再判定を行う（`CLAUDE.md` Stop conditions）。

- `docs/harness/**`（ハーネス設計アンカー。serial-only）
- `docs/ai/tasks/**`（self 以外）
- `docs/ai/issues/**`（self 以外）
- `docs/ai/plans/**`（dev-plan が触る領域）
- `AGENTS.md`, `CLAUDE.md`, `CODEX.md`（role / ownership 定義、serial-only）
- `.gtrconfig.v4`（ハーネス設定）
- `.claude/**`, `.codex/**`, `.agents/**`（エージェント設定、serial-only）
- `scripts/harness/**`（ハーネススクリプト、serial-only）
- `.runtime/**`（runtime allocation registry、ハーネス管理）
- `.worktrees/**`（lane worktree、ハーネス管理）
- `apps/**`, `packages/**`, `tests/**`（他 Wave 0 タスクの領分）
- `tsconfig*.json`（I-002 の領分）
- `eslint.config.*`, `.prettierrc*`, `.husky/**`, `commitlint.config.*`（I-006）
- `.github/**`（I-007）

## Serial-only areas touched
- yes
- details:
  - root `package.json` は **package manifest**（FOUNDATION Anchor 4 /
    serial-only-areas policy）
  - `pnpm-workspace.yaml` は **app bootstrap / plugin bootstrap** に相当
  - `.gitignore` は **shared global settings** に相当
  - これら 3 種が同一 commit に載るため、**Wave 0 の他タスクとは並列実行しない**。
    Wave 0 内の merge order の先頭（before: I-002, I-003, I-004, I-005, I-006, I-007）
    に位置づける。I-008 はドキュメントのみなので I-001 完了後に論理並列可だが、
    Wave 0 の最初に I-001 を serial で閉じてから進めるのが推奨。
  - parallel exception の発生余地は無い（human approval は不要と判定）

## Verification commands

```text
# 推定。レビュー済み前提（要件 v0.2 §11, §15 / Appendix A §A.7）。
# planning 時に pnpm / Node の具体 version 確定と合わせて再確認すること。

# 1. 必須ファイルの存在
test -f pnpm-workspace.yaml
test -f package.json
test -f .nvmrc
test -f .gitignore
test -f .editorconfig
test -f .env.example
test -f README.md

# 2. package.json の構造チェック（jq 前提、CI 環境で jq が入る保証は I-007 で用意）
node -e "const p=require('./package.json'); if(!p.private) process.exit(1); if(!p.packageManager || !p.packageManager.startsWith('pnpm@')) process.exit(2); if(!p.engines || !p.engines.node) process.exit(3);"

# 3. pnpm-workspace.yaml に apps と packages が含まれる
grep -q '"apps/\*"\|apps/\*' pnpm-workspace.yaml
grep -q '"packages/\*"\|packages/\*' pnpm-workspace.yaml

# 4. .gitignore が NFR-003 の最小セットを含む
grep -qE '^node_modules(/|$)' .gitignore
grep -qE '^\.env(\b|$)' .gitignore
grep -qE 'prisma/.*\.db' .gitignore
grep -qE '^backups/' .gitignore
grep -qE '^\.runtime/' .gitignore
grep -qE '^\.worktrees/' .gitignore

# 5. pnpm と Node のバージョン宣言が .nvmrc / package.json で矛盾していない
#    （planning 時に具体値決定後に埋めなおす、stub 段階では存在確認のみ）
test -s .nvmrc
node -e "const p=require('./package.json'); if(!p.engines.node) process.exit(1);"

# 6. ハーネス artifact validator の通過
scripts/harness/validate-task-artifacts.sh I-001     # Linux/mac
# または
# pwsh scripts/harness/validate-task-artifacts.ps1 -TaskId I-001     # Windows

# 7. Anchor 5 の遵守: pnpm-lock.yaml を本 commit で作っていない
! git diff --cached --name-only | grep -qE '^pnpm-lock\.yaml$'
```

## GUI verification
- required: no
- recipe path: n/a
- final frontmost validation required: no
- may be deferred by human: n/a
- 理由: Wave 0 の skeleton は GUI を起動しない。NFR-001 の性能検証対象でもない。

## Runtime isolation
- required: no
- notes:
  - 本タスクは runtime process を一切起動しない（Anchor 3 の「pure docs / static
    analysis」判定に相当）
  - `.runtime/allocations.json` への登録は不要
  - bootstrap を呼ぶ場合も `-PrepareRuntime` / `prepare_runtime=true` は付けない

## Done definition

- 7 ファイル全てが存在し、上記 Verification commands のうち 1〜5 と 7 が全て成功
- `scripts/harness/validate-task-artifacts` が I-001 に対して PASS
- `status.yaml` の state が `implemented` 以上、`exact_next_action` が review 起動指示
- `handoff.md` に以下が記録されている:
  - pnpm と Node の採用バージョン（最終確定値）
  - UQ-I001-01〜05 の決着
  - 次タスク（I-002）への影響（`tsconfig.base.json` は I-002 で I-001 成果を前提に追加する旨）
- `review.md` verdict が `PASS` または `PASS-WITH-NOTES`
- Must Fix 未解消なし
- ハーネス同梱ファイルが一切変更されていない（Forbidden files 準拠）

## Blocked if

- UQ-I001-01（pnpm 版）または UQ-I001-02（Node 版）が planning 時点で未決
- UQ-I001-03 の install 運用方針が未決
- 要件 v0.2 §11 の技術制約に後方不整合な提案がレビューで出た（human decision 必須）
- ハーネス bundle 内のファイルを touch する必要が出た（role / ownership 問題、停止して handoff）

## Review focus

- **Anchor 4 の遵守**: touched files が 7 ファイルに収まり、他タスクの領分を侵していないか
- **Anchor 5 の遵守**: `pnpm install` が走っておらず、`pnpm-lock.yaml` が commit に含まれていないか
- **NFR-003 の遵守**: `.gitignore` が個人データ混入を防ぐ最小集合を満たすか
  （`prisma/dev.db`, `.env*`, `backups/`, `logs/`）
- **NFR-008 の遵守**: Node/pnpm の宣言が LTS に合致しているか、`.nvmrc` と `engines.node` が矛盾しないか
- Wave 0 の他タスクから `packageManager` / `engines.node` を参照して問題ない形か
  （I-002 以降に `pnpm-lock.yaml` を初期化させる場合の動線が書かれているか）

## Merge order
- before: I-002, I-003, I-004, I-005, I-006, I-007
- after: (none) — Wave 0 の先頭タスク
- notes:
  - I-008 は論理的に並列可だがドキュメント単独タスクのため、planning 時に
    「I-001 完了後に並列可」と queue に明記する
  - I-001 が merged になるまで他 Wave 0 タスクの impl lane は起動しない

## Notes for implementer
- writable lane is `impl` only
- tool ownership: default = Codex（impl）/ Claude（review）
- 7 ファイル以外を touch してはならない。必要と感じたら stop して handoff
- `pnpm install` を実行しない（UQ-I001-03 に従って操作者が別タイミングで明示実行）
- `.gitignore` の順序は「生成物 → 環境 → 個人データ → IDE」の順を推奨
- README.md は navigational に留め、設計や仕様を書き込まない
  （それらは requirements_v0.2.md / Appendix A / Appendix B の仕事）
