# Issue Spec: I-005

- title: apps/web UI stack (Tailwind v4 + shadcn/ui + Tremor + theming)
- area: apps/web/ui
- slug: apps-web-ui-stack
- batch id: BATCH-WAVE0
- derived from: 要件定義 v0.2 §11.1 (shadcn/ui + Tremor + Recharts),
  Appendix B §B.4 (コンポーネント採用ポリシー), §B.4.5 (カラートークン),
  §B.4.6 (ダークモード), §B.4.7 (A11y 方針)
- harness: v4.1-p0-tool-ownership

## Background

I-004 で Next.js App Router の最小骨格が立ち上がる。I-005 はこの上に UI スタックを
一括で乗せる。対象は:
- Tailwind CSS v4
- shadcn/ui CLI 初期化と初期コンポーネントセット（Appendix B §B.4.2）
- Tremor（限定的な Card / Metric / BadgeDelta のみ、Appendix B §B.4.3）
- `next-themes`（ダークモード、Appendix B §B.4.6、`system` デフォルト）
- `lucide-react` / `sonner`
- `react-hook-form` + `zod`
- Appendix B §B.4.5 のカラートークン CSS 変数（`--series-income` /
  `--series-networth` / `--series-cpi`）

これらをまとめて 1 タスクにする理由:
- Tailwind と shadcn/ui CLI と `next-themes` と globals.css は互いに結線しており、
  個別タスクに割ると中間状態が壊れて dev lane のビルドが何度も落ちる
- Appendix B §B.4.5 のカラートークン CSS 変数は Tailwind v4 の `@theme` 宣言と
  `next-themes` のクラス（`html.dark`）の両方に依存する
- コンポーネント初期セットはすべて `components.json` の設定に影響される

逆に Wave 4（各画面の実装）は分離する。I-005 では初期コンポーネントの
「配置」と「カラートークンの導入」までに留め、画面実装は行わない。

## Objective

`apps/web` に UI 描画基盤を揃え、以下を満たす:
- Tailwind v4 が有効化され、`app/globals.css` に Appendix B §B.4.5 の
  CSS 変数（`--series-income`, `--series-networth`, `--series-cpi`）が定義されている
- shadcn/ui の初期セット（Appendix B §B.4.2）が `apps/web/components/ui/` に
  配置されている
- `next-themes` の `ThemeProvider` が `app/layout.tsx` に組み込まれ、
  `system` / `light` / `dark` を切替可能、デフォルトが `system`
- `@repo/ui` (I-003 の ui skeleton) に `charts/theme.ts` と Recharts 共通ラッパーの
  **最低限の export 構造だけ**を作る（中身の実装は Wave 4）

## Scope

### apps/web 側
- `apps/web/package.json`: UI 系依存の追加（下記 Done 参照）
- `apps/web/tailwind.config.ts` 新規（Tailwind v4 の最小設定、`content` を
  `app/**/*` + `components/**/*` + `../../packages/ui/src/**/*` に向ける）
- `apps/web/postcss.config.js` 新規（Tailwind v4 の PostCSS プラグイン）
- `apps/web/app/globals.css` 新規（`@import "tailwindcss"` +
  Appendix B §B.4.5 の CSS 変数定義 + ダークテーマ override）
- `apps/web/components.json` 新規（shadcn/ui CLI 設定）
- `apps/web/components/ui/*.tsx`: Appendix B §B.4.2 の初期セット
- `apps/web/lib/utils.ts` 新規（shadcn が要求する `cn` helper）
- `apps/web/components/theme-provider.tsx` 新規（`next-themes` wrapper）
- `apps/web/app/layout.tsx` 更新（ThemeProvider / globals.css import）

### packages/ui 側
- `packages/ui/package.json`: `recharts`, `react`, `tailwind-merge`, `clsx` を
  peer/dev に適切に設定
- `packages/ui/src/index.ts`: barrel re-export の更新
- `packages/ui/src/charts/theme.ts` 新規（Recharts 用テーマオブジェクトの
  **export 構造のみ**、値は Appendix B §B.4.5 の CSS 変数参照の雛形）

## Out of scope

- 各画面の実装（ダッシュボード / 入力 / 設定 / 情報源）（→ Wave 4）
- Recharts による実際のチャート描画（→ Wave 4）
- A11y 自動検証の CI 組込み（`@axe-core/playwright`）（→ I-007 / Wave 4）
- モックデータ生成スクリプト（`scripts/seed-mock.ts`）
- Lighthouse ベースライン測定（→ Wave 4）
- Appendix B §B.4.2 の初期セットを超える shadcn コンポーネント追加
- `packages/ui/src/charts/` の実ラッパー実装
- カラーパレットの色彩値のハードコード（CSS 変数経由のみ、Appendix B §B.4.5）
- Prisma / データ層 (Wave 2)
- Phase B の PWA 実装（manifest.webmanifest のみ Appendix B §B.3.4 で言及、
  今回は作らない）

## Done definition

- `apps/web/package.json` に以下が追加:
  - `dependencies`: `tailwindcss`, `@tremor/react`, `next-themes`,
    `lucide-react`, `sonner`, `react-hook-form`, `zod`,
    `@hookform/resolvers`, `tailwind-merge`, `clsx`,
    `class-variance-authority`, `@radix-ui/*`（shadcn が要求するもの）
  - `devDependencies`: `@tailwindcss/postcss`, `postcss`
