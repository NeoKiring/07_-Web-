# Unresolved: I-004

## UQ-I004-01: `apps/web/package.json` の name

- 候補: `@repo/web` / `web` / `@repo/apps-web`
- 推奨: **`@repo/web`**（packages/* と scope 統一）
- 要人間判断: **no**（I-002 UQ-I002-02 に連動）

## UQ-I004-02: `next.config` の拡張子

- 候補: `.js` / `.ts` / `.mjs`
- 推奨: **`.ts`**（Next.js 15 stable）
- 要人間判断: **no**

## UQ-I004-03: `src/` layout vs flat layout

- 論点: `apps/web/app/` か `apps/web/src/app/` か
- 推奨: **`apps/web/app/`**（Appendix B §B.1.3 と shadcn/ui CLI デフォルトと整合）
- 要人間判断: **yes**（Wave 4 の全画面タスクに波及）

## UQ-I004-04: Next.js のバージョン

- 候補: 15.x
- 推奨: **Next.js 15 の最新 patch**
- 要人間判断: **yes**

## UQ-I004-05: 初期化方法

- 候補:
  - (a) `create-next-app --tailwind false --eslint false --turbopack --app`
  - (b) 手動で `package.json` を書き `pnpm add next react react-dom -F web`
- 推奨: **(b) 手動**。触るファイルを制御しやすく、Anchor 5 との整合が良い
- 要人間判断: **yes**

## UQ-I004-06: `apps/web/package.json` の scripts 最小セット

- 候補:
  - (a) `dev` / `build` / `start` / `typecheck` の 4 つ
  - (b) 上記 + `lint`（I-006 で実体化予定）
- 推奨: **(a) 4 つ**。lint は I-006 の追加で埋める
- 要人間判断: **no**

## 解消の期限

全 UQ は I-004 `ready-for-impl` 遷移時までに contract.md 反映。
