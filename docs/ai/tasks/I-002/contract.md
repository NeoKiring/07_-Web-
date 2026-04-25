# Task Contract: I-002

## Identity
- task id: I-002
- title: packages/types skeleton + TypeScript project references base
- area: packages/types
- slug: packages-types-skeleton
- batch id: BATCH-WAVE0
- harness_version: 4.1-p0-tool-ownership

## Objective

`packages/types` を空の workspace package として作成し、strict 設定の
`tsconfig.base.json` と project references 用の root `tsconfig.json` を置く。
Appendix A §A.2 のドメイン型実装は Wave 1 の別タスクで行うため、本タスクでは
`src/index.ts` は placeholder (`export {};`) のみ。

本タスクが **初回の `pnpm install -w` を実行するタスク** となる (UQ-I002-05)。
これにより `pnpm-lock.yaml` が初期化される。以降の Wave 0 タスクはこの lock
を更新するのみ。

## Business / user value

要件 v0.2 §15.4 で「最優先・単独実行」と指定された `packages/types` の
workspace 解決経路を確立する。以降の全 package / apps が共通契約として
`@repo/types` を参照できるようになる (UQ-I002-02 確定)。
Wave 1 の型実体化タスクは、この土台の上に型ファイルを追加するだけで完結する。

## In scope

- `packages/types/package.json` 新規作成
  - `"name": "@repo/types"` (**UQ-I002-02**)
  - `"version": "0.0.0"`
  - `"private": true`
  - `"exports": { ".": { "types": "./src/index.ts", "default": "./src/index.ts" } }`
    (**barrel のみ、sub-path 禁止**、UQ-I002-06)
  - `"devDependencies": { "typescript": "5.6.x" }` (**TypeScript 5.6 最新 patch**、UQ-I002-01)
- `packages/types/tsconfig.json` 新規作成
  - `"extends": "../../tsconfig.base.json"`
  - `"compilerOptions": { "composite": true, "outDir": "dist", "rootDir": "src" }`
  - `"include": ["src"]`
- `packages/types/src/index.ts` 新規作成（`export {};` 1 行のみ）
- `tsconfig.base.json` 新規作成（repo root）、`compilerOptions` 最低限:
  - `"strict": true`
  - `"noUncheckedIndexedAccess": true`
  - `"exactOptionalPropertyTypes": true` (**UQ-I002-03**)
  - `"isolatedModules": true`
  - `"skipLibCheck": true`
  - `"moduleResolution": "bundler"` (**UQ-I002-04**)
  - `"target": "ES2022"` 以上
  - `"module": "ESNext"` (bundler moduleResolution と整合)
  - `"esModuleInterop": true`, `"forceConsistentCasingInFileNames": true`
- `tsconfig.json` 新規作成（repo root、project references の親、`"files": []`、
  `"references": [{ "path": "packages/types" }]` のみ。I-003/I-004 で追加される）
- root `package.json` への `"devDependencies": { "typescript": "5.6.x" }` 追加
  (I-001 で作った scripts 枠・`packageManager`・`engines.node` は触らない)
- `pnpm-lock.yaml` の初期生成 (**UQ-I002-05 (b) 確定**)
  - impl lane が `pnpm install -w` を **1 回明示実行**
  - CI / hook / script からの間接呼び出し禁止 (Anchor 5 遵守)

## Out of scope

- Appendix A §A.2 の全ドメイン型の実体定義
  （`Amount` / `YearMonth` / `CurrencyCode` / `Income` / `Asset` / `Liability` /
  `RepaymentSchedule` / `AssetCategory` / `LiabilityCategory` / `RepaymentMethod` /
  `CPISeries` / `CPIIndicator` / `ForexRate` / `RealValueResult` /
  `NormalizedSeries` / `ComparisonSeries` / `Granularity` / `IncomeType`）
  → Wave 1 で別タスク
- `@prisma/client/runtime/library` からの `Decimal` import、Prisma 依存追加
  → Prisma は Wave 2
