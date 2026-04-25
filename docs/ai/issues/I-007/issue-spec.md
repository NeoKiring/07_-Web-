# Issue Spec: I-007

- title: GitHub Actions CI (typecheck / lint / vitest / playwright+axe scaffolding)
- area: infra/ci
- slug: infra-ci-actions
- batch id: BATCH-WAVE0
- derived from: 要件定義 v0.2 NFR-005 (CI で型検査・Lint・テスト合格),
  Appendix A §A.5 NFR-005 (CI カバレッジ 80% 強制),
  Appendix B §B.4.7 (`@axe-core/playwright` CI 導入), §B.5.2 層 5 (CI 強制)
- harness: v4.1-p0-tool-ownership

## Background

I-006 でローカル側の静的解析と pre-commit hook が効く。I-007 はこれを CI
（GitHub Actions）に持ち上げ、PR / push で自動走行する状態を作る。

Appendix B §B.4.7 の A11y 自動検証（`@axe-core/playwright`）は Wave 4 で
具体ページに対して実施するが、I-007 ではワークフロー骨格のみ用意する
（空の e2e テストを 1 本流し、将来 Wave 4 が追加したテストがその場で
走るように配線）。

Vitest のカバレッジ 80% 強制（NFR-005）は `packages/core` 実装開始時に
意味を持つ。I-007 段階ではまだ core の実装が無いため、カバレッジチェックは
**ワークフローとして用意はするが閾値は `packages/core` 対象のみ、かつ
`packages/core/src/` が空の段階では strict 失敗しないよう** にしておく。
具体設定は UQ。

## Objective

以下を 1 commit で満たす:
1. PR / push で `typecheck` / `lint` / `format:check` / `test` が並列実行
2. `build`（`pnpm --filter web build`）が別 job として走る
3. e2e の scaffold（Playwright + `@axe-core/playwright` の最小 1 テスト）
4. 上記すべての結果がブランチ保護ルールに使える状態

## Scope

- `.github/workflows/ci.yml`（新規、メイン CI）
  - `typecheck` job
  - `lint` job
  - `format-check` job
  - `test` job（`pnpm -r test`、Vitest 雛形）
  - `build` job（`pnpm --filter web build`）
  - `e2e` job（Playwright + axe の最小テスト、Wave 4 で拡張）
- `.github/workflows/release.yml`（保留）※ P0 非目標
- Playwright 初期設定:
  - `apps/web/playwright.config.ts`（新規、ポート / baseURL / A11y 設定）
  - `apps/web/e2e/smoke.spec.ts`（新規、最小 smoke テスト + axe scan）
  - `apps/web/package.json`（modify）: `e2e` script、`@playwright/test`,
    `@axe-core/playwright` devDep 追加
- Vitest 初期設定:
  - `vitest.workspace.ts`（新規、root）
  - `packages/core/vitest.config.ts`（新規、雛形）
  - `packages/core/package.json`（modify）: `test`, `test:coverage` script、
    `vitest`, `@vitest/coverage-v8` devDep 追加
- `pnpm-lock.yaml`（modify）

## Out of scope

- `packages/core` の実テストコード（→ Wave 1）
- Vitest カバレッジ閾値 80% の厳格強制（→ Wave 1 の core 実装タスクで調整）
- 各画面の A11y e2e テスト（→ Wave 4）
- Playwright の Visual Regression
- release / publish workflow（P0 非目標）
- Lighthouse の CI 組込み（Wave 4）
- matrix build（OS × Node）は UQ、推奨は Linux の単一 matrix のみ
- Preview deploy（Vercel 等、Phase B）
- Security scanning（CodeQL / Dependabot、Phase B で判断）

## Done definition

- `.github/workflows/ci.yml` が存在し、以下 6 job を含む:
  - `typecheck`: `pnpm -r typecheck`
  - `lint`: `pnpm lint`
  - `format-check`: `pnpm format:check`
  - `test`: `pnpm -r test`（Vitest 雛形）
  - `build`: `pnpm --filter web build`
  - `e2e`: Playwright 起動 + smoke spec + axe scan が 0 exit
