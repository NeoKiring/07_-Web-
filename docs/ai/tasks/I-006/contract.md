# Task Contract: I-006

## Identity
- task id: I-006
- title: quality tooling (ESLint + Prettier + husky + lint-staged + commitlint)
- area: infra/quality
- slug: infra-quality-tooling
- batch id: BATCH-WAVE0
- harness_version: 4.1-p0-tool-ownership

## Objective

ローカル開発での静的解析・フォーマッタ・pre-commit / commit-msg hook を有効化し、
NFR-003 (pre-commit 個人データ混入検査) と NFR-005 (AI 主体開発ガードレール) を
実装レベルで効かせる。CI 組込みは I-007 の領分。

本タスクで確定する運用:
- **ESLint flat config root 集約** (**UQ-I006-01 (a)**)
- **Prettier 設定**: `printWidth: 100`, `semi: true`, `singleQuote: true`,
  `trailingComma: "all"`, `arrowParens: "always"` (**UQ-I006-02**)
- **Conventional Commits scope**: `core`, `db`, `ingestion`, `ui`, `types`,
  `web`, `infra`, `docs`, `deps` (**UQ-I006-03**)
- **pre-commit の NFR-003 検知は shell grep** (**UQ-I006-04 (a)**)
- **`eslint-plugin-tailwindcss` 不採用** (**UQ-I006-05**、Wave 4 判断)
- **`no-number-for-amount` は骨子 TODO のみ** (**UQ-I006-06 (a)**、Wave 1 で有効化)
- **typecheck は pre-commit に入れない** (**UQ-I006-07 (a)**)
- **`.vscode/extensions.json` opt-in**: I-001 で `.vscode/` 一括 ignore、
  I-006 で `.gitignore` に `!.vscode/extensions.json` を追加

## Business / user value

AI impl lane が書き換える commit が常に同じ lint / format / commit 規約を
通る状態を作る。Appendix B §B.5.2 層 1（仕様ロック）と層 3（型ロック）の
ローカル側強制。

## In scope

- `eslint.config.js` (new, flat config, root 集約):
  - `@typescript-eslint/strict` 適用
  - `eslint-config-prettier` で Prettier 競合解消
  - React 系ルール (`react`, `react-hooks`) を `apps/web` / `packages/ui` に適用
  - `no-number-for-amount` 相当のカスタムルール **骨子** (TODO コメント付き、
    Wave 1 で有効化)
  - `ignorePatterns`: `apps/web/components/ui/**` (shadcn 生成物、impl lane が
    必要と判断した場合のみ)、`**/dist/**`, `**/.next/**`, `**/node_modules/**`

- `.prettierrc` (new): 上記 UQ-I006-02 確定値 JSON
- `.prettierignore` (new): `**/dist/**`, `**/.next/**`, `pnpm-lock.yaml`,
  `apps/web/components/ui/**` (shadcn 生成物、任意)

- `.husky/pre-commit` (new, shell script, `+x` 権限):
  - `lint-staged` 実行
  - NFR-003 パターン検知: staged file name を grep で検査、以下を含んでいたら reject:
    - `.env*` (ただし `.env.example` は許可)
    - `*.sqlite`
    - `*.sqlite-journal` / `*.db-journal`
    - `*.db` (prisma 配下)
    - `backups/**`
  - **typecheck は実行しない** (UQ-I006-07)

- `.husky/commit-msg` (new, shell script, `+x` 権限):
  - `npx commitlint --edit $1` を呼ぶ

- `commitlint.config.js` (new, root):
  - `extends: ['@commitlint/config-conventional']`
  - `rules`: `scope-enum` に UQ-I006-03 確定 9 scope を列挙

- `lint-staged.config.js` (new, root):
  - TypeScript / TSX: ESLint + Prettier
  - JSON / YAML / MD: Prettier のみ

- `.gitignore` (**modify, 最小追加**):
  - `!.vscode/extensions.json` を追加 (UQ-I001-04 の Wave 0 最終形)
  - 他 I-001 の内容は触らない

