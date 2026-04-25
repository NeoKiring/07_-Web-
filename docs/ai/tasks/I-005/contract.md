# Task Contract: I-005

## Identity
- task id: I-005
- title: apps/web UI stack (Tailwind v4 + shadcn/ui + Tremor + theming)
- area: apps/web/ui
- slug: apps-web-ui-stack
- batch id: BATCH-WAVE0
- harness_version: 4.1-p0-tool-ownership

## Objective

`apps/web` に UI 描画基盤を導入し、以下を成立させる:
- **Tailwind v4** 有効化 (**UQ-I005-01**)
- Appendix B §B.4.5 のカラートークン CSS 変数定義 (**OKLCH 表記**、UQ-I005-04)
- **shadcn/ui 24 点初期セット一括配置** (**UQ-I005-06**、`apps/web/components/ui/`、
  UQ-I005-07 確定)
- **shadcn CLI 採用** (**UQ-I005-02**、`components.json` 先行 commit)
- Tremor（限定セット: Card / Metric / BadgeDelta）導入
- **`next-themes` `attribute: class` + `defaultTheme: system`** (**UQ-I005-03**)
- `packages/ui/src/charts/theme.ts` に Recharts 共通ラッパー用 **export 構造のみ**
  (**UQ-I005-05**、値は Wave 4 で埋める)

## Business / user value

Wave 4 の全画面実装が、以下の契約の上で動けるようになる:
- Appendix B §B.4 のコンポーネント使い分け規約（1 コンポーネント = 1 ライブラリ）
- §B.4.5 のカラートークンからの参照のみ（ハードコード禁止）
- §B.4.6 のダーク対応（`defaultTheme: system`）
- §B.5.2 層 3（型ロック）と層 1（仕様ロック）の一部の事前充足

## In scope

### apps/web 側

- `apps/web/package.json` (modify) — 以下を追加:
  - `dependencies`:
    - `tailwindcss` (v4 最新)
    - `@tremor/react`
    - `next-themes`
    - `lucide-react`
    - `sonner`
    - `react-hook-form`
    - `zod`
    - `@hookform/resolvers`
    - `tailwind-merge`
    - `clsx`
    - `class-variance-authority`
    - `@radix-ui/*` (shadcn CLI が追加する分のみ。独自追加禁止、UQ-I005-08)
  - `devDependencies`:
    - `@tailwindcss/postcss`
    - `postcss`

- `apps/web/tailwind.config.ts` (new):
  - Tailwind v4 最小設定
  - `content`: `app/**/*`, `components/**/*`, `../../packages/ui/src/**/*`

- `apps/web/postcss.config.js` (new):
  - Tailwind v4 の PostCSS プラグイン

- `apps/web/app/globals.css` (new):
  - `@import "tailwindcss";`
  - Appendix B §B.4.5 の CSS 変数定義 (`--series-income`, `--series-networth`,
    `--series-cpi`)、**OKLCH 表記** (UQ-I005-04)
  - shadcn 標準トークン (`--background`, `--foreground`, `--primary`,
    `--destructive`, `--border`, `--ring` 等)
  - `.dark { ... }` または `:root.dark { ... }` で dark override
  - Tailwind v4 の `@theme` ディレクティブ活用

- `apps/web/components.json` (new, **先行 commit**):
  - `"style": "default"`
  - `"rsc": true`
  - `"tailwind": { "config": "tailwind.config.ts", "css": "app/globals.css", "baseColor": "slate", "cssVariables": true }`
  - `"aliases"`: `components`, `utils`, `ui`, `lib`, `hooks`

