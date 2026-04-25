# Task Contract: I-004

## Identity
- task id: I-004
- title: apps/web initialization (Next.js App Router base)
- area: apps/web
- slug: apps-web-next-init
- batch id: BATCH-WAVE0
- harness_version: 4.1-p0-tool-ownership

## Objective

`apps/web` に Next.js 15 (App Router) + TypeScript の最小骨格を追加し、
`pnpm --filter web build` / `pnpm --filter web typecheck` が 0 exit する状態にする。
UI スタック（Tailwind / shadcn / Tremor / next-themes 等）は含めない (I-005 の領分)。

本タスクは以下を確定する:
- **Next.js 15 最新 patch** (UQ-I004-04)
- **`apps/web/app/` flat layout** (UQ-I004-03、`src/` 使わない)
- **`next.config.ts` TypeScript 拡張子** (UQ-I004-02)
- **手動初期化** (UQ-I004-05、`create-next-app` 非使用)
- **package.json scripts: dev / build / start / typecheck のみ** (UQ-I004-06)
- **package name: `@repo/web`** (UQ-I004-01)

## Business / user value

Wave 4（UI 実装）および Wave 2/3（データ接続）の作業基盤となる。
Tailwind や shadcn 初期化で失敗しても、本タスクの最小 Next.js 起動は独立に
動く状態にしておく。これにより I-005 の初期化失敗を切り分けやすくする。

## In scope

- `apps/web/package.json` 新規:
  - `"name": "@repo/web"` (**UQ-I004-01**)
  - `"private": true`, `"version": "0.0.0"`
  - `"dependencies": { "next": "15.x.y", "react": "19.x.y", "react-dom": "19.x.y" }`
    (**Next.js 15 最新 patch**、UQ-I004-04)
  - `"devDependencies": { "@types/react": "...", "@types/react-dom": "...", "@types/node": "..." }`
  - `"scripts": { "dev": "next dev", "build": "next build", "start": "next start", "typecheck": "tsc --noEmit" }`
    (**UQ-I004-06 (a) 確定、lint は I-006 で追加**)
- `apps/web/tsconfig.json` 新規:
  - `"extends": "../../tsconfig.base.json"`
  - Next.js App Router 必須の `compilerOptions`:
    - `"jsx": "preserve"`, `"incremental": true`, `"allowJs": false`,
    - `"plugins": [{ "name": "next" }]`
    - `"paths"` は設定しない (I-002 の方針に従う)
  - `"include": ["next-env.d.ts", "app/**/*", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"]`
  - `"exclude": ["node_modules"]`
- `apps/web/next.config.ts` 新規 (**TypeScript 拡張子、UQ-I004-02**):
  - 最小設定: `reactStrictMode: true` のみ
- `apps/web/app/layout.tsx` 新規:
  - `<html lang="ja"><body>{children}</body></html>` の最小 RootLayout、default export
- `apps/web/app/page.tsx` 新規:
  - placeholder のトップページ (default export、Wave 4 で上書き)
- `apps/web/public/.gitkeep` 新規 (public dir の git 管理維持)
- `apps/web/next-env.d.ts` 新規 (Next 起動時自動生成、commit する)
- `tsconfig.json` (root) の `references` に `{ "path": "apps/web" }` 追加
- `pnpm-lock.yaml` 更新 (`next`, `react`, `react-dom` と型定義追加)

**初期化方法は手動** (**UQ-I004-05 (b) 確定**): `create-next-app` 非使用、
`pnpm init` 後に `pnpm add next react react-dom -F web` 等で依存を個別追加する。

## Out of scope

- Tailwind v4 の導入、`tailwind.config.ts`（→ I-005）
- shadcn/ui CLI の実行、`components.json`、`components/ui/*`（→ I-005）
- Tremor の追加（→ I-005）
- `next-themes`, `lucide-react`, `sonner`, `react-hook-form`, `zod`（→ I-005）
- `apps/web/app/globals.css` 作成（→ I-005 で Tailwind import と同時）
- Appendix B §B.1.3 の全ディレクトリ（`app/dashboard/` / `app/input/` /
  `app/settings/` / `app/sources/` 等）→ Wave 4
- Prisma 接続、`apps/web/app/api/**`（→ Wave 2 以降）
- `packages/ui` からの import（`packages/ui` は skeleton のまま）
- `manifest.webmanifest`, PWA, Service Worker（→ Phase B）
- `middleware.ts`, i18n（→ 必要になった時点で別タスク）
- `apps/web/components/**` ディレクトリ (→ I-005)
- `apps/web/lib/**` ディレクトリ (→ I-005 で `lib/utils.ts`)
- ESLint 設定 / lint script 実体化 (→ I-006)

## Touched files

- `apps/web/package.json` (new)
- `apps/web/tsconfig.json` (new)
- `apps/web/next.config.ts` (new、**.ts 拡張子固定**)
- `apps/web/app/layout.tsx` (new)
- `apps/web/app/page.tsx` (new)
- `apps/web/public/.gitkeep` (new)
- `apps/web/next-env.d.ts` (new, auto-generated)
- `tsconfig.json` (modify, root — references に `apps/web` 追加のみ)
- `pnpm-lock.yaml` (modify)