- root `package.json` (modify):
  - `devDependencies` 追加: `eslint`, `@eslint/js`, `typescript-eslint`,
    `prettier`, `eslint-config-prettier`, `eslint-plugin-react`,
    `eslint-plugin-react-hooks`, `husky`, `lint-staged`, `@commitlint/cli`,
    `@commitlint/config-conventional`
  - `scripts` 追加: `lint`, `lint:fix`, `format`, `format:check`, `prepare`
    (`husky`)
  - I-001 の既存 scripts (`build`, `test`, `lint`, `typecheck` stub) を
    実体化 (例: `lint: eslint .`)
  - `packageManager` / `engines.node` / `private` は変更しない

- `apps/web/package.json` (modify):
  - `scripts.lint`: `eslint .` または `next lint` どちらか (planning 時点は
    `eslint .` を推奨、I-005 との整合で問題無し)

- `packages/<n>/package.json` × 5 (modify, 各 1-2 行レベル):
  - `scripts.lint`: `eslint src`
  - `scripts.typecheck`: `tsc --noEmit`
  - 対象: `types`, `core`, `db`, `ingestion`, `ui`

- `pnpm-lock.yaml` (modify)

## Out of scope

- GitHub Actions workflow（→ I-007）
- Appendix A §A.5 `no-number-for-amount` の**有効化**（骨子のみ、Wave 1 で有効化）
- gitleaks / secret scanning（Phase B）
- `prettier-plugin-tailwindcss`（Wave 4 判断）
- `eslint-plugin-tailwindcss`（UQ-I006-05 で Wave 0 不採用確定）
- `changesets` / release automation
- `turbo` / `nx` 等の monorepo runner
- Vitest / Playwright の設定ファイル（Wave 1 / Wave 4）
- カバレッジ閾値設定（NFR-005 の 80% は I-007 の CI で強制）
- `typecheck` の pre-commit 実行 (UQ-I006-07、CI に回す)

## Touched files

- `eslint.config.js` (new, root)
- `.prettierrc` (new, root)
- `.prettierignore` (new, root)
- `.husky/pre-commit` (new)
- `.husky/commit-msg` (new)
- `commitlint.config.js` (new, root)
- `lint-staged.config.js` (new, root)
- `.gitignore` (modify, `!.vscode/extensions.json` 追加のみ)
- `package.json` (modify, root)
- `apps/web/package.json` (modify)
- `packages/types/package.json` (modify)
- `packages/core/package.json` (modify)
- `packages/db/package.json` (modify)
- `packages/ingestion/package.json` (modify)
- `packages/ui/package.json` (modify)
- `pnpm-lock.yaml` (modify)

## Forbidden files

- `docs/harness/**`, `AGENTS.md`, `CLAUDE.md`, `CODEX.md`, `.gtrconfig*`,
  `.claude/**`, `.codex/**`, `.agents/**`, `scripts/harness/**`,
  `.runtime/**`, `.worktrees/**`
- `docs/ai/tasks/**`（self 除く）, `docs/ai/issues/**`（self 除く）, `docs/ai/plans/**`
- `tsconfig.base.json`, root `tsconfig.json`（I-002 / I-003 の領分）
- I-001 root ファイル群のうち `.gitignore` 以外（`.gitignore` の `!.vscode/extensions.json`
  追加のみ許可）
- `apps/web/{tsconfig.json,next.config.ts,app/**,components/**,lib/**,tailwind.config.ts,postcss.config.js,globals.css,components.json}`
  (I-004 / I-005 の領分、本タスクは `apps/web/package.json` の scripts のみ modify)
- `packages/*/src/**`, `packages/*/tsconfig.json`
- `.github/**`（I-007）
- `prisma/**`
- `pnpm-workspace.yaml`, `.nvmrc`, `.editorconfig`, `.env.example`, `README.md`

## Serial-only areas touched
- yes
- details:
  - 全 package の `package.json` (scripts 追加、package manifest)
  - `pnpm-lock.yaml`
  - `.husky/**`, `eslint.config.js`, `commitlint.config.js` (shared global
    settings 相当)
  - `.gitignore` (`.vscode/extensions.json` opt-in のみ)
  - merge order: I-005 の after、I-007 の before

## Verification commands

