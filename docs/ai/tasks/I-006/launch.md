# Launch: I-006 impl

## Lane identity
- task id: I-006
- lane: impl
- tool: Codex
- writable: yes

## Branch / commit target
- implementation branch: `ai/infra/quality/I-006-infra-quality-tooling`
- target commit for inspection lanes: (to be set by impl after first commit)

## Worktree
- path: `.worktrees/I-006__impl`
- create command (Linux/mac):
  ```bash
  scripts/harness/new-impl-lane.sh I-006 infra/quality infra-quality-tooling main
  ```
- create command (Windows):
  ```powershell
  pwsh scripts/harness/new-impl-lane.ps1 -TaskId I-006 -Area infra/quality -Slug infra-quality-tooling -BaseBranch main
  ```

## Session name
`[I-006][impl][codex]`

## Read first
- `docs/harness/FOUNDATION.md` (Anchor 4/5)
- `AGENTS.md`, `CODEX.md`
- `docs/ai/tasks/I-006/contract.md` (finalized)
- `docs/ai/tasks/I-006/status.yaml`
- `docs/ai/tasks/I-005/handoff.md` (merged 後、shadcn 生成物の lint 扱い判断)
- `docs/ai/plans/BATCH-WAVE0/uq-decisions.md` (グループ 7 全項目)
- 要件 v0.2 NFR-003, NFR-005
- Appendix A §A.5 (カスタムルール `no-number-for-amount` の仕様)
- Appendix B §B.5.2 (6 層防御、特に層 1 Conventional Commits scope)

## Start instruction

1. **前提確認**: I-005 merged 済みを `git log main` で確認、未 merge なら blocked
2. impl worktree に cd、`status.yaml` を `state: in-progress` に更新
3. 依存追加 (root devDep 一括):
   ```bash
   pnpm add -Dw eslint @eslint/js typescript-eslint prettier \
     eslint-config-prettier eslint-plugin-react eslint-plugin-react-hooks \
     husky lint-staged @commitlint/cli @commitlint/config-conventional
   ```
4. `eslint.config.js` (flat config, root 集約、UQ-I006-01 (a)):
   - `@typescript-eslint/strict` を適用
   - `eslint-config-prettier` で Prettier と競合解消
   - React 系ルールを `apps/web/**` と `packages/ui/**` に適用
   - `no-number-for-amount` 相当のカスタムルール **骨子** (TODO コメント付き、
     Wave 1 で有効化、UQ-I006-06):
     ```js
     // TODO(Wave 1): implement no-number-for-amount custom rule per Appendix A §A.5
     ```
   - `ignorePatterns`: `**/dist/**`, `**/.next/**`, `**/node_modules/**`
     (shadcn 生成物 `apps/web/components/ui/**` は I-005 handoff の判断に従う、
     lint 対象に含めるなら `.eslint-warn` 程度、対象外にするなら ignore 追加。
     impl lane が判断した結果を handoff に記録)
5. `.prettierrc` (UQ-I006-02 確定値):
   ```json
   {
     "printWidth": 100,
     "semi": true,
     "singleQuote": true,
     "trailingComma": "all",
     "arrowParens": "always"
   }
   ```
6. `.prettierignore`: `**/dist/**`, `**/.next/**`, `pnpm-lock.yaml`、
   必要なら `apps/web/components/ui/**`
7. `.husky/pre-commit` (UQ-I006-04 (a) shell grep、UQ-I006-07 typecheck なし):
   ```sh
   #!/usr/bin/env sh
   . "$(dirname -- "$0")/_/husky.sh"
   
   # NFR-003: prevent personal data leak via staged files
   staged=$(git diff --cached --name-only)
   echo "$staged" | grep -E '^\.env($|\.[^e])|^\.env$|^.*\.env\..*$' | grep -v '^\.env\.example$' && {
     echo "ERROR: .env* (other than .env.example) must not be committed"
     exit 1
   } || true
   echo "$staged" | grep -qE '\.(sqlite|sqlite-journal|db-journal)$' && {
     echo "ERROR: sqlite/db journal files must not be committed"
     exit 1
   } || true
   echo "$staged" | grep -qE '^prisma/.*\.db$' && {
     echo "ERROR: prisma/*.db files must not be committed"
     exit 1
   } || true
   echo "$staged" | grep -qE '^backups/' && {
     echo "ERROR: backups/ must not be committed"
     exit 1
   } || true
   
   npx lint-staged
   ```
   - chmod +x 必須
