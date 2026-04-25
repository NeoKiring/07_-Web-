# Unresolved: I-005

## UQ-I005-01: Tailwind v4 vs v3

- 論点: Tailwind の major バージョン
- 推奨: **v4**。Appendix B §B.4 が v4 の `@theme` / PostCSS 前提で記述されている
- 要人間判断: **yes**

## UQ-I005-02: shadcn/ui CLI 利用可否

- 論点: CLI (`pnpm dlx shadcn@latest add`) を使うか、`.tsx` を手動複製するか
- 推奨: **CLI 採用**、ただし `components.json` は先に commit しておく
- 要人間判断: **yes**（Anchor 5 との関係で CLI 実行タイミングを planning で明記）

## UQ-I005-03: `next-themes` の attribute

- 候補: `class` / `data-theme`
- 推奨: **`class`**（Tailwind dark variant と整合）
- 要人間判断: **no**

## UQ-I005-04: カラー値の色空間表現

- 候補: OKLCH / HSL / RGB
- 推奨: **OKLCH**（shadcn/ui 2.x デフォルト、WCAG Level AA のコントラスト
  計算で安定）
- 要人間判断: **no**

## UQ-I005-05: `packages/ui/src/charts/theme.ts` の実装深度

- 候補:
  - (a) export 構造のみ、値は Wave 4 で
  - (b) 実値まで埋める（CSS 変数から参照する色値のオブジェクト化）
- 推奨: **(a)**。Wave 4 の Recharts 実ラッパータスクと一緒に埋める方が整合
- 要人間判断: **no**

## UQ-I005-06: shadcn 初期セット 24 点の一括導入

- 候補: 一括 / 段階追加
- 推奨: **一括**。Appendix B §B.4.2 の初期セット前提と整合
- 要人間判断: **yes**（24 点の review 工数が review lane にかかる）

## UQ-I005-07: 初期コンポーネントの `apps/web/components/ui/` 配置確定

- I-003 UQ-I003-05 で「shadcn は apps/web 側」が暫定推奨
- ここで最終確定してから I-005 に入る
- 要人間判断: **yes**（最終確認レベル）

## UQ-I005-08: `@radix-ui/*` の個別 pin か shadcn CLI 任せか

- 候補: 各 @radix-ui/* を package.json に明示 pin / shadcn が追加したまま
- 推奨: **shadcn CLI に任せる**。依存管理は shadcn/ui の既定運用に乗る
- 要人間判断: **no**

## 解消の期限

全 UQ は I-005 `ready-for-impl` 遷移時までに contract.md 反映。
UQ-I005-01（Tailwind v4）と UQ-I005-07（配置）は Wave 4 への波及大、優先解消。
