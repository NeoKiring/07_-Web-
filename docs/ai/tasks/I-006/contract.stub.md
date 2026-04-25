# Task Contract: I-006

本ファイルは **stub**。`dev-plan` で finalized へ昇格。
Verification commands / Touched files / Forbidden files は
v0.2 + Appendix A/B レビュー済み前提での推定記述。

## Identity
- task id: I-006
- title: quality tooling (ESLint + Prettier + husky + lint-staged + commitlint)
- area: infra/quality
- slug: infra-quality-tooling
- batch id: BATCH-WAVE0

## Objective

ローカル開発での静的解析・フォーマッタ・pre-commit / commit-msg hook を有効化し、
NFR-003 (pre-commit 個人データ混入検査) と NFR-005 (AI 主体開発ガードレール) を
実装レベルで効かせる。CI 組込みは I-007 の領分。

## Business / user value

AI impl lane が書き換える commit が常に同じ lint / format / commit 規約を
通る状態を作る。Appendix B §B.5.2 層 1 の仕様ロックと層 3 の型ロックの
ローカル側強制。

## In scope

- `eslint.config.js` (new, flat config)
- `.prettierrc` (new)
- `.prettierignore` (new)
- `.husky/pre-commit` (new)
- `.husky/commit-msg` (new)
- `commitlint.config.js` (new)
- `lint-staged.config.js` (new)
- root `package.json` (modify):
  - devDep 追加
  - scripts 追加: `lint`, `lint:fix`, `format`, `format:check`, `prepare`
- `apps/web/package.json` (modify): `lint` script 実体化
- `packages/<n>/package.json` × 5 (modify, 各 1 行レベル):
  - `lint`, `typecheck` script 追加
  - `types` / `core` / `db` / `ingestion` / `ui` すべて
- `pnpm-lock.yaml` (modify)

## Out of scope

- GitHub Actions workflow（→ I-007）
- Appendix A §A.5 `no-number-for-amount` の**有効化**（骨子のみ）
- gitleaks / secret scanning（Phase B）
- `prettier-plugin-tailwindcss`（Wave 4 判断）
- `changesets` / release automation
- `turbo` / `nx` 等の monorepo runner
- Vitest / Playwright の設定ファイル（Wave 1 / Wave 4）
- カバレッジ閾値設定（NFR-005 の 80% は I-007 の CI で強制）

## Touched files

- `eslint.config.js` (new, root)
- `.prettierrc` (new, root)
- `.prettierignore` (new, root)
- `.husky/pre-commit` (new)
- `.husky/commit-msg` (new)
- `commitlint.config.js` (new, root)
- `lint-staged.config.js` (new, root)
- `package.json` (modify, root)
- `apps/web/package.json` (modify)
- `packages/types/package.json` (modify)
- `packages/core/package.json` (modify)
- `packages/db/package.json` (modify)
- `packages/ingestion/package.json` (modify)
- `packages/ui/package.json` (modify)
- `pnpm-lock.yaml` (modify)

## Forbidden files

- `docs/harness/**`, `AGENTS.md`, `CLAUDE.md`, `CODEX.md`, `.gtrconfig.v4`,
  `.claude/**`, `.codex/**`, `.agents/**`, `scripts/harness/**`,
  `.runtime/**`, `.worktrees/**`
- `docs/ai/tasks/**`（self 除く）, `docs/ai/issues/**`（self 除く）, `docs/ai/plans/**`
- `tsconfig.base.json`, root `tsconfig.json`（I-002 / I-003 の領分）
- I-001 root ファイル群
- `apps/web/{tsconfig.json,next.config.ts,app/**,components/**,lib/**,tailwind.config.ts,postcss.config.js,app/globals.css,components.json}`
  （各 package.json の modify に限定）
- `packages/*/src/**`, `packages/*/tsconfig.json`
- `.github/**`（I-007）
- `prisma/**`

## Serial-only areas touched
- yes
- details:
  - 全 package の `package.json`（scripts 追加）
  - `pnpm-lock.yaml`
  - `.husky/**`, `eslint.config.js`, `commitlint.config.js` (cross-cutting
    logging / tracing initialization に相当する shared global settings)
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