- Zod スキーマ定義、`z.infer<typeof ...>` 派生
- Branded type のヘルパー関数（`toYearMonth(s: string): YearMonth` 等）
- `packages/core` / `packages/db` / `packages/ingestion` / `packages/ui` の
  tsconfig / package.json（→ I-003）
- `apps/web/tsconfig.json`（→ I-004）
- ESLint カスタムルール（`no-number-for-amount`）（→ I-006）
- ゴールデンテストフィクスチャ（→ Wave 1）
- type-only な path alias の設定（I-003 以降の package の tsconfig で設定）
- `"baseUrl"` / `"paths"` の設定 (過度に固定しない方針、Review focus)

## Touched files

以下のファイルのみ。それ以外の touch は Out of scope 違反。

- `packages/types/package.json` (new)
- `packages/types/tsconfig.json` (new)
- `packages/types/src/index.ts` (new)
- `tsconfig.base.json` (new, root)
- `tsconfig.json` (new, root)
- `package.json` (modify, root — typescript devDep 追加のみ)
- `pnpm-lock.yaml` (new — 初回生成、UQ-I002-05 (b) 確定)

## Forbidden files

- `docs/harness/**`, `AGENTS.md`, `CLAUDE.md`, `CODEX.md`, `.gtrconfig*`,
  `.claude/**`, `.codex/**`, `.agents/**`, `scripts/harness/**`,
  `.runtime/**`, `.worktrees/**`
- `docs/ai/tasks/**`（self 除く）, `docs/ai/issues/**`（self 除く）, `docs/ai/plans/**`
- I-001 で作った root ファイルの **実質**変更（`pnpm-workspace.yaml`, `.nvmrc`,
  `.gitignore`, `.editorconfig`, `.env.example`, `README.md`）
  - root `package.json` は **`devDependencies.typescript` の追加のみ**許可
- `packages/core/**`, `packages/db/**`, `packages/ingestion/**`, `packages/ui/**`
- `apps/**`
- `.github/**`, `.husky/**`, `eslint.config.*`, `.prettierrc*`, `commitlint.config.*`
- `prisma/**`（Wave 2）

## Serial-only areas touched
- yes
- details:
  - root `package.json`（**package manifest**、serial-only）
  - `pnpm-lock.yaml`（**lockfile**、serial-only、本タスクが初回生成）
  - `tsconfig.base.json`（**shared global settings**、以降すべての package が extends する）
  - `tsconfig.json`（**shared global settings**、以降すべての package を references で参照する）
  - merge order: I-001 の **after**、I-003 以降の **before**
  - Wave 0 内で並列実行しない
  - parallel exception 無し

## Verification commands

