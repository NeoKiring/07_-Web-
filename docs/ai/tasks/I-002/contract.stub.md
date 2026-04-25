# Task Contract: I-002

本ファイルは **stub** である。`dev-plan` で finalized に昇格する。

特記:
  Verification commands / Touched files / Forbidden files は
  要件 v0.2 + Appendix A/B のレビュー済み前提に基づく推定記述。
  planning 時に再確認すること。

## Identity
- task id: I-002
- title: packages/types skeleton + TypeScript project references base
- area: packages/types
- slug: packages-types-skeleton
- batch id: BATCH-WAVE0

## Objective

`packages/types` を空の workspace package として作成し、strict 設定の
`tsconfig.base.json` と project references 用の root `tsconfig.json` を置く。
Appendix A §A.2 のドメイン型実装は Wave 1 の別タスクで行うため、本タスクでは
`src/index.ts` は placeholder (`export {};`) のみ。

## Business / user value

要件 v0.2 §15.4 で「最優先・単独実行」と指定された `packages/types` の
workspace 解決経路を確立する。以降の全 package / apps が共通契約として
`@repo/types`（または決定された name）を参照できるようになる。
Wave 1 の型実体化タスクは、この土台の上に型ファイルを追加するだけで完結する。

## In scope

- `packages/types/package.json` 新規作成
  - `"name"`: UQ-I002-02 で決定（推奨 `@repo/types`）
  - `"version": "0.0.0"`
  - `"private": true`
  - `"exports"`: barrel のみ（推奨、UQ-I002-06）
  - `"devDependencies"`: typescript のみ
- `packages/types/tsconfig.json` 新規作成
  - `extends: "../../tsconfig.base.json"`
  - `"compilerOptions": { "composite": true, "outDir": "dist", "rootDir": "src" }`
  - `"include": ["src"]`
- `packages/types/src/index.ts` 新規作成（`export {};` のみ）
- `tsconfig.base.json` 新規作成（repo root）
- `tsconfig.json` 新規作成（repo root、project references の親）
- root `package.json` への typescript devDep 追加
- `pnpm-lock.yaml` の初期生成（UQ-I002-05 で (b) を採択した場合のみ。impl lane が
  `pnpm install -w` を 1 回明示的に実行する）

## Out of scope

- Appendix A §A.2 の全ドメイン型の実体定義
  （`Amount` / `YearMonth` / `CurrencyCode` / `Income` / `Asset` / `Liability` /
  `RepaymentSchedule` / `AssetCategory` / `LiabilityCategory` / `RepaymentMethod` /
  `CPISeries` / `CPIIndicator` / `ForexRate` / `RealValueResult` /
  `NormalizedSeries` / `ComparisonSeries` / `Granularity` / `IncomeType`）
  → Wave 1 で別タスクとして処理
- `@prisma/client/runtime/library` からの `Decimal` import の実装や
  Prisma dependency の追加（Prisma は Wave 2）
- Zod スキーマ定義、`z.infer<typeof ...>` 派生
- Branded type のヘルパー関数（`toYearMonth(s: string): YearMonth` 等）
- `packages/core` / `packages/db` / `packages/ingestion` / `packages/ui` の
  tsconfig / package.json（→ I-003）
- `apps/web/tsconfig.json`（→ I-004）
- ESLint カスタムルール（`no-number-for-amount`）（→ I-006）
- ゴールデンテストフィクスチャ（→ Wave 1）
- type-only な path alias の設定（I-003 以降の package の tsconfig で設定）

## Touched files

以下のファイルのみ。それ以外の touch は Out of scope 違反。

- `packages/types/package.json` (new)
- `packages/types/tsconfig.json` (new)
- `packages/types/src/index.ts` (new)
- `tsconfig.base.json` (new, root)
- `tsconfig.json` (new, root)
- `package.json` (modify, root — typescript devDep 追加のみ)
- `pnpm-lock.yaml` (new, 条件付き — UQ-I002-05 で (b) を採った場合のみ)

