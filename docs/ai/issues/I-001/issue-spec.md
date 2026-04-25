# Issue Spec: I-001

- title: monorepo skeleton (pnpm workspace + root configs)
- area: infra/monorepo
- slug: monorepo-skeleton
- batch id: BATCH-WAVE0
- derived from: 要件定義 v0.2 §15.1 (module layout), §15.2 (Wave 0), NFR-003, NFR-005
- harness: v4.1-p0-tool-ownership

## Background

「資産・収入インフレ影響可視化プラットフォーム」の Wave 0 最初のタスク。
要件定義 v0.2 §15.1 および Appendix A §A.7 は、このリポジトリが pnpm monorepo
で運用されることを前提としている。以降の全 Wave（`packages/types` /
`packages/core` / `packages/db` / `packages/ingestion` / `packages/ui` /
`apps/web`）は、このタスクで確定する workspace / root configs / package manager
設定に乗ることになる。

このタスクの成否は Wave 0 の他タスク（I-002〜I-007）の前提であり、ここでの不整合
（例：pnpm と npm の混在、Node バージョンの未固定、.gitignore の欠落）は下流で
serial-only な再修正を強いる。したがって Wave 0 の最初に serial で完了させる。

本タスクは **skeleton のみ** を扱い、packages の中身・Next.js の実体・Tailwind
初期化・UI スタック・Lint/CI は扱わない。それぞれ I-002 以降に分離する。

## Objective

pnpm monorepo の root レイヤに、以降のすべてのタスクが依存してよい
「空の workspace 骨格」を 1 commit で確定する。具体的には以下を満たす。

- `pnpm-workspace.yaml` が `apps/*` と `packages/*` を含む
- root `package.json` が private:true で、pnpm を `packageManager` として固定
- Node バージョンが `.nvmrc` で固定される
- `.gitignore` が NFR-003 の要件（`.env*`, `prisma/dev.db`, `backups/`, `logs/`,
  `.runtime/`, `.worktrees/` などのハーネス生成物含む）を満たす
- `.editorconfig` が UTF-8 / LF / 末尾改行ありを強制
- `.env.example` が実在し、e-Stat API キーの placeholder を含む

このタスクが完了すると、I-002 以降の `impl` lane が `pnpm add -w -D <pkg>` や
`pnpm -F <pkg>` を問題なく呼べる状態になる。

## Scope

- `pnpm-workspace.yaml` の新規作成
- root `package.json` の新規作成（private:true / packageManager 固定 / scripts は空の骨格のみ）
- `.gitignore` の新規作成（下記 Done definition 参照）
- `.editorconfig` の新規作成
- `.nvmrc` の新規作成
- `.env.example` の新規作成（APIキー等の placeholder のみ、値は書かない）
- `README.md` の新規作成または最小更新（リポジトリ直下の短い navigational README）

## Out of scope

- `apps/web` ディレクトリ内のいかなる変更（→ I-004）
- `packages/*` ディレクトリ内のいかなる変更（→ I-002 / I-003）
- TypeScript の base tsconfig 作成（→ I-002 で `packages/types` と同時に導入）
- ESLint / Prettier / husky / lint-staged / commitlint（→ I-006）
- GitHub Actions workflow（→ I-007）
- Prisma 初期化 / SQLite 設定（→ Wave 2）
- shadcn/ui CLI 実行 / Tailwind 初期化（→ I-005）
- 依存パッケージの実 install（`pnpm install` の実行は Done definition の対象外、
  `packageManager` 宣言の存在のみを対象とする。Anchor 5: bootstrap は暗黙 install しない）
- プロジェクト supplement ドキュメント（→ I-008）

## Done definition

- `pnpm-workspace.yaml` に `apps/*` と `packages/*` が含まれる
- root `package.json` が以下を満たす:
  - `"private": true`
  - `"packageManager"` に pnpm バージョンを固定（候補: `pnpm@9.x`、Wave 0 planning
    時に決定）
  - `"engines.node"` に Node LTS 範囲を指定
  - `"scripts"` は空または `build` / `test` / `lint` / `typecheck` の stub のみ
    （中身は no-op でよい、I-006/I-007 で埋める）
