# Task Contract: I-007

## Identity
- task id: I-007
- title: GitHub Actions CI (typecheck / lint / vitest / playwright+axe scaffolding)
- area: infra/ci
- slug: infra-ci-actions
- batch id: BATCH-WAVE0
- harness_version: 4.1-p0-tool-ownership

## Objective

GitHub Actions で PR / push 時に `typecheck` / `lint` / `format-check` / `test` /
`build` / `e2e (playwright + axe)` が並列実行される状態を作る。e2e は最小 smoke
spec のみで、Wave 4 が追加する spec がそのまま走る配線に留める。

本タスクで確定する運用:
- **Node / pnpm は `.nvmrc` / `packageManager` から動的取得** (**UQ-I007-01 (a)**)
- **Playwright ブラウザキャッシュ**: `actions/cache` で `~/.cache/ms-playwright`
  を `playwright-browsers-${{ runner.os }}-${{ lockfile hash }}` をキーにキャッシュ
  (**UQ-I007-02**)
- **axe 失敗基準**: `impact: serious|critical` のみ fail、moderate/minor は
  warning として report のみ (**UQ-I007-03 (b)**、WCAG 2.1 Level AA を
  Wave 4 で段階強化する方針)
- **Vitest カバレッジ閾値は未設定** (**UQ-I007-04**、Wave 1 で 80% に引き上げ)
- **CI matrix は ubuntu-latest のみ** (**UQ-I007-05**、Windows は operator が
  手元で確認、Harness Anchor 7 は `.sh`/`.ps1` 両提供で担保済み)
- **CODEOWNERS / ruleset は本タスクで作成しない** (**UQ-I007-06**、GitHub repo
  設定で別途実施)
- **concurrency**: `pr-${{ github.head_ref }}` + `cancel-in-progress: true`
  を PR 向けに設定 (**UQ-I007-07**)

## Business / user value

Appendix B §B.5.2 層 5（CI 強制）の土台。ローカルで通らないコードが main に
入らない。Wave 4 以降で A11y 違反検知が自動化される下準備。

## In scope

- `.github/workflows/ci.yml` (new)
  - 6 job: `typecheck`, `lint`, `format-check`, `test`, `build`, `e2e`
  - 各 job:
    - `actions/checkout@v4`
    - `pnpm/action-setup@v4` (`packageManager` フィールドを参照、UQ-I007-01)
    - `actions/setup-node@v4` with `node-version-file: .nvmrc`
    - `pnpm install --frozen-lockfile` (明示、Anchor 5 の CI 版遵守)
  - `concurrency: pr-${{ github.head_ref }}` + `cancel-in-progress: true`
    (PR トリガー時、UQ-I007-07)
  - matrix: `runs-on: ubuntu-latest` のみ (UQ-I007-05)
  - `e2e` job は Playwright ブラウザキャッシュ使用 (UQ-I007-02)
  - job 詳細:
    - `typecheck`: `pnpm -r typecheck`
    - `lint`: `pnpm lint`
    - `format-check`: `pnpm format:check`
    - `test`: `pnpm -r test`
    - `build`: `pnpm --filter web build`
    - `e2e`: `pnpm --filter web build && pnpm --filter web e2e`

- `apps/web/playwright.config.ts` (new):
  - `webServer: { command: 'pnpm --filter web start', port: 3000, reuseExistingServer: !process.env.CI }`
  - `baseURL`, `retries: 2` (CI のみ), `reporter: [['html', { open: 'never' }]]`

- `apps/web/e2e/smoke.spec.ts` (new):
  - `/` にアクセス、`expect(page).toHaveTitle(/./)` 程度の最小 assertion
  - `AxeBuilder({ page }).analyze()` で scan
  - `impact: serious|critical` のみ fail、moderate/minor は warning report
    (UQ-I007-03 (b))

- `apps/web/package.json` (modify):
  - `scripts`:
    - `e2e`: `playwright test`
    - `e2e:install`: `playwright install --with-deps`
  - `devDependencies`:
    - `@playwright/test`
    - `@axe-core/playwright`

