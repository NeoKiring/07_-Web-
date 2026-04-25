# Issue Spec: I-003

- title: packages/{core,db,ingestion,ui} skeleton (rest of workspace packages)
- area: packages/*
- slug: packages-rest-skeleton
- batch id: BATCH-WAVE0
- derived from: 要件定義 v0.2 §15.1 (module layout), §15.4 / §15.5 (共有契約領域),
  NFR-004 (`packages/core` UI/DB 非依存)
- harness: v4.1-p0-tool-ownership

## Background

I-002 で `packages/types` と root の TypeScript 土台が出来る。I-003 は同じ土台の上に、
残り 4 パッケージ `packages/core` / `packages/db` / `packages/ingestion` / `packages/ui`
の「空骨子」を同時にまとめて追加する。

まとめて 1 タスクにする理由:
- 各パッケージの skeleton は pattern が同一（package.json / tsconfig.json / src/index.ts）
- root `tsconfig.json` の references に 4 行追加するのは 1 commit で閉じるのが素直
- serial-only（root `package.json` + root `tsconfig.json` + `pnpm-lock.yaml`）を
  4 回に割るメリットが無く、merge order が逆に複雑化する

Wave 1 以降の各 package の実体化（core のロジック、db の Prisma、ingestion の
API クライアント、ui のコンポーネント）はすべて本タスクの Out of scope である。

NFR-004 の「`packages/core` は UI/DB 非依存」は本タスクの段階ですでに
物理的に担保される（`core/package.json` の dependencies に `@repo/db` /
`@repo/ui` を書かない）。これは review focus とする。

## Objective

`packages/core` / `packages/db` / `packages/ingestion` / `packages/ui` の
4 パッケージを、I-002 の `tsconfig.base.json` / root `tsconfig.json` と
整合する形で空骨子として追加する。

## Scope

各パッケージにつき以下 3 ファイル、計 12 ファイル:
- `packages/<name>/package.json`
- `packages/<name>/tsconfig.json`（I-002 の base を extends）
- `packages/<name>/src/index.ts`（`export {};`）

加えて root ファイル 2 点の更新:
- root `tsconfig.json`（references に 4 パッケージを追加）
- root `package.json`（必要最小の devDep 追加のみ）

## Out of scope

- `packages/core`:
  - 実質額計算 (`calculateRealValue` / FR-007)
  - 純資産算出 (FR-015, BR-12)
  - 系列正規化・基準点切替 (FR-009)
  - 系列特性別集約 (FR-010, BR-06〜BR-11)
  - CPI 接続指数 (Appendix A §A.6 NEW-03)
  - ゴールデンテスト・フィクスチャ（test/golden/）
  - Zod スキーマ
- `packages/db`:
  - Prisma 初期化 (`prisma init`)
  - `prisma/schema.prisma` の作成・編集（Appendix A §A.1）
  - Prisma client 生成
  - リポジトリ層の実装
- `packages/ingestion`:
  - e-Stat クライアント (FR-005, Appendix A §A.3.1)
  - 日銀 API クライアント (FR-006, Appendix A §A.3.2)
  - `boj-series-map.ts`（NEW-01）
  - リトライロジック (`retry.ts`)
- `packages/ui`:
  - shadcn/ui CLI 初期化（→ I-005）
  - Tremor 導入（→ I-005）
  - Tailwind v4 設定（→ I-005）
  - `charts/theme.ts`、Recharts ラッパー
  - カラートークン CSS 変数（Appendix B §B.4.5、→ I-005）
- 各パッケージ間の依存関係宣言（`dependencies: { "@repo/types": "workspace:*" }` 等は
  現時点では書かない。Wave 1 以降の impl lane が必要に応じて追加する）
- Vitest / Playwright 設定ファイル
- ESLint / Prettier（→ I-006）
- `apps/web`（→ I-004）

## Done definition

- 4 パッケージ × 3 ファイル = 12 ファイルが存在
- 各 `packages/<name>/package.json` が:
  - `"name"` が I-002 で確定した scope 規約に従う（例: `@repo/core`, `@repo/db`,
    `@repo/ingestion`, `@repo/ui`）
  - `"private": true`, `"version": "0.0.0"`
  - `"exports"` が barrel のみ（I-002 UQ-I002-06 と同じ方針）
  - `"dependencies"` は空または `{}`（NFR-004 担保の最も強い形）
  - `"devDependencies"` は空または typescript のみ（root の hoist に任せるなら空）
- 各 `packages/<name>/tsconfig.json` が `../../tsconfig.base.json` を extends
- 各 `packages/<name>/src/index.ts` が `export {};` のみを含む
- root `tsconfig.json` の `references` に 4 パッケージが全て登録
- root `package.json` が破壊されていない（I-001 の scripts / I-002 の typescript devDep
  に影響なし）
- `pnpm -w tsc -b --dry` が 0 exit（project references graph 整合）
- `scripts/harness/validate-task-artifacts` が I-003 に対して PASS
- NFR-004 担保: `packages/core/package.json` の dependencies に `@repo/db` /
  `@repo/ui` / `@repo/ingestion` が含まれない

## Risks

- **R-I003-01**: 「ついでに」1 ファイル入れたくなる誘惑
  → Scope 条項 + Out of scope の詳細列挙で明示的にブロック。
- **R-I003-02**: `packages/ui/package.json` に React 依存を入れようとする
  → React 導入は I-004（apps/web）と I-005（UI スタック）の領分。dependencies 空で閉じる。
- **R-I003-03**: Prisma 依存誤導入
  → Prisma は Wave 2。`packages/db/package.json` の dependencies は空。
- **R-I003-04**: root `tsconfig.json` の references 書式ミス
  → planning 時に I-002 の書式を確定し、本タスクは 4 行の機械的追加で済むようにする。

## Unresolved questions

- UQ-I003-01: 4 パッケージの name 最終形（I-002 UQ-I002-02 に連動）
  - 推奨: `@repo/core` / `@repo/db` / `@repo/ingestion` / `@repo/ui`
- UQ-I003-02: 各 package の `src/` レイアウト雛形
  - 現時点は `src/index.ts` のみ。サブディレクトリ（`core/internal/`, `ui/charts/`）は
    Wave 1 以降で作る
- UQ-I003-03: `packages/core` の test ディレクトリを skeleton で先に作るか
  - 推奨: skeleton では作らない。Wave 1 開始時に `packages/core/test/golden/` を
    作るタスクで一緒に作る
- UQ-I003-04: `packages/ui` に Tailwind 設定の空ファイル (`tailwind.config.ts`) を
  skeleton で置くか
  - 推奨: 置かない。Tailwind 初期化は I-005 の領分、skeleton 段階で中途半端な
    設定を入れると I-005 で書き直しが発生する

## References

- `requirements_v0.2.md` §15.1, §15.2, §15.4, §15.5, §15.6,
  NFR-004 (`packages/core` UI/DB 非依存)
- `requirements_v0.2_appendix_A_technical.md` §A.1 (Prisma schema), §A.2 (types),
  §A.3 (API contracts), §A.6 (NEW-01, NEW-03)
- `requirements_v0.2_appendix_B_ux.md` §B.4 (UI コンポーネント採用ポリシー)
- `docs/ai/tasks/I-002/contract.stub.md` (前提: tsconfig.base.json, root tsconfig.json)
