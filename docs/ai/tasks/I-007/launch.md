# Launch: I-007 impl

## Lane identity
- task id: I-007
- lane: impl
- tool: Codex
- writable: yes

## Branch / commit target
- implementation branch: `ai/infra/ci/I-007-infra-ci-actions`
- target commit for inspection lanes: (to be set by impl after first commit)

## Worktree
- path: `.worktrees/I-007__impl`
- create command (Linux/mac):
  ```bash
  scripts/harness/new-impl-lane.sh I-007 infra/ci infra-ci-actions main
  ```
- create command (Windows):
  ```powershell
  pwsh scripts/harness/new-impl-lane.ps1 -TaskId I-007 -Area infra/ci -Slug infra-ci-actions -BaseBranch main
  ```

## Runtime allocation (conditional)
**CI 自体は runtime allocation 不要** (GitHub Actions runner は独立環境)。
**ローカルで `pnpm --filter web e2e` を走らせる場合のみ**、Playwright + Next.js
webServer が起動するため:
```bash
scripts/harness/alloc-runtime.sh I-007 impl
scripts/harness/gen-worktree-env.sh I-007 impl
# → .worktrees/I-007__impl/.env.worktree.local に APP_PORT 等
```
`playwright.config.ts` の `webServer.port` は `process.env.APP_PORT ?? 3000`
のようにフォールバック。

## Session name
`[I-007][impl][codex]`

## Read first
- `docs/harness/FOUNDATION.md` (Anchor 3 runtime, Anchor 5 no-implicit-install)
- `docs/harness/policies/runtime-isolation.md`
- `AGENTS.md`, `CODEX.md`
- `docs/ai/tasks/I-007/contract.md` (finalized)
- `docs/ai/tasks/I-007/status.yaml`
- `docs/ai/tasks/I-006/handoff.md` (ESLint/Prettier/husky/commitlint の運用)
- `docs/ai/plans/BATCH-WAVE0/uq-decisions.md` (グループ 8 全項目)
- 要件 v0.2 NFR-005, NFR-008
- Appendix A §A.5 NFR-005
- Appendix B §B.4.7, §B.5.2 層 5

## Start instruction

1. **前提確認**: I-006 merged 済みを `git log main` で確認、未 merge なら blocked
2. impl worktree に cd、`status.yaml` を `state: in-progress` に更新
3. CI workflow 作成、`.github/workflows/ci.yml`:
   - トリガー: `push` (main, develop), `pull_request`
   - `concurrency: pr-${{ github.head_ref }}` + `cancel-in-progress: true`
     (PR トリガー時、UQ-I007-07)
   - 共通 setup (各 job 頭):
     ```yaml
     - uses: actions/checkout@v4
     - uses: pnpm/action-setup@v4    # packageManager から版取得 (UQ-I007-01)
     - uses: actions/setup-node@v4
       with:
         node-version-file: '.nvmrc'
         cache: 'pnpm'
     - run: pnpm install --frozen-lockfile    # Anchor 5 CI 版遵守
     ```
   - 6 job 構成:
     - `typecheck`: `pnpm -r typecheck`
     - `lint`: `pnpm lint`
     - `format-check`: `pnpm format:check`
     - `test`: `pnpm -r test`
     - `build`: `pnpm --filter web build`
     - `e2e`:
       - Playwright ブラウザキャッシュ (UQ-I007-02):
         ```yaml
         - uses: actions/cache@v4
           with:
             path: ~/.cache/ms-playwright
             key: playwright-browsers-${{ runner.os }}-${{ hashFiles('**/pnpm-lock.yaml') }}
         ```
       - `pnpm --filter web exec playwright install --with-deps chromium`
       - `pnpm --filter web build`
       - `pnpm --filter web e2e`
   - `runs-on: ubuntu-latest` のみ (UQ-I007-05、matrix 非使用)
4. Playwright init:
   ```bash
   pnpm add -D -F web @playwright/test @axe-core/playwright
   ```
