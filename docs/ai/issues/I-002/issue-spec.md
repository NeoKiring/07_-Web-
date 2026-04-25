# Issue Spec: I-002

- title: packages/types skeleton + TypeScript project references base
- area: packages/types
- slug: packages-types-skeleton
- batch id: BATCH-WAVE0
- derived from: 要件定義 v0.2 §15.1, §15.4 (`packages/types` 最優先・単独実行),
  §15.6 (公開 API 型定義固定), NFR-005 (strict mode), Appendix A §A.2
- harness: v4.1-p0-tool-ownership

## Background

要件定義 v0.2 §15.4 で `packages/types` は「**最優先・単独実行**」と指定されており、
Wave 1 以降の全 package（`core` / `db` / `ingestion` / `ui`）と `apps/web` は
`packages/types` を共通契約として参照する。

一方で Appendix A §A.2 のドメイン型（`Amount` / `YearMonth` / `CurrencyCode` /
`Income` / `Asset` / `Liability` / `CPISeries` / `ForexRate` / `RealValueResult`
/ `NormalizedSeries` / `ComparisonSeries` / `Granularity` / `IncomeType`）は
`@prisma/client/runtime/library` の `Decimal` に依存する。Prisma client は Wave 2
で生成されるため、Appendix A §A.2 の完全実装は Wave 1 の開始前提になれない。

したがって I-002 は **skeleton のみ** を扱う。具体的には、
- 空の `packages/types` パッケージを作る
- TypeScript の strict 設定と project references の土台を root に置く
- 他 package / apps が `@repo/types`（または命名規約に従ったエイリアス）として
  workspace 解決できる状態にする

Appendix A §A.2 のドメイン型実体化は Wave 1 の別タスク（本 Batch の対象外）に分離する。
これにより I-002 は Prisma 依存を引き込まずに閉じられ、serial-only 領域の触り幅を最小化できる。

## Objective

以下 2 つを 1 commit で満たす:

1. `packages/types` が workspace package として解決可能な空骨子を持つ
2. root に TypeScript strict 設定 (`tsconfig.base.json`) と project references
   (`tsconfig.json`) の土台があり、以降の package が `extends` / `references`
   で参加できる

## Scope

- `packages/types/package.json`（新規）: name, version, main/types, private:true
- `packages/types/tsconfig.json`（新規）: `extends: "../../tsconfig.base.json"`、
  composite:true、outDir
- `packages/types/src/index.ts`（新規）: placeholder 1 行（例: `export {};`）
- `tsconfig.base.json`（新規）: NFR-005 に合致する strict 設定
- `tsconfig.json`（新規、repo root）: project references の親、`references` に
  `packages/types` のみを登録（I-003 以降で他 package が追加される）
- root `package.json` への `"devDependencies": { "typescript": "x.y.z" }` 追加
  （UQ-I002-01 で具体版を決定）

## Out of scope

- Appendix A §A.2 のドメイン型実体定義（`Amount` / `YearMonth` / ... すべて）
  → Wave 1 で別タスクとして shaping する
- `@prisma/client/runtime/library` からの `Decimal` import の解決（Prisma client は Wave 2）
- `packages/core` / `packages/db` / `packages/ingestion` / `packages/ui` の
  tsconfig / package.json（→ I-003）
- `apps/web` の tsconfig（→ I-004）
- Zod スキーマと型の二重定義回避ルール（`z.infer<typeof ...>` 方針）
  → Wave 1 の型実体化時に適用
- `Decimal` 型強制 ESLint カスタムルール（→ I-006）
- ゴールデンテストのフィクスチャ（→ Wave 1）
- `pnpm install` の明示実行（Anchor 5、操作者の明示指示に依存）

## Done definition

- `packages/types/package.json` が以下を満たす:
  - `"name"` がプロジェクト命名規約に従う（候補: `@repo/types` / `@inflation/types`、UQ-I002-02）
  - `"private": true`
  - `"version": "0.0.0"` または `"0.1.0"`
  - `"main"` / `"types"` / `"exports"` のいずれかが `src/index.ts` または `dist/index.d.ts` を指す
  - 依存は typescript のみ（devDep）、他 package への依存なし
- `packages/types/tsconfig.json` が `../../tsconfig.base.json` を `extends`
- `packages/types/src/index.ts` が存在し、少なくとも `export {};` を含む
- `tsconfig.base.json` が以下の strict 設定を含む:
  - `"strict": true`
  - `"noUncheckedIndexedAccess": true`
  - `"exactOptionalPropertyTypes": true`（UQ-I002-03 で最終確認）
  - `"isolatedModules": true`
  - `"skipLibCheck": true`
  - `"moduleResolution": "bundler"` または `"nodenext"`（UQ-I002-04）
  - `"target": "ES2022"` 以上
- root `tsconfig.json` が project references を持ち、`packages/types` を含む
- root `package.json` の `devDependencies.typescript` が pin 済み
- `tsc --noEmit -p packages/types` が 0 exit
- `tsc -b --dry` が 0 exit（build graph が整合）
- `scripts/harness/validate-task-artifacts` が I-002 に対して PASS

## Risks

- **R-I002-01**: Appendix A §A.2 の型を「skeleton」と称してここで書いてしまうと、
  Prisma `Decimal` 未解決で I-002 が自己完結できなくなる
  → Out of scope に明記。review focus にも挙げる。
- **R-I002-02**: `tsconfig.base.json` は global shared settings で serial-only。
  I-003 以降で `module` / `moduleResolution` / `paths` を後から書き換えると
  全 package の型解決が動く可能性がある
  → planning 時点で「Wave 0 期間中の再変更は serial 管理」と明記。
- **R-I002-03**: project references の使い方ミスで循環参照 / watch パフォーマンス悪化
  → skeleton 段階ではリーフ（packages/types）のみ登録、依存方向は後続タスクで積む。
- **R-I002-04**: `exactOptionalPropertyTypes: true` は Appendix A §A.2 の
  `memo?: string` 等に影響する。planning 時に副作用を確認。

## Unresolved questions

- UQ-I002-01: typescript のバージョン（候補: 5.5.x / 5.6.x）
- UQ-I002-02: workspace package の scope/name 規約（`@repo/types` / `@inflation/types` /
  他）。以降の I-003 以降も同一規約に従う
- UQ-I002-03: `exactOptionalPropertyTypes` を true にするか
  （Appendix A §A.2 の optional プロパティ表現と衝突しないかの確認が必要）
- UQ-I002-04: `moduleResolution` に `bundler` と `nodenext` のどちらを選ぶか
  （Next.js 15 / Prisma / Vitest の推奨と整合性確認）
- UQ-I002-05: `pnpm-lock.yaml` の初期化がこのタスクで発生するか
  （UQ-I001-03 との連動。operator が `pnpm install` を明示実行するタイミング）
- UQ-I002-06: `packages/types/package.json` の `exports` フィールド方針
  （`"./*"` で barrel + sub-path どちらも、`"."` のみで barrel のみ、等）

## References

- `requirements_v0.2.md` §15.1, §15.2 (Wave 1), §15.4, §15.5, §15.6,
  NFR-004 (`packages/core` の UI/DB 非依存), NFR-005 (strict mode)
- `requirements_v0.2_appendix_A_technical.md` §A.2 (TypeScript ドメイン型),
  §A.7 (Wave 0 〜 3 着手前チェックリスト)
- `docs/harness/FOUNDATION.md` Anchor 4 (Serial-only: shared tsconfig / root manifest)
- `docs/ai/tasks/I-001/contract.stub.md` (前提: pnpm workspace / root manifest)
