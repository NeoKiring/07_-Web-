# Issue Spec: I-006

- title: quality tooling (ESLint + Prettier + husky + lint-staged + commitlint)
- area: infra/quality
- slug: infra-quality-tooling
- batch id: BATCH-WAVE0
- derived from: 要件定義 v0.2 NFR-003 (Phase A セキュリティ・pre-commit 検査),
  NFR-005 (AI 主体開発対応・ESLint カスタムルール),
  Appendix A §A.5 NFR-005 (Decimal 型強制、Commit 規約),
  Appendix B §B.5.2 層 1 (仕様ロック・Conventional Commits)
- harness: v4.1-p0-tool-ownership

## Background

要件定義 v0.2 NFR-003 は Phase A のセキュリティ要件として「pre-commit フック
で `dev.db` / `.sqlite` / `.env` の混入を検査」を求め、NFR-005 は AI 主体開発
対応として ESLint strict / Prettier / Conventional Commits を規定する。
Appendix A §A.5 はさらに具体化し、`Decimal` 型強制（金額に `number` を
使わせない）の ESLint カスタムルール適用を指示する。
Appendix B §B.5.2 層 1 は Conventional Commits の scope 運用と `core!:` の
Draft PR 自動化を示唆する。

これらを 1 タスクにまとめる理由:
- ESLint / Prettier / husky / lint-staged / commitlint は互いに設定を参照し合う
- pre-commit hook が半端に効く状態は最悪（commit ごとに落ちる / 通らない）
- 層 1 のガードレールは一気通貫で仕上げないと AI impl lane で
  「通らない commit」が増える

ただし CI（GitHub Actions）への組込みは I-007 で分離する。
I-006 は「ローカル側の静的解析 + pre-commit 系」までが領分。

## Objective

以下 5 点をローカル開発で有効にする:
1. ESLint（TypeScript strict + `@typescript-eslint/strict` + カスタムルール）
2. Prettier（プロジェクト共通）
3. husky（git hooks マネージャ）
4. lint-staged（stage 済みファイルのみに Lint/Prettier 実行）
5. commitlint（Conventional Commits の強制、scope 対応）

加えて pre-commit で以下を検査:
- NFR-003: `.env*`, `*.sqlite`, `*.sqlite-journal`, `prisma/*.db`, `backups/*`
  のコミット禁止
- NFR-005: ESLint の `no-number-for-amount` カスタムルール相当（Appendix A §A.5）
  ※ Wave 1 着手前の段階なので、I-006 では**ルール骨子のみ作成し
  TODO コメントで有効化は Wave 1 に延期**

## Scope

- `eslint.config.js`（新規、ESLint flat config）
- `.prettierrc`（新規）
- `.prettierignore`（新規）
- `.husky/pre-commit`（新規、shell script）
- `.husky/commit-msg`（新規、commitlint）
- `commitlint.config.js`（新規）
- `lint-staged.config.js`（新規）
- `packages/eslint-config/` または `eslint.config.js` の中にインライン
  （UQ-I006-01）
- root `package.json`（modify）
  - devDep 追加: `eslint`, `@eslint/js`, `typescript-eslint`, `prettier`,
    `eslint-config-prettier`, `eslint-plugin-react`, `eslint-plugin-react-hooks`,
    `eslint-plugin-tailwindcss`（Tailwind v4 対応版、UQ-I006-05）,
    `husky`, `lint-staged`, `@commitlint/cli`, `@commitlint/config-conventional`
  - scripts 追加: `lint`, `lint:fix`, `format`, `format:check`, `prepare`（husky install）
- `apps/web/package.json`（modify）: `"scripts": { "lint": "..." }` が既に
  I-004 で入っていれば実体化のみ、無ければ追加
- `packages/*/package.json`（modify）: 同様に `lint`, `typecheck` スクリプトを追加
  （各 package ごとの 1 行 modify のみ、Out of scope 境界を守る）

## Out of scope

- GitHub Actions の CI workflow（→ I-007）
- Appendix A §A.5 の `no-number-for-amount` カスタムルールの**実装・有効化**
  → ルール骨子を `eslint.config.js` の TODO コメントで置くのみ、Wave 1 の
    `packages/types` 実装タスクが有効化する
- gitleaks 等、外部ツールによる機密スキャン
  → NFR-003 の pre-commit フックとしてはパターンマッチで十分、Phase B で検討
- `prettier-plugin-tailwindcss`（Tailwind class の自動ソート）
  → オプション扱い、Wave 4 で追加判断
- `changesets` / release automation
- `turbo` / `nx` 等の monorepo タスクランナー（pnpm script + `-r` で足りる前提）
- 統合テスト向け設定（Vitest / Playwright、→ Wave 1 / Wave 4 で個別導入）