# 2. pre-commit hook の実行権限
test -x .husky/pre-commit
test -x .husky/commit-msg

# 3. NFR-003 パターン検知の実装
grep -qE '(\.env\*|\*\.sqlite|\*\.db-journal|backups/)' .husky/pre-commit

# 4. 全 package に lint / typecheck script
for p in types core db ingestion ui; do
  node -e "const s=require('./packages/$p/package.json').scripts||{}; if(!s.lint||!s.typecheck) process.exit(1);"
done
node -e "const s=require('./apps/web/package.json').scripts||{}; if(!s.lint) process.exit(1);"

# 5. root scripts
node -e "const s=require('./package.json').scripts||{}; const r=['lint','lint:fix','format','format:check','prepare']; for(const k of r) if(!s[k]) { console.error('missing root script '+k); process.exit(1); }"

# 6. commitlint.config が conventional 準拠
grep -q '@commitlint/config-conventional' commitlint.config.js
grep -qE '(scope-enum|scopeEnum)' commitlint.config.js

# 7. 全 repo を lint が通る
pnpm lint

# 8. format:check
pnpm format:check

# 9. commitlint のサンプル検証（失敗系）
echo "bad commit" | npx commitlint ; test $? -ne 0

# 10. 成功系
echo "feat(types): add Amount brand" | npx commitlint

# 11. no-number-for-amount の骨子 TODO が存在
grep -qE 'no-number-for-amount|TODO.*amount' eslint.config.js

# 12. pre-commit simulation: .env が staged に入ったら hook が reject
# （scripts/harness/validate-task-artifacts がここまでシミュレートしないので、
#  impl lane は手動で 1 度確認、handoff に記録）

# 13. ハーネス artifact validator
scripts/harness/validate-task-artifacts.sh I-006
```

## GUI verification
- required: no
- recipe path: n/a
- final frontmost validation required: no
- may be deferred by human: n/a

## Runtime isolation
- required: no
- notes: 本タスクは runtime process を起動しない

## Done definition

- Verification 1〜13 全 PASS（項目 12 は impl lane の手動確認結果を handoff に記録）
- `scripts/harness/validate-task-artifacts` が I-006 に対して PASS
- `status.yaml` state が `implemented` 以上
- `handoff.md` に以下記録:
  - ESLint / Prettier / husky / lint-staged / commitlint の採用版
  - Commit scope 一覧の最終確定値（UQ-I006-03）
  - `no-number-for-amount` 骨子の配置（UQ-I006-06）
  - Appendix A §A.5 のカスタムルール実装 TODO を Wave 1 着手前に解消する旨の明記
- `review.md` verdict `PASS` / `PASS-WITH-NOTES`、Must Fix 解消
- I-001〜I-005 成果物への回帰なし（Touched files に含めた package.json の
  scripts フィールド以外）

## Blocked if

- I-005 が `merged` 未到達
- UQ-I006-01〜06 のいずれかが planning 時未決
- ESLint flat config と `typescript-eslint` の版互換問題

## Review focus

- **NFR-003 実装の網羅性**: `.env*`, `*.sqlite`, `*.db-journal`, `backups/*`
  が pre-commit で確実に reject されるパターンになっているか
- **NFR-005 の段階的適用**: カスタムルールの骨子が TODO で残っており、
  I-001〜I-005 の既存コードを壊していないか
- **pre-commit 負荷**: lint-staged で staged ファイルのみに限定されているか、
  typecheck が pre-commit に入っていないか
- **Conventional Commits scope**: Appendix B §B.5.2 層 1 の運用と一致しているか
- **依存最小性**: 追加された devDep が意図通りか、偶発的な sub-dep の PR 化を招かないか

## Merge order
- before: I-007
- after: I-005
- notes: I-008 は並列可

## Notes for implementer
- writable lane is `impl` only
- tool ownership: default = Codex（impl）/ Claude（review）
- `no-number-for-amount` を有効化したら stop（Wave 1 の仕事）
- pre-commit が重いと感じたら scope を削る前に planning に差し戻す
- Appendix B §B.5.2 層 1 の Conventional Commits scope は AGENTS.md / CLAUDE.md
  と整合する必要あり。ハーネス bundle 側の編集は Forbidden。
