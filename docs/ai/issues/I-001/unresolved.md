# Unresolved: I-001

以下は本 issue 単独では確定できない論点。planning（`dev-plan`）フェーズで
人間オペレータの判断、または v0.2 / Appendix A/B のレビュー済み前提に照らして
確定する必要がある。実装 (`impl`) 着手前に解消されていなければ、ハーネス上は
`planned` から `ready-for-impl` に遷移させてはならない。

## UQ-I001-01: pnpm バージョンの具体値

- 論点: `"packageManager": "pnpm@X.Y.Z"` の X.Y.Z
- 候補: `9.15.x`（安定）/ `10.x`（最新）
- 影響:
  - CI と全 impl lane の挙動一致
  - `.gtrconfig.v4` 採用時の worktree 側への反映
- 推奨: **pnpm 9.x の最新 patch**（Next.js / shadcn / Prisma の公式採用実績が厚い）
- 要人間判断: **yes**
- 参照: 要件 v0.2 §11.1（pnpm monorepo であること自体は確定）

## UQ-I001-02: Node LTS の具体値

- 論点: `.nvmrc` と `engines.node` に書く Node バージョン
- 候補: `20.x`（LTS Iron）/ `22.x`（LTS Jod）
- 影響:
  - Next.js 15 系・Prisma 5 系・shadcn/ui CLI の動作前提
  - CI（GitHub Actions）の matrix
- 推奨: **Node 22 LTS**（Phase A MVP を 3 ヶ月想定、MVP 期間中に 20.x EOL に
  接近するため。Next.js 15 の公式サポートに含まれる）
- 要人間判断: **yes**
- 参照: 要件 v0.2 NFR-008（Node LTS 要件）

## UQ-I001-03: 初回 `pnpm install` の運用

- 論点: I-001 完了時点で root に `pnpm-lock.yaml` を作るか、I-002 以降の
  impl lane が初めて依存を追加した時点で生成するか
- ハーネス的制約: **Anchor 5（No implicit installs）** により、bootstrap が
  勝手に install してはならない。よってどちらの選択でも、install は人間または
  impl lane の明示操作である
- 候補:
  - (a) I-001 の Done definition に install を含めず、`pnpm-lock.yaml` は
    I-002 で初めて生成される
  - (b) I-001 の Done definition の **オプション扱い** として、操作者が明示的に
    `pnpm install` を走らせてロックファイルを初期化する
- 推奨: **(a)**。I-001 の契約を install 非依存に保つ方がシンプル、かつ
  `pnpm-lock.yaml` は serial-only area（Anchor 4 / serial-only-areas policy）
  なので、最初に触るタスクは contract で明示されているべき。
- 要人間判断: **yes**

## UQ-I001-04: `.vscode/` の扱い

- 論点: `.vscode/settings.json` / `.vscode/extensions.json` を commit するか、
  `.gitignore` に倒すか
- 候補:
  - (a) `.vscode/` 丸ごと ignore
  - (b) `.vscode/extensions.json` だけ commit（推奨拡張の共有）、`settings.json`
    は ignore
- 推奨: **(b)**。ただし I-001 では `.gitignore` に `.vscode/` を一旦入れ、
  I-006（quality tooling）で `!.vscode/extensions.json` として opt-in する
  方針を取る。これにより I-001 の Scope を settings 議論に広げない。
- 要人間判断: **no**（上記推奨で進めてよいか、planning 時に軽く確認）

## UQ-I001-05: README.md の言語方針

- 論点: 日本語 / 英語 / 二言語併記
- 候補:
  - (a) 日本語（要件定義 v0.2 と揃える）
  - (b) 英語（ハーネス文書と揃える）
  - (c) 冒頭は英語 / 詳細は日本語の併記
- 推奨: **(a) 日本語**。要件定義と supplement が日本語であり、読者は同一。
  ハーネス同梱の AGENTS.md / CLAUDE.md / CODEX.md は独立した外部規約として
  英語のまま残す。
- 要人間判断: **no**（上記推奨で進めてよいか、planning 時に確認）

## 解消の期限

すべての UQ は I-001 を `ready-for-impl` に遷移させる時点までに、
`contract.md`（finalized）へ反映されていること。
planning 時に判断不可であれば `blocked` に落とす。
