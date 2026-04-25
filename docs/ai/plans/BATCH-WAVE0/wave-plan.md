# Wave Plan: BATCH-WAVE0

- batch_id: `BATCH-WAVE0`
- wave: 0
- harness_version: `4.1-p0-tool-ownership`
- shaping date: 2026-04-23
- planning date: 2026-04-24
- total tasks: 8 (I-001 〜 I-008)
- purpose: pnpm monorepo + TypeScript strict + Next.js 15 骨格 + UI スタック +
  quality tooling + CI + プロジェクト supplement まで、Wave 1 以降の全 impl lane
  が前提にできる土台を確定する

---

## 1. UQ 解消サマリ (前提条件)

全 26 件の UQ は `uq-decisions.md` で解消済み。本計画の全タスクはこの確定値を
前提とする。代表的な採用値:

- pnpm 9.x 最新 / Node 22 LTS / TypeScript 5.6 最新 / Next.js 15 最新
- workspace scope: `@repo/*` (全 package 共通)
- `exactOptionalPropertyTypes: true`, `moduleResolution: "bundler"`, barrel exports のみ
- `pnpm install` は I-002 が最初に実行 (明示、Anchor 5 遵守)
- shadcn プリミティブは `apps/web/components/ui/`、`packages/ui` はチャート共通のみ
- Tailwind v4 + shadcn CLI + 24 点初期セット一括
- ESLint flat config root 集約 / Prettier 幅 100 / `no-number-for-amount` 骨子のみ (Wave 1 で有効化)
- Commit scope: `core`, `db`, `ingestion`, `ui`, `types`, `web`, `infra`, `docs`, `deps`
- CI は ubuntu-latest のみ / axe は serious+critical で fail
- Supplement は `docs/ai/project/CLAUDE.project.md` に配置

---

## 2. タスク一覧

| task_id | title | area | merge order | GUI | runtime | serial-only |
|---|---|---|---|---|---|---|
| I-001 | monorepo skeleton (pnpm workspace + root configs) | `infra/monorepo` | 1 | no | no | yes |
| I-002 | packages/types skeleton + tsconfig base + root refs | `packages/types` | 2 | no | no | yes |
| I-003 | packages/{core,db,ingestion,ui} skeleton | `packages/*` | 3 | no | no | yes |
| I-004 | apps/web Next.js bare skeleton | `apps/web` | 4 | no | no | yes |
| I-005 | apps/web UI stack (Tailwind v4 + shadcn + Tremor + themes) | `apps/web/ui` | 5 | **required** | **required** | yes |
| I-006 | quality tooling (ESLint/Prettier/husky/lint-staged/commitlint) | `infra/quality` | 6 | no | no | yes |
| I-007 | CI pipeline (GitHub Actions + smoke + axe) | `infra/ci` | 7 | no | 条件付 | yes |
| I-008 | `docs/ai/project/CLAUDE.project.md` supplement | `docs/project` | parallel after I-001 | no | no | **no** |

---

## 3. 依存グラフ

```
I-001 (monorepo skeleton)
  ├──> I-002 (packages/types + tsconfig base)
  │       └──> I-003 (packages/{core,db,ingestion,ui})
  │               └──> I-004 (apps/web bare)
  │                       └──> I-005 (UI stack)
  │                               └──> I-006 (quality tooling)
  │                                       └──> I-007 (CI)
  │
  └──> I-008 (docs supplement)  [parallel, after I-001 only]
```

- **直列チェーン (serial chain)**: I-001 → I-002 → I-003 → I-004 → I-005 → I-006 → I-007
- **並列分岐 (parallel branch)**: I-008 は I-001 merge 後に並列開始可。
  他 7 タスクのどれとも競合しない (`docs/ai/project/` 配下のみを触るため
  serial-only 領域への touch が無い)

---

## 4. Merge Order (serial-only 遵守)

Wave 0 の 7 タスク (I-001〜I-007) は全て以下のいずれかの serial-only area に
touch するため、**merge は strict 直列**とする:

- root manifest (`package.json`, `pnpm-lock.yaml`, `pnpm-workspace.yaml`)
- shared TS settings (`tsconfig.base.json`, root `tsconfig.json`)
- quality config (`eslint.config.js`, `.prettierrc`, `.husky/`)
- CI config (`.github/workflows/**`)

### 推奨 merge 順序

1. **I-001 merged** → I-002 と I-008 を並列 ready
2. **I-002 merged** → I-003 ready
3. **I-003 merged** → I-004 ready
4. **I-004 merged** → I-005 ready
5. **I-005 merged** → I-006 ready
6. **I-006 merged** → I-007 ready
7. **I-007 merged** → Wave 0 直列チェーン完了
8. **I-008 merged** → Wave 0 全体完了 (I-001 merge 後いつでも可、遅くとも I-007 merge と同時まで)

---

## 5. 並列化機会

### 5.1 実装レーン (impl) の並列

**I-001 merged 直後**: `I-002 impl` と `I-008 impl` は同時並列開始可。

- 競合: なし
- 根拠: I-002 = `packages/types/**` + `tsconfig*.json` / I-008 = `docs/ai/project/**`
  で完全分離
