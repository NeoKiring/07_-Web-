# Task Contract: I-007

本ファイルは **stub**。`dev-plan` で finalized へ昇格。
Verification commands / Touched files / Forbidden files は
v0.2 + Appendix A/B レビュー済み前提での推定記述。

## Identity
- task id: I-007
- title: GitHub Actions CI (typecheck / lint / vitest / playwright+axe scaffolding)
- area: infra/ci
- slug: infra-ci-actions
- batch id: BATCH-WAVE0

## Objective

GitHub Actions で PR / push 時に `typecheck` / `lint` / `format-check` / `test` /
`build` / `e2e (playwright + axe)` が並列実行される状態を作る。e2e は最小 smoke
spec のみで、Wave 4 が追加する spec がそのまま走る配線に留める。

## Business / user value

Appendix B §B.5.2 層 5（CI 強制）の土台。ローカルで通らないコードが main に
入らない。Wave 4 以降で A11y 違反検知が自動化される下準備。

## In scope

- `.github/workflows/ci.yml` (new)
  - 6 job: `typecheck`, `lint`, `format-check`, `test`, `build`, `e2e`
  - `actions/checkout` / `pnpm/action-setup` / `actions/setup-node`
    （バージョンは `.nvmrc` と `packageManager` を参照、UQ-I007-01）
  - `concurrency`: `pr-${{ github.head_ref }}` + cancel-in-progress=true (UQ-I007-07)
  - matrix: `ubuntu-latest` のみ (UQ-I007-05)
- `apps/web/playwright.config.ts` (new)
  - webServer: `pnpm --filter web start`（build 済み前提）
  - baseURL, retries, reporter
- `apps/web/e2e/smoke.spec.ts` (new)
  - `/` にアクセス
  - `new AxeBuilder({ page }).analyze()` で scan
  - `impact: serious|critical` のみ fail (UQ-I007-03)
- `apps/web/package.json` (modify)
  - `scripts`: `e2e` (= `playwright test`), `e2e:install` (= `playwright install --with-deps`)
  - `devDependencies`: `@playwright/test`, `@axe-core/playwright`
- `vitest.workspace.ts` (new, root)
- `packages/core/vitest.config.ts` (new, 雛形。カバレッジ閾値は設定しない)
- `packages/core/package.json` (modify)
  - `scripts`: `test`, `test:coverage`
  - `devDependencies`: `vitest`, `@vitest/coverage-v8`
- `pnpm-lock.yaml` (modify)

## Out of scope

- `packages/core` の実テスト（→ Wave 1）
- カバレッジ閾値 80% の厳格強制（→ Wave 1）
- 各画面の A11y e2e（→ Wave 4）
- Visual Regression
- release / publish workflow
- Lighthouse CI
- Preview deploy
- Security scanning (CodeQL, Dependabot)
- CODEOWNERS / ruleset 作成 (UQ-I007-06)
- matrix build の OS 拡張（Phase A は ubuntu のみ）

## Touched files

- `.github/workflows/ci.yml` (new)
- `apps/web/playwright.config.ts` (new)
- `apps/web/e2e/smoke.spec.ts` (new)
- `apps/web/package.json` (modify)
- `vitest.workspace.ts` (new, root)
- `packages/core/vitest.config.ts` (new)
- `packages/core/package.json` (modify)
- `pnpm-lock.yaml` (modify)

## Forbidden files

- `docs/harness/**`, `AGENTS.md`, `CLAUDE.md`, `CODEX.md`, `.gtrconfig.v4`,
  `.claude/**`, `.codex/**`, `.agents/**`, `scripts/harness/**`,
  `.runtime/**`, `.worktrees/**`
- `docs/ai/tasks/**`（self 除く）, `docs/ai/issues/**`（self 除く）, `docs/ai/plans/**`
- `tsconfig.base.json`, root `tsconfig.json`, root `package.json`
  （root scripts は I-006 で揃えた前提、追加しない）
- `eslint.config.js`, `.prettierrc*`, `commitlint.config.js`, `lint-staged.config.js`,
  `.husky/**`（I-006 の領分）
- I-001〜I-005 の成果物（apps/web の globals.css / components / lib、
  packages/*/src, packages/*/tsconfig.json、tailwind.config.ts 等）
- `prisma/**`

## Serial-only areas touched
- yes
- details:
  - `pnpm-lock.yaml` (lockfile)
  - `apps/web/package.json` (package manifest、scripts + devDep 追加)
  - `packages/core/package.json` (package manifest)
  - `.github/workflows/ci.yml`, `vitest.workspace.ts` は shared global settings 相当
  - merge order: I-006 の after、Wave 0 最後のタスク
  - 並列実行しない

## Verification commands

