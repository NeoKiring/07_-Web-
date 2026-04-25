# Task Contract: I-001

## Identity
- task id: I-001
- title: monorepo skeleton (pnpm workspace + root configs)
- area: infra/monorepo
- slug: monorepo-skeleton
- batch id: BATCH-WAVE0
- harness_version: 4.1-p0-tool-ownership

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
  - `package.json`: `"private": true` / `"packageManager": "pnpm@9.x.y"` (**pnpm 9 最新 patch**、UQ-I001-01)
    / `"engines": { "node": ">=22.0.0 <23.0.0" }` (**Node 22 LTS**、UQ-I001-02)
    / `"scripts"` は `build`, `test`, `lint`, `typecheck` の空 stub (中身は no-op、I-006/I-007 で埋める)
  - `.nvmrc`: Node 22 LTS (例: `22.11.0` など最新 patch 値、`engines.node` と矛盾しない)
  - `.gitignore`: NFR-003 最小セット + ハーネス生成物 + `.vscode/` (UQ-I001-04)
  - `.editorconfig`: UTF-8 / LF / `insert_final_newline = true` / `trim_trailing_whitespace = true`
  - `.env.example`: `ESTAT_API_KEY=` / `DATABASE_URL=` の placeholder、値は空
  - `README.md`: 日本語 (UQ-I001-05)、プロジェクト navigational、v0.2 と Appendix A/B への相対リンク
- 上記 7 ファイルに閉じた commit 1 本

## Out of scope

- `apps/web` 配下のいかなる変更（→ I-004）
- `packages/*` 配下のいかなる変更（→ I-002, I-003）
- `tsconfig.base.json` / TypeScript project references（→ I-002）
- ESLint / Prettier / husky / lint-staged / commitlint（→ I-006）
- GitHub Actions workflow / CI（→ I-007）
- Prisma / SQLite / `prisma/schema.prisma` 生成（→ Wave 2）
- shadcn/ui 初期化 / Tailwind v4 導入（→ I-005）
- **依存パッケージの実 install および `pnpm-lock.yaml` の生成**
  （Anchor 5 遵守。UQ-I001-03 確定: I-001 の Done definition に install を含めない。
  `pnpm-lock.yaml` は **I-002** の impl lane が `pnpm install -w` を 1 回明示実行して初期化する）
- プロジェクト固有 supplement（`docs/ai/project/CLAUDE.project.md`）（→ I-008）
- ハーネス同梱ファイル（`docs/harness/**`, `AGENTS.md`, `CLAUDE.md`, `CODEX.md`,
  `.gtrconfig.v4`, `.claude/**`, `.codex/**`, `.agents/**`）の改変
- `.vscode/extensions.json` の opt-in (`!.vscode/extensions.json`) は **I-006** の領分。
  本タスクでは `.vscode/` を一括 ignore に倒す

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
- `.gtrconfig.v4` / `.gtrconfig`（ハーネス設定）
- `.claude/**`, `.codex/**`, `.agents/**`（エージェント設定、serial-only）
- `scripts/harness/**`（ハーネススクリプト、serial-only）
- `.runtime/**`（runtime allocation registry、ハーネス管理）
- `.worktrees/**`（lane worktree、ハーネス管理）
- `apps/**`, `packages/**`, `tests/**`（他 Wave 0 タスクの領分）
- `tsconfig*.json`（I-002 の領分）
- `eslint.config.*`, `.prettierrc*`, `.husky/**`, `commitlint.config.*`,
  `lint-staged.config.*`（I-006）
- `.github/**`（I-007）
- `pnpm-lock.yaml`（本タスクでは生成禁止、I-002 が初期化）