- `apps/web/components/ui/*.tsx` (new、**一括 24 点導入**、UQ-I005-06):
  1. `button.tsx`
  2. `input.tsx`
  3. `label.tsx`
  4. `select.tsx`
  5. `checkbox.tsx`
  6. `form.tsx`
  7. `dialog.tsx`
  8. `alert-dialog.tsx`
  9. `sheet.tsx`
  10. `drawer.tsx`
  11. `tabs.tsx`
  12. `tooltip.tsx`
  13. `popover.tsx`
  14. `calendar.tsx`
  15. `sonner.tsx` (toast)
  16. `table.tsx`
  17. `badge.tsx`
  18. `skeleton.tsx`
  19. `scroll-area.tsx`
  20. `separator.tsx`
  21. `card.tsx`
  22. `dropdown-menu.tsx`
  23. `navigation-menu.tsx`
  24. `command.tsx`
  実追加リストは impl lane の handoff.md で確定

- `apps/web/lib/utils.ts` (new, `cn` helper の shadcn 標準実装)

- `apps/web/components/theme-provider.tsx` (new):
  - `next-themes` の `ThemeProvider` wrapper
  - 必須 4 点: `defaultTheme="system"` / `attribute="class"` / `enableSystem` /
    `disableTransitionOnChange`

- `apps/web/app/layout.tsx` (modify):
  - `import './globals.css'` を追加
  - `<html lang="ja" suppressHydrationWarning>` に変更
  - `<body>` 内で `<ThemeProvider>` が children を wrap

### packages/ui 側

- `packages/ui/package.json` (modify):
  - `"peerDependencies": { "react": "^19", "react-dom": "^19" }`
  - `"dependencies"`: `recharts`, `tailwind-merge`, `clsx`
  - `"devDependencies"`: `@types/react`, `@types/react-dom`

- `packages/ui/src/index.ts` (modify):
  - barrel re-export で `charts/theme.ts` を公開

- `packages/ui/src/charts/theme.ts` (new):
  - Recharts 用テーマオブジェクトの **export 構造のみ** (UQ-I005-05)
  - 値は Appendix B §B.4.5 の CSS 変数参照 (例: `color: "var(--series-income)"`)
  - **実色値のハードコード禁止** (OKLCH / HSL / RGB / hex すべて禁止)

### root

- `pnpm-lock.yaml` (modify)

## Out of scope

- 各画面の実装（ダッシュボード / 入力 / 設定 / 情報源）（→ Wave 4）
- Recharts による実際のチャート描画（→ Wave 4）
- A11y 自動検証の CI 組込み（`@axe-core/playwright`）（→ I-007 / Wave 4）
- モックデータ生成スクリプト（`scripts/seed-mock.ts`）
- Lighthouse ベースライン測定（→ Wave 4）
- Appendix B §B.4.2 の初期セットを超える shadcn コンポーネント追加
- `packages/ui/src/charts/` の実ラッパー実装（theme.ts の export 構造のみ）
- カラーパレットの色彩値のハードコード（CSS 変数経由のみ、Appendix B §B.4.5）
- `packages/types` / `packages/core` / `packages/db` / `packages/ingestion` への変更
  （I-002 / I-003 の領分、本タスクで touch 禁止）
- Prisma / データ層 (Wave 2)
- Phase B の PWA 実装（manifest.webmanifest）
- `eslint-plugin-tailwindcss` 導入 (UQ-I006-05 で Wave 0 不採用確定)
- shadcn プリミティブを `packages/ui` に配置すること (UQ-I003-05 (b) / UQ-I005-07
  で禁止確定)

## Touched files

- `apps/web/package.json` (modify)
- `apps/web/tailwind.config.ts` (new)
- `apps/web/postcss.config.js` (new)
- `apps/web/app/globals.css` (new)
- `apps/web/components.json` (new, 先行 commit)
- `apps/web/components/ui/*.tsx` (new, 24 ファイル)
- `apps/web/lib/utils.ts` (new)
- `apps/web/components/theme-provider.tsx` (new)
- `apps/web/app/layout.tsx` (modify)
- `packages/ui/package.json` (modify)
- `packages/ui/src/index.ts` (modify)
- `packages/ui/src/charts/theme.ts` (new)
- `pnpm-lock.yaml` (modify)

## Forbidden files

