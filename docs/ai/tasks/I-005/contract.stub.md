# Task Contract: I-005

本ファイルは **stub**。`dev-plan` で finalized へ昇格。
Verification commands / Touched files / Forbidden files は
v0.2 + Appendix A/B レビュー済み前提での推定記述。

## Identity
- task id: I-005
- title: apps/web UI stack (Tailwind v4 + shadcn/ui + Tremor + theming)
- area: apps/web/ui
- slug: apps-web-ui-stack
- batch id: BATCH-WAVE0

## Objective

`apps/web` に UI 描画基盤を導入し、以下を成立させる:
- Tailwind v4 有効化
- Appendix B §B.4.5 のカラートークン CSS 変数定義
- shadcn/ui 初期セット 24 点前後の配置
- Tremor（限定セット）導入
- `next-themes` による system / light / dark 切替（`system` デフォルト）
- `packages/ui` に Recharts 共通ラッパーの export 構造のみ準備

## Business / user value

Wave 4 の全画面実装が、以下の契約の上で動けるようになる:
- Appendix B §B.4 のコンポーネント使い分け規約
- §B.4.5 のカラートークンからの参照のみ
- §B.4.6 のダーク対応
- §B.5.2 層 3（型ロック）と層 1（仕様ロック）の一部の事前充足

## In scope

### apps/web
- `apps/web/package.json` (modify): UI 系依存の追加
- `apps/web/tailwind.config.ts` (new)
- `apps/web/postcss.config.js` (new)
- `apps/web/app/globals.css` (new)
- `apps/web/components.json` (new)
- `apps/web/components/ui/*.tsx` (new, 24 点前後)
- `apps/web/lib/utils.ts` (new, `cn` helper)
- `apps/web/components/theme-provider.tsx` (new)
- `apps/web/app/layout.tsx` (modify, ThemeProvider / globals.css 組込み)

### packages/ui
- `packages/ui/package.json` (modify)
- `packages/ui/src/index.ts` (modify)
- `packages/ui/src/charts/theme.ts` (new, export 構造のみ)

### root
- `pnpm-lock.yaml` (modify)

## Out of scope

- 各画面の実装（→ Wave 4）
- Recharts の実チャート実装
- `@axe-core/playwright` 組込み（→ I-007 / Wave 4）
- モックデータ生成
- Lighthouse 測定
- Appendix B §B.4.2 の初期セット外の shadcn コンポーネント
- `packages/ui/src/charts/` の実ラッパー（theme.ts の export 構造のみ）
- カラーのハードコード（CSS 変数経由のみ）
- Prisma / データ層
- PWA / manifest.webmanifest

## Touched files

- `apps/web/package.json` (modify)
- `apps/web/tailwind.config.ts` (new)
- `apps/web/postcss.config.js` (new)
- `apps/web/app/globals.css` (new)
- `apps/web/components.json` (new)
- `apps/web/components/ui/*.tsx` (new, 24 点前後)
- `apps/web/lib/utils.ts` (new)
- `apps/web/components/theme-provider.tsx` (new)
- `apps/web/app/layout.tsx` (modify)
- `packages/ui/package.json` (modify)
- `packages/ui/src/index.ts` (modify)
- `packages/ui/src/charts/theme.ts` (new)
- `pnpm-lock.yaml` (modify)

## Forbidden files

- `docs/harness/**`, `AGENTS.md`, `CLAUDE.md`, `CODEX.md`, `.gtrconfig.v4`,
  `.claude/**`, `.codex/**`, `.agents/**`, `scripts/harness/**`,
  `.runtime/**`, `.worktrees/**`
- `docs/ai/tasks/**`（self 除く）, `docs/ai/issues/**`（self 除く）, `docs/ai/plans/**`
- `packages/types/**`, `packages/core/**`, `packages/db/**`, `packages/ingestion/**`
  （I-002 / I-003 の領分、I-005 で触らない）
- `apps/web/next.config.ts`（I-004 確定、本タスクで触らない）
- `apps/web/app/page.tsx` の大幅変更（placeholder のまま、または最小の調整のみ）
- I-001 の root ファイル群の実質変更
- `tsconfig.base.json`, root `tsconfig.json`, root `package.json`
- `.github/**`, `.husky/**`, `eslint.config.*`, `.prettierrc*`
- `prisma/**`

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

# 2. shadcn 初期セットの存在（Appendix B §B.4.2）
for c in button input label select checkbox form dialog alert-dialog sheet drawer \
         tabs tooltip popover calendar table badge skeleton scroll-area separator \
         card dropdown-menu navigation-menu command; do
  test -f "apps/web/components/ui/$c.tsx" || { echo "missing ui/$c.tsx"; exit 1; }
done

# 3. 依存追加
node -e "
const p = require('./apps/web/package.json');
const deps = Object.assign({}, p.dependencies||{}, p.devDependencies||{});
const required = ['tailwindcss','@tremor/react','next-themes','lucide-react',
  'sonner','react-hook-form','zod','@hookform/resolvers',
  'tailwind-merge','clsx','class-variance-authority'];
for (const r of required) if (!deps[r]) { console.error('missing '+r); process.exit(1); }
"

