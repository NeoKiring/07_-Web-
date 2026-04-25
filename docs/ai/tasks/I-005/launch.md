# Launch: I-005 impl

## Lane identity
- task id: I-005
- lane: impl
- tool: Codex
- writable: yes

## Branch / commit target
- implementation branch: `ai/apps/web/ui/I-005-apps-web-ui-stack`
- target commit for inspection lanes: (to be set by impl after first commit)

## Worktree
- path: `.worktrees/I-005__impl`
- create command (Linux/mac):
  ```bash
  scripts/harness/new-impl-lane.sh I-005 apps/web/ui apps-web-ui-stack main
  ```
- create command (Windows):
  ```powershell
  pwsh scripts/harness/new-impl-lane.ps1 -TaskId I-005 -Area apps/web/ui -Slug apps-web-ui-stack -BaseBranch main
  ```

## Runtime allocation (required)
```bash
scripts/harness/alloc-runtime.sh I-005 impl
# → .runtime/allocations.json に APP_PORT / USER_DATA_DIR / LOG_DIR を記録
scripts/harness/gen-worktree-env.sh I-005 impl
# → .worktrees/I-005__impl/.env.worktree.local を生成
```
GUI single-instance 制約のため、**impl と gui を同時に走らせない**。

## Session name
`[I-005][impl][codex]`

## Read first
- `docs/harness/FOUNDATION.md` (Anchor 3/4/5)
- `docs/harness/policies/runtime-isolation.md`
- `AGENTS.md`, `CODEX.md`
- `docs/ai/tasks/I-005/contract.md` (finalized)
- `docs/ai/tasks/I-005/status.yaml`
- `docs/ai/tasks/I-005/gui.md` (recipe、本タスクで実行)
- `docs/ai/tasks/I-004/handoff.md` (依存予定リスト確認)
- `docs/ai/plans/BATCH-WAVE0/uq-decisions.md` (グループ 5, 7 特に)
- Appendix B §B.4.1〜§B.4.6 (UI 採用ポリシー + カラートークン + ダーク対応)

## Start instruction

1. **前提確認**: I-004 merged 済みを確認、未 merge なら blocked
2. runtime allocation を取得 (上記 Runtime allocation セクション)
3. impl worktree に cd、`status.yaml` を `state: in-progress` /
   `runtime_status: allocated` に更新
4. **components.json を先行 commit** (UQ-I005-02)、`apps/web/components.json`:
   ```json
   {
     "$schema": "https://ui.shadcn.com/schema.json",
     "style": "default",
     "rsc": true,
     "tsx": true,
     "tailwind": {
       "config": "tailwind.config.ts",
       "css": "app/globals.css",
       "baseColor": "slate",
       "cssVariables": true
     },
     "aliases": {
       "components": "@/components",
       "utils": "@/lib/utils",
       "ui": "@/components/ui",
       "lib": "@/lib",
       "hooks": "@/hooks"
     }
   }
   ```
5. Tailwind v4 + PostCSS 導入:
   ```bash
   pnpm add tailwindcss @tailwindcss/postcss postcss -F web
   ```
   - `apps/web/tailwind.config.ts` (Tailwind v4 最小設定、`content` に
     `app/**/*`, `components/**/*`, `../../packages/ui/src/**/*`)
   - `apps/web/postcss.config.js` (Tailwind v4 PostCSS plugin)
6. `apps/web/app/globals.css` を作成:
   - `@import "tailwindcss";`
   - Appendix B §B.4.5 の CSS 変数を **OKLCH 表記** (UQ-I005-04):
     `--series-income`, `--series-networth`, `--series-cpi`
   - shadcn 標準トークン (`--background`, `--foreground`, `--primary`,
     `--destructive`, `--border`, `--ring` 等)
   - `.dark { ... }` で dark override
   - Tailwind v4 の `@theme` ディレクティブ活用