- `vitest.workspace.ts` (new, root):
  - `packages/core` のみ登録 (他パッケージは Wave 1 以降で追加)

- `packages/core/vitest.config.ts` (new, 雛形):
  - `coverage.provider: "v8"`
  - カバレッジ閾値は **未設定** (UQ-I007-04、Wave 1 で `80` に引き上げ)

- `packages/core/package.json` (modify):
  - `scripts`:
    - `test`: `vitest run`
    - `test:coverage`: `vitest run --coverage`
  - `devDependencies`:
    - `vitest`
    - `@vitest/coverage-v8`

- `pnpm-lock.yaml` (modify)

## Out of scope

- `packages/core` の実テスト（→ Wave 1）
- Vitest カバレッジ閾値 80% の厳格強制（→ Wave 1 の core 実装タスク、UQ-I007-04）
- 各画面の A11y e2e（→ Wave 4）
- Playwright の Visual Regression
- release / publish workflow
- Lighthouse CI
- Preview deploy（Vercel 等、Phase B）
- Security scanning (CodeQL, Dependabot)
- CODEOWNERS / branch ruleset 作成 (UQ-I007-06)
- matrix build の OS 拡張（Phase A は ubuntu のみ、UQ-I007-05）
- Windows runner (Harness Anchor 7 は lane script で担保、CI では不要)
- `.github/` に CI 以外のファイル (issue template, PR template、別タスクで判断)

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

- `docs/harness/**`, `AGENTS.md`, `CLAUDE.md`, `CODEX.md`, `.gtrconfig*`,
  `.claude/**`, `.codex/**`, `.agents/**`, `scripts/harness/**`,
  `.runtime/**`, `.worktrees/**`
- `docs/ai/tasks/**`（self 除く）, `docs/ai/issues/**`（self 除く）, `docs/ai/plans/**`
- `tsconfig.base.json`, root `tsconfig.json`, root `package.json`
  （root scripts は I-006 で揃えた前提、追加しない）
- `eslint.config.js`, `.prettierrc*`, `commitlint.config.js`,
  `lint-staged.config.js`, `.husky/**`, `.prettierignore` (I-006 の領分)
- I-001〜I-005 の成果物 (apps/web の globals.css / components / lib、
  packages/*/src, packages/*/tsconfig.json、tailwind.config.ts 等)
- `prisma/**`
- `.github/` の ci.yml 以外全て (`.github/CODEOWNERS`, `.github/ISSUE_TEMPLATE/**`,
  `.github/PULL_REQUEST_TEMPLATE.md` 等、UQ-I007-06 で非対象)
- packages/{types,db,ingestion,ui}/package.json (本タスクは core のみ変更)

## Serial-only areas touched
- yes
- details:
  - `pnpm-lock.yaml` (lockfile)
  - `apps/web/package.json` (package manifest、scripts + devDep 追加)
  - `packages/core/package.json` (package manifest)
  - `.github/workflows/ci.yml` (shared global settings 相当)
  - `vitest.workspace.ts` (shared global settings 相当)
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

# 3. Node / pnpm バージョン参照 (.nvmrc / packageManager、UQ-I007-01)
grep -q 'node-version-file' .github/workflows/ci.yml
grep -qE '(pnpm/action-setup|packageManager)' .github/workflows/ci.yml

# 4. frozen-lockfile
grep -q 'frozen-lockfile' .github/workflows/ci.yml

# 5. concurrency / cancel-in-progress (UQ-I007-07)
grep -qE 'concurrency:' .github/workflows/ci.yml
grep -q 'cancel-in-progress' .github/workflows/ci.yml
grep -qE 'pr-\$\{\{\s*github\.head_ref\s*\}\}' .github/workflows/ci.yml

# 6. matrix が ubuntu-latest のみ (UQ-I007-05)
grep -q 'ubuntu-latest' .github/workflows/ci.yml
! grep -q 'windows-latest' .github/workflows/ci.yml
! grep -q 'macos-latest' .github/workflows/ci.yml