- `docs/harness/**`, `AGENTS.md`, `CLAUDE.md`, `CODEX.md`, `.gtrconfig*`,
  `.claude/**`, `.codex/**`, `.agents/**`, `scripts/harness/**`,
  `.runtime/**`, `.worktrees/**`
- `docs/ai/tasks/**`（self 除く）, `docs/ai/issues/**`（self 除く）, `docs/ai/plans/**`
- `packages/types/**`, `packages/core/**`, `packages/db/**`, `packages/ingestion/**`
  （I-002 / I-003 の領分、I-005 で触らない）
- `packages/ui/src/components/` ディレクトリ全体 (UQ-I003-05 (b) / UQ-I005-07
  で禁止確定、shadcn プリミティブは `apps/web/components/ui/` 側)
- `apps/web/next.config.ts`（I-004 確定、本タスクで触らない）
- `apps/web/app/page.tsx` の大幅変更（placeholder のまま、または最小調整のみ）
- I-001 の root ファイル群の実質変更
- `tsconfig.base.json`, root `tsconfig.json`, root `package.json`
- `.github/**`, `.husky/**`, `eslint.config.*`, `.prettierrc*`, `commitlint.config.*`
- `prisma/**`
- `apps/web/app/api/**` (Wave 2 以降)
- `apps/web/app/dashboard/`, `apps/web/app/input/`, `apps/web/app/settings/`,
  `apps/web/app/sources/` (Wave 4 以降の画面ディレクトリ)

## Serial-only areas touched
- yes
- details:
  - `pnpm-lock.yaml` (lockfile)
  - `apps/web/package.json` (package manifest, 大量依存追加)
  - `apps/web/app/globals.css` (shared global settings 相当、全画面のスタイル基盤)
  - `apps/web/app/layout.tsx` (shared global settings 相当、Root UI)
  - merge order: I-004 の after、I-006 / I-007 の before
  - Wave 0 内で並列実行しない

## Verification commands

```text
# 1. 必須ファイルの存在
test -f apps/web/tailwind.config.ts
test -f apps/web/postcss.config.js
test -f apps/web/app/globals.css
test -f apps/web/components.json
test -f apps/web/lib/utils.ts
test -f apps/web/components/theme-provider.tsx
test -f packages/ui/src/charts/theme.ts

# 2. shadcn 初期セット 24 点の存在 (Appendix B §B.4.2、UQ-I005-06)
required_ui=(button input label select checkbox form dialog alert-dialog \
  sheet drawer tabs tooltip popover calendar sonner table badge skeleton \
  scroll-area separator card dropdown-menu navigation-menu command)
for c in "${required_ui[@]}"; do
  test -f "apps/web/components/ui/$c.tsx" || { echo "missing ui/$c.tsx"; exit 1; }
done
count=$(ls apps/web/components/ui/ | wc -l)
test "$count" -ge 24 || { echo "need at least 24 shadcn components, got $count"; exit 1; }

# 3. 依存追加の網羅
node -e "
const p = require('./apps/web/package.json');
const deps = Object.assign({}, p.dependencies||{}, p.devDependencies||{});
const required = ['tailwindcss','@tremor/react','next-themes','lucide-react',
  'sonner','react-hook-form','zod','@hookform/resolvers',
  'tailwind-merge','clsx','class-variance-authority',
  '@tailwindcss/postcss','postcss'];
for (const r of required) if (!deps[r]) { console.error('missing '+r); process.exit(1); }
"

# 4. Appendix B §B.4.5 カラートークン CSS 変数（OKLCH 表記）
grep -qE -- '--series-income' apps/web/app/globals.css
grep -qE -- '--series-networth' apps/web/app/globals.css
grep -qE -- '--series-cpi' apps/web/app/globals.css
grep -qE 'oklch\(' apps/web/app/globals.css     # OKLCH 使用確認

# 5. ダークテーマ override
grep -qE '(^|\s)\.dark\s*\{' apps/web/app/globals.css

# 6. Tailwind v4 前提
grep -q '@import \"tailwindcss\"' apps/web/app/globals.css

# 7. ThemeProvider 4 点揃い + components.json
grep -q 'next-themes' apps/web/components/theme-provider.tsx
grep -q 'defaultTheme=\"system\"' apps/web/components/theme-provider.tsx
grep -q 'attribute=\"class\"' apps/web/components/theme-provider.tsx
grep -q 'enableSystem' apps/web/components/theme-provider.tsx
grep -q 'ThemeProvider' apps/web/app/layout.tsx
grep -qE "import .*globals\.css" apps/web/app/layout.tsx
grep -q 'suppressHydrationWarning' apps/web/app/layout.tsx
grep -qE '\"rsc\":\s*true' apps/web/components.json
grep -qE '\"style\":\s*\"default\"' apps/web/components.json

# 8. packages/ui の charts/theme.ts が CSS 変数参照 (ハードコード禁止)
! grep -E 'rgb\(|rgba\(|#[0-9a-fA-F]{3,8}\b|\boklch\(' packages/ui/src/charts/theme.ts
grep -q 'series-' packages/ui/src/charts/theme.ts
grep -qE 'var\(--series-' packages/ui/src/charts/theme.ts

# 9. packages/types / core / db / ingestion 未変更
for p in types core db ingestion; do
  git diff --name-only HEAD~1 -- \"packages/$p/\" | { ! grep -q .; }
done

# 10. UQ-I003-05 (b) 遵守: packages/ui に shadcn プリミティブが無い
! test -d packages/ui/src/components

# 11. 他の Forbidden 領域に回帰無し
git diff --name-only HEAD~1 -- \
  docs/harness/ AGENTS.md CLAUDE.md CODEX.md \
  .gtrconfig.v4 .gtrconfig .claude/ .codex/ .agents/ scripts/harness/ \
  tsconfig.base.json tsconfig.json apps/web/next.config.ts \
  | { ! grep -q .; }

# 12. ビルドと型検査
pnpm --filter web build
pnpm --filter web typecheck

# 13. ハーネス artifact validator
scripts/harness/validate-task-artifacts.sh I-005
```