7. shadcn CLI で初期セット 24 点を一括導入 (UQ-I005-06):
   ```bash
   cd apps/web
   pnpm dlx shadcn@latest add button input label select checkbox form \
     dialog alert-dialog sheet drawer tabs tooltip popover calendar sonner \
     table badge skeleton scroll-area separator card dropdown-menu \
     navigation-menu command --overwrite false
   ```
   - 生成は `apps/web/components/ui/` 配下 (UQ-I005-07)
   - CLI 実行ログを全文 handoff.md に添付
   - `apps/web/lib/utils.ts` (cn helper) が生成される
8. 追加依存を入れる:
   ```bash
   pnpm add @tremor/react next-themes lucide-react sonner \
     react-hook-form zod @hookform/resolvers \
     tailwind-merge clsx class-variance-authority -F web
   ```
   (`@radix-ui/*` は shadcn CLI がすでに追加、独自追加禁止、UQ-I005-08)
9. `apps/web/components/theme-provider.tsx` を作成:
   ```tsx
   'use client';
   import { ThemeProvider as NextThemesProvider } from 'next-themes';
   import type { ThemeProviderProps } from 'next-themes';
   export function ThemeProvider({ children, ...props }: ThemeProviderProps) {
     return (
       <NextThemesProvider
         attribute="class"
         defaultTheme="system"
         enableSystem
         disableTransitionOnChange
         {...props}
       >
         {children}
       </NextThemesProvider>
     );
   }
   ```
10. `apps/web/app/layout.tsx` を modify:
    - `import './globals.css'` 追加
    - `<html lang="ja" suppressHydrationWarning>` に変更
    - `<body>` 内で `<ThemeProvider>` が children を wrap
11. `packages/ui` 側を更新:
    - `packages/ui/package.json`: `peerDependencies: { react: "^19", react-dom: "^19" }`、
      `dependencies: { recharts, tailwind-merge, clsx }`
    - `packages/ui/src/charts/theme.ts` (new):
      ```typescript
      export const chartTheme = {
        series: {
          income: 'var(--series-income)',
          networth: 'var(--series-networth)',
          cpi: 'var(--series-cpi)',
        },
      } as const;
      ```
      **実色値のハードコード禁止** (hex/rgb/hsl/oklch 直接値)
    - `packages/ui/src/index.ts` に barrel re-export 追加
12. contract.md の Verification commands 1〜13 を実行、全 PASS を確認
13. gui lane 起動準備: `head_commit` を記録し、`gui.md` の recipe に従って
    Claude が gui lane を走らせる (pinned commit)
14. 変更を 1 commit にまとめる。コミットメッセージ:
    `feat(web,ui): add Tailwind v4 + shadcn 24-piece + Tremor + themes (I-005)`
15. `status.yaml` を `state: implemented` / `head_commit: <sha>` /
    `gui_status: required` / `runtime_status: recorded` に更新
16. `handoff.md` 記入: 全依存採用 patch、shadcn CLI ログ、24 点実リスト、
    OKLCH 値リスト、次タスク I-006 への引き継ぎ (shadcn 生成物の lint 扱い)

## Stop conditions

- I-004 が merged でない
- runtime allocation が取得できない (APP_PORT 等が確保不能)
- shadcn CLI 実行が 2 回 serious failure (UQ-I005-02 再判定で手動に切替判断)
- 色値をハードコードしたくなった (hex/rgb/hsl/oklch 直接値を
  `theme.ts` やコンポーネントに書きたくなった) → stop
- shadcn プリミティブを `packages/ui` に置きたくなった (UQ-I003-05 違反、stop)
- `@radix-ui/*` を独自追加したくなった (UQ-I005-08、shadcn CLI 経由のみ)
- `packages/ui/src/components/` ディレクトリを作りたくなった (Forbidden)
- `@axe-core/playwright` を入れたくなった (I-007 / Wave 4)
- `eslint-plugin-tailwindcss` を入れたくなった (UQ-I006-05 不採用)
- `apps/web/app/page.tsx` をリデザインしたくなった (Wave 4)
- 24 点の一部が shadcn CLI で取得できない (planning 差し戻し or 手動書き)
- Verification commands のいずれかが PASS しない、かつ 2 回の serious attempt
  でも解消できない

停止時は `handoff.md` を作成し `status.yaml` を `blocked` に更新、
runtime allocation を解放 (`scripts/harness/release-runtime`)。