```text
# 1. 必須ファイルの存在
test -f eslint.config.js
test -f .prettierrc
test -f .prettierignore
test -f .husky/pre-commit
test -f .husky/commit-msg
test -f commitlint.config.js
test -f lint-staged.config.js

# 2. pre-commit / commit-msg hook の実行権限
test -x .husky/pre-commit
test -x .husky/commit-msg

# 3. NFR-003 パターン検知の実装 (UQ-I006-04 (a) shell grep)
grep -qE '\.env' .husky/pre-commit
grep -qE '\*\.sqlite|sqlite-journal|db-journal' .husky/pre-commit
grep -qE 'backups/' .husky/pre-commit

# 4. 全 package に lint / typecheck script
for p in types core db ingestion ui; do
  node -e "
  const s = require('./packages/$p/package.json').scripts||{};
  if (!s.lint) { console.error('missing lint in packages/$p'); process.exit(1); }
  if (!s.typecheck) { console.error('missing typecheck in packages/$p'); process.exit(2); }
  "
done
node -e "
const s = require('./apps/web/package.json').scripts||{};
if (!s.lint) { console.error('apps/web missing lint script'); process.exit(1); }
"

# 5. root scripts (lint / lint:fix / format / format:check / prepare)
node -e "
const s = require('./package.json').scripts||{};
const required = ['lint','lint:fix','format','format:check','prepare'];
for (const k of required) if (!s[k]) { console.error('missing root script '+k); process.exit(1); }
if (!/husky/.test(s.prepare)) { console.error('prepare must invoke husky'); process.exit(2); }
"

# 6. commitlint.config が conventional 準拠 + scope-enum (UQ-I006-03)
grep -q '@commitlint/config-conventional' commitlint.config.js
grep -qE '(scope-enum|scopeEnum)' commitlint.config.js
# 9 scope がすべて含まれる
for scope in core db ingestion ui types web infra docs deps; do
  grep -qE "[\"']$scope[\"']" commitlint.config.js || { echo "missing scope: $scope"; exit 1; }
done

# 7. Prettier 設定が UQ-I006-02
node -e "
const p = require('./.prettierrc');
if (p.printWidth !== 100) process.exit(1);
if (p.semi !== true) process.exit(2);
if (p.singleQuote !== true) process.exit(3);
if (p.trailingComma !== 'all') process.exit(4);
if (p.arrowParens !== 'always') process.exit(5);
"

# 8. 全 repo を lint が通る
pnpm lint

# 9. format:check
pnpm format:check

# 10. commitlint のサンプル検証（失敗系）
echo \"bad commit\" | npx commitlint && exit 1 || true

# 11. commitlint 成功系（全 scope を 1 例ずつ確認）
for scope in core db ingestion ui types web infra docs deps; do
  echo \"feat($scope): add sample\" | npx commitlint || { echo \"scope rejected: $scope\"; exit 1; }
done

# 12. no-number-for-amount の骨子 TODO が存在 (UQ-I006-06 (a))
grep -qE 'no-number-for-amount|TODO.*amount' eslint.config.js

# 13. typecheck が pre-commit に入っていない (UQ-I006-07 (a))
! grep -qE 'typecheck|tsc\s+--noEmit' .husky/pre-commit

# 14. eslint-plugin-tailwindcss が入っていない (UQ-I006-05)
! node -e "const p=require('./package.json'); const d=Object.assign({},p.dependencies||{},p.devDependencies||{}); if(d['eslint-plugin-tailwindcss']) process.exit(1);"

# 15. .gitignore に !.vscode/extensions.json が追加されている
grep -qE '^!.vscode/extensions\.json' .gitignore

# 16. pre-commit simulation (手動、handoff に記録):
#  .env を staged に入れて commit が reject されることを impl lane が確認

# 17. ハーネス同梱ファイルに touch 無し
git diff --name-only HEAD~1 -- \
  docs/harness/ AGENTS.md CLAUDE.md CODEX.md \
  .gtrconfig.v4 .gtrconfig .claude/ .codex/ .agents/ scripts/harness/ \
  | { ! grep -q .; }

# 18. I-001〜I-005 成果物に scripts 以外の回帰無し
git diff --name-only HEAD~1 -- \
  apps/web/tsconfig.json apps/web/next.config.ts \
  apps/web/app/ apps/web/components/ apps/web/lib/ apps/web/tailwind.config.ts \
  apps/web/postcss.config.js apps/web/components.json \
  packages/*/tsconfig.json packages/*/src/ \
  tsconfig.base.json tsconfig.json \
  pnpm-workspace.yaml .nvmrc .editorconfig .env.example README.md \
  | { ! grep -q .; }

# 19. ハーネス artifact validator
scripts/harness/validate-task-artifacts.sh I-006
```

