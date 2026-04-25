# Task Contract: I-008

## Identity
- task id: I-008
- title: project-specific supplement document (CLAUDE.project.md)
- area: docs/project
- slug: docs-project-supplement
- batch id: BATCH-WAVE0
- harness_version: 4.1-p0-tool-ownership

## Objective

プロジェクト固有の AI 向け supplement `docs/ai/project/CLAUDE.project.md` を
作成し、要件 v0.2 §15.6 の「CLAUDE.md への転記」要請を、ハーネス CLAUDE.md を
改変せずに満たす橋渡しとする。

本タスクで確定する運用:
- **配置パス: `docs/ai/project/CLAUDE.project.md`** (**UQ-I008-01**)
- **言語: 日本語** (**UQ-I008-02**、読者は要件定義と同一想定)
- **ハーネス CLAUDE.md からの参照経路は本タスク非対象** (**UQ-I008-03 (b)**、
  root README.md への導線追加は Wave 0 完走後の別軽タスクに切り出し)
- **地雷マップは MVP で確実に踏むもののみ** (**UQ-I008-04**、将来分は
  「Wave X で追記予定」コメントで明示)
- **Wave 別読書ガイドは Wave 単位 3-5 行 index** (**UQ-I008-05**、Issue 単位は
  task shaping 成果物が担う)

## Business / user value

Wave 1 以降の全 impl lane が、ハーネス CLAUDE.md + project supplement を
セットで参照することで、プロジェクト固有のガードレール（型規約 / カラートークン
/ 6 層防御 / 地雷マップ）に常時アクセスできる。

本タスクは Wave 0 内で **唯一 serial-only 領域に非依存**で、I-001 merge 後に
他 7 タスクと並列走行可能。

## In scope

- `docs/ai/project/CLAUDE.project.md` (new)、以下 8 セクション:

  - **§1 プロジェクト要件の索引**: 要件 v0.2 本体 + Appendix A + Appendix B の
    相対パスと「何が書いてあるか」の 1-2 文要旨

  - **§2 型規約** (Appendix A §A.2 要旨 + 参照): `Amount` / `YearMonth` /
    `CurrencyCode` / Branded Types / 金額は `Decimal` のみ / `number` 禁止の
    **見出しのみ**。本文は Appendix A §A.2 を参照

  - **§3 UI 採用ポリシー** (Appendix B §B.4 要旨 + 参照): 1 コンポーネント =
    1 ライブラリ / shadcn プリミティブ = `apps/web/components/ui/` /
    `packages/ui` = チャート共通のみ / Tremor = Card/Metric/BadgeDelta のみ。
    本文は Appendix B §B.4 を参照

  - **§4 カラートークン** (Appendix B §B.4.5 要旨 + 参照): CSS 変数名リスト
    (`--series-income`, `--series-networth`, `--series-cpi`)、OKLCH 表記、
    ハードコード禁止の **見出しのみ**。本文は Appendix B §B.4.5 を参照

  - **§5 ガードレール** (Appendix B §B.5.2 6 層防御への索引): 各層の名称のみ
    列挙、**本文再掲なし**。リンクで Appendix B §B.5.2 へ誘導

  - **§6 NFR 要旨**: NFR-003 (Phase A セキュリティ・pre-commit) / NFR-004
    (`packages/core` UI/DB 非依存) / NFR-005 (AI 主体開発ガードレール) /
    NFR-009 の要旨 + 参照

  - **§7 地雷マップ** (箇条書き、**MVP で確実に踏むもののみ**、UQ-I008-04):
    - `localStorage` / `sessionStorage` を Artifact-like UI 実装で使わない
    - 金額に `number` を使わない（`Decimal` / `Amount` のみ）
    - CPI 未取得月は `null` を保つ（0 に fallback しない）
    - `Decimal × number` の四則演算を書かない
    - shadcn `<Card>` の中に Tremor `<Card>` を入れ子にしない
    - カラー値をハードコードしない（CSS 変数経由のみ）
    - `packages/core` から `@repo/db` / `@repo/ui` / `@repo/ingestion` に依存しない
    - 将来踏みそうなものは「Wave X で追記予定」とコメント

  - **§8 Wave 別読書ガイド** (Wave 0 / 1 / 2 / 3 / 4 / 5 ごと、各 3-5 行 index、
    UQ-I008-05):
    - Wave 0: 本文書 + `docs/harness/FOUNDATION.md` + AGENTS.md + 要件 §15.1-2
    - Wave 1: Appendix A §A.2 (型) + §A.5 + `packages/core` 系
    - Wave 2: 要件 §3-5 + Appendix A §A.1 (Prisma)
    - Wave 3: Appendix A §A.3 (API)
    - Wave 4: Appendix B §B.1-4 (UX + UI)
    - Wave 5: Phase B 関連（Wave X で追記予定）

- `docs/ai/project/README.md` (new): 1 段落の説明 + `CLAUDE.project.md` への link

## Out of scope