# 7. Playwright ブラウザキャッシュ (UQ-I007-02)
grep -qE 'actions/cache' .github/workflows/ci.yml
grep -qE 'ms-playwright|~/.cache/ms-playwright' .github/workflows/ci.yml

# 8. Playwright config が webServer を持つ
grep -q 'webServer' apps/web/playwright.config.ts

# 9. smoke.spec.ts が axe 呼び出し + impact serious|critical filter
grep -qE '@axe-core/playwright|AxeBuilder' apps/web/e2e/smoke.spec.ts
grep -qE '(serious|critical)' apps/web/e2e/smoke.spec.ts

# 10. apps/web/package.json の devDep + scripts
node -e "
const p = require('./apps/web/package.json');
const dd = p.devDependencies || {};
for (const r of ['@playwright/test','@axe-core/playwright']) {
  if (!dd[r]) { console.error('missing devDep: '+r); process.exit(1); }
}
const s = p.scripts || {};
if (!s.e2e) { console.error('missing script: e2e'); process.exit(2); }
if (!s['e2e:install']) { console.error('missing script: e2e:install'); process.exit(3); }
"

# 11. packages/core vitest devDep + scripts
node -e "
const p = require('./packages/core/package.json');
const dd = p.devDependencies || {};
for (const r of ['vitest','@vitest/coverage-v8']) {
  if (!dd[r]) { console.error('missing devDep: '+r); process.exit(1); }
}
const s = p.scripts || {};
if (!s.test) { console.error('missing script: test'); process.exit(2); }
if (!s['test:coverage']) { console.error('missing script: test:coverage'); process.exit(3); }
"

# 12. vitest.workspace.ts に packages/core
grep -q 'packages/core' vitest.workspace.ts

# 13. vitest.config.ts のカバレッジ閾値が未設定 (UQ-I007-04)
! grep -qE 'thresholds?\s*:\s*\{' packages/core/vitest.config.ts
grep -qE 'coverage|provider.*v8' packages/core/vitest.config.ts

# 14. ローカルで test / e2e が通る (impl lane 実行、CI は別環境)
pnpm -r test
pnpm --filter web exec playwright install --with-deps chromium
pnpm --filter web build
pnpm --filter web e2e

# 15. CODEOWNERS / branch ruleset 等、UQ-I007-06 で非対象が作成されていない
! test -f .github/CODEOWNERS
! test -d .github/rulesets

# 16. I-001〜I-006 成果物への回帰無し
git diff --name-only HEAD~1 -- \
  tsconfig.base.json tsconfig.json eslint.config.js \
  .prettierrc .prettierignore .husky/ commitlint.config.js lint-staged.config.js \
  package.json .gitignore .nvmrc .editorconfig .env.example README.md \
  pnpm-workspace.yaml \
  packages/types/ packages/db/ packages/ingestion/ packages/ui/ \
  apps/web/tsconfig.json apps/web/next.config.ts \
  apps/web/app/ apps/web/components/ apps/web/lib/ apps/web/tailwind.config.ts \
  apps/web/postcss.config.js apps/web/components.json \
  | { ! grep -q .; }

# 17. ハーネス同梱ファイルに touch 無し
git diff --name-only HEAD~1 -- \
  docs/harness/ AGENTS.md CLAUDE.md CODEX.md \
  .gtrconfig.v4 .gtrconfig .claude/ .codex/ .agents/ scripts/harness/ \
  | { ! grep -q .; }