## Forbidden files

- `docs/harness/**`, `AGENTS.md`, `CLAUDE.md`, `CODEX.md`, `.gtrconfig*`,
  `.claude/**`, `.codex/**`, `.agents/**`, `scripts/harness/**`,
  `.runtime/**`, `.worktrees/**`
- `docs/ai/tasks/**`（self 除く）, `docs/ai/issues/**`（self 除く）, `docs/ai/plans/**`
- `packages/**`（全パッケージ、I-002 / I-003 の領分）
- `tsconfig.base.json`（I-002 確定）
- I-001 の root ファイル群（`pnpm-workspace.yaml`, `.gitignore`, `.nvmrc`,
  `.editorconfig`, `.env.example`, `README.md`）の実質変更
- root `package.json` の scripts（scripts 追加は I-006 以降の quality tooling で）
- `apps/web/app/globals.css`（I-005）
- `apps/web/components/**`（I-005 or Wave 4）
- `apps/web/lib/**`（I-005）
- `.github/**`, `.husky/**`, `eslint.config.*`, `.prettierrc*`, `commitlint.config.*`
- `prisma/**`
- `tailwind.config.*`, `postcss.config.*`（I-005）
- `apps/web/app/src/**` (flat layout、UQ-I004-03 (a) 遵守、src/ 配下禁止)

## Serial-only areas touched
- yes
- details:
  - root `tsconfig.json`（shared global settings、references 追加）
  - `pnpm-lock.yaml`（lockfile）
  - `apps/web/next.config.ts`（app entrypoint、serial-only）
  - merge order: I-003 の after、I-005 / I-006 / I-007 の before
  - 並列実行しない

## Verification commands

```text
# 1. 必須ファイルの存在
test -f apps/web/package.json
test -f apps/web/tsconfig.json
test -f apps/web/next.config.ts
test -f apps/web/app/layout.tsx
test -f apps/web/app/page.tsx
test -f apps/web/public/.gitkeep

# 2. package.json の構造 (name / deps / scripts / UI スタック非混入)
node -e "
const p = require('./apps/web/package.json');
if (!p.private) process.exit(1);
if (p.name !== '@repo/web') { console.error('name must be @repo/web, got: '+p.name); process.exit(2); }
const deps = Object.keys(p.dependencies || {});
const required = ['next','react','react-dom'];
for (const r of required) if (!deps.includes(r)) { console.error('missing dep: '+r); process.exit(3); }
if (!/^15\./.test((p.dependencies.next||'').replace(/[\^~]/, ''))) { console.error('Next.js must be 15.x'); process.exit(4); }
// UI スタックが先行混入していないこと
const banned = ['tailwindcss','@tailwindcss/postcss','next-themes','lucide-react','sonner','react-hook-form','zod','@tremor/react','@hookform/resolvers','tailwind-merge','clsx','class-variance-authority'];
const allDeps = Object.assign({}, p.dependencies||{}, p.devDependencies||{});
for (const b of banned) if (allDeps[b]) { console.error('I-005 dep leaked: '+b); process.exit(5); }
// scripts は UQ-I004-06 (a): dev/build/start/typecheck の 4 つ
const s = p.scripts || {};
for (const k of ['dev','build','start','typecheck']) if (!s[k]) { console.error('missing script: '+k); process.exit(6); }
if (s.lint) { console.error('lint script must be added in I-006, not here'); process.exit(7); }
"

# 3. tsconfig が base を extends
grep -q '\"extends\"' apps/web/tsconfig.json
grep -qE 'tsconfig\.base\.json' apps/web/tsconfig.json

# 4. Appendix B §B.1.3 のフルディレクトリを先行作成していないこと
! test -d apps/web/app/dashboard
! test -d apps/web/app/input
! test -d apps/web/app/settings
! test -d apps/web/app/sources
! test -d apps/web/components
! test -d apps/web/lib

# 5. UI スタック関連ファイルが無いこと（I-005 の領分）
! test -f apps/web/app/globals.css
! test -f apps/web/tailwind.config.ts
! test -f apps/web/tailwind.config.js
! test -f apps/web/postcss.config.js
! test -f apps/web/components.json

# 6. flat layout: src/ を使っていないこと (UQ-I004-03)
! test -d apps/web/src

# 7. next.config の拡張子 (.ts 固定)
test -f apps/web/next.config.ts
! test -f apps/web/next.config.js
! test -f apps/web/next.config.mjs

# 8. root tsconfig の references に apps/web
node -e "
const t = JSON.parse(require('fs').readFileSync('tsconfig.json','utf8').replace(/\/\/.*\n/g,''));
if (!t.references.some(r => r.path && r.path.includes('apps/web'))) process.exit(1);
// 既存の packages/* references も維持
for (const p of ['packages/types','packages/core','packages/db','packages/ingestion','packages/ui']) {
  if (!t.references.some(r => r.path && r.path.includes(p))) { console.error('regression on '+p); process.exit(2); }
}
"

# 9. ビルドと型検査
pnpm --filter web build
pnpm --filter web typecheck

# 10. packages/* / tsconfig.base.json に回帰が無い
git diff --name-only HEAD~1 -- packages/ | { ! grep -q .; }
git diff --name-only HEAD~1 -- tsconfig.base.json | { ! grep -q .; }
for f in pnpm-workspace.yaml .nvmrc .gitignore .editorconfig .env.example README.md; do
  git diff --name-only HEAD~1 -- "$f" | { ! grep -q .; }
done

# 11. ハーネス同梱ファイルに touch 無し
git diff --name-only HEAD~1 -- \
  docs/harness/ AGENTS.md CLAUDE.md CODEX.md \
  .gtrconfig.v4 .gtrconfig .claude/ .codex/ .agents/ scripts/harness/ \
  | { ! grep -q .; }

# 12. ハーネス artifact validator
scripts/harness/validate-task-artifacts.sh I-004
```