## GUI verification
- required: no
- recipe path: n/a
- final frontmost validation required: no
- may be deferred by human: n/a

## Runtime isolation
- required: no
- notes: 本タスクは runtime process を起動しない (lint / format / commitlint は
  静的、husky install は一度きりの script 実行)

## Done definition

- Verification 1〜19 全 PASS (項目 16 は impl lane が手動確認、結果を handoff に記録)
- `scripts/harness/validate-task-artifacts` が I-006 に対して PASS
- `status.yaml` state が `implemented` 以上
- `handoff.md` に以下記録:
  - ESLint / Prettier / husky / lint-staged / commitlint の採用版
  - Commit scope 一覧の最終確定値 (UQ-I006-03 の 9 scope)
  - `no-number-for-amount` 骨子の配置 (UQ-I006-06 (a))、Wave 1 着手前に
    有効化する TODO の明記
  - Appendix A §A.5 のカスタムルール実装を Wave 1 で行う旨
  - pre-commit simulation: `.env` が reject される動作確認結果
  - `.vscode/extensions.json` opt-in の形 (`.gitignore` 変更差分)
  - I-005 の shadcn 生成物を ESLint `ignorePatterns` に入れたか否かの判断
- `review.md` verdict `PASS` / `PASS-WITH-NOTES`、Must Fix 解消
- I-001〜I-005 成果物への回帰なし（Touched files に含めた package.json の
  scripts フィールド + `.gitignore` の 1 行追加以外）

## Blocked if

- I-005 が `merged` 未到達
- ESLint flat config と `typescript-eslint` の版互換問題 (2026 年時点では
  解消しているはず)
- shadcn 生成物が ESLint で大量に warn/error を発する (planning 時点で
  `ignorePatterns` 方針を決める)

## Review focus

- **NFR-003 実装の網羅性**: `.env*`, `*.sqlite`, `*.db-journal`, `backups/*`
  が pre-commit で確実に reject されるパターンになっているか (項目 3)
- **NFR-005 の段階的適用**: カスタムルールの骨子が TODO で残っており、
  I-001〜I-005 の既存コードを壊していないか (項目 12)
- **pre-commit 負荷**: lint-staged で staged ファイルのみに限定されているか、
  typecheck が pre-commit に入っていないか (項目 13)
- **Conventional Commits scope**: 9 scope 全てが commitlint.config.js に列挙、
  Appendix B §B.5.2 層 1 の運用と一致 (項目 6, 11)
- **Prettier 確定値の遵守**: UQ-I006-02 の 5 項目全て (項目 7)
- **依存最小性**: 追加された devDep が意図通りか、偶発的な sub-dep の PR 化を
  招かないか、`eslint-plugin-tailwindcss` が入っていないか (項目 14)
- **回帰検知**: I-001〜I-005 の非 scripts ファイルが変更されていない (項目 18)
- **`.vscode/extensions.json` の opt-in**: `.gitignore` 差分が 1 行のみ (項目 15)

## Merge order
- before: I-007
- after: I-005
- notes: I-008 は並列可

## Notes for implementer
- writable lane is `impl` only
- tool ownership: default = Codex（impl）/ Claude（review）
- `no-number-for-amount` を有効化したら stop（Wave 1 の仕事、骨子 TODO のみ）
- pre-commit が重いと感じたら scope を削る前に planning に差し戻す
- Appendix B §B.5.2 層 1 の Conventional Commits scope は AGENTS.md / CLAUDE.md
  と整合する必要あり。ハーネス bundle 側の編集は Forbidden
- `eslint-plugin-tailwindcss` を入れたくなったら stop (UQ-I006-05 不採用確定)
- `typecheck` を pre-commit に入れたくなったら stop (UQ-I006-07)
- `.gitignore` は `!.vscode/extensions.json` の 1 行追加のみ。他は触らない
- shadcn 生成物 (`apps/web/components/ui/**`) を lint 対象外にするか否かは
  impl lane の判断、handoff に根拠を記録

## Tool ownership preferences
- default tool owner: Codex (impl)
- review tool: Claude
- verify tool: Codex
- switch trigger: `eslint-plugin-tailwindcss` の誤混入、typecheck の
  pre-commit 追加、`no-number-for-amount` の有効化が検出されたら即 stop