## Serial-only areas touched
- yes
- details:
  - root `package.json` は **package manifest**（FOUNDATION Anchor 4 /
    serial-only-areas policy）
  - `pnpm-workspace.yaml` は **app bootstrap / plugin bootstrap** に相当
  - `.gitignore` は **shared global settings** に相当
  - これら 3 種が同一 commit に載るため、Wave 0 の他タスクとは並列実行しない。
    Wave 0 内の merge order の先頭（merge_order_position: 1）に位置づける
  - I-008 は `docs/ai/project/**` のみを触り serial-only 領域に非依存のため、
    I-001 merged 後に並列起動可（queue.json 参照）
  - parallel exception は発生しない（human approval 不要）

## Verification commands

```text
# 1. 必須ファイルの存在
test -f pnpm-workspace.yaml
test -f package.json
test -f .nvmrc
test -f .gitignore
test -f .editorconfig
test -f .env.example
test -f README.md

# 2. package.json の構造チェック
node -e "
const p = require('./package.json');
if (!p.private) { console.error('package.json must be private'); process.exit(1); }
if (!p.packageManager || !/^pnpm@9\./.test(p.packageManager)) {
  console.error('packageManager must be pnpm@9.x.y, got: ' + p.packageManager);
  process.exit(2);
}
if (!p.engines || !p.engines.node || !/22/.test(p.engines.node)) {
  console.error('engines.node must pin Node 22 LTS');
  process.exit(3);
}
"

# 3. pnpm-workspace.yaml に apps と packages が含まれる
grep -qE '(apps/\*|\"apps/\*\")' pnpm-workspace.yaml
grep -qE '(packages/\*|\"packages/\*\")' pnpm-workspace.yaml

# 4. .gitignore が NFR-003 最小セット + ハーネス生成物 + .vscode を含む
grep -qE '^node_modules(/|$)' .gitignore
grep -qE '^\.env(\b|$)' .gitignore
grep -qE 'prisma/.*\.db' .gitignore
grep -qE '^backups/' .gitignore
grep -qE '^\.runtime/' .gitignore
grep -qE '^\.worktrees/' .gitignore
grep -qE '^\.vscode/' .gitignore
grep -qE '^logs/' .gitignore
grep -qE '^coverage/' .gitignore

# 5. .nvmrc が Node 22 LTS を示し engines.node と整合
nvmrc_version=$(cat .nvmrc)
echo "$nvmrc_version" | grep -qE '^(v?22\.)'
node -e "
const p = require('./package.json');
const nvmrc = require('fs').readFileSync('.nvmrc','utf8').trim().replace(/^v/, '');
const major = nvmrc.split('.')[0];
if (major !== '22') {
  console.error('.nvmrc major must be 22, got: ' + major);
  process.exit(1);
}
"

# 6. .env.example に必要な placeholder
grep -qE '^ESTAT_API_KEY=' .env.example
grep -qE '^DATABASE_URL=' .env.example

# 7. README.md が日本語で navigational
grep -qE '資産.*収入|インフレ|Phase A|Phase B' README.md    # 日本語キーワード
grep -qE 'requirements_v0\.2' README.md                          # 要件定義への link

# 8. Anchor 5 の遵守: pnpm-lock.yaml を本 commit で作っていない
! test -f pnpm-lock.yaml
! git diff --cached --name-only | grep -qE '^pnpm-lock\.yaml$'

# 9. ハーネス同梱ファイルに touch 無し
git diff --name-only HEAD~1 -- \
  docs/harness/ AGENTS.md CLAUDE.md CODEX.md \
  .gtrconfig.v4 .gtrconfig .claude/ .codex/ .agents/ scripts/harness/ \
  | { ! grep -q .; }

# 10. ハーネス artifact validator の通過
scripts/harness/validate-task-artifacts.sh I-001     # Linux/mac
# または
# pwsh scripts/harness/validate-task-artifacts.ps1 -TaskId I-001     # Windows
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

- 7 ファイル全てが存在し、上記 Verification commands 1〜10 すべてが成功
- `scripts/harness/validate-task-artifacts` が I-001 に対して PASS
- `status.yaml` の state が `implemented` 以上、`exact_next_action` が review 起動指示
- `handoff.md` に以下が記録:
  - 採用 pnpm バージョン (`packageManager` 宣言の最終値)
  - 採用 Node LTS (`.nvmrc` と `engines.node` の最終値)
  - `pnpm-lock.yaml` を I-002 で生成する方針確認 (UQ-I001-03)
  - `.vscode/` を一括 ignore、`extensions.json` opt-in は I-006 に委ねる旨 (UQ-I001-04)
  - README 日本語方針 (UQ-I001-05)
  - 次タスク (I-002) への影響: `tsconfig.base.json` は I-002 で I-001 成果を
    前提に追加、`pnpm install -w` は I-002 が初実行
- `review.md` verdict が `PASS` / `PASS-WITH-NOTES`、Must Fix 未解消なし
- ハーネス同梱ファイルが一切変更されていない（Forbidden files 準拠）
- `pnpm-lock.yaml` が生成されていない (Anchor 5 遵守)

## Blocked if

- 要件 v0.2 §11 の技術制約に後方不整合な提案がレビューで出た（human decision 必須）
- ハーネス bundle 内のファイルを touch する必要が出た（role / ownership 問題、停止して handoff）
- pnpm 9.x の最新 patch が調査時点で不明確、または Node 22 LTS の安定 patch が
  当該週の NPM/Node リリースで判然としない (operator に確認)

## Review focus

- **Anchor 4 の遵守**: touched files が 7 ファイルに収まり、他タスクの領分を侵していないか
- **Anchor 5 の遵守**: `pnpm install` が走っておらず、`pnpm-lock.yaml` が commit に含まれていないか
- **NFR-003 の遵守**: `.gitignore` が個人データ混入を防ぐ最小集合を満たすか
  （`prisma/dev.db`, `.env*`, `backups/`, `logs/`, `.runtime/`, `.worktrees/`）
- **NFR-008 の遵守**: `.nvmrc` と `engines.node` の値が両方とも Node 22 LTS で
  矛盾しないか
- **UQ 解消値の反映**: `packageManager` が `pnpm@9.x.y` 形式か、README が日本語か、
  `.vscode/` が ignore に入っているか
- Wave 0 の他タスクから `packageManager` / `engines.node` を参照して問題ない形か
- I-002 以降で `pnpm install -w` を初実行する前提の動線が handoff に明記されているか

## Merge order
- before: I-002, I-003, I-004, I-005, I-006, I-007
- after: (none) — Wave 0 の先頭タスク
- notes:
  - I-008 は I-001 merged 後に並列可（queue.json の `parallelizable_with_after_merge` 参照）
  - I-001 が merged になるまで他 Wave 0 タスクの impl lane は起動しない
  - 直列チェーンの起点として、ここで Anchor 4/5/8 を全て成立させる

## Notes for implementer
- writable lane is `impl` only
- tool ownership: default = Codex（impl）/ Claude（review）
- 7 ファイル以外を touch してはならない。必要と感じたら stop して handoff
- **`pnpm install` を実行しない** (UQ-I001-03 確定、I-002 の impl lane が初実行)
- `packageManager` は `pnpm@9.x.y` 形式 (Wave 0 planning 時点の最新 9 系 patch)
- `.nvmrc` と `engines.node` は Node 22 LTS を指す。両者で major version を揃える
- `.gitignore` の順序は「生成物 → 環境 → 個人データ → IDE」の順を推奨、
  `.vscode/` は IDE セクションに入れる
- `README.md` は **日本語**、navigational に留め、設計や仕様を書き込まない
  （それらは requirements_v0.2.md / Appendix A / Appendix B の仕事）
- `scripts` は no-op でよい (例: `"lint": "echo 'lint stub, implemented in I-006'"`)。
  中身を書いたら I-006 侵犯となり stop

## Tool ownership preferences
- default tool owner: Codex (impl)
- review tool: Claude
- verify tool: Codex
- switch trigger: Codex が scope 拡張を 2 度試みた場合、または 7 ファイル以外へ
  touch した diff が発生した場合は `handoff.md` 経由で Claude impl に reassignment 検討