```text
# 1. 必須ファイルの存在
test -f .github/workflows/ci.yml
test -f apps/web/playwright.config.ts
test -f apps/web/e2e/smoke.spec.ts
test -f vitest.workspace.ts
test -f packages/core/vitest.config.ts

# 2. ci.yml に必要な 6 job が含まれる
for job in typecheck lint format-check test build e2e; do
  grep -qE "^\s*$job:" .github/workflows/ci.yml || { echo "missing job: $job"; exit 1; }
done

# 3. Node / pnpm バージョン参照（.nvmrc / packageManager）
grep -q 'node-version-file' .github/workflows/ci.yml
grep -qE '(pnpm/action-setup|packageManager)' .github/workflows/ci.yml

# 4. frozen-lockfile
grep -q 'frozen-lockfile' .github/workflows/ci.yml

# 5. concurrency / cancel-in-progress
grep -qE 'concurrency:' .github/workflows/ci.yml
grep -q 'cancel-in-progress' .github/workflows/ci.yml

# 6. Playwright config が webServer を持つ
grep -q 'webServer' apps/web/playwright.config.ts

# 7. smoke.spec.ts が axe 呼び出し
grep -qE '@axe-core/playwright|AxeBuilder' apps/web/e2e/smoke.spec.ts

# 8. apps/web/package.json の devDep
node -e "
const p = require('./apps/web/package.json');
const dd = p.devDependencies || {};
for (const r of ['@playwright/test','@axe-core/playwright']) {
  if (!dd[r]) { console.error('missing devDep: '+r); process.exit(1); }
}
"

# 9. packages/core vitest devDep
node -e "
const p = require('./packages/core/package.json');
const dd = p.devDependencies || {};
for (const r of ['vitest','@vitest/coverage-v8']) {
  if (!dd[r]) { console.error('missing devDep: '+r); process.exit(1); }
}
"

# 10. vitest.workspace.ts に packages/core
grep -q 'packages/core' vitest.workspace.ts

# 11. ローカルで test / e2e が通る
pnpm -r test
pnpm --filter web exec playwright install --with-deps chromium
pnpm --filter web build
pnpm --filter web e2e

# 12. I-001〜I-006 成果物への回帰無し
git diff --name-only HEAD~1 -- tsconfig.base.json tsconfig.json eslint.config.js \
  .prettierrc .husky/ commitlint.config.js lint-staged.config.js | { ! grep -q .; }

# 13. ハーネス artifact validator
scripts/harness/validate-task-artifacts.sh I-007
```

## GUI verification
- required: no
- recipe path: n/a
- final frontmost validation required: no
- may be deferred by human: n/a
- 理由: e2e は headless。UI スタックの見た目検証は I-005 の gui lane で完了済み。

## Runtime isolation
- required: **条件付き yes**
- notes:
  - ローカルで `pnpm --filter web e2e` を走らせると Next.js サーバーが起動する
  - `scripts/harness/alloc-runtime` で `I-007` / `impl` に port を割り当て、
    `playwright.config.ts` の webServer に渡す
  - CI 環境では GitHub Actions runner が独立して立ち上がるため isolation 不要

## Done definition

- Verification 1〜13 全 PASS
- `scripts/harness/validate-task-artifacts` が I-007 に対して PASS
- `status.yaml` state `implemented` 以上
- `handoff.md` に記録:
  - Node / pnpm 参照方法（UQ-I007-01）
  - axe の失敗基準（UQ-I007-03）
  - カバレッジ閾値の扱い（UQ-I007-04）
  - Wave 1 着手時にカバレッジ 80 へ引き上げる引き継ぎ
  - Wave 4 着手時に e2e spec 追加位置（`apps/web/e2e/`）
  - ブランチ保護設定が本 repo 管理者の手動作業である旨
- `review.md` verdict `PASS` / `PASS-WITH-NOTES`、Must Fix 解消

## Blocked if

- I-006 が `merged` 未到達
- UQ-I007-03 / UQ-I007-05 が planning 時未決
- `@axe-core/playwright` が初期 placeholder ページで serious/critical を出す
  （I-005 への back-port 必要性が出たら blocker）

## Review focus

- **Anchor 5 の CI 版遵守**: `pnpm install --frozen-lockfile` が明示指定されているか、
  暗黙 install が無いか
- **job 分割**: 6 job が並列可能な粒度で切れているか（速度と fail-fast 両立）
- **axe の failure policy**: UQ-I007-03 の決定が smoke.spec.ts に反映されているか
- **vitest workspace**: packages/core のみ登録で、他パッケージが暗黙に巻き込まれていないか
- **frozen-lockfile の前提**: I-001〜I-006 の lockfile 更新が accumulated で正しく
  CI 側でインストールできるか

## Merge order
- before: (none) — Wave 0 の最後のタスク（I-008 は並列可、後完了でも可）
- after: I-006
- notes: I-008 完了を待たない（docs のみ、CI 本体に影響しない）

## Notes for implementer
- writable lane is `impl` only
- tool ownership: default = Codex（impl）/ Claude（review）
- `packages/core` の実テストを書きたくなったら stop（Wave 1 の仕事）
- Playwright の Visual Regression を追加したくなったら stop（Wave 4）
- CI matrix を windows-latest に広げたくなったら stop して planning 差し戻し
