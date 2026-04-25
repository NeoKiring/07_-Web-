# Issue Spec: I-004

- title: apps/web initialization (Next.js App Router base)
- area: apps/web
- slug: apps-web-next-init
- batch id: BATCH-WAVE0
- derived from: 要件定義 v0.2 §11.1 (Next.js App Router + TypeScript),
  §15.1 (module layout), Appendix B §B.1.3 (app/ ディレクトリ構造)
- harness: v4.1-p0-tool-ownership

## Background

要件定義 v0.2 §11.1 で Next.js (App Router) + TypeScript が確定している。
I-004 はこの apps/web 配下に、素の Next.js App Router の最小骨格を置く。

UI スタック（Tailwind v4 / shadcn/ui / Tremor / `next-themes` / `lucide-react` /
`sonner` / `react-hook-form` + `zod`）は I-005 の領分。失敗モードが異なる
（Next 自体の init と、CSS / デザインシステム初期化は切り分けた方が review
しやすい）ため、I-004 と I-005 に分割する。

Appendix B §B.1.3 のフルディレクトリ構造は I-005 および Wave 4 で段階的に
構築される。I-004 は `app/layout.tsx` と `app/page.tsx` のみの最小版で止める。

## Objective

apps/web に Next.js (App Router) + TypeScript の最小骨格をコミットする。
`pnpm --filter web dev` が `localhost` で起動し、空白 or プレースホルダーの
トップページを返す状態にする。UI スタックは導入しない。

## Scope

- `apps/web/package.json`（新規）
  - `"name"`: `@repo/web` または `web`（UQ-I004-01）
  - `"private": true`
  - `"dependencies": { "next", "react", "react-dom" }`
  - `"devDependencies": { "@types/react", "@types/react-dom", "@types/node" }`
  - `"scripts"`: `dev`, `build`, `start`, `typecheck` の 4 つ
- `apps/web/tsconfig.json`（新規）: Next.js 公式の App Router 推奨設定 +
  `extends: "../../tsconfig.base.json"`
- `apps/web/next.config.(js|ts|mjs)`（新規）: 最小（`reactStrictMode: true` 程度）
  （拡張子は UQ-I004-02 で確定）
- `apps/web/app/layout.tsx`（新規）: 最小の RootLayout（`<html><body>{children}</body></html>`）
- `apps/web/app/page.tsx`（新規）: プレースホルダーのトップページ（Wave 4 で上書き）
- `apps/web/public/.gitkeep`（新規）: public dir の git 管理のみ
- `apps/web/next-env.d.ts`（Next 初回起動時に自動生成、git 管理する）
- root `tsconfig.json` の `references` に `apps/web` を追加
- root `package.json` への最小変更（必要に応じて workspace レベルの scripts 追加、
  ただし本タスクでは scripts は触らず、I-006 以降で整える方が安全）

## Out of scope

- Tailwind CSS v4 の初期化（→ I-005）
- `apps/web/app/globals.css` の Tailwind imports（→ I-005）
- shadcn/ui CLI 初期化、`components/ui/*`（→ I-005）
- Tremor 導入、カラートークン CSS 変数（Appendix B §B.4.5）（→ I-005）
- `next-themes` によるダークモード実装（Appendix B §B.4.6）（→ I-005）
- `lucide-react`, `sonner`, `react-hook-form`, `zod`（→ I-005 / Wave 4）
- `@axe-core/playwright`（→ I-007 or Wave 4）
- Appendix B §B.1.3 の全ディレクトリ作成
  （`app/dashboard/`, `app/input/`, `app/settings/`, `app/sources/` 等）
  → Wave 4 の各画面タスクで作る
- `prisma/`, `packages/db` 連携（→ Wave 2）
- 実ページのコンテンツ実装
- `manifest.webmanifest` / PWA 準備（Appendix B §B.3.4）

## Done definition

- 上記 In scope のファイル全てが存在
- `apps/web/package.json` の `"dependencies"` が `next`, `react`, `react-dom`
  のみ（余計な UI 依存が入っていない）
- `apps/web/tsconfig.json` が `../../tsconfig.base.json` を extends し、
  Next.js App Router に必要な最低限の設定を追加
  （`jsx: "preserve"`, `plugins: [{ name: "next" }]`, `incremental: true` 等）
- `apps/web/app/layout.tsx` が 最小 RootLayout を export（default export）
- `apps/web/app/page.tsx` が default export を持つ
- `pnpm --filter web build` が 0 exit
- `pnpm --filter web typecheck`（または `tsc --noEmit`）が 0 exit
- Out of scope に挙げた依存が `apps/web/package.json` に入っていない
- root `tsconfig.json` の `references` に `apps/web` が追加されている
- I-003 までの packages/* skeleton に変更なし
- `scripts/harness/validate-task-artifacts` が I-004 に対して PASS

## Risks

- **R-I004-01**: Tailwind / shadcn を「ついでに」入れたくなる
  → I-005 に分けた理由を contract に明記し、review focus に置く。
- **R-I004-02**: `apps/web/app/globals.css` を空で置くと I-005 の Tailwind import
  と衝突する
  → I-004 では globals.css を作らない。I-005 で初めて作る。
- **R-I004-03**: `create-next-app` を無加工で使うと、`eslint` / `tailwind`
  依存が勝手に package.json に書き込まれる
  → `create-next-app` を直接使わず、手動で最小 package.json を書く。あるいは
  `--tailwind false --eslint false` のフラグで抑制する（planning で確定）。
- **R-I004-04**: `pnpm-lock.yaml` 更新と他 Wave 0 タスクのマージ衝突
  → serial-only merge order を明記。I-004 → I-005 → I-006 → I-007 の順で直列。
- **R-I004-05**: App Router と Pages Router の誤用
  → `app/` 直下のみを使用。`pages/` ディレクトリを作らない。

## Unresolved questions

- UQ-I004-01: `apps/web/package.json` の `"name"`
  - 候補: `@repo/web` / `web` / `@repo/apps-web`
  - 推奨: `@repo/web`（`packages/*` と同じ scope、pnpm workspace の命名規約）
- UQ-I004-02: `next.config` の拡張子
  - 候補: `.js` / `.ts` / `.mjs`
  - 推奨: `.ts`（Next.js 15 で stable、型安全）。要 TS 5.4+ 確認
- UQ-I004-03: `src/` ディレクトリを使うか、直下に `app/` を置くか
  - 候補: (a) `apps/web/app/...`（直下）/ (b) `apps/web/src/app/...`
  - 推奨: **(a) 直下**。shadcn/ui CLI のデフォルトと Appendix B §B.1.3 の
    記述 `apps/web/app/` に整合
- UQ-I004-04: Next.js のバージョン
  - 候補: 15.x（App Router stable、最新）
  - 推奨: 15 の最新 patch
- UQ-I004-05: `create-next-app` を使うか手動初期化か
  - 候補: (a) `create-next-app` + flags で余計な依存を抑制 /
    (b) 手動で package.json を書き、必要なら `pnpm init` 後に依存追加
  - 推奨: **(b) 手動**。Anchor 5 との整合が良く、触る範囲が明確

## References

- `requirements_v0.2.md` §11.1 (Next.js App Router), §15.1 (monorepo 構造)
- `requirements_v0.2_appendix_B_ux.md` §B.1.3 (apps/web ディレクトリ構造、
  Wave 4 で段階的に構築), §B.3 (レスポンシブ設計)
- `docs/ai/tasks/I-003/contract.stub.md` (前提: packages/* skeleton)
- `docs/harness/FOUNDATION.md` Anchor 4 (serial-only), Anchor 5 (no implicit installs)
