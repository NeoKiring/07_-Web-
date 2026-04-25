# Task Contract: I-003

本ファイルは **stub**。`dev-plan` で finalized へ昇格。
Verification commands / Touched files / Forbidden files は
v0.2 + Appendix A/B レビュー済み前提での推定記述。

## Identity
- task id: I-003
- title: packages/{core,db,ingestion,ui} skeleton (rest of workspace packages)
- area: packages/*
- slug: packages-rest-skeleton
- batch id: BATCH-WAVE0

## Objective

`packages/core`, `packages/db`, `packages/ingestion`, `packages/ui` の 4 パッケージを、
I-002 で整えた `tsconfig.base.json` / root `tsconfig.json` に乗る形で、
空骨子としてまとめて追加する。実装は一切含めない。

## Business / user value

Wave 1 以降の各 package 実体化タスクが、workspace 構造や project references に
悩まず、`src/*.ts` を追加するだけで済む状態にする。

## In scope

4 パッケージ × 3 ファイル = 12 ファイルの新規作成:

- `packages/core/package.json`, `packages/core/tsconfig.json`, `packages/core/src/index.ts`
- `packages/db/package.json`, `packages/db/tsconfig.json`, `packages/db/src/index.ts`
- `packages/ingestion/package.json`, `packages/ingestion/tsconfig.json`, `packages/ingestion/src/index.ts`
- `packages/ui/package.json`, `packages/ui/tsconfig.json`, `packages/ui/src/index.ts`

加えて:
- root `tsconfig.json` の `references` に 4 エントリ追加
- root `package.json` への最小変更（必要があれば typescript hoist 用の devDep のみ）

## Out of scope

- `packages/core` 実装全般（実質額計算、純資産、系列正規化、集約、CPI 接続）
- `packages/db` の Prisma 初期化、schema.prisma、リポジトリ層
- `packages/ingestion` の e-Stat / 日銀 API クライアント、boj-series-map
- `packages/ui` の shadcn/ui 初期化、Tremor 導入、Tailwind 設定、カラートークン、
  Recharts ラッパー
- 各 package 間の `dependencies` 宣言（空で閉じる。Wave 1 以降で追加）
- Vitest / Playwright 設定
- test/ ディレクトリ作成（golden 含む）
- ESLint / Prettier（→ I-006）
- `apps/web`（→ I-004）

## Touched files

- `packages/core/package.json` (new)
- `packages/core/tsconfig.json` (new)
- `packages/core/src/index.ts` (new)
- `packages/db/package.json` (new)
- `packages/db/tsconfig.json` (new)
- `packages/db/src/index.ts` (new)
- `packages/ingestion/package.json` (new)
- `packages/ingestion/tsconfig.json` (new)
- `packages/ingestion/src/index.ts` (new)
- `packages/ui/package.json` (new)
- `packages/ui/tsconfig.json` (new)
- `packages/ui/src/index.ts` (new)
- `tsconfig.json` (modify, root — references 4 行追加のみ)
- `package.json` (modify, root — 必要最小の devDep のみ、scripts は触らない)
- `pnpm-lock.yaml` (modify, 条件付き — impl lane が明示的に `pnpm install -w` する場合)

## Forbidden files

- `docs/harness/**`, `AGENTS.md`, `CLAUDE.md`, `CODEX.md`, `.gtrconfig.v4`,
  `.claude/**`, `.codex/**`, `.agents/**`, `scripts/harness/**`,
  `.runtime/**`, `.worktrees/**`
- `docs/ai/tasks/**`（self 除く）, `docs/ai/issues/**`（self 除く）, `docs/ai/plans/**`
- `packages/types/**`（I-002 の領分、変更禁止）
- `apps/**`（→ I-004）
- `tsconfig.base.json`（I-002 で確定、本タスクは extends のみ）
- I-001 で作った root ファイル群の実質変更（`pnpm-workspace.yaml`, `.gitignore`,
  `.nvmrc`, `.editorconfig`, `.env.example`, `README.md`）
- `.github/**`, `.husky/**`, `eslint.config.*`, `.prettierrc*`, `commitlint.config.*`
- `prisma/**`（Wave 2）

## Serial-only areas touched
- yes
- details:
  - root `package.json`（package manifest）
  - root `tsconfig.json`（shared global settings）
  - `pnpm-lock.yaml`（lockfile、触る条件付き）
  - merge order: I-002 の after、I-004/I-005/I-006/I-007 の before
  - Wave 0 内で並列実行しない
  - parallel exception 無し

## Verification commands

```text
# 推定。planning 時に package name 規約確定後、$NAME を置換。

# 1. 必須ファイルの存在（12 ファイル）
for p in core db ingestion ui; do
  test -f "packages/$p/package.json" || exit 1
  test -f "packages/$p/tsconfig.json" || exit 1
  test -f "packages/$p/src/index.ts" || exit 1
done

# 2. 各 package.json の構造
for p in core db ingestion ui; do
  node -e "
  const pkg = require('./packages/$p/package.json');
  if (!pkg.private) process.exit(10);
  if (!pkg.name || !pkg.name.includes('/')) process.exit(11);
  if (pkg.dependencies && Object.keys(pkg.dependencies).length > 0) process.exit(12);
  "
done

# 3. 各 tsconfig.json が base を extends
for p in core db ingestion ui; do
  grep -q '"extends"' "packages/$p/tsconfig.json"
  grep -qE 'tsconfig\.base\.json' "packages/$p/tsconfig.json"
done

# 4. 各 src/index.ts は空 export のみ（ドメイン型実装が無いこと）
for p in core db ingestion ui; do
  content=$(cat "packages/$p/src/index.ts")
  if [ "$(echo "$content" | grep -cE '^export (type|interface|class|function|const|let|var|enum) ')" != "0" ]; then
    echo "packages/$p/src/index.ts contains non-trivial exports"; exit 1
  fi
done

# 5. NFR-004 担保: packages/core/package.json に db/ui/ingestion 依存が無い
node -e "
const p = require('./packages/core/package.json');
const deps = Object.assign({}, p.dependencies||{}, p.peerDependencies||{});
const banned = ['@repo/db','@repo/ui','@repo/ingestion'];
for (const k of Object.keys(deps)) {
  if (banned.includes(k)) { console.error('forbidden dep in core: '+k); process.exit(1); }
}
"

# 6. root tsconfig.json の references に 4 パッケージが登録
node -e "
const t = JSON.parse(require('fs').readFileSync('tsconfig.json','utf8').replace(/\/\/.*\n/g,''));
const needed = ['packages/core','packages/db','packages/ingestion','packages/ui'];
for (const n of needed) {
  if (!t.references.some(r => r.path && r.path.includes(n))) {
    console.error('missing reference: '+n); process.exit(1);
  }
}
"

# 7. 型検査・build graph
pnpm -w tsc -b --dry
for p in core db ingestion ui; do pnpm -w tsc --noEmit -p "packages/$p"; done

# 8. I-001 / I-002 成果物への回帰無しの確認
git diff --name-only HEAD~1 -- packages/types/ | { ! grep -q .; }   # packages/types は触っていない
git diff --name-only HEAD~1 -- tsconfig.base.json | { ! grep -q .; } # base は触っていない

# 9. Out of scope 違反検知: Prisma / shadcn / Tailwind 痕跡
! grep -RE '@prisma/client|prisma\s+generator' packages/
! grep -RE 'from "react"|shadcn|tremor' packages/ui/src
! find packages/ -name 'tailwind.config.*' -type f | grep -q .

# 10. ハーネス artifact validator
scripts/harness/validate-task-artifacts.sh I-003
# pwsh scripts/harness/validate-task-artifacts.ps1 -TaskId I-003
```

## GUI verification
- required: no
- recipe path: n/a
- final frontmost validation required: no
- may be deferred by human: n/a

## Runtime isolation
- required: no
- notes: runtime process なし、`.runtime/allocations.json` 登録不要

## Done definition

- Verification 1〜10 全 PASS
- `scripts/harness/validate-task-artifacts` が I-003 に対して PASS
- `status.yaml` state が `implemented` 以上
- `handoff.md` に package name 規約の最終形、依存ゼロであること、
  次タスク（I-004）からの参照方法を記載
- `review.md` verdict が `PASS` / `PASS-WITH-NOTES`、Must Fix 解消
- Forbidden files に touch 無し

## Blocked if

- I-002 が `merged` 未到達
- UQ-I003-05（shadcn 配置方針）が planning 時未決、かつ I-005 に先送りできない状況
- Prisma 依存を引き込まなければ成立しない設計案が提案された

## Review focus

- **NFR-004 の強検証**: `packages/core` が `@repo/db` / `@repo/ui` / `@repo/ingestion`
  に依存していないこと
- **Out of scope 厳守**: Prisma / shadcn / Tailwind / React / Vitest の痕跡が
  一切無いこと（Verification 項目 9）
- **references 書式**: I-002 の書式に揃っているか、後続の `apps/web` 追加が
  機械的に済むか
- **12 ファイル以外の touch**: Forbidden files policy 違反の早期検出

## Merge order
- before: I-004, I-005, I-006, I-007
- after: I-002
- notes:
  - I-008 は I-001 完了後に並列可、I-003 の完了は待たない
  - I-004 は `apps/web` 初期化で `packages/*` を workspace 経由で参照しうるため、
    I-003 完了後に開始

## Notes for implementer
- writable lane is `impl` only
- tool ownership: default = Codex（impl）/ Claude（review）
- 実体コードは 1 行も書かない。`export {};` 以外は stop
- `dependencies` を埋めたくなったら stop（Wave 1 の仕事）
- Prisma / React / shadcn の記述が入ったら契約違反として revert