## Done definition

- ESLint flat config が root に存在し、以下の基本ルールを適用:
  - `@typescript-eslint/strict`
  - `eslint-config-prettier` で Prettier 競合解消
  - React 系ルール（`react`, `react-hooks`）を `apps/web` / `packages/ui` に適用
  - `no-number-for-amount` 相当のカスタムルール骨子（TODO コメント付き）
- `pnpm lint` が全パッケージ横断で 0 exit
- `pnpm format:check` が 0 exit
- husky が `.husky/` 配下を管理、`prepare` スクリプトで `husky install` が走る
- `.husky/pre-commit` が以下を検査:
  - `lint-staged` の実行
  - NFR-003 のパターン検知（ステージ済みファイル名に `.env`, `*.sqlite`,
    `*.db-journal`, `backups/*` が含まれていたら reject）
- `.husky/commit-msg` が commitlint を呼ぶ
- `commitlint.config.js` が Conventional Commits を強制、scope リストを持つ
  （`core`, `db`, `ingestion`, `ui`, `types`, `web`, `infra`, `docs`, `deps`）
- `lint-staged.config.js` が TypeScript / TSX に ESLint + Prettier を割り当て
- `scripts/harness/validate-task-artifacts` が I-006 に対して PASS
- I-001〜I-005 の成果物に回帰なし

## Risks

- **R-I006-01**: ESLint flat config と既存エコシステム互換
  → 2026 年時点では flat config が標準。Next.js 15 / shadcn ともに対応済み
- **R-I006-02**: `eslint-plugin-tailwindcss` の Tailwind v4 対応有無
  → planning 時点で v4 対応状況を確認、未対応なら Wave 4 に延期し本タスクでは
    入れない
- **R-I006-03**: pre-commit hook が重すぎて開発者が `--no-verify` する
  → lint-staged で staged ファイルのみに限定、typecheck は pre-commit から除外
- **R-I006-04**: `no-number-for-amount` カスタムルールを今回有効化すると
  I-001〜I-005 の既存コードが落ちる可能性（特に Tremor の width/height 等）
  → 本タスクは骨子のみ、有効化は Wave 1 に委ねる
- **R-I006-05**: `prepare: "husky install"` が fresh clone 時の `pnpm install`
  依存になる
  → README.md に運用説明を追記するのは I-008 の領分、本タスクでは package.json
    の修正のみ

## Unresolved questions

- UQ-I006-01: ESLint config をどこに置くか
  - 候補: (a) root `eslint.config.js` に全集約 / (b) `packages/eslint-config/`
    として独立パッケージ化
  - 推奨: **(a)**（Wave 0 段階では過剰分離しない。必要になれば後で分離）
- UQ-I006-02: Prettier の設定内容
  - 推奨: `printWidth: 100`, `semi: true`, `singleQuote: true`, `trailingComma: "all"`
  - 要人間判断: **yes**
- UQ-I006-03: Conventional Commits の scope 一覧の最終決定
  - 推奨: `core`, `db`, `ingestion`, `ui`, `types`, `web`, `infra`, `docs`, `deps`
  - 要人間判断: **yes**（Appendix B §B.5.2 の「`core!:` は Draft PR」運用と一致）
- UQ-I006-04: pre-commit でのパターン検知の書式
  - 候補: (a) shell grep で staged name を検査 / (b) lint-staged のカスタム関数で検査
  - 推奨: **(a) shell grep**（依存が少なく、異常系の解釈が単純）
- UQ-I006-05: `eslint-plugin-tailwindcss` の採否
  - 候補: 採用（class 順序自動化）/ 不採用（Wave 4 まで保留）
  - 推奨: **不採用（Wave 4 判断）**。v4 対応が不十分な版を入れて後で直すより、
    Wave 4 で Tailwind 運用が固まってから導入する方が安全
- UQ-I006-06: `no-number-for-amount` カスタムルールの実装場所
  - 候補: flat config 内にインラインで書く / `packages/eslint-plugin-repo/` に分離
  - 推奨: **骨子は flat config 内にインライン、Wave 1 で有効化**

## References

- `requirements_v0.2.md` NFR-003, NFR-005, §15.6 (AI 主体開発時の注意点)
- `requirements_v0.2_appendix_A_technical.md` §A.5 NFR-005 (ガードレール詳細)
- `requirements_v0.2_appendix_B_ux.md` §B.5.2 層 1 (仕様ロック), 層 3 (型ロック)
- `docs/ai/tasks/I-002/contract.stub.md` (前提: tsconfig.base.json strict)
- `docs/ai/tasks/I-005/contract.stub.md` (前提: apps/web UI stack)
