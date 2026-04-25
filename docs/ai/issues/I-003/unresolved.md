# Unresolved: I-003

## UQ-I003-01: 4 パッケージの name（I-002 UQ-I002-02 連動）

- 論点: `@repo/core`, `@repo/db`, `@repo/ingestion`, `@repo/ui` の採用可否
- 推奨: I-002 で `@repo/*` が確定したならそのまま継承
- 要人間判断: **no**（I-002 の判断に従属）

## UQ-I003-02: `src/` レイアウト雛形

- 論点: skeleton で `src/index.ts` のみにするか、sub-directory を切るか
- 候補:
  - (a) `src/index.ts` のみ（最小）
  - (b) `src/index.ts` + 典型的 sub-dir（例: `core/internal/`, `ui/charts/`）
- 推奨: **(a) 最小**。Wave 1 以降で実コードを書く人間/AI が必要に応じて作る。
- 要人間判断: **no**

## UQ-I003-03: `packages/core` の test ディレクトリ

- 論点: skeleton で `packages/core/test/golden/` を空 dir として作っておくか
- 推奨: **作らない**。Wave 1 で golden fixture を作る別タスクが来たときに一緒に作る。
- 要人間判断: **no**

## UQ-I003-04: `packages/ui/tailwind.config.ts` を置くか

- 論点: skeleton で Tailwind config を置くか
- 推奨: **置かない**。I-005（UI スタック初期化）の領分。
- 要人間判断: **no**

## UQ-I003-05: `packages/ui` と `apps/web` の責務境界

- 論点: shadcn/ui の生成物を `packages/ui/src/components/` と
  `apps/web/components/` のどちらに落とすか
- shadcn/ui 公式推奨: `apps/web/components/ui/` 直下（アプリ単位）
- プロジェクト規約: `packages/ui` は共通コンポーネント用と v0.2 §15.1 に記載
- 候補:
  - (a) shadcn プリミティブは `packages/ui/src/components/`、
    app 固有コンポーネントは `apps/web/components/`
  - (b) shadcn プリミティブも含め `apps/web/components/ui/` に全て、
    `packages/ui` はチャート共通ラッパー等のみ
- 推奨: **(b)**。shadcn/ui は「コード全コピー」前提で、app 単位で自由に
  カスタムする設計なので、`apps/web` 側に置く方が shadcn の設計思想と整合。
  `packages/ui` は Appendix B §B.4 の `charts/theme.ts` + Recharts 共通ラッパー等、
  app 非依存の再利用部品のみを持たせる。
- 要人間判断: **yes**（I-005 shaping 時に確定する前にここで合意が必要）
- 影響先: I-005, 将来の UI 共通化

## 解消の期限

全 UQ は I-003 `ready-for-impl` 遷移時までに contract.md 反映。
UQ-I003-05 のみ I-005 にも影響するため、Wave 0 planning 前までに優先解消。