# 4. Appendix B §B.4.5 カラートークン CSS 変数
grep -qE -- '--series-income' apps/web/app/globals.css
grep -qE -- '--series-networth' apps/web/app/globals.css
grep -qE -- '--series-cpi' apps/web/app/globals.css

# 5. ダークテーマ override
grep -qE '\.dark\s*\{' apps/web/app/globals.css

# 6. Tailwind v4 前提
grep -q '@import "tailwindcss"' apps/web/app/globals.css

# 7. ThemeProvider 組込み
grep -q 'next-themes' apps/web/components/theme-provider.tsx
grep -q 'defaultTheme="system"' apps/web/components/theme-provider.tsx
grep -q 'attribute="class"' apps/web/components/theme-provider.tsx
grep -q 'ThemeProvider' apps/web/app/layout.tsx
grep -q "import .* './globals.css'" apps/web/app/layout.tsx
grep -q 'suppressHydrationWarning' apps/web/app/layout.tsx

# 8. packages/ui の charts/theme.ts が CSS 変数を参照（ハードコード禁止）
!  grep -RE 'rgb\(|#[0-9a-fA-F]{3,8}\b' packages/ui/src/charts/theme.ts
grep -q 'series-' packages/ui/src/charts/theme.ts

# 9. packages/core / packages/db / packages/ingestion / packages/types 未変更
for p in types core db ingestion; do
  git diff --name-only HEAD~1 -- "packages/$p/" | { ! grep -q .; }
done

# 10. ビルドと型検査
pnpm --filter web build
pnpm --filter web typecheck

# 11. ハーネス artifact validator
scripts/harness/validate-task-artifacts.sh I-005
```

## GUI verification
- required: **yes**
- recipe path: Wave 4 で正式作成。I-005 段階は以下のみ:
  1. `pnpm --filter web dev`
  2. `http://localhost:<APP_PORT>` にアクセス
  3. placeholder ページが描画されることを確認
  4. OS のライト/ダーク切替で body の theme class が変化することを確認
     (`html class="dark"` <-> class 無し または `class="light"`)
  5. 明らかな Tailwind 未適用や console error が出ていないこと
- final frontmost validation required: yes（`gui` lane で Claude 担当）
- may be deferred by human: **no**（本タスクの Done condition に含める）
- 背景: §B.4.6 のダーク default=system の動作確認は shell では判定できない

## Runtime isolation
- required: **yes**
- notes:
  - `pnpm --filter web dev` が起動する。`APP_PORT` と `LOG_DIR` の衝突回避が必要
  - `scripts/harness/alloc-runtime` で `I-005` / `impl` に port を割り当て、
    `.env.worktree.local` 経由で Next.js に渡す
  - GUI single-instance 制約は OS ブラウザ次第。`gui` lane で GUI lock を取得
  - `USER_DATA_DIR` は `.runtime/userdata/I-005_<lane>` を使う

## Done definition

- Verification 1〜11 全 PASS
- `gui.md` に recipe 実行結果を記録（light/dark 切替で class 変化の観測）
- `scripts/harness/validate-task-artifacts` が I-005 に対して PASS
- `status.yaml` state が `implemented` 以上、`gui_status: required` で `gui` lane 記録済み
- `handoff.md` に以下記録:
  - Tailwind / shadcn / Tremor / next-themes の採用版
  - shadcn CLI 使用 or 手動の最終判断
  - 初期セット 24 点の実追加リスト
  - 次タスク I-006 への引き継ぎ（ESLint ルール追加時に shadcn 生成 .tsx を
    `ignorePatterns` に入れる必要があるか等）
- `review.md` verdict が `PASS` / `PASS-WITH-NOTES`、Must Fix 解消

## Blocked if

- I-004 が `merged` 未到達
- UQ-I005-01 / UQ-I005-02 / UQ-I005-06 / UQ-I005-07 が planning 時未決
- shadcn CLI がプロジェクトに合わないことが確認された（手動に切替の判断必要）
- `gui` lane で runtime 分離が取れない

## Review focus

- **カラーのハードコード禁止**: `packages/ui/src/charts/theme.ts` と
  コンポーネント実装で CSS 変数経由のみを徹底（Verification 項目 8）
- **Appendix B §B.4.2 の初期セット完全性**: 24 点不足なし（項目 2）
- **1 コンポーネント = 1 ライブラリ**原則（Appendix B §B.4.1）の入口が壊れていないか
  （shadcn `<Card>` の中に Tremor `<Card>` を組まない等）
- **ThemeProvider の設定**: `defaultTheme="system"` / `attribute="class"` /
  `enableSystem` / `suppressHydrationWarning` の 4 点揃い
- **他パッケージへの回帰なし**: packages/types / core / db / ingestion 未変更
- **依存の最小性**: `@radix-ui/*` は shadcn が持ち込む分のみ。独自追加禁止

## Merge order
- before: I-006, I-007
- after: I-004
- notes: I-008 は I-001 完了後に並列可

## Notes for implementer
- writable lane is `impl` only
- tool ownership: default = Codex（impl）/ Claude（review + gui）
- Appendix B §B.4.5 のカラー値を globals.css 以外に書いたら stop
- shadcn CLI 実行ログを handoff に添付すること
- `apps/web/app/page.tsx` をリデザインしたくなったら stop（Wave 4 の仕事）
- `@axe-core/playwright` を導入したくなったら stop（I-007 / Wave 4）