# 18. ハーネス artifact validator
scripts/harness/validate-task-artifacts.sh I-007
```

## GUI verification
- required: no
- recipe path: n/a
- final frontmost validation required: no
- may be deferred by human: n/a
- 理由: e2e は headless。UI スタックの見た目検証は I-005 の gui lane で完了済み

## Runtime isolation
- required: **条件付き yes**
- notes:
  - **ローカル impl lane が `pnpm --filter web e2e` を走らせる場合**: Next.js
    サーバーが起動するため、`scripts/harness/alloc-runtime` で `I-007` / `impl`
    に port を割り当て、`playwright.config.ts` の `webServer.port` と整合させる
  - **CI 環境 (GitHub Actions runner)**: 独立環境で起動、runtime allocation 不要
  - Done definition の項目 14 は impl lane の手元確認、runtime allocation 推奨

## Done definition

- Verification 1〜18 全 PASS
- `scripts/harness/validate-task-artifacts` が I-007 に対して PASS
- `status.yaml` state `implemented` 以上
- `handoff.md` に記録:
  - Node / pnpm 参照方法 (UQ-I007-01 (a))
  - Playwright キャッシュ戦略 (UQ-I007-02)
  - axe の失敗基準 (UQ-I007-03 (b))、Wave 4 で (a) strict に上げる引き継ぎ
  - カバレッジ閾値の扱い (UQ-I007-04、Wave 1 で 80 に引き上げ)
  - CI matrix は ubuntu-latest のみ (UQ-I007-05)、Windows は operator 手元確認の運用
  - CODEOWNERS / ruleset は本 repo の GitHub 設定画面で別途実施 (UQ-I007-06)
  - Wave 1 着手時にカバレッジ 80 へ引き上げる引き継ぎ
  - Wave 4 着手時に e2e spec 追加位置 (`apps/web/e2e/`)
  - PR でブランチ保護設定が本 repo 管理者の手動作業である旨
- `review.md` verdict `PASS` / `PASS-WITH-NOTES`、Must Fix 解消
- **Wave 0 完走を宣言できる状態** (I-008 の merge は並列に可)

## Blocked if

- I-006 が `merged` 未到達
- `@axe-core/playwright` が I-005 の placeholder ページで serious/critical を出す
  (I-005 への back-port が必要 → blocker、planning 時点で要確認)
- `frozen-lockfile` が accumulated lock で失敗する (lockfile の整合性問題)

## Review focus

- **Anchor 5 の CI 版遵守**: `pnpm install --frozen-lockfile` が明示指定、
  暗黙 install が無いか (項目 4)
- **job 分割**: 6 job が並列可能な粒度で切れているか (速度と fail-fast 両立)
- **axe の failure policy**: UQ-I007-03 (b) が smoke.spec.ts に反映されているか
  (項目 9)
- **vitest workspace**: `packages/core` のみ登録で、他パッケージが暗黙に
  巻き込まれていないか (項目 12)
- **frozen-lockfile の前提**: I-001〜I-006 の lockfile 更新が accumulated で
  正しく CI 側でインストールできるか
- **matrix の厳守**: ubuntu-latest のみ、windows/macos が混入していない (項目 6)
- **UQ-I007-04 の未設定**: vitest.config.ts の `coverage.thresholds` が無い
  (項目 13)
- **UQ-I007-06 の遵守**: CODEOWNERS 等が存在しない (項目 15)

## Merge order
- before: (none) — Wave 0 の最後のタスク (I-008 は並列可、後完了でも可)
- after: I-006
- notes: I-008 完了を待たない (docs のみ、CI 本体に影響しない)

## Notes for implementer
- writable lane is `impl` only
- tool ownership: default = Codex（impl）/ Claude（review）
- `packages/core` の実テストを書きたくなったら stop（Wave 1 の仕事）
- Playwright の Visual Regression を追加したくなったら stop（Wave 4）
- CI matrix を windows-latest に広げたくなったら stop して planning 差し戻し
  (UQ-I007-05 確定)
- カバレッジ閾値を 80 に設定したくなったら stop (UQ-I007-04、Wave 1 の仕事)
- CODEOWNERS を書き始めたら stop (UQ-I007-06 非対象)
- `.github/workflows/release.yml` や deploy workflow を書き始めたら stop
- axe の失敗基準を (a) violation 0 に強化したくなったら stop (Wave 4 の仕事)

## Tool ownership preferences
- default tool owner: Codex (impl)
- review tool: Claude
- verify tool: Codex
- switch trigger: CI matrix に windows 追加、カバレッジ閾値設定、CODEOWNERS
  作成が検出されたら即 stop。axe の impact filter を (a) strict に上げる提案が
  出たら即 stop + planning 差し戻し