- `.nvmrc` が `"engines.node"` と矛盾しない Node LTS 値を持つ
- `.gitignore` が以下を含む:
  - `node_modules/`
  - `.pnpm-store/`
  - `.next/`
  - `dist/`, `build/`
  - `.env`, `.env.*.local`, `.env.local`（ただし `.env.example` は除外されない）
  - `prisma/dev.db`, `prisma/*.db-journal`
  - `backups/`
  - `logs/`
  - `.runtime/`（ハーネス runtime allocation）
  - `.worktrees/`（ハーネス inspection worktree）
  - `.DS_Store`, `Thumbs.db`
  - `coverage/`
  - IDE 系（`.vscode/` の扱いは planning 時確認、現状は無視に倒す）
- `.editorconfig` が UTF-8 / LF / `insert_final_newline = true` / `trim_trailing_whitespace = true` を持つ
- `.env.example` に以下の placeholder キーが書かれている（値は空）:
  - `ESTAT_API_KEY=`
  - `DATABASE_URL=`
- `README.md` が少なくとも以下を含む:
  - プロジェクト名
  - Phase A/B 概要 1 段落
  - `pnpm` での初期 setup 手順の短い案内（実 install コマンドは呼ばず提示のみ）
  - 要件定義 / Appendix A / Appendix B のリンク（relative path）
- ハーネス同梱の `README_bundle.md` / `docs/harness/**` / `AGENTS.md` /
  `CLAUDE.md` / `CODEX.md` は本タスクで改変しない
- `scripts/harness/validate-task-artifacts` が本 task ID に対して PASS

## Risks

- **R-I001-01**: pnpm バージョンの揺れ（オペレータ環境 / CI / 各 impl lane 間）
  → `packageManager` を固定し、`.nvmrc` と合わせて揃える。planning 時に具体 version を決定。
- **R-I001-02**: `.gitignore` の漏れ（個人データ混入）
  → NFR-003 は最高優先度ではないが Phase A のセキュリティ制約として明記されている。
  Done definition の `.gitignore` エントリーは NFR-003 を満たす最小セット。
- **R-I001-03**: Anchor 4 (serial-only) の意識不足
  → このタスクは明確に serial-only area（root manifest）に触れる。Wave 0 の他タスクと
  並列実行しないことを contract に明記する。
- **R-I001-04**: Anchor 5 (no implicit install) 違反
  → skeleton 段階で `pnpm install` を自動実行しないこと。`pnpm-lock.yaml` の新規作成は
  本タスクの Done definition に含めない（I-006 以降のいずれかで自然発生する）。

## Unresolved questions

- UQ-I001-01: pnpm の正確なメジャー/マイナーバージョン（候補 9.x / 10.x）
- UQ-I001-02: Node LTS の具体的値（候補 20.x / 22.x）
- UQ-I001-03: `packageManager` 宣言のみで stop するか、最初の `pnpm install` を
  人間オペレータが明示的に実行するフローとするか（Anchor 5 的には後者推奨）
- UQ-I001-04: `.vscode/` を ignore するかコミットするか
- UQ-I001-05: `README.md` の英/日言語方針（v0.2 は日本語、ハーネス文書は英日混在）

## References

- `requirements_v0.2.md` §11 (技術制約), §15.1 (module layout), §15.2 (Wave 0),
  NFR-003 (Phase A セキュリティチェックリスト), NFR-005 (AI主体開発対応),
  NFR-008 (対応環境: Node LTS)
- `requirements_v0.2_appendix_A_technical.md` §A.7 (Wave 0 〜 Wave 3 着手前チェックリスト)
- `docs/harness/FOUNDATION.md` Anchor 4 (Serial-only), Anchor 5 (No implicit installs)
- `docs/harness/policies/serial-only-areas.md`
- `docs/harness/templates/contract.template.md`
