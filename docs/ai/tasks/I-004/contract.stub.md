# Task Contract: I-004

本ファイルは **stub**。`dev-plan` で finalized へ昇格。
Verification commands / Touched files / Forbidden files は
v0.2 + Appendix A/B レビュー済み前提での推定記述。

## Identity
- task id: I-004
- title: apps/web initialization (Next.js App Router base)
- area: apps/web
- slug: apps-web-next-init
- batch id: BATCH-WAVE0

## Objective

`apps/web` に Next.js (App Router) + TypeScript の最小骨格を追加し、
`pnpm --filter web build` / `pnpm --filter web dev` が動く状態にする。
UI スタック（Tailwind / shadcn / Tremor / next-themes 等）は含めない。

## Business / user value

Wave 4（UI 実装）および Wave 2/3（データ接続）の作業基盤となる。
Tailwind や shadcn 初期化で失敗しても、本タスクの最小 Next.js 起動は独立に
動く状態にしておく。これにより I-005 の初期化失敗を切り分けやすくする。

## In scope

- `apps/web/package.json` 新規
- `apps/web/tsconfig.json` 新規（`extends: "../../tsconfig.base.json"`）
- `apps/web/next.config.ts` 新規（UQ-I004-02 で (b) ts 採用の場合）
- `apps/web/app/layout.tsx` 新規（最小 RootLayout）
- `apps/web/app/page.tsx` 新規（プレースホルダー）
- `apps/web/public/.gitkeep` 新規
- `apps/web/next-env.d.ts`（Next 起動時自動生成、commit する）
- `tsconfig.json` (root) の references に `apps/web` 追加
- `pnpm-lock.yaml` 更新（`next`, `react`, `react-dom` 導入）

## Out of scope

- Tailwind v4 の導入、`tailwind.config.ts`（→ I-005）
- shadcn/ui CLI の実行、`components.json`、`components/ui/*`（→ I-005）
- Tremor の追加（→ I-005）
- `next-themes`, `lucide-react`, `sonner`, `react-hook-form`, `zod`（→ I-005）
- `apps/web/app/globals.css` 作成（→ I-005 で Tailwind import と同時）
- Appendix B §B.1.3 の全ディレクトリ（`app/dashboard/` / `app/input/` /
  `app/settings/` / `app/sources/` 等）
- Prisma 接続、`apps/web/app/api/**`（→ Wave 2 以降）
- `packages/ui` からの import（`packages/ui` は skeleton のまま）
- `manifest.webmanifest`, PWA, Service Worker（→ Phase B）
- `middleware.ts`, i18n（→ 必要になった時点で別タスク）

## Touched files

- `apps/web/package.json` (new)
- `apps/web/tsconfig.json` (new)
- `apps/web/next.config.ts` (new)（拡張子は UQ-I004-02 に従う）
- `apps/web/app/layout.tsx` (new)
- `apps/web/app/page.tsx` (new)
- `apps/web/public/.gitkeep` (new)
- `apps/web/next-env.d.ts` (new, auto-generated)
- `tsconfig.json` (modify, root — references に `apps/web` 追加のみ)
- `pnpm-lock.yaml` (modify)

## Forbidden files

- `docs/harness/**`, `AGENTS.md`, `CLAUDE.md`, `CODEX.md`, `.gtrconfig.v4`,
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
- `.github/**`, `.husky/**`, `eslint.config.*`, `.prettierrc*`, `commitlint.config.*`
- `prisma/**`
- `tailwind.config.*`, `postcss.config.*`（I-005）

## Serial-only areas touched
- yes
- details:
  - root `tsconfig.json`（shared global settings）
  - `pnpm-lock.yaml`（lockfile）
  - `apps/web/next.config.ts`（app entrypoint、serial-only）
  - merge order: I-003 の after、I-005 / I-006 / I-007 の before
  - 並列実行しない

## Verification commands

