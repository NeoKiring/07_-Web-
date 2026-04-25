# UQ Decisions: BATCH-WAVE0

- batch_id: BATCH-WAVE0
- harness_version: 4.1-p0-tool-ownership
- purpose: Wave 0 全 8 タスクの `unresolved.md` から「要人間判断: yes」の項目のみ
  を抽出し、planning phase (B') 着手前に一括解消する
- 総数: **26 件** (9 グループに分類)
- 各 UQ の詳細論点と候補は `docs/ai/issues/I-00N/unresolved.md` を参照。本
  ドキュメントは推奨値とその根拠の summary のみ

---

## グループ 1: 環境バージョン pin (4 件)

全て「latest stable patch を採用」「EOL 猶予を優先」の原則。Phase A (3 ヶ月
MVP) + Phase B の合計寿命を見越した選定。

| UQ | 論点 | 推奨値 | 根拠 |
|---|---|---|---|
| UQ-I001-01 | pnpm バージョン | **pnpm 9.x 最新 patch** | Next.js 15 / shadcn / Prisma の公式採用実績が最厚。10.x は採用実績がまだ薄い |
| UQ-I001-02 | Node LTS | **Node 22 LTS (Jod)** | MVP 3 ヶ月期間中に 20.x (Iron) EOL 接近。Next.js 15 公式サポート内 |
| UQ-I002-01 | TypeScript バージョン | **TypeScript 5.6 最新 patch** | Next.js 15 公式推奨範囲、`moduleResolution: "bundler"` で安定 |
| UQ-I004-04 | Next.js バージョン | **Next.js 15 最新 patch** | App Router stable、shadcn/ui 2.x と整合 |

---

## グループ 2: Package naming (1 件)

| UQ | 論点 | 推奨値 | 根拠 |
|---|---|---|---|
| UQ-I002-02 | workspace package name scope | **`@repo/*`** (`@repo/types`, `@repo/core`, `@repo/db`, `@repo/ingestion`, `@repo/ui`, `@repo/web`) | shadcn/ui 公式モノレポ template 準拠。ローカル限定 Phase A では org 名に悩まない。Phase B 公開時 rename は機械的置換で対応可 |

**波及**: I-003 (全 4 package 名), I-004 (apps/web)。グループ 2 承認で
UQ-I003-01 / UQ-I004-01 (= 要人間判断: no) も自動確定。

---

## グループ 3: TypeScript strict / module 設定 (3 件)

| UQ | 論点 | 推奨値 | 根拠 |
|---|---|---|---|
| UQ-I002-03 | `exactOptionalPropertyTypes` | **true** | NFR-005 厳密化に寄与。Appendix A §A.2 の optional プロパティは Wave 1 で `memo: string \| undefined` 形式に書き直す手数を許容 |
| UQ-I002-04 | `moduleResolution` | **`"bundler"`** | Next.js 15 公式推奨、shadcn CLI 前提、Vitest も両対応 |
| UQ-I002-06 | `packages/types` の `exports` 方針 | **(a) barrel のみ** (`"exports": { ".": { ... } }`) | 要件 v0.2 §15.6「公開 API の型定義を固定」。AI が sub-path import で境界を曖昧にするのを防ぐ |

---

## グループ 4: pnpm install タイミング (2 件、相互連動)

| UQ | 論点 | 推奨値 | 根拠 |
|---|---|---|---|
| UQ-I001-03 | I-001 で install するか | **(a) I-001 では install しない** (Done に含めない、`pnpm-lock.yaml` は未生成で終わる) | I-001 の契約を install 非依存に保つ |
| UQ-I002-05 | I-002 で `pnpm-lock.yaml` 初期化するか | **(b) I-002 の Done に `pnpm-lock.yaml` 存在を含める** (impl lane が明示的に `pnpm install -w` を 1 回実行) | 初めて devDep (typescript) が発生するタスクで lock 生成が自然。Anchor 5 (No implicit installs) は「operator/lane の明示実行」で遵守 |

**整合性**: (a) + (b) は矛盾なし。I-001 は lock 無しで terminate、I-002 が最初の
install を担う。

---

## グループ 5: UI スタック決定 (5 件、Wave 4 波及大)

| UQ | 論点 | 推奨値 | 根拠 |
|---|---|---|---|
| UQ-I003-05 | `packages/ui` と `apps/web` の責務境界 | **(b) shadcn プリミティブは `apps/web/components/ui/`、`packages/ui` はチャート共通ラッパー等のみ** | shadcn/ui は「コード全コピー」前提で app 単位カスタムの設計思想。`packages/ui` は Appendix B §B.4 の `charts/theme.ts` + Recharts 共通ラッパーに集中 |
| UQ-I005-01 | Tailwind v4 vs v3 | **Tailwind v4** | Appendix B §B.4 が v4 の `@theme` / PostCSS 前提で記述 |
| UQ-I005-02 | shadcn/ui CLI 利用可否 | **CLI 採用** (`pnpm dlx shadcn@latest add`)、ただし `components.json` は先に commit | 手動コピーは運用負荷が高い。CLI は `--overwrite false` で安全化 |
| UQ-I005-06 | shadcn 初期セット 24 点一括導入 | **一括導入** (Appendix B §B.4.2 の 24 点) | 段階追加は review lane の後回しが発生しがち。Wave 4 は「追加ルール」だけ決める |
| UQ-I005-07 | 初期コンポーネント `apps/web/components/ui/` 配置最終確定 | **確定** | UQ-I003-05 (b) の最終確認レベル |

**波及**: Wave 4 の全画面タスクの配置規約、`packages/ui` の肥大化防止ルール。

---

## グループ 6: apps/web 構造 (2 件)

| UQ | 論点 | 推奨値 | 根拠 |
|---|---|---|---|
| UQ-I004-03 | `src/` layout vs flat layout | **`apps/web/app/` 直下** (flat) | Appendix B §B.1.3 記述と整合、shadcn/ui CLI デフォルトと整合 |
| UQ-I004-05 | 初期化方法 | **(b) 手動** (`pnpm init` 後に依存追加) | `create-next-app` は余計な依存 (eslint, tailwind) を package.json に書き込むため、Anchor 5 整合性が (b) の方が良い |

---

## グループ 7: Quality tooling (5 件)

| UQ | 論点 | 推奨値 | 根拠 |
|---|---|---|---|
| UQ-I006-01 | ESLint config の配置 | **(a) root `eslint.config.js` に全集約** | Wave 0 段階で過剰分離しない。必要になれば後で `packages/eslint-config/` 分離 |
| UQ-I006-02 | Prettier 詳細設定 | **`{ printWidth: 100, semi: true, singleQuote: true, trailingComma: "all", arrowParens: "always" }`** | Next.js / shadcn 慣例。100 幅はダッシュボード JSX で有利 |
| UQ-I006-03 | Conventional Commits scope 一覧 | **`core`, `db`, `ingestion`, `ui`, `types`, `web`, `infra`, `docs`, `deps`** | Wave 別の impl lane 運用と package 構造に 1:1 対応。Appendix B §B.5.2 層 1 の `core!:` = Draft PR 示唆と整合 |
| UQ-I006-05 | `eslint-plugin-tailwindcss` 採否 | **不採用 (Wave 4 で判断)** | Tailwind v4 対応が 2026/04 時点で不十分な版を入れるリスクを避ける |
| UQ-I006-06 | `no-number-for-amount` カスタムルール実装 | **(a) 骨子のみ (TODO コメント)、Wave 1 で有効化** | 有効化すると I-001〜I-005 の既存コードが落ちる可能性 (特に Tremor の `width/height`) |

**波及**: UQ-I006-03 は Wave 1 以降の全 PR タイトルに波及、最優先確定。

---

## グループ 8: CI 方針 (2 件)

| UQ | 論点 | 推奨値 | 根拠 |
|---|---|---|---|
| UQ-I007-03 | axe smoke テスト失敗基準 | **(b) `impact: serious\|critical` のみ fail、moderate/minor は warning** | WCAG 2.1 Level AA 達成を Wave 4 で段階強化する方針と整合。Wave 0 の初期導入で strict すぎると impl lane が通らない |
| UQ-I007-05 | CI matrix 範囲 | **ubuntu-latest のみ** (Windows は operator 手元確認) | Harness Anchor 7 の Windows first-class は lane 起動スクリプトの両方提供 (`.sh` + `.ps1`) で担保。CI matrix 追加は工数/時間対効果低い |

**注意**: UQ-I007-05 は Harness Anchor 7 との整合を再確認対象。**operator 手元で Windows 確認する運用** が担保できれば ubuntu-latest のみで可。

---

## グループ 9: Docs 配置 (2 件)

| UQ | 論点 | 推奨値 | 根拠 |
|---|---|---|---|
| UQ-I008-01 | CLAUDE supplement ファイルパス | **`docs/ai/project/CLAUDE.project.md`** | ハーネス `docs/harness/` と明確に分離、`docs/ai/` 配下の役割分担 (issues/ tasks/ plans/ project/) と整合 |
| UQ-I008-03 | ハーネス CLAUDE.md からの参照経路 | **(b) root README.md に導線を置く (本タスクではなく別タスクで)** | ハーネス `CLAUDE.md` は Forbidden。I-008 は `docs/ai/project/` に閉じ、root README 更新は Wave 0 完走後の軽タスクに切り出す |

---

## 集計

- グループ 1 (環境版): 4 件
- グループ 2 (package naming): 1 件
- グループ 3 (TS 設定): 3 件
- グループ 4 (install タイミング): 2 件
- グループ 5 (UI スタック): 5 件
- グループ 6 (apps/web 構造): 2 件
- グループ 7 (quality): 5 件
- グループ 8 (CI): 2 件
- グループ 9 (docs): 2 件

**合計: 26 件**

---

## 確定後の扱い

本ドキュメントでユーザー承認が得られた項目は以下に反映する:

1. 各タスクの `contract.md` (finalized、`contract.stub.md` から昇格) の
   **Verification commands** / **Touched files** / **Done definition** 内の
   具体値として展開。「特記（推定記述）」ヘッダを削除
2. 各タスクの `launch.md` (新規) の **Start instruction** / **Verification plan**
   に確定値として引用
3. 各タスクの `handoff.md` の Record items として「UQ-XXX-NN の最終確定値」を
   予約領域として定義 (impl lane が記録する)
4. `wave-plan.md` (新規) の Wave 0 全体タイムラインで前提条件として参照
5. `status.yaml` の `exact_next_action` 更新、`state: planned` → `ready-for-impl`

---

## 手動変更したい場合

以下のいずれかで修正可能:

- **個別 UQ の推奨値変更**: 「グループ X の UQ-YYY-NN は (a) ではなく (b) を採用」のように指示
- **グループ単位で議論**: 「グループ 5 は再検討したい」のように指示
- **全推奨値承認**: 「全 26 件、推奨値で承認」のように一括指示