## Forbidden files

- `docs/harness/**`, `AGENTS.md`, `CLAUDE.md`, `CODEX.md`, `.gtrconfig.v4`,
  `.claude/**`, `.codex/**`, `.agents/**`, `scripts/harness/**`,
  `.runtime/**`, `.worktrees/**`
- `docs/ai/tasks/**`（self を除く）
- `docs/ai/issues/**`（self を除く）
- `docs/ai/plans/**`
- I-001 で作った root ファイル群の上書き（`pnpm-workspace.yaml`, `.nvmrc`,
  `.gitignore`, `.editorconfig`, `.env.example`, `README.md`）
  ただし root `package.json` は I-001 の `scripts` 枠に触れず、
  `devDependencies.typescript` の追加のみに限定する
- `packages/core/**`, `packages/db/**`, `packages/ingestion/**`, `packages/ui/**`
- `apps/**`
- `.github/**`, `.husky/**`, `eslint.config.*`, `.prettierrc*`, `commitlint.config.*`
- `prisma/**`（Wave 2）

## Serial-only areas touched
- yes
- details:
  - root `package.json`（**package manifest**、serial-only）
  - `pnpm-lock.yaml`（**lockfile**、serial-only、触る条件付き）
  - `tsconfig.base.json`（**shared global settings**、以降すべての package が extends する）
  - `tsconfig.json`（**shared global settings**、以降すべての package を references で参照する）
  - merge order: I-001 の **after**、I-003 以降の **before**
  - Wave 0 内で並列実行しない（I-001 と同じく serial path に載る）
  - parallel exception は無し（human approval 不要）

## Verification commands

```text
# 推定。レビュー済み前提。planning 時に pnpm / TS 版確定後に再確認すること。

# 1. 必須ファイルの存在
test -f packages/types/package.json
test -f packages/types/tsconfig.json
test -f packages/types/src/index.ts
test -f tsconfig.base.json
test -f tsconfig.json

# 2. packages/types/package.json の構造
node -e "const p=require('./packages/types/package.json'); if(!p.private) process.exit(1); if(!p.name || !p.name.includes('/')) process.exit(2); if(!p.devDependencies || !p.devDependencies.typescript) process.exit(3);"

# 3. packages/types/tsconfig.json が base を extends している
grep -q '"extends"' packages/types/tsconfig.json
grep -qE 'tsconfig\.base\.json' packages/types/tsconfig.json

# 4. tsconfig.base.json の strict 設定
node -e "
const t = JSON.parse(require('fs').readFileSync('tsconfig.base.json','utf8').replace(/\/\/.*\n/g,''));
const co = t.compilerOptions || {};
const required = ['strict','noUncheckedIndexedAccess','isolatedModules','skipLibCheck'];
for (const k of required) { if (co[k] !== true) { console.error('missing '+k); process.exit(1); } }
"

# 5. root tsconfig.json の references に packages/types が含まれる
node -e "
const t = JSON.parse(require('fs').readFileSync('tsconfig.json','utf8').replace(/\/\/.*\n/g,''));
if (!Array.isArray(t.references) || !t.references.some(r => r.path && r.path.includes('packages/types'))) process.exit(1);
"

# 6. root package.json に typescript devDep が入っている（I-001 の scripts を壊していない）
node -e "
const p = require('./package.json');
if (!p.devDependencies || !p.devDependencies.typescript) process.exit(1);
"

# 7. packages/types の型検査が通る（空 export のみの状態で 0 exit）
#    impl lane が pnpm install -w を実行した後であること
pnpm -w tsc --noEmit -p packages/types

# 8. build graph の整合（project references）
pnpm -w tsc -b --dry

# 9. ハーネス artifact validator
scripts/harness/validate-task-artifacts.sh I-002     # Linux/mac
# または pwsh scripts/harness/validate-task-artifacts.ps1 -TaskId I-002

# 10. Out of scope 違反検知: Appendix A §A.2 の型を先行実装していないこと
!  grep -RE 'export (type|interface) (Amount|YearMonth|CurrencyCode|Income|Asset|Liability|CPISeries|ForexRate|RealValueResult|NormalizedSeries|ComparisonSeries|Granularity|IncomeType|RepaymentSchedule|RepaymentMethod|AssetCategory|LiabilityCategory|CPIIndicator)\\b' packages/types/src
```