- ハーネス `CLAUDE.md` / `AGENTS.md` / `CODEX.md` の改変 (**Forbidden**)
- `docs/harness/**` の改変
- 要件定義 v0.2 / Appendix A / B の改訂
- 実装・設定ファイルの変更
- root `README.md` の改訂 (I-001 で作成済、追加導線は Wave 0 完走後の別タスク、
  UQ-I008-03 (b))
- Codex / Copilot 向け supplement (Phase A では不要)
- Wave ごとの Issue 単位 supplement (task shaping 成果物が担う、UQ-I008-05)
- 6 層防御の本文転記 (参照のみ、二重管理回避)
- 型規約の本文転記 (Appendix A §A.2 を参照のみ)
- カラートークン実値の転記 (Appendix B §B.4.5 を参照のみ)

## Touched files

- `docs/ai/project/CLAUDE.project.md` (new)
- `docs/ai/project/README.md` (new)

## Forbidden files

- `docs/harness/**` (**特に厳格**)
- `AGENTS.md`, `CLAUDE.md`, `CODEX.md` (repo root, ハーネス同梱)
- `.gtrconfig*`, `.claude/**`, `.codex/**`, `.agents/**`, `scripts/harness/**`
- `.runtime/**`, `.worktrees/**`
- `docs/ai/tasks/**`（self 除く）, `docs/ai/issues/**`（self 除く）, `docs/ai/plans/**`
- `requirements_v0.2.md`, `requirements_v0.2_appendix_A_technical.md`,
  `requirements_v0.2_appendix_B_ux.md` (要件定義本体、改変禁止)
- I-001 で作成した root ファイル (`pnpm-workspace.yaml`, `.gitignore`, `.nvmrc`,
  `.editorconfig`, `.env.example`, `package.json`, `README.md`)
- I-002〜I-007 の全成果物
- `apps/**`, `packages/**`, `tsconfig*.json`, `eslint.config.js`,
  `commitlint.config.js`, `lint-staged.config.js`, `.husky/**`,
  `.github/**`, `prisma/**`

## Serial-only areas touched
- **no**
- details:
  - 新規ディレクトリ `docs/ai/project/` 配下のみ
  - 既存 serial-only エリア（root manifest / lockfile / `tsconfig.base.json` /
    shared global settings / app bootstrap）に **触れない**
  - Wave 0 内で **唯一並列可能**なタスク。**I-001 merged 後、他 Wave 0
    タスク (I-002〜I-007) と並列走行して良い**
  - parallel exception 不要

## Verification commands

```text
# 1. 必須ファイルの存在
test -f docs/ai/project/CLAUDE.project.md
test -f docs/ai/project/README.md

# 2. 必要セクション 8 点が揃っている (§1〜§8 相当、UQ-I008-05)
for kw in 要件 型規約 UI カラートークン ガードレール NFR 地雷 Wave; do
  grep -qE "## .*${kw}" docs/ai/project/CLAUDE.project.md \
    || { echo "missing section keyword: ${kw}"; exit 1; }
done

# 3. 参照のみ方針: 6 層防御の本文が転記されていないこと
# (見出しに「6 層」があるが、本文に「層1」「層2」「層3」「層4」「層5」「層6」
# が全部書かれているなら転記の疑い)
count=$(grep -cE '層\s*[1-6]' docs/ai/project/CLAUDE.project.md || true)
if [ "${count:-0}" -gt 6 ]; then
  echo "6-layer defense appears to be transcribed rather than referenced"
  exit 1
fi

# 4. Appendix B §B.4.5 のカラー実値が転記されていないこと (OKLCH / HSL / hex)
! grep -E 'oklch\([^)]+\)|hsl\([^)]+\)|#[0-9a-fA-F]{6}' \
  docs/ai/project/CLAUDE.project.md

# 5. 地雷マップの keyword 網羅 (UQ-I008-04)
for kw in localStorage number Decimal CPI 'shadcn.*Tremor' 'ハードコード' \
          'packages/core'; do
  grep -qE "$kw" docs/ai/project/CLAUDE.project.md \
    || { echo "missing landmine keyword: $kw"; exit 1; }
done

# 6. Wave 別読書ガイド (UQ-I008-05、Wave 0〜5)
for wave in "Wave 0" "Wave 1" "Wave 2" "Wave 3" "Wave 4" "Wave 5"; do
  grep -q "$wave" docs/ai/project/CLAUDE.project.md \
    || { echo "missing wave in guide: $wave"; exit 1; }
done

# 7. 日本語であること (UQ-I008-02、仮判定: 平仮名/カタカナ出現)
LC_ALL=C.UTF-8 grep -qE '[あ-んア-ン]' docs/ai/project/CLAUDE.project.md \
  || { echo "file must be Japanese"; exit 1; }

# 8. ハーネス同梱ファイルに touch 無し
git diff --name-only HEAD~1 -- \
  AGENTS.md CLAUDE.md CODEX.md docs/harness/ \
  .gtrconfig.v4 .gtrconfig .claude/ .codex/ .agents/ scripts/harness/ \
  | { ! grep -q .; }

# 9. 要件定義本体に touch 無し
git diff --name-only HEAD~1 -- \
  requirements_v0.2.md \
  requirements_v0.2_appendix_A_technical.md \
  requirements_v0.2_appendix_B_ux.md \
  | { ! grep -q .; }

# 10. I-001〜I-007 の成果物に touch 無し (serial-only 非依存確認)
git diff --name-only HEAD~1 -- \
  apps/ packages/ tsconfig.base.json tsconfig.json \
  eslint.config.js .prettierrc .prettierignore .husky/ \
  commitlint.config.js lint-staged.config.js \
  .github/ package.json pnpm-workspace.yaml pnpm-lock.yaml \
  .nvmrc .gitignore .editorconfig .env.example README.md \
  vitest.workspace.ts \
  | { ! grep -q .; }

# 11. 本タスクで作成したファイルが docs/ai/project/ 配下のみ
changed=$(git diff --name-only HEAD~1)
for f in $changed; do
  case "$f" in
    docs/ai/project/*) ;;
    docs/ai/tasks/I-008/*) ;;
    *) echo "unexpected touched file: $f"; exit 1 ;;
  esac
done

# 12. ハーネス artifact validator
scripts/harness/validate-task-artifacts.sh I-008
```