- 各 job で `pnpm install --frozen-lockfile` を明示実行（Anchor 5 の CI 版
  遵守：CI は明示的に install を呼ぶ）
- Node バージョンは I-001 の `.nvmrc` と一致（action で `.nvmrc` 参照）
- pnpm バージョンは I-001 の `packageManager` と一致
- `apps/web/playwright.config.ts` が webServer 起動を含む
- `apps/web/e2e/smoke.spec.ts` が:
  - `/` にアクセス
  - `AxeBuilder` で A11y 違反 0 を assertion（warning でも可、UQ-I007-03）
- `vitest.workspace.ts` が `packages/core` を含む
- `packages/core/vitest.config.ts` がカバレッジ provider v8 を指定
- ローカルで `pnpm -r test` が 0 exit（packages/core の空 src で空 pass）
- ローカルで `pnpm --filter web e2e` が 0 exit（localhost 起動→axe scan）
- I-001〜I-006 の成果物に回帰なし
- `scripts/harness/validate-task-artifacts` が I-007 に対して PASS

## Risks

- **R-I007-01**: CI で runtime 競合（複数 job 同時実行時の port 衝突）
  → 各 job は別 runner で独立実行されるため発生しないが、matrix で並列時の
    ポート衝突は planning で確認
- **R-I007-02**: Playwright のブラウザインストール（`pnpm exec playwright install`）
  のキャッシュ戦略
  → GitHub Actions の `cache: playwright-browsers` パターンを使用
- **R-I007-03**: `@axe-core/playwright` の smoke テストが I-005 の UI 初期状態で
  警告を出す（ランドマーク不足等）
  → planning 時に初期ページの構造を確認。必要なら I-005 に back-port、または
    UQ-I007-03 で warning 扱い
- **R-I007-04**: `frozen-lockfile` がローカルとの差異で失敗する
  → impl lane は必ず `pnpm install` 後にコミット、その状態で CI に載せる
- **R-I007-05**: Vitest カバレッジ閾値が core 空状態で無条件失敗
  → I-007 では閾値を設定しない（または 0 に設定）、Wave 1 で閾値追加

## Unresolved questions

- UQ-I007-01: Node / pnpm バージョンの固定方法
  - 候補: (a) `.nvmrc` / `packageManager` から action で動的取得 /
    (b) workflow 内にハードコード
  - 推奨: **(a)**（単一ソース。I-001 の成果と整合）
- UQ-I007-02: Playwright のブラウザキャッシュ
  - 推奨: `actions/cache` で `~/.cache/ms-playwright` を key にキャッシュ
- UQ-I007-03: axe smoke テストの失敗レベル
  - 候補: (a) violation 0 を厳格に assertion / (b) warning を許容、impact=serious 以上のみ fail
  - 推奨: **(b)**。Wave 4 の実画面タスクで (a) に強化
- UQ-I007-04: `packages/core/vitest.config.ts` のカバレッジ閾値
  - 候補: 設定しない / 0 に設定 / 80 に設定（Wave 1 で厳格化）
  - 推奨: **設定しない（または 0）**、Wave 1 で 80 に引き上げ
- UQ-I007-05: matrix build（OS × Node）
  - 候補: ubuntu-latest のみ / ubuntu + windows-latest（Windows first-class）
  - 推奨: **ubuntu-latest のみ**（Phase A）。Windows は I-001 / I-006 の
    husky 動作を人間オペレータが局所的に検証する運用で代替

## References

- `requirements_v0.2.md` NFR-005, NFR-008
- `requirements_v0.2_appendix_A_technical.md` §A.5 NFR-005 (カバレッジ強制)
- `requirements_v0.2_appendix_B_ux.md` §B.4.7 (`@axe-core/playwright`),
  §B.5.2 層 5 (CI 強制)
- `docs/ai/tasks/I-006/contract.stub.md` (前提: ローカル lint / format / commitlint)
- `docs/harness/policies/runtime-isolation.md` (CI は別 runner で独立)