## GUI verification
- required: no
- recipe path: n/a
- final frontmost validation required: no
- may be deferred by human: n/a
- 理由: skeleton のみ。GUI 非依存。

## Runtime isolation
- required: no
- notes:
  - runtime process なし（pure static analysis）
  - `.runtime/allocations.json` 登録不要
  - `pnpm install` を 1 回走らせる場合も runtime allocation は不要
    （ネットワーク取得のみで port / user-data / log は関与しない）

## Done definition

- Verification commands 1〜9 のうち 1〜6 は必達。7〜8 は UQ-I002-05 で (b) を
  採択した場合に必達、(a) の場合は planning で代替条件を定義する
- `scripts/harness/validate-task-artifacts` が I-002 に対して PASS
- `status.yaml` state が `implemented` 以上、`exact_next_action` が review 起動指示
- `handoff.md` に以下が記録:
  - typescript 採用版（UQ-I002-01 最終値）
  - package name 規約（UQ-I002-02 最終値）
  - `exactOptionalPropertyTypes` / `moduleResolution` の採用（UQ-I002-03/04）
  - `pnpm install` を走らせたか否か（UQ-I002-05 最終値）
  - `exports` 方針（UQ-I002-06）
  - 次タスク I-003 で再利用できるよう、`tsconfig.base.json` の最終内容を記載
- `review.md` verdict が `PASS` / `PASS-WITH-NOTES`、Must Fix 解消済み
- Out of scope 違反検知コマンド（Verification 項目 10）が 0 件
- `pnpm-lock.yaml` 以外の Forbidden files に touch なし

## Blocked if

- UQ-I002-01〜04 いずれかが planning 時未決
- UQ-I002-05 の方針（operator の install タイミング）が未決
- Prisma 依存の要否で scope が広がりそうになった（→ Wave 2 に切り出す判断を要す）
- I-001 がまだ `merged` に到達していない（I-002 は I-001 の after）

## Review focus

- **Out of scope の厳守**: Appendix A §A.2 の型が `src/` に 1 つも書かれていないこと
  （Verification 項目 10）
- **Serial-only 領域の最小化**: `tsconfig.base.json` が過度な paths / baseUrl
  設定を含んでいないか（後続 package の解決を固定しすぎないこと）
- **strict 設定の妥当性**: NFR-005 に対し十分か、`exactOptionalPropertyTypes`
  が Wave 1 の型実装で破綻しないか
- **Anchor 5 の遵守**: `pnpm install` は操作者の明示実行による 1 回のみ、
  bootstrap / husky / CI からの自動実行が入っていないか
- **I-003 以降との接続**: project references の書き方が、後続で package を
  追加するだけで済む形式になっているか

## Merge order
- before: I-003, I-004, I-005, I-006, I-007
- after: I-001
- notes:
  - I-008（ドキュメント）は I-001 完了後に並列可、I-002 の完了は待たない
  - I-003 は I-002 の `tsconfig.base.json` に依存するため、I-002 完了後のみ開始

## Notes for implementer
- writable lane is `impl` only
- tool ownership: default = Codex（impl）/ Claude（review）
- Prisma 依存を引き込まないこと。`Decimal` を書きたくなったら stop。Wave 1 の仕事。
- `src/index.ts` は `export {};` 1 行で良い。placeholder 型を置きたくなったら stop。
- `pnpm install` は最大 1 回、explicit に実行。CI / hook / script からの間接呼び出し禁止。
- `tsconfig.base.json` に `paths` / `baseUrl` を足したくなったら stop して review。
