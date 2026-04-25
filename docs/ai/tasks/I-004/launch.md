# Launch: I-004 impl

## Lane identity
- task id: I-004
- lane: impl
- tool: Codex
- writable: yes

## Branch / commit target
- implementation branch: `ai/apps/web/I-004-apps-web-next-init`
- target commit for inspection lanes: (to be set by impl after first commit)

## Worktree
- path: `.worktrees/I-004__impl`
- create command (Linux/mac):
  ```bash
  scripts/harness/new-impl-lane.sh I-004 apps/web apps-web-next-init main
  ```
- create command (Windows):
  ```powershell
  pwsh scripts/harness/new-impl-lane.ps1 -TaskId I-004 -Area apps/web -Slug apps-web-next-init -BaseBranch main
  ```

## Session name
`[I-004][impl][codex]`

## Read first
- `docs/harness/FOUNDATION.md` (Anchor 4/5)
- `AGENTS.md`, `CODEX.md`
- `docs/ai/tasks/I-004/contract.md` (finalized)
- `docs/ai/tasks/I-004/status.yaml`
- `docs/ai/tasks/I-003/handoff.md` (merged 後、`@repo/*` 命名規約と packages/ui
  の責務境界確認)
- `docs/ai/plans/BATCH-WAVE0/uq-decisions.md` (グループ 6 特に: flat layout,
  `next.config.ts`, 手動初期化, scripts 4 つ)
- 要件 v0.2 §11.1, Appendix B §B.1.3

## Start instruction

1. **前提確認**: I-003 merged 済みを `git log main` で確認、未 merge なら blocked
2. impl worktree に cd、`status.yaml` を `state: in-progress` に更新
3. **手動初期化** (UQ-I004-05 (b)、`create-next-app` 不使用)。以下を作成:
   - `apps/web/package.json`:
     ```json
     {
       "name": "@repo/web",
       "version": "0.0.0",
       "private": true,
       "scripts": {
         "dev": "next dev",
         "build": "next build",
         "start": "next start",
         "typecheck": "tsc --noEmit"
       },
       "dependencies": {
         "next": "15.x.y",
         "react": "19.x.y",
         "react-dom": "19.x.y"
       },
       "devDependencies": {
         "@types/node": "...",
         "@types/react": "...",
         "@types/react-dom": "..."
       }
     }
     ```
     - **`scripts.lint` は入れない** (I-006 で追加、UQ-I004-06)
     - UI 依存 (Tailwind, Tremor, next-themes 等) は一切入れない (I-005 領分)
   - `apps/web/tsconfig.json`:
     ```json
     {
       "extends": "../../tsconfig.base.json",
       "compilerOptions": {
         "jsx": "preserve",
         "incremental": true,
         "allowJs": false,
         "plugins": [{ "name": "next" }]
       },
       "include": ["next-env.d.ts", "app/**/*", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
       "exclude": ["node_modules"]
     }
     ```
   - `apps/web/next.config.ts` (**TypeScript 拡張子のみ**、UQ-I004-02):
     ```typescript
     import type { NextConfig } from 'next';
     const nextConfig: NextConfig = { reactStrictMode: true };
     export default nextConfig;
     ```
   - `apps/web/app/layout.tsx` (最小、`ThemeProvider` は入れない):
     ```tsx
     export default function RootLayout({ children }: { children: React.ReactNode }) {
       return (
         <html lang="ja">
           <body>{children}</body>
         </html>
       );
     }
     ```
   - `apps/web/app/page.tsx` (placeholder):
     ```tsx
     export default function Page() {
       return <main>資産・収入インフレ影響可視化プラットフォーム (placeholder)</main>;
     }
     ```
   - `apps/web/public/.gitkeep` (空ファイル)
4. `pnpm add next@15 react@19 react-dom@19 -F web` を実行、型定義も追加
5. `pnpm --filter web dev` を一度起動して `next-env.d.ts` を生成、commit する
   (Ctrl+C で即停止、localhost の応答確認は任意)
6. root `tsconfig.json` の `references` に `{ "path": "apps/web" }` を追加
   (I-003 の 5 references を維持)
7. contract.md の Verification commands 1〜12 を全て実行、全 PASS を確認
8. 変更を 1 commit にまとめる。コミットメッセージ:
   `feat(web): initialize Next.js 15 App Router bare skeleton (I-004)`
9. `status.yaml` を `state: implemented` に更新
10. `handoff.md` 記入: Next.js 採用 patch、手動初期化で進めた旨、
    次タスク I-005 で追加される依存予定一覧 (tailwindcss, @tremor/react,
    next-themes, lucide-react, sonner, react-hook-form, zod,
    @hookform/resolvers, tailwind-merge, clsx, class-variance-authority,
    @tailwindcss/postcss, postcss, @radix-ui/*)

## Stop conditions

- I-003 が merged でない
- `create-next-app` を使いたくなった (UQ-I004-05 (b) で禁止確定)
- Tailwind / shadcn / Tremor / next-themes を 1 行でも書いたら stop (I-005)
- `apps/web/app/globals.css` を作りたくなったら stop (I-005)
- `apps/web/components/` / `apps/web/lib/` ディレクトリを作りたくなったら stop (I-005)
- `apps/web/src/` ディレクトリを作りたくなったら stop (UQ-I004-03 で flat 確定)
- `apps/web/pages/` (Pages Router) を作りたくなったら stop
- `next.config` に `.js` / `.mjs` 拡張子を使いたくなったら stop
- `scripts.lint` を `apps/web/package.json` に入れたくなったら stop (I-006 の領分)
- Appendix B §B.1.3 の画面ディレクトリ (`dashboard/`, `input/`, `settings/`,
  `sources/`) を作りたくなったら stop (Wave 4)
- `prisma/**` 関連を触りたくなったら stop (Wave 2)
- Verification commands のいずれかが PASS しない、かつ 2 回の serious attempt
  でも解消できない

停止時は `handoff.md` を作成し `status.yaml` を `blocked` に更新。