## GUI verification
- required: no
- recipe path: n/a
- final frontmost validation required: no
- may be deferred by human: n/a
- 理由: GUI の意味での validation は I-005 以降。I-004 は起動確認は不要で
  `build` / `typecheck` で代替 (impl lane の手元確認は任意)

## Runtime isolation
- required: no
- notes:
  - 本タスクの Done definition は `pnpm --filter web build` と `typecheck` のみ
  - `pnpm --filter web dev` の起動を Done definition に含めないため、**runtime
    allocation 不要**
  - impl lane が個人的に `pnpm --filter web dev` で動作確認したい場合は
    `scripts/harness/alloc-runtime` で APP_PORT を確保することを推奨

## Done definition

- Verification 1〜12 全 PASS
- `scripts/harness/validate-task-artifacts` が I-004 に対して PASS
- `status.yaml` state が `implemented` 以上
- `handoff.md` に以下記録:
  - Next.js 採用版 (最終 patch、UQ-I004-04)
  - 手動初期化で進めた旨 (UQ-I004-05 (b))
  - 次タスク I-005 で追加される依存予定一覧 (tailwindcss, @tremor/react,
    next-themes, lucide-react, sonner, react-hook-form, zod,
    @hookform/resolvers, tailwind-merge, clsx, class-variance-authority,
    @tailwindcss/postcss, postcss, @radix-ui/*)
- `review.md` verdict が `PASS` / `PASS-WITH-NOTES`、Must Fix 解消
- Forbidden files に touch 無し（特に I-005 の領分）
- `apps/web/components/` / `apps/web/lib/` ディレクトリが存在しない

## Blocked if

- I-003 が `merged` 未到達
- `create-next-app` を試して Tailwind/ESLint を強制導入された (手動に切替必要、
  UQ-I004-05 (b) で回避済み)
- `packages/ui` との結線が必要との判断 (planning で Wave 4 に回すべきか検討)

## Review focus

- **UI スタック先行混入の検知**: Verification 項目 2 と 5 の遵守
- **Appendix B §B.1.3 の段階化**: I-004 では最小ディレクトリのみ、
  `app/dashboard/` 等は Wave 4 で作る
- **依存の最小性**: `next`, `react`, `react-dom` と `@types/*` のみ
- **UQ 確定値の反映**: flat layout (src/ 無し)、`next.config.ts`、
  scripts 4 つ、`@repo/web` name
- **serial-only 領域の最小化**: root `tsconfig.json` への追加が references 1 行のみ
- **App Router のみ**: `apps/web/pages/` ディレクトリが無い

## Merge order
- before: I-005, I-006, I-007
- after: I-003
- notes: I-008 は I-001 完了後に並列可

## Notes for implementer
- writable lane is `impl` only
- tool ownership: default = Codex（impl）/ Claude（review）
- Tailwind / shadcn / Tremor / next-themes / その他 UI 依存を 1 行でも書いたら stop
- `apps/web/app/globals.css` を作らないこと
- `apps/web/components/` / `apps/web/lib/` ディレクトリを作らないこと
- **`create-next-app` を使わない** (UQ-I004-05 (b) 確定、flags 制御より手動の方が安全)
- `next.config` は `.ts` 拡張子のみ、`.js` / `.mjs` は作らない
- `apps/web/app/page.tsx` の中身は placeholder (例: `<main>Hello</main>`)
  の 1 要素程度、Wave 4 で上書きされる
- `apps/web/app/layout.tsx` は最小、`<ThemeProvider>` を入れたくなったら
  stop (I-005 の仕事)

## Tool ownership preferences
- default tool owner: Codex (impl)
- review tool: Claude
- verify tool: Codex
- switch trigger: `create-next-app` を使った痕跡が出たり、UI 依存が混入した
  場合は即 stop。`apps/web/components/` / `apps/web/lib/` / `globals.css` を
  作成した場合も即 stop。
