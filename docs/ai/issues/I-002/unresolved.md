# Unresolved: I-002

## UQ-I002-01: typescript のバージョン

- 論点: `devDependencies.typescript` に pin する具体版
- 候補: `5.5.x` / `5.6.x`
- 影響: `moduleResolution: "bundler"` の対応、Next.js 15 / Prisma 5 系の型生成
- 推奨: **TypeScript 5.6 最新 patch**（Next.js 15 の公式推奨範囲）
- 要人間判断: **yes**（pinned version の最終確定）
- 参照: 要件 v0.2 NFR-005

## UQ-I002-02: workspace package の name 規約

- 論点: `packages/types/package.json` の `"name"` をどの scope で統一するか
- 候補:
  - (a) `@repo/types`（shadcn/ui の公式モノレポ template に準拠）
  - (b) `@inflation/types`（プロジェクトドメイン由来、読みやすい）
  - (c) `@<ghuser-or-org>/types`（将来 npm publish 時に自然）
- 影響: I-003 以降の全パッケージ名、apps/web からの import path
- 推奨: **(a) `@repo/types`**。理由:
  - ローカル限定の Phase A では org 名に悩まない
  - shadcn/ui 公式例に揃えると後続参照が楽
  - Phase B で外部公開時に rename する必要が出ても、scope 変更は比較的機械的
- 要人間判断: **yes**（Phase B 以降の命名ポリシーに影響）

## UQ-I002-03: `exactOptionalPropertyTypes` の扱い

- 論点: `tsconfig.base.json` で `"exactOptionalPropertyTypes": true` を有効化するか
- 影響:
  - Appendix A §A.2 の `memo?: string` / `grossBonusAmount?: Amount` /
    `interestRate?: number` が `undefined` 明示代入と衝突する可能性
  - Prisma から返る nullable field の扱いで余分な型狭め処理が必要になる場合あり
- 候補:
  - (a) true（最も厳しい）
  - (b) false（strict だけ有効にして、optional は緩める）
- 推奨: **(a) true**。Wave 1 の型実体化時に `memo?: string` を
  `memo: string | undefined` に書き直す手数は許容できる。NFR-005 の厳密化に寄与。
- 要人間判断: **yes**（Wave 1 以降のコーディングスタイルに直接影響）

## UQ-I002-04: `moduleResolution` の選択

- 論点: `tsconfig.base.json` の `moduleResolution`
- 候補:
  - (a) `"bundler"`（TypeScript 5.0+、bundler 前提。Next.js 公式推奨）
  - (b) `"nodenext"`（Node.js ネイティブ ESM 向け、拡張子付き import 必須）
- 影響:
  - Next.js 15 は `bundler` 推奨
  - Vitest は両対応だが `bundler` のほうが導入が軽い
  - Prisma client は両対応
- 推奨: **(a) `"bundler"`**。理由: Next.js 公式推奨 + I-005 の shadcn CLI 前提と整合。
- 要人間判断: **yes**（プロジェクト寿命全体に影響）

## UQ-I002-05: `pnpm-lock.yaml` の初期化タイミング

- 論点: I-002 で typescript を devDep として追加する時点で `pnpm install` を走らせるか
- ハーネス的制約: **Anchor 5（No implicit installs）**。bootstrap が勝手に install
  してはならないが、**operator が明示的に実行する分には構わない**
- 候補:
  - (a) I-002 の contract には含めず、operator が別途明示実行
  - (b) I-002 の Done definition に `pnpm install` の結果である `pnpm-lock.yaml`
    存在を含める（impl lane が明示的に `pnpm install -w` を実行する）
- 推奨: **(b)**。理由: I-002 で初めて devDep が発生するため、ここで
  `pnpm-lock.yaml` を初期化する方が自然。contract.md に「impl lane は `pnpm install -w`
  を 1 回、明示的に実行する」と書けば Anchor 5 違反にならない。
- 要人間判断: **yes**（UQ-I001-03 と連動）

## UQ-I002-06: `packages/types/package.json` の `exports` 方針

- 論点: barrel のみ / sub-path も許容 / `exports` を書かず `main`+`types` で済ませる
- 候補:
  - (a) `"exports": { ".": { "types": "./src/index.ts", "default": "./src/index.ts" } }`
    （barrel のみ、sub-path 禁止）
  - (b) `"exports": { ".": ..., "./*": ... }`（sub-path を許容）
  - (c) `main` + `types` のみ（legacy、小規模なら動く）
- 推奨: **(a) barrel のみ**。理由:
  - 要件 v0.2 §15.6「公開 API の型定義を固定」の強化
  - Appendix A §A.2 の型は全部 `packages/types/src/index.ts` から re-export させる
  - AI が勝手に sub-path import を増やして境界を曖昧にするのを防ぐ
- 要人間判断: **yes**（API 境界ポリシーに直結）

## 解消の期限

すべての UQ は I-002 `ready-for-impl` 遷移時までに contract.md 確定へ反映。
planning 時に判断不能なら `blocked`。