8. `.husky/commit-msg`:
   ```sh
   #!/usr/bin/env sh
   . "$(dirname -- "$0")/_/husky.sh"
   npx --no -- commitlint --edit "$1"
   ```
   - chmod +x 必須
9. `commitlint.config.js` (UQ-I006-03、9 scope):
   ```js
   module.exports = {
     extends: ['@commitlint/config-conventional'],
     rules: {
       'scope-enum': [
         2,
         'always',
         ['core', 'db', 'ingestion', 'ui', 'types', 'web', 'infra', 'docs', 'deps'],
       ],
     },
   };
   ```
10. `lint-staged.config.js`:
    ```js
    module.exports = {
      '**/*.{ts,tsx}': ['eslint --fix', 'prettier --write'],
      '**/*.{json,yml,yaml,md}': ['prettier --write'],
    };
    ```
11. `.gitignore` に **`!.vscode/extensions.json` を 1 行のみ追加** (UQ-I001-04
    の Wave 0 最終形)
12. root `package.json` を modify:
    - `scripts` に追加 (既存 stub を実体化):
      ```json
      {
        "scripts": {
          "build": "echo 'root build stub'",
          "test": "pnpm -r test",
          "lint": "eslint .",
          "lint:fix": "eslint . --fix",
          "format": "prettier --write .",
          "format:check": "prettier --check .",
          "typecheck": "pnpm -r typecheck",
          "prepare": "husky"
        }
      }
      ```
    - `packageManager` / `engines.node` / `private` は変更しない
13. `apps/web/package.json` modify: `scripts.lint: "eslint ."` を追加
14. `packages/{types,core,db,ingestion,ui}/package.json` を一括 modify:
    ```bash
    for p in types core db ingestion ui; do
      node -e "
      const fs = require('fs');
      const path = 'packages/$p/package.json';
      const pkg = JSON.parse(fs.readFileSync(path,'utf8'));
      pkg.scripts = pkg.scripts || {};
      pkg.scripts.lint = 'eslint src';
      pkg.scripts.typecheck = 'tsc --noEmit';
      fs.writeFileSync(path, JSON.stringify(pkg, null, 2) + '\n');
      "
    done
    ```
15. husky init: `pnpm prepare` を 1 回実行 (`.husky/_/` 生成、commit する)
16. `pnpm install -w` を実行して lockfile 更新
17. **pre-commit simulation を手動で確認**:
    - `touch .env.test` → `git add .env.test` → `git commit -m "feat(infra): test"`
      が reject されることを観測
    - `git reset HEAD .env.test && rm .env.test` で戻す
    - 結果を handoff.md に記録
18. contract.md の Verification commands 1〜19 を実行、全 PASS を確認
19. 変更を 1 commit にまとめる。コミットメッセージ:
    `feat(infra): add ESLint flat + Prettier + husky + lint-staged + commitlint (I-006)`
    - このコミットは自身の commitlint 規約を通ることも確認
20. `status.yaml` を `state: implemented` に更新
21. `handoff.md` 記入: 採用版一覧、9 scope 確定、`.vscode/extensions.json`
    opt-in 差分、`no-number-for-amount` TODO の配置、shadcn 生成物の lint 扱い判断、
    pre-commit simulation 結果、次タスク I-007 への引き継ぎ

## Stop conditions

- I-005 が merged でない
- ESLint flat config と `typescript-eslint` の版互換で解消不能な衝突
- `no-number-for-amount` を有効化したくなった (UQ-I006-06、Wave 1 の仕事)
- typecheck を pre-commit に入れたくなった (UQ-I006-07)
- `eslint-plugin-tailwindcss` を入れたくなった (UQ-I006-05)
- 9 scope 以外の scope を commitlint に追加したくなった (UQ-I006-03)
- `.gitignore` を `!.vscode/extensions.json` 以外の行で変更したくなった
- `packages/*/src/` / `apps/web/app/` / `tsconfig*.json` を触りたくなった
  (他タスクの領分)
- `prettier-plugin-tailwindcss` を入れたくなった (Wave 4 判断、Wave 0 不採用)
- `gitleaks` / secret scanning を入れたくなった (Phase B)
- pre-commit simulation で `.env` が reject されない
- Verification commands のいずれかが PASS しない、かつ 2 回の serious attempt
  でも解消できない

停止時は `handoff.md` を作成し `status.yaml` を `blocked` に更新。
