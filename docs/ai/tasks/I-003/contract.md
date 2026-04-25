# Task Contract: I-003

## Identity
- task id: I-003
- title: packages/{core,db,ingestion,ui} skeleton (rest of workspace packages)
- area: packages/*
- slug: packages-rest-skeleton
- batch id: BATCH-WAVE0
- harness_version: 4.1-p0-tool-ownership

## Objective

`packages/core`, `packages/db`, `packages/ingestion`, `packages/ui` の 4 パッケージを、
I-002 で整えた `tsconfig.base.json` / root `tsconfig.json` に乗る形で、
空骨子としてまとめて追加する。実装は一切含めない。

本タスクで **shadcn プリミティブは `apps/web/components/ui/` 側に置き**、
`packages/ui` は Appendix B §B.4 の `charts/theme.ts` + Recharts 共通ラッパー等
(app 非依存の再利用部品) のみを持たせる方針を確定する (**UQ-I003-05 (b) 確定**)。

## Business / user value

Wave 1 以降の各 package 実体化タスクが、workspace 構造や project references に
悩まず、`src/*.ts` を追加するだけで済む状態にする。I-005 の UI スタック初期化
でも、配置境界に迷わず shadcn CLI を `apps/web` 側に向けられる。

## In scope

4 パッケージ × 3 ファイル = 12 ファイルの新規作成:

- `packages/core/package.json`, `packages/core/tsconfig.json`, `packages/core/src/index.ts`
- `packages/db/package.json`, `packages/db/tsconfig.json`, `packages/db/src/index.ts`
- `packages/ingestion/package.json`, `packages/ingestion/tsconfig.json`, `packages/ingestion/src/index.ts`
- `packages/ui/package.json`, `packages/ui/tsconfig.json`, `packages/ui/src/index.ts`

各 `package.json` の仕様:
- `"name"`: `@repo/core` / `@repo/db` / `@repo/ingestion` / `@repo/ui`
  (**UQ-I003-01 確定、I-002 の `@repo/*` scope に継承**)
- `"private": true`, `"version": "0.0.0"`
- `"exports": { ".": { "types": "./src/index.ts", "default": "./src/index.ts" } }`
  (barrel のみ、I-002 と同方針)
- `"dependencies": {}` または空 (空で閉じる、Wave 1 で必要に応じ追加)
- `"devDependencies"`: 空 または `typescript` のみ (root hoist に任せる)

各 `tsconfig.json`:
- `"extends": "../../tsconfig.base.json"`
- `"compilerOptions": { "composite": true, "outDir": "dist", "rootDir": "src" }`
- `"include": ["src"]`

各 `src/index.ts`:
- `export {};` 1 行のみ (**UQ-I003-02 確定、minimal**)

加えて:
- root `tsconfig.json` の `references` に 4 エントリ追加
  (`packages/core`, `packages/db`, `packages/ingestion`, `packages/ui`)
- root `package.json` への最小変更 (必要がなければ触らない。scripts は絶対に触らない)
- `pnpm-lock.yaml` の更新 (新 workspace package 追加に伴う、`pnpm install -w` 1 回)

## Out of scope

- `packages/core` 実装全般（実質額計算、純資産、系列正規化、集約、CPI 接続）
- `packages/db` の Prisma 初期化、schema.prisma、リポジトリ層
- `packages/ingestion` の e-Stat / 日銀 API クライアント、boj-series-map
- `packages/ui` の shadcn/ui 初期化、Tremor 導入、Tailwind 設定、カラートークン、
  Recharts ラッパー実装 (→ I-005 + Wave 4)
- 各 package 間の `dependencies` 宣言（空で閉じる。Wave 1 以降で追加）
- Vitest / Playwright 設定
- test/ ディレクトリ作成（golden 含む、UQ-I003-03 確定で作らない）
- `packages/ui/tailwind.config.ts` (UQ-I003-04 確定、I-005 の領分)
- ESLint / Prettier（→ I-006）
- `apps/web`（→ I-004）
- packages/ui に `react` / shadcn プリミティブを置くこと (**UQ-I003-05 (b) で禁止**)

## Touched files

- `packages/core/package.json` (new)
- `packages/core/tsconfig.json` (new)
- `packages/core/src/index.ts` (new)
- `packages/db/package.json` (new)
- `packages/db/tsconfig.json` (new)
- `packages/db/src/index.ts` (new)
- `packages/ingestion/package.json` (new)
- `packages/ingestion/tsconfig.json` (new)
- `packages/ingestion/src/index.ts` (new)
- `packages/ui/package.json` (new)
- `packages/ui/tsconfig.json` (new)
- `packages/ui/src/index.ts` (new)
- `tsconfig.json` (modify, root — references 4 行追加のみ)
- `package.json` (modify, root — 必要があれば最小の devDep のみ。scripts touch 禁止)
- `pnpm-lock.yaml` (modify — impl lane が `pnpm install -w` を 1 回実行)

## Forbidden files

- `docs/harness/**`, `AGENTS.md`, `CLAUDE.md`, `CODEX.md`, `.gtrconfig*`,
  `.claude/**`, `.codex/**`, `.agents/**`, `scripts/harness/**`,
  `.runtime/**`, `.worktrees/**`
- `docs/ai/tasks/**`（self 除く）, `docs/ai/issues/**`（self 除く）, `docs/ai/plans/**`
- `packages/types/**`（I-002 の領分、変更禁止）
- `apps/**`（→ I-004）
- `tsconfig.base.json`（I-002 で確定、本タスクは extends のみ）
- I-001 で作った root ファイル群の実質変更（`pnpm-workspace.yaml`, `.gitignore`,
  `.nvmrc`, `.editorconfig`, `.env.example`, `README.md`）
- `.github/**`, `.husky/**`, `eslint.config.*`, `.prettierrc*`, `commitlint.config.*`
- `prisma/**`（Wave 2）
- `packages/ui/tailwind.config.ts` (I-005 の領分)

## Serial-only areas touched
- yes
- details:
  - root `tsconfig.json` (shared global settings、references 追加)
  - root `package.json` (package manifest、最小変更)
  - `pnpm-lock.yaml` (lockfile)
  - merge order: I-002 の after、I-004/I-005/I-006/I-007 の before
  - Wave 0 内で並列実行しない (I-008 を除く)

## Verification commands

```text
# 1. 必須ファイルの存在（12 ファイル）
for p in core db ingestion ui; do
  test -f "packages/$p/package.json"
  test -f "packages/$p/tsconfig.json"
  test -f "packages/$p/src/index.ts"
done

# 2. 各 package.json の構造 (@repo/* scope + private + no runtime deps)
for p in core db ingestion ui; do
  node -e "
  const pkg = require('./packages/$p/package.json');
  if (!pkg.private) process.exit(10);
  if (pkg.name !== '@repo/$p') { console.error('name must be @repo/$p, got: ' + pkg.name); process.exit(11); }
  if (pkg.dependencies && Object.keys(pkg.dependencies).length > 0) { console.error('no runtime deps allowed in skeleton'); process.exit(12); }
  if (!pkg.exports || !pkg.exports['.']) { console.error('barrel exports required'); process.exit(13); }
  if (pkg.exports['./*'] !== undefined) { console.error('sub-path exports forbidden'); process.exit(14); }
  "
done

# 3. 各 tsconfig.json が base を extends
for p in core db ingestion ui; do
  grep -q '\"extends\"' "packages/$p/tsconfig.json"
  grep -qE 'tsconfig\.base\.json' "packages/$p/tsconfig.json"
done

# 4. 各 src/index.ts は export {}; のみ (Wave 1 へ実装を送る)
for p in core db ingestion ui; do
  content=$(cat "packages/$p/src/index.ts" | tr -d '[:space:]')
  if [ "$content" != "export{};" ] && [ "$content" != "export{}" ]; then
    echo "packages/$p/src/index.ts must be 'export {};' only, got: $content"; exit 1
  fi
done

# 5. NFR-004 担保: packages/core/package.json に db/ui/ingestion 依存が無い
node -e "
const p = require('./packages/core/package.json');
const deps = Object.assign({}, p.dependencies||{}, p.peerDependencies||{});
const banned = ['@repo/db','@repo/ui','@repo/ingestion'];
for (const k of Object.keys(deps)) {
  if (banned.includes(k)) { console.error('forbidden dep in core: '+k); process.exit(1); }
}
"

# 6. root tsconfig.json の references に 4 パッケージ全て登録
node -e "
const t = JSON.parse(require('fs').readFileSync('tsconfig.json','utf8').replace(/\/\/.*\n/g,''));
const needed = ['packages/core','packages/db','packages/ingestion','packages/ui'];
for (const n of needed) {
  if (!t.references.some(r => r.path && r.path.includes(n))) {
    console.error('missing reference: '+n); process.exit(1);
  }
}
// I-002 の packages/types も維持されていること
if (!t.references.some(r => r.path && r.path.includes('packages/types'))) {
  console.error('I-002 packages/types reference must survive'); process.exit(2);
}
"

# 7. 型検査・build graph
pnpm -w tsc -b --dry
for p in core db ingestion ui; do pnpm -w tsc --noEmit -p \"packages/$p\"; done

# 8. I-001 / I-002 成果物への回帰無し
git diff --name-only HEAD~1 -- packages/types/ | { ! grep -q .; }
git diff --name-only HEAD~1 -- tsconfig.base.json | { ! grep -q .; }
for f in pnpm-workspace.yaml .nvmrc .gitignore .editorconfig .env.example README.md; do
  git diff --name-only HEAD~1 -- "$f" | { ! grep -q .; }
done

# 9. Out of scope 違反検知: Prisma / shadcn / Tailwind / React 痕跡
! grep -RE '@prisma/client|prisma\s+generator' packages/
! grep -RE 'from \"react\"|shadcn|tremor' packages/ui/src
! find packages/ -name 'tailwind.config.*' -type f | grep -q .
! test -d packages/ui/src/components

# 10. ハーネス同梱ファイルに touch 無し
git diff --name-only HEAD~1 -- \
  docs/harness/ AGENTS.md CLAUDE.md CODEX.md \
  .gtrconfig.v4 .gtrconfig .claude/ .codex/ .agents/ scripts/harness/ \
  | { ! grep -q .; }

# 11. ハーネス artifact validator
scripts/harness/validate-task-artifacts.sh I-003
```

## GUI verification
- required: no
- recipe path: n/a
- final frontmost validation required: no
- may be deferred by human: n/a

## Runtime isolation
- required: no
- notes: runtime process なし、`.runtime/allocations.json` 登録不要

## Done definition

- Verification 1〜11 全 PASS
- `scripts/harness/validate-task-artifacts` が I-003 に対して PASS
- `status.yaml` state が `implemented` 以上
- `handoff.md` に以下記録:
  - 4 package name の最終形 (`@repo/core`, `@repo/db`, `@repo/ingestion`, `@repo/ui`)
  - 依存ゼロ (NFR-004 担保)
  - shadcn プリミティブを `apps/web/components/ui/` 側に置く方針確定
    (UQ-I003-05 (b))、`packages/ui` はチャート共通のみの方針
  - Wave 1 以降で必要になる package 間 dependencies 宣言のパターン例
  - 次タスク I-004 (`apps/web`) からの参照方法
- `review.md` verdict `PASS` / `PASS-WITH-NOTES`、Must Fix 解消
- Forbidden files に touch 無し
- NFR-004 担保: `packages/core/package.json` の dependencies に `@repo/db` /
  `@repo/ui` / `@repo/ingestion` が含まれない

## Blocked if

- I-002 が `merged` 未到達
- Prisma / shadcn / React / Tailwind 依存を引き込まなければ成立しない設計案が
  提案された (Wave 0 境界違反、stop)

## Review focus

- **NFR-004 の強検証**: `packages/core` が `@repo/db` / `@repo/ui` / `@repo/ingestion`
  に依存していないこと (Verification 項目 5)
- **UQ-I003-05 (b) の遵守**: `packages/ui/src/components/` ディレクトリが存在せず、
  shadcn / React / Tremor 痕跡が無い (Verification 項目 9)
- **Out of scope 厳守**: Prisma / shadcn / Tailwind / React / Vitest の痕跡が
  一切無いこと
- **references 書式**: I-002 の書式に揃っているか、後続の `apps/web` 追加が
  機械的に済むか
- **12 ファイル + root 2 ファイル以外の touch 無し**: Forbidden files policy 違反の
  早期検出
- **`export {};` の厳守**: 各 `src/index.ts` に余計な記述が無い

## Merge order
- before: I-004, I-005, I-006, I-007
- after: I-002
- notes:
  - I-008 は I-001 完了後に並列可、I-003 の完了は待たない
  - I-004 は `apps/web` 初期化で `packages/*` を workspace 経由で参照しうるため、
    I-003 completed 後に開始

## Notes for implementer
- writable lane is `impl` only
- tool ownership: default = Codex（impl）/ Claude（review）
- 実体コードは 1 行も書かない。`export {};` 以外は stop
- `dependencies` を埋めたくなったら stop（Wave 1 の仕事）
- Prisma / React / shadcn / Tailwind の記述が入ったら契約違反として revert
- `packages/ui` に component ディレクトリを作りたくなったら stop (UQ-I003-05 違反)
- root `package.json` の `scripts` は I-001 のまま、絶対に触らない

## Tool ownership preferences
- default tool owner: Codex (impl)
- review tool: Claude
- verify tool: Codex
- switch trigger: `packages/*/src/` に `export {}` 以外の行が入った diff が
  発生した場合、即 stop + Claude impl に reassignment 検討
