# Unresolved: I-008

## UQ-I008-01: ファイルパス

- 候補:
  - (a) `docs/ai/project/CLAUDE.project.md`
  - (b) `docs/ai/CLAUDE.project.md`（project/ 階層なし）
  - (c) `CLAUDE.project.md`（root 直下）
- 推奨: **(a) `docs/ai/project/CLAUDE.project.md`**
  理由: ハーネス `docs/ai/` 配下の役割分担（issues/ tasks/ plans/）に
  同居させつつ、プロジェクト固有を `project/` で明確に分離
- 要人間判断: **yes**

## UQ-I008-02: 言語方針

- 候補: 日本語 / 英語 / 二言語
- 推奨: **日本語**（要件定義 v0.2 と同一読者想定）
- 要人間判断: **no**

## UQ-I008-03: ハーネス CLAUDE.md からの参照経路

- 候補:
  - (a) ハーネス CLAUDE.md を改変 (**Forbidden**)
  - (b) root README.md に導線を置く（別の軽タスクで実施）
  - (c) I-008 自身で root README.md 更新も兼ねる
- 推奨: **(b)**。I-008 は `docs/ai/project/` に閉じ、root README への導線
  追加は Wave 0 完走後の別タスクで。I-001 の README.md 記述が既に relative link を
  許していれば、その運用の一貫として扱う
- 要人間判断: **yes**

## UQ-I008-04: 地雷マップのスコープ

- 候補:
  - (a) MVP で確実に踏むものだけ
  - (b) Phase B / Wave 5 以降の将来分も含む
- 推奨: **(a)**、将来分は「Wave X で追記予定」のコメントで明示
- 要人間判断: **no**

## UQ-I008-05: Wave 別読書ガイドの粒度

- 候補:
  - (a) Wave 単位で 3〜5 行の index
  - (b) 各 Wave の各 Issue 単位で個別の index
- 推奨: **(a)**。Issue 単位は task shaping（本 Batch の成果物）が既に担う
- 要人間判断: **no**

## 解消の期限

全 UQ は I-008 `ready-for-impl` 遷移時までに contract.md 反映。
本タスクは I-001 後に並列可能なので、他 Wave 0 の serial 進行を block しない。