5. `apps/web/playwright.config.ts`:
   ```typescript
   import { defineConfig, devices } from '@playwright/test';
   const PORT = process.env.APP_PORT ?? '3000';
   export default defineConfig({
     testDir: './e2e',
     fullyParallel: false,
     retries: process.env.CI ? 2 : 0,
     reporter: [['html', { open: 'never' }]],
     use: {
       baseURL: `http://localhost:${PORT}`,
     },
     webServer: {
       command: `pnpm --filter web start --port ${PORT}`,
       port: Number(PORT),
       reuseExistingServer: !process.env.CI,
       stdout: 'pipe',
     },
     projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
   });
   ```
6. `apps/web/e2e/smoke.spec.ts` (UQ-I007-03 (b)、serious|critical のみ fail):
   ```typescript
   import { test, expect } from '@playwright/test';
   import AxeBuilder from '@axe-core/playwright';
   
   test('homepage loads and has no serious/critical A11y violations', async ({ page }) => {
     await page.goto('/');
     await expect(page).toHaveTitle(/./);
     
     const results = await new AxeBuilder({ page }).analyze();
     const serious = results.violations.filter(
       (v) => v.impact === 'serious' || v.impact === 'critical'
     );
     if (results.violations.length > 0) {
       console.warn('A11y violations (moderate/minor warnings):', 
         JSON.stringify(results.violations, null, 2));
     }
     expect(serious, `serious/critical A11y violations: ${JSON.stringify(serious, null, 2)}`).toEqual([]);
   });
   ```
7. `apps/web/package.json` modify: scripts 追加
   ```json
   {
     "scripts": {
       "e2e": "playwright test",
       "e2e:install": "playwright install --with-deps"
     }
   }
   ```
8. Vitest init:
   ```bash
   pnpm add -D -F core vitest @vitest/coverage-v8
   ```
9. `vitest.workspace.ts` (root):
   ```typescript
   import { defineWorkspace } from 'vitest/config';
   export default defineWorkspace([
     'packages/core',
   ]);
   ```
10. `packages/core/vitest.config.ts` (UQ-I007-04 閾値未設定):
    ```typescript
    import { defineConfig } from 'vitest/config';
    export default defineConfig({
      test: {
        coverage: {
          provider: 'v8',
          reporter: ['text', 'html'],
          // NOTE(Wave 1): thresholds: { lines: 80, functions: 80, branches: 80, statements: 80 }
        },
      },
    });
    ```
11. `packages/core/package.json` modify:
    ```json
    {
      "scripts": {
        "test": "vitest run",
        "test:coverage": "vitest run --coverage"
      }
    }
    ```
12. **UQ-I007-06 遵守**: `.github/CODEOWNERS` / `.github/rulesets/` を **作らない**
13. ローカル検証:
    ```bash
    pnpm install --frozen-lockfile   # lockfile 整合性確認
    pnpm -r typecheck
    pnpm lint
    pnpm format:check
    pnpm -r test
    pnpm --filter web build
    pnpm --filter web exec playwright install --with-deps chromium
    pnpm --filter web e2e
    ```
    - すべて 0 exit することを確認、特に e2e で placeholder ページに対する
      axe が serious/critical を出さないこと
14. contract.md の Verification commands 1〜18 を実行、全 PASS を確認
15. 変更を 1 commit にまとめる。コミットメッセージ:
    `feat(infra): add GitHub Actions CI + Playwright/axe scaffold + Vitest workspace (I-007)`
16. `status.yaml` を `state: implemented` に更新
17. `handoff.md` 記入:
    - Node/pnpm 参照方法 (`.nvmrc` + packageManager)
    - Playwright キャッシュキー戦略
    - axe (b) の運用メモ、Wave 4 で (a) strict 化の引き継ぎ
    - vitest.config.ts の thresholds コメント位置 (Wave 1 で有効化)
    - CODEOWNERS は repo 管理者の手動設定で実施する旨
    - branch protection 設定も repo 管理者の手動作業
    - Wave 1 での golden fixture と実テスト配置予定

## Stop conditions

- I-006 が merged でない
- axe が I-005 の placeholder ページで serious/critical を出す
  → I-005 への back-port 要、planning 差し戻し (blocker)
- `frozen-lockfile` が accumulated lock で失敗する (lockfile 破損の可能性)
- CI matrix に windows/macos を入れたくなった (UQ-I007-05)
- カバレッジ閾値を 80 に設定したくなった (UQ-I007-04、Wave 1)
- CODEOWNERS を作りたくなった (UQ-I007-06)
- release/deploy workflow を書きたくなった (P0 非目標)
- Visual Regression / Lighthouse CI を追加したくなった (Wave 4)
- `packages/core` の実テストを書きたくなった (Wave 1)
- axe の失敗基準を (a) violation 0 strict に上げたくなった (Wave 4)
- Verification commands のいずれかが PASS しない、かつ 2 回の serious attempt
  でも解消できない

停止時は `handoff.md` を作成し `status.yaml` を `blocked` に更新。