```text
# 1. 必須ファイルの存在
test -f packages/types/package.json
test -f packages/types/tsconfig.json
test -f packages/types/src/index.ts
test -f tsconfig.base.json
test -f tsconfig.json
test -f pnpm-lock.yaml

# 2. packages/types/package.json の構造
node -e "
const p = require('./packages/types/package.json');
if (!p.private) process.exit(1);
if (p.name !== '@repo/types') { console.error('name must be @repo/types, got: ' + p.name); process.exit(2); }
if (!p.devDependencies || !p.devDependencies.typescript) process.exit(3);
if (!p.exports || !p.exports['.']) { console.error('barrel exports required'); process.exit(4); }
if (p.exports['./*'] !== undefined) { console.error('sub-path exports forbidden'); process.exit(5); }
if (p.dependencies && Object.keys(p.dependencies).length > 0) { console.error('no runtime deps allowed'); process.exit(6); }
"

# 3. packages/types/tsconfig.json が base を extends
grep -q '\"extends\"' packages/types/tsconfig.json
grep -qE 'tsconfig\.base\.json' packages/types/tsconfig.json

# 4. tsconfig.base.json の strict 設定と UQ 確定値
node -e "
const t = JSON.parse(require('fs').readFileSync('tsconfig.base.json','utf8').replace(/\/\/.*\n/g,''));
const co = t.compilerOptions || {};
const required = {
  strict: true,
  noUncheckedIndexedAccess: true,
  exactOptionalPropertyTypes: true,
  isolatedModules: true,
  skipLibCheck: true,
};
for (const [k, v] of Object.entries(required)) {
  if (co[k] !== v) { console.error('must be ' + k + ': ' + v); process.exit(1); }
}
if (co.moduleResolution !== 'bundler') { console.error('moduleResolution must be bundler'); process.exit(2); }
if (!co.target || parseInt(co.target.replace(/\D/g,'')) < 2022) { console.error('target must be ES2022+'); process.exit(3); }
if (co.baseUrl || co.paths) { console.error('baseUrl/paths must not be set in base'); process.exit(4); }
"

# 5. root tsconfig.json の references に packages/types が含まれる
node -e "
const t = JSON.parse(require('fs').readFileSync('tsconfig.json','utf8').replace(/\/\/.*\n/g,''));
if (!Array.isArray(t.references) || !t.references.some(r => r.path && r.path.includes('packages/types'))) process.exit(1);
"

# 6. root package.json に typescript devDep、かつ I-001 scripts が壊れていない
node -e "
const p = require('./package.json');
if (!p.devDependencies || !p.devDependencies.typescript) process.exit(1);
if (!/^5\.6\./.test(p.devDependencies.typescript.replace(/[\^~]/, ''))) { console.error('typescript must be 5.6.x'); process.exit(2); }
if (!p.packageManager || !/^pnpm@9\./.test(p.packageManager)) { console.error('I-001 packageManager must survive'); process.exit(3); }
if (!p.engines || !p.engines.node) { console.error('I-001 engines.node must survive'); process.exit(4); }
"

# 7. packages/types の型検査が通る（空 export のみの状態で 0 exit）
pnpm -w tsc --noEmit -p packages/types

# 8. build graph の整合（project references）
pnpm -w tsc -b --dry

# 9. Out of scope 違反検知: Appendix A §A.2 の型を先行実装していないこと
! grep -REn 'export (type|interface) (Amount|YearMonth|CurrencyCode|Income|Asset|Liability|CPISeries|ForexRate|RealValueResult|NormalizedSeries|ComparisonSeries|Granularity|IncomeType|RepaymentSchedule|RepaymentMethod|AssetCategory|LiabilityCategory|CPIIndicator)\b' packages/types/src/

# 10. Prisma / Zod 依存が無いこと (Wave 2 / Wave 1 への leak 防止)
! grep -RE '@prisma/client|from "zod"' packages/types/
! node -e "const p=require('./packages/types/package.json'); const deps=Object.assign({},p.dependencies||{},p.devDependencies||{}); if(deps['@prisma/client']||deps['zod']) process.exit(1);"

# 11. ハーネス同梱ファイルに touch 無し
git diff --name-only HEAD~1 -- \
  docs/harness/ AGENTS.md CLAUDE.md CODEX.md \
  .gtrconfig.v4 .gtrconfig .claude/ .codex/ .agents/ scripts/harness/ \
  | { ! grep -q .; }

# 12. I-001 ファイル群の実質変更無し（package.json の devDep 追加のみ許可）
for f in pnpm-workspace.yaml .nvmrc .gitignore .editorconfig .env.example README.md; do
  git diff --name-only HEAD~1 -- "$f" | { ! grep -q .; }
done

# 13. ハーネス artifact validator
scripts/harness/validate-task-artifacts.sh I-002
```

## GUI verification
- required: no
- recipe path: n/a
- final frontmost validation required: no
- may be deferred by human: n/a
- 理由: skeleton のみ、GUI 非依存

## Runtime isolation
- required: no
- notes:
  - runtime process なし（pure static analysis）
  - `.runtime/allocations.json` 登録不要
  - `pnpm install -w` はネットワーク取得のみで port / user-data / log は関与しない
    (runtime allocation 不要)

## Done definition