## GUI verification
- required: **yes**
- recipe path: `docs/ai/tasks/I-005/gui.md` (本タスクで新規作成)
- final frontmost validation required: yes（`gui` lane で Claude 担当）
- may be deferred by human: **no**（本タスクの Done condition に含める）
- 背景: §B.4.6 のダーク `defaultTheme=system` の動作確認は shell では判定できない
- GUI recipe 要旨:
  1. `pnpm --filter web dev` を allocate された `APP_PORT` で起動
  2. `http://localhost:<APP_PORT>` にアクセス
  3. placeholder ページが Tailwind 適用状態で描画されることを確認
  4. OS のライト/ダーク切替で `<html>` の class が変化することを観測
     (`class="dark"` ↔ class 無し or `class="light"`)
  5. console error 無し、明らかな Tailwind 未適用が無い
  6. Light/Dark 両方で `--series-*` トークンが CSS 変数経由で解決されていること
     を DevTools で確認 (色値の直接指定が無い)

## Runtime isolation
- required: **yes**
- notes:
  - `pnpm --filter web dev` が起動する。`APP_PORT` と `LOG_DIR` の衝突回避が必要
  - `scripts/harness/alloc-runtime` で `I-005` / `impl` および `I-005` / `gui`
    それぞれに port と user-data を割り当て、`.env.worktree.local` 経由で
    Next.js に渡す
  - GUI single-instance 制約は OS ブラウザ次第。`gui` lane で GUI lock を取得
  - `USER_DATA_DIR` は `.runtime/userdata/I-005_<lane>` を使う
  - impl と gui が同時に走らないこと (GUI single-instance)

## Done definition

- Verification 1〜13 全 PASS
- `gui.md` に recipe 実行結果を記録（light/dark 切替で class 変化の観測 + 色値
  CSS 変数経由の確認）
- `scripts/harness/validate-task-artifacts` が I-005 に対して PASS
- `status.yaml` state が `implemented` 以上、`gui_status: required` で `gui` lane
  記録済み、`runtime_status: recorded`