- 前提: 各 lane が個別 worktree (`.worktrees/I-002__impl`, `.worktrees/I-008__impl`)
  で動くこと

それ以外の全タスクは serial-only 領域の touch 順序があるため、impl も直列。

### 5.2 インスペクションレーン (review/verify/gui) の並列

- pinned commit に対して read-only で走る inspection lane は、同 task 内でも
  別 task 間でも並列可
- 例: `I-001 review` (Claude) と `I-001 verify` (Codex) は同時並列可
- 例: `I-002 impl` (Codex) と `I-001 gui` (N/A だが概念的に) は同時並列可

### 5.3 runtime 衝突の回避

runtime を使うのは **I-005 のみ** (`pnpm --filter web dev` が port を
確保する + ブラウザが GUI single-instance 制約を持つ)。Wave 0 内で runtime
分離は I-005 だけで考えればよい (allocator は `.runtime/allocations.json`
に登録)。

---

## 6. Tool Ownership (デフォルト)

全 8 タスクに共通で適用する標準担当:

| lane | tool | 根拠 |
|---|---|---|
| impl | Codex | AGENTS.md §Lane model 既定 |
| review | Claude | AGENTS.md + CLAUDE.md の default review owner |
| verify | Codex | command-based verification の主務 |
| gui (I-005 のみ) | Claude | Windows desktop frontmost validation |
| docs (必要時) | Codex | artifact completion |

本 batch では **Claude は impl を取らない**:
- Wave 0 は bounded patch が中心、architecture-sensitive ではない
- UQ は shaping / planning 段階で解消済みで ambiguity が少ない
- 各タスクの contract が Scope / Touched files / Verification commands まで
  具体値で固まっており、Codex が bounded に遂行できる
- Claude が impl を取る「例外条件」(CLAUDE.md) には該当しない

切替が必要になった場合は AGENTS.md §Reassignment ルールに従い `handoff.md`
に記録する。

---

## 7. Runtime Isolation Requirements

| task_id | runtime_required | notes |
|---|---|---|
| I-001 | no | 静的ファイル作成のみ |
| I-002 | no | tsc のみ、process 起動なし |
| I-003 | no | 4 package skeleton のみ、tsc --noEmit |
| I-004 | no | `pnpm --filter web build` のみ (dev server 起動は I-005 まで待つ) |
| I-005 | **yes** | `pnpm --filter web dev` 起動 + ブラウザ GUI。`APP_PORT` / `USER_DATA_DIR` / `LOG_DIR` を `scripts/harness/alloc-runtime` で確保 |
| I-006 | no | lint / format / husky setup のみ |
| I-007 | 条件付 | local e2e 実行する場合は必要 (Playwright 起動)。CI 本体 (GitHub Actions) は runtime allocation 不要 |
| I-008 | no | docs のみ |

---

## 8. GUI Verification Requirements

| task_id | gui_required | defer_ok | 観測内容 |
|---|---|---|---|
| I-001 | no | - | - |
| I-002 | no | - | - |
| I-003 | no | - | - |
| I-004 | no | - | - |
| I-005 | **yes** | **no** (Done に含める) | `pnpm --filter web dev` → `http://localhost:<APP_PORT>` → light/dark 切替で `<html>` class 変化 + Tailwind 適用確認 + console error 無し |
| I-006 | no | - | - |
| I-007 | no | - | - |
| I-008 | no | - | - |

- I-005 の GUI 詳細 recipe は `docs/ai/tasks/I-005/gui.md` (Phase 3 で生成)
- Wave 4 で各画面の GUI recipe が本格化する。I-005 は「UI stack が起動する
  こと」の最小確認に留める

---

## 9. Serial-only Areas Map

### 9.1 Wave 0 期間中に逐次 touch される serial-only ファイル

| ファイル | 最初に作る | 最後に触る | 経由タスク |
|---|---|---|---|
| `pnpm-workspace.yaml` | I-001 | I-001 | I-001 のみ |
| root `package.json` | I-001 | I-007 | I-001 → I-002 → I-003 → I-005 → I-006 → I-007 |
| `pnpm-lock.yaml` | I-002 | I-007 | I-002 が初期化、以降の install で更新 |
| `tsconfig.base.json` | I-002 | I-002 | I-002 のみ (以降は触らない) |
| root `tsconfig.json` | I-002 | I-004 | I-002 → I-003 → I-004 (references 追加のみ) |
| `.gitignore` | I-001 | I-006 | I-001 → I-006 (`.vscode/`, ESLint/Prettier 生成物) |
| `eslint.config.js` | I-006 | I-006 | I-006 のみ |
| `.husky/**` | I-006 | I-006 | I-006 のみ |
| `.github/workflows/**` | I-007 | I-007 | I-007 のみ |

### 9.2 並列開始ルール

上記の「経由タスク」列で重複があるファイルは、該当タスク間で serial-only。
Wave 0 の直列チェーンでこれを担保している。I-008 は上記リストのファイル
すべてに非 touch なので並列化できる。