- Verification commands 1〜13 すべて PASS
- `scripts/harness/validate-task-artifacts` が I-002 に対して PASS
- `status.yaml` state が `implemented` 以上、`exact_next_action` が review 起動指示
- `handoff.md` に以下が記録:
  - 採用 TypeScript バージョン (`^5.6.x` の最終値、UQ-I002-01)
  - 採用 package name: `@repo/types` (UQ-I002-02)
  - `exactOptionalPropertyTypes: true` / `moduleResolution: bundler` 採用
    (UQ-I002-03/04)
  - `pnpm install -w` の実行を明示的に 1 回行い `pnpm-lock.yaml` を生成した旨
    (UQ-I002-05)
  - `exports` は barrel のみ、sub-path 禁止 (UQ-I002-06)
  - `tsconfig.base.json` の最終内容の全文 or 要旨 (I-003 が extends する際の参照)
  - 次タスク I-003 で `@repo/core`, `@repo/db`, `@repo/ingestion`, `@repo/ui` に
    揃える旨
- `review.md` verdict が `PASS` / `PASS-WITH-NOTES`、Must Fix 解消
- Out of scope 違反検知コマンド（Verification 項目 9, 10）0 件
- Forbidden files に touch 無し（特にハーネス同梱 + I-001 root ファイル）

## Blocked if

- I-001 が `merged` 未到達
- Prisma 依存の要否で scope が広がりそうになった（→ Wave 2 に切り出す判断を要す、stop）
- `pnpm install -w` が失敗する (lockfile 生成失敗、ネットワーク or registry 問題)
- `tsconfig.base.json` に `exactOptionalPropertyTypes: true` を入れたら
  I-001 の `package.json` scripts stub が落ちる (後者を scope 外だがゼロ確認)

## Review focus

- **Out of scope の厳守**: Appendix A §A.2 の型が `src/` に 1 つも書かれていないこと
  （Verification 項目 9）
- **UQ 確定値の反映**: package name `@repo/types`、TypeScript `^5.6.x`、
  `moduleResolution: bundler`、`exactOptionalPropertyTypes: true`、
  `exports` barrel のみ
- **Serial-only 領域の最小化**: `tsconfig.base.json` に `paths` / `baseUrl` が
  無く、過度な制約を入れていないか
- **strict 設定の妥当性**: NFR-005 に対し十分か、Wave 1 の型実装で破綻しないか
- **Anchor 5 の遵守**: `pnpm install -w` は操作者の明示実行による 1 回のみ、
  bootstrap / husky / CI からの自動実行が入っていないか
- **I-001 への非破壊**: `packageManager` / `engines.node` / scripts が I-001
  の内容のまま、`devDependencies.typescript` のみが追加されているか
- **I-003 以降との接続**: project references の書き方が、後続で package を
  追加するだけで済む形式か

## Merge order
- before: I-003, I-004, I-005, I-006, I-007
- after: I-001
- notes:
  - I-008 は I-001 完了後に並列可、I-002 の完了は待たない
  - I-003 は I-002 の `tsconfig.base.json` に依存するため、I-002 merged 後のみ開始

## Notes for implementer
- writable lane is `impl` only
- tool ownership: default = Codex（impl）/ Claude（review）
- Prisma 依存を引き込まない。`Decimal` を書きたくなったら stop (Wave 1 の仕事)
- `src/index.ts` は `export {};` 1 行。placeholder 型を置きたくなったら stop
- `pnpm install -w` は **最大 1 回**、明示実行。CI / hook / script からの
  間接呼び出し禁止
- `tsconfig.base.json` に `paths` / `baseUrl` を足したくなったら stop して review
- package.json の `exports` は barrel のみ (`"./*"` は書かない)
- Wave 0 planning 時点の TypeScript 5.6 最新 patch を採用 (例: `^5.6.3`)

## Tool ownership preferences
- default tool owner: Codex (impl)
- review tool: Claude
- verify tool: Codex
- switch trigger: ドメイン型の実装が本タスク内で始まった場合 → 即 stop。
  `pnpm install -w` が 2 回以上呼ばれた形跡があれば handoff 経由で再検討