```text
# 推定。planning 時に Next.js 版確定後に再確認。

# 1. 必須ファイルの存在
test -f apps/web/package.json
test -f apps/web/tsconfig.json
test -f apps/web/next.config.ts
test -f apps/web/app/layout.tsx
test -f apps/web/app/page.tsx
test -f apps/web/public/.gitkeep

# 2. package.json の構造
node -e "
const p = require('./apps/web/package.json');
const deps = Object.keys(p.dependencies || {});
const required = ['next','react','react-dom'];
for (const r of required) if (!deps.includes(r)) { console.error('missing dep: '+r); process.exit(1); }
// UI スタックが先行混入していないこと
const banned = ['tailwindcss','@tailwindcss/postcss','next-themes','lucide-react','sonner','react-hook-form','zod','@tremor/react'];
for (const b of banned) if (deps.includes(b)) { console.error('I-005 dep leaked: '+b); process.exit(1); }
"

# 3. tsconfig が base を extends
grep -q '"extends"' apps/web/tsconfig.json
grep -qE 'tsconfig\.base\.json' apps/web/tsconfig.json

# 4. Appendix B §B.1.3 のフルディレクトリを先行作成していないこと
! test -d apps/web/app/dashboard
! test -d apps/web/app/input
! test -d apps/web/app/settings
! test -d apps/web/app/sources
! test -d apps/web/components
! test -d apps/web/lib

# 5. globals.css / tailwind config が無いこと（I-005 の領分）
! test -f apps/web/app/globals.css
! test -f apps/web/tailwind.config.ts
! test -f apps/web/tailwind.config.js
! test -f apps/web/postcss.config.js

# 6. root tsconfig の references に apps/web
node -e "
const t = JSON.parse(require('fs').readFileSync('tsconfig.json','utf8').replace(/\/\/.*\n/g,''));
if (!t.references.some(r => r.path && r.path.includes('apps/web'))) process.exit(1);
"

# 7. ビルドが通る
pnpm --filter web build
pnpm --filter web typecheck   # または pnpm -w tsc --noEmit -p apps/web

# 8. packages/* / tsconfig.base.json に回帰が無い
git diff --name-only HEAD~1 -- packages/ | { ! grep -q .; }
git diff --name-only HEAD~1 -- tsconfig.base.json | { ! grep -q .; }

# 9. ハーネス artifact validator
scripts/harness/validate-task-artifacts.sh I-004
```

## GUI verification
- required: no
- recipe path: n/a
- final frontmost validation required: no
- may be deferred by human: n/a
- 理由: GUI の意味での validation は I-005 以降。I-004 は起動確認 (`dev` で
  localhost が応答する) 程度。それは impl lane の build / typecheck で代替する。

## Runtime isolation
- required: **条件付き no**
- notes:
  - 本タスクの Done definition は `pnpm --filter web build` と `typecheck` のみ。
    `pnpm --filter web dev` の起動を Done definition に含めないため、**runtime
    allocation は不要**。
  - impl lane が個人的に `pnpm --filter web dev` で動作確認したい場合は
    runtime allocation を取得するのが安全（planning 時に運用メモ化）。

## Done definition

- Verification 1〜9 全 PASS
- `scripts/harness/validate-task-artifacts` が I-004 に対して PASS
- `status.yaml` state が `implemented` 以上
- `handoff.md` に以下記録:
  - Next.js 採用版（UQ-I004-04 最終値）
  - `create-next-app` 使ったか手動か（UQ-I004-05）
  - 次タスク I-005 で追加される依存予定一覧
- `review.md` verdict が `PASS` / `PASS-WITH-NOTES`、Must Fix 解消
- Forbidden files に touch 無し（特に I-005 の領分）

## Blocked if

- I-003 が `merged` 未到達
- UQ-I004-01〜06 いずれかが planning 時未決
- `create-next-app` が Tailwind/ESLint を強制的に導入するような変更があった
  （planning で手動初期化に切り替える判断が必要）
- `packages/ui` との結線が必要との判断（planning で Wave 4 に回すべきか検討）

## Review focus

- **UI スタック先行混入の検知**: Verification 項目 2 と 4/5 の遵守
- **Appendix B §B.1.3 の段階化**: I-004 では最小ディレクトリのみ、
  `app/dashboard/` 等は Wave 4 で作る
- **依存の最小性**: `next`, `react`, `react-dom` と `@types/*` のみ
- **serial-only 領域の最小化**: root `tsconfig.json` への追加が references 1 行のみ

## Merge order
- before: I-005, I-006, I-007
- after: I-003
- notes: I-008 は I-001 完了後に並列可

## Notes for implementer
- writable lane is `impl` only
- tool ownership: default = Codex（impl）/ Claude（review）
- Tailwind / shadcn / Tremor / next-themes を 1 行でも書いたら stop
- `apps/web/app/globals.css` を作らないこと
- `apps/web/components/` ディレクトリを作らないこと（I-005 / Wave 4 の領分）
- `create-next-app` を使う場合は flags で余計な依存を明示的に抑制