### 9.3 Forbidden files (全タスク共通)

以下はハーネス bundle 由来で全 Wave 0 タスクで編集禁止:

- `docs/harness/**`, `AGENTS.md`, `CLAUDE.md`, `CODEX.md`
- `.gtrconfig*`, `.claude/**`, `.codex/**`, `.agents/**`
- `scripts/harness/**`, `.runtime/**`, `.worktrees/**`

---

## 10. Wave 1 への引き継ぎ事項

Wave 0 完了時点で Wave 1 が前提にできる状態:

1. **pnpm workspace 稼働** (I-001): `pnpm` コマンドが通る
2. **TypeScript strict** (I-002): `pnpm -w tsc --noEmit` 0 exit
3. **全 workspace package 骨格** (I-003, I-004): 全 package の `src/index.ts` が存在、
   `tsc -b --dry` graph 整合
4. **UI スタック初期化済み** (I-005): Tailwind v4 / shadcn 24 点 / Tremor /
   next-themes / lucide / sonner / RHF / zod
5. **lint / format / commit 規約** (I-006): ローカル開発で pre-commit 効く
6. **CI パイプライン** (I-007): push / PR 時に typecheck / lint / build / smoke
   が走る
7. **プロジェクト supplement** (I-008): `docs/ai/project/CLAUDE.project.md` が
   AI impl lane の参照点として存在

### Wave 1 で最初に実施すべきこと (Wave 0 の契約で明示的に後回しにしたもの)

- Appendix A §A.2 の TypeScript ドメイン型の実体化 (I-002 で placeholder のみ)
- `packages/core` の実質額計算・純資産・系列正規化・集約・CPI 接続の実装
- Prisma 初期化 + schema.prisma (Wave 2 領域だが I-003 で out of scope 明示)
- `no-number-for-amount` ESLint ルールの有効化 (I-006 で骨子 TODO のみ)
- `packages/core/test/golden/` の初期 fixture
- Wave 1 で発生する package 間 dependencies 宣言 (I-003 では空で閉じた)

---

## 11. Throughput Estimate

### 11.1 Shaping + Planning (完了済み)

- shaping: 前セッションで完了 (32 ファイル、8 タスク × 4 artifact)
- planning: 本セッションで実施中
  - Phase 1 (wave-plan + queue): 2 ファイル
  - Phase 2 (contract × 8 finalized): 8 ファイル
  - Phase 3 (launch × 8 + gui × 1): 9 ファイル
  - Phase 4 (status × 8 更新): 8 ファイル
  - 合計: 27 ファイル (+ `uq-decisions.md` = 28)

### 11.2 Impl phase (Wave 0 実装、参考見積)

各タスクの complexity から概算:

| task_id | impl 概算 | review/verify 概算 | gui 概算 |
|---|---|---|---|
| I-001 | S | S | - |
| I-002 | M | S | - |
| I-003 | S | S | - |
| I-004 | M | S | - |
| I-005 | **L** | M | M |
| I-006 | M | M | - |
| I-007 | M | M | - |
| I-008 | S | S | - |

凡例: S = small / M = medium / L = large。L は I-005 (shadcn 24 点 + Tailwind
v4 + themes) のみ、他は全て M 以下。

---

## 12. Planning Checklist 確認

`dev-plan` skill の Required planning checklist を全タスクで通した結果:

- [x] scope boundary: 各 contract の In scope / Out of scope で確定
- [x] touched files: 各 contract の Touched files で具体ファイル列挙済み
- [x] serial-only area impact: §9 で map 化、merge order で担保
- [x] shared runtime risk: §7 で明示、I-005 のみ allocator 必須
- [x] GUI need: §8 で明示、I-005 のみ required
- [x] runtime isolation need: §7 と一致
- [x] review lane need: 全タスクで required (Claude default)
- [x] verify lane need: 全タスクで required (Codex default)
- [x] merge order: §4 で直列 + I-008 並列分岐を確定
- [x] blocker conditions: 各 contract の `Blocked if` セクションに明示

---

## 13. Wave 0 完了条件

以下を全て満たした時点で Wave 0 終了:

- 全 8 タスクの `status.yaml` が `state: merged`
- 全 8 タスクの `scripts/harness/validate-task-artifacts --require-merge-ready` が PASS
- Wave 1 への引き継ぎ事項 (§10) が全て成立
- この `wave-plan.md` に後続 Wave へのメモが追記されている
- Wave 1 batch の `BATCH-WAVE1` が shaping phase 開始可能な状態

---

## 14. 参照

- `uq-decisions.md` (同ディレクトリ、UQ 26 件の確定値)
- `queue.json` (同ディレクトリ、タスク実行順とステータス)
- 各タスクの `docs/ai/tasks/I-00N/contract.md` (finalized)
- 要件定義 v0.2 + Appendix A + Appendix B
- `docs/harness/FOUNDATION.md` + `AGENTS.md` + `CLAUDE.md` + `CODEX.md`
- `docs/harness/policies/serial-only-areas.md`
- `docs/harness/policies/runtime-isolation.md`
- `docs/harness/policies/merge-readiness.md`