- `handoff.md` に以下記録:
  - Tailwind v4 採用 patch、shadcn 採用 patch、Tremor / next-themes の採用版
  - shadcn CLI 採用確定 (UQ-I005-02)、実行コマンドと生成ファイルログ
  - 初期セット 24 点の **実追加リスト** (UQ-I005-06)
  - OKLCH 採用 (UQ-I005-04)、globals.css の CSS 変数全文
  - UQ-I005-07 確定: `apps/web/components/ui/` 配置
  - 次タスク I-006 への引き継ぎ (ESLint `ignorePatterns` で shadcn 生成 .tsx
    をスキップ対象にする可能性、lint-staged の対象から除外する可能性)
- `review.md` verdict が `PASS` / `PASS-WITH-NOTES`、Must Fix 解消
- `runtime` lane の allocation が `.runtime/allocations.json` に記録済み

## Blocked if

- I-004 が `merged` 未到達
- shadcn CLI がプロジェクトに合わないことが確認された（手動に切替の判断必要、
  UQ-I005-02 再判定）
- `gui` lane で runtime 分離が取れない (APP_PORT の allocation 失敗)
- Tailwind v4 の `@tailwindcss/postcss` がビルドで deps resolution に失敗する
- shadcn 24 点の一部が現行 shadcn CLI バージョンで未提供

## Review focus

- **カラーのハードコード禁止**: `packages/ui/src/charts/theme.ts` と
  コンポーネント実装で CSS 変数経由のみを徹底 (Verification 項目 8)
- **OKLCH 採用** (UQ-I005-04): globals.css が `oklch()` 記法を使っている
- **Appendix B §B.4.2 の初期セット完全性**: 24 点不足なし (項目 2)
- **1 コンポーネント = 1 ライブラリ**原則（Appendix B §B.4.1）の入口が壊れていないか
  （shadcn `<Card>` の中に Tremor `<Card>` を組まない等）
- **ThemeProvider の設定**: `defaultTheme="system"` / `attribute="class"` /
  `enableSystem` / `disableTransitionOnChange` + `suppressHydrationWarning` on html
- **他パッケージへの回帰なし**: packages/types / core / db / ingestion 未変更
- **UQ-I003-05 (b) 遵守**: `packages/ui/src/components/` ディレクトリ不在
- **依存の最小性**: `@radix-ui/*` は shadcn CLI が追加した分のみ。独自追加禁止
  (UQ-I005-08)
- **Tailwind v4 の正しい導入**: `@tailwindcss/postcss` / `@import "tailwindcss"`
  / `@theme` の組み合わせ

## Merge order
- before: I-006, I-007
- after: I-004
- notes: I-008 は I-001 完了後に並列可

## Notes for implementer
- writable lane is `impl` only
- tool ownership: default = Codex（impl）/ Claude（review + gui）
- Appendix B §B.4.5 のカラー値を globals.css 以外に書いたら stop
- **shadcn CLI 実行ログを handoff に添付すること** (必須)
- `apps/web/app/page.tsx` をリデザインしたくなったら stop（Wave 4 の仕事）
- `@axe-core/playwright` を導入したくなったら stop（I-007 / Wave 4）
- `eslint-plugin-tailwindcss` を導入したくなったら stop（UQ-I006-05 で不採用確定）
- 色値のハードコード (hex / rgb / hsl / oklch 直接) を theme.ts に書いたら stop
- shadcn プリミティブを `packages/ui` に配置しようとしたら stop (UQ-I003-05 違反)

## Tool ownership preferences
- default tool owner: Codex (impl)
- review tool: Claude
- verify tool: Codex
- gui tool: **Claude** (frontmost validation、`defaultTheme=system` の OS
  切替観測は Claude の default 担当)
- switch trigger: shadcn CLI 実行が 2 回以上失敗した場合、または 24 点の
  一括導入で review で 3 件以上の Must Fix が出た場合は Claude impl に
  reassignment 検討