- `apps/web/tailwind.config.ts` が Tailwind v4 の `content` を正しく指す
- `apps/web/app/globals.css` が以下を含む:
  - `@import "tailwindcss";`
  - `:root { --series-income: ...; --series-networth: ...; --series-cpi: ...; }`
  - `.dark { ... }` または `:root.dark { ... }` で dark override
  - `--background`, `--foreground` 等の shadcn 標準トークン
- `apps/web/components.json` が存在し、`"style": "default"` / `"rsc": true` /
  `"tailwind": { ... }` / `"aliases"` が設定
- `apps/web/components/ui/` に Appendix B §B.4.2 の初期セットが存在:
  `button, input, label, select, checkbox, form, dialog, alert-dialog,
  sheet, drawer, tabs, tooltip, popover, calendar, toast (sonner),
  table, badge, skeleton, scroll-area, separator, card, dropdown-menu,
  navigation-menu, command`（計 24 点前後）
- `apps/web/lib/utils.ts` に `cn` が export されている
- `apps/web/components/theme-provider.tsx` が `next-themes` の
  `ThemeProvider` を wrap、`defaultTheme="system"` / `attribute="class"` /
  `enableSystem` を設定
- `apps/web/app/layout.tsx` が以下を満たす:
  - `import './globals.css'` がある
  - `<html lang="ja" suppressHydrationWarning>` を持つ
  - `<body>` 内で `<ThemeProvider>` が children を wrap
- `packages/ui/src/charts/theme.ts` が存在し、CSS 変数名（`--series-income` 等）
  を参照する export 構造を持つ（実値のハードコードなし）
- `pnpm --filter web build` が 0 exit
- `pnpm --filter web typecheck` が 0 exit
- ビルド後の HTML/CSS で、ライト/ダーク切替時に系列色が CSS 変数経由で解決されること
  （impl lane の手元確認、Done definition の一部としてスクリーンショットは求めない）
- `scripts/harness/validate-task-artifacts` が I-005 に対して PASS

## Risks

- **R-I005-01**: Tailwind v3 → v4 のマイグレーション挙動差異
  → planning 時に Tailwind v4 で進めることを確定、`@tailwindcss/postcss` 前提
- **R-I005-02**: shadcn/ui CLI がプロジェクト構造に合わず、想定外のファイル生成
  → `components.json` を先に commit、CLI は `--overwrite false` で実行。
    planning で手動書きに切り替える選択肢も残す
- **R-I005-03**: Appendix B §B.4.5 のカラートークンを CSS ではなく
  `tailwind.config.ts` に書いてしまう → Tailwind v4 は `@theme` を CSS 側に書く
  のが推奨。planning で方針確定
- **R-I005-04**: `next-themes` の FOUC（Flash of Unstyled Content）
  → `suppressHydrationWarning` + `defaultTheme="system"` + `attribute="class"` で
  公式 recipe を踏襲
- **R-I005-05**: `packages/ui` の責務肥大化（UQ-I003-05 で shadcn は `apps/web`
  に置く方針を採った前提）
  → `packages/ui` は `charts/` の雛形のみ、shadcn プリミティブは置かない
- **R-I005-06**: `@axe-core/playwright` の CI 組込みを「ついでに」入れたくなる
  → I-007 / Wave 4 の領分。明示的に Out of scope

## Unresolved questions

- UQ-I005-01: Tailwind v4 か v3 か（Next.js 15 は両対応）
  - 推奨: **v4**（Appendix B §B.4 の前提に v4 を採用する方向で記述されている）
- UQ-I005-02: shadcn/ui CLI を使うか、手動で各 `.tsx` を複製するか
  - 推奨: **CLI**（`pnpm dlx shadcn@latest add <component>`）。
    ただし `components.json` は先に commit
- UQ-I005-03: `next-themes` の `attribute` 値（`class` / `data-theme`）
  - 推奨: **`class`**（Tailwind dark variant と互換）
- UQ-I005-04: Appendix B §B.4.5 のカラー値（emerald-500 / sky-500 / amber-500 等）
  の OKLCH 表現 or HSL 表現
  - 推奨: **OKLCH**（shadcn/ui 2.x のデフォルト）
- UQ-I005-05: `packages/ui/src/charts/theme.ts` の実値をどこまで書くか
  - 推奨: **export 構造のみ**（値は Wave 4 の実ラッパータスクで埋める）
- UQ-I005-06: shadcn 初期セット 24 点を一括導入するか、必要に応じて段階追加するか
  - Appendix B §B.4.2 は一括導入を示唆
  - 推奨: **一括導入**（I-005 で 24 点追加、Wave 4 以降は追加ルールのみ）

## References

- `requirements_v0.2.md` §11.1
- `requirements_v0.2_appendix_B_ux.md` §B.4.1 (ライブラリ使い分け規約),
  §B.4.2 (shadcn 初期セット), §B.4.3 (Tremor 限定セット),
  §B.4.4 (Recharts), §B.4.5 (カラートークン CSS 変数),
  §B.4.6 (ダークモード + next-themes), §B.4.7 (A11y),
  §B.5.2 層 6 (プロンプトガードレール)
- `docs/ai/tasks/I-004/contract.stub.md` (前提: Next.js 素骨格)
- `docs/ai/tasks/I-003/contract.stub.md` (前提: packages/ui skeleton)