## GUI verification
- required: no
- recipe path: n/a
- final frontmost validation required: no
- may be deferred by human: n/a

## Runtime isolation
- required: no
- notes: docs のみ。runtime 起動なし、`.runtime/allocations.json` 登録不要

## Done definition

- Verification 1〜12 全 PASS
- `scripts/harness/validate-task-artifacts` が I-008 に対して PASS
- `status.yaml` state `implemented` 以上
- `handoff.md` に以下記録:
  - ファイルパス `docs/ai/project/CLAUDE.project.md` 確定 (UQ-I008-01)
  - 言語: 日本語 (UQ-I008-02)
  - root README.md への導線追加を別タスクに切り出した旨 (UQ-I008-03 (b))
  - 地雷マップのスコープ: MVP のみ (UQ-I008-04)
  - Wave 別読書ガイド: Wave 単位 index (UQ-I008-05)
  - Wave 1 以降に追記すべき候補 (TODO として次タスクへ引き継ぐ、
    特に Wave 5 = Phase B 関連)
  - root README.md への導線追加の follow-up タスク ID 候補 (Wave 0 完走後)
- `review.md` verdict `PASS` / `PASS-WITH-NOTES`、Must Fix 解消
- Forbidden files に touch 無し (特にハーネス同梱ファイル、要件定義本体、
  他タスク成果物)

## Blocked if

- I-001 が `merged` 未到達 (最小前提として root README / .gitignore 等の
  path 運用が確定しているべき)
- 本タスクで `CLAUDE.md` を上書きする必要があるとの判断が出た (Forbidden 違反、
  即 blocker)
- 要件定義本体の記述が転記対象になってしまい、参照では解決できないと判明した
  (planning 差し戻し)

## Review focus

- **Forbidden 遵守**: ハーネス同梱ファイル / 要件定義本体 / 他タスク成果物に
  touch が無いこと (Verification 項目 8, 9, 10, 11)
- **参照のみ方針**: 6 層防御本文 / カラー実値 / 型実装本文が転記されていないこと
  (項目 3, 4)
- **地雷マップの実効性**: 項目 5 の keyword すべて含まれているか、文脈が
  Wave 1 以降の impl lane に通じる具体性か
- **セクション網羅性**: §1〜§8 相当の内容がすべて存在 (項目 2)
- **Wave 別読書ガイド**: Wave 0〜5 すべて記載、Wave 5 は「追記予定」コメントでも可
- **日本語**: 平仮名/カタカナ/漢字の自然な記述 (項目 7)

## Merge order
- before: (none) — 並列タスク
- after: I-001 (最小前提)
- notes:
  - I-002〜I-007 の完了を待たない
  - **I-001 merge 後に並列レーンで走行可能**
  - Wave 0 全体の完了要件としては他 7 タスクと同等
  - Wave 0 直列チェーン (I-001→...→I-007) と並列で進行してもよい

## Notes for implementer
- writable lane is `impl` only（docs のみだが手続きは通す）
- tool ownership: default = Codex（impl）/ Claude（review）
- ハーネス CLAUDE.md から転記したくなったら stop (参照のみ)
- 6 層防御の本文を書き始めたら stop (Appendix B §B.5.2 への参照で済ませる)
- role / stop conditions / tool ownership を書き始めたら stop (ハーネスの仕事)
- 「Wave X で追記予定」コメントは許容 (TODO 管理として)
- root README.md を触りたくなったら stop (UQ-I008-03 (b) で別タスクに分離確定)
- 型実装のコード例を書きたくなったら stop (Wave 1 の仕事、§2 は要旨のみ)
- カラー値のハードコード例を書きたくなったら stop (参照のみ方針)

## Tool ownership preferences
- default tool owner: Codex (impl)
- review tool: Claude
- verify tool: Codex
- switch trigger: ハーネス同梱ファイル・要件定義本体・他タスク成果物への touch が
  発生したら即 stop + Claude 介入 (Forbidden 違反の重大度高)。6 層防御の本文
  転記が始まったら stop
