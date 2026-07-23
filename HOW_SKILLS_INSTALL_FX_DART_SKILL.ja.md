# `skills` CLI が fxdart スキルをインストールする仕組み

**言語:** [English](HOW_SKILLS_INSTALL_FX_DART_SKILL.md) · [한국어](HOW_SKILLS_INSTALL_FX_DART_SKILL.ko.md) · [简体中文](HOW_SKILLS_INSTALL_FX_DART_SKILL.zh-Hans.md) · **日本語** · [Español](HOW_SKILLS_INSTALL_FX_DART_SKILL.es.md) · [Português](HOW_SKILLS_INSTALL_FX_DART_SKILL.pt-BR.md) · [Русский](HOW_SKILLS_INSTALL_FX_DART_SKILL.ru.md)

---

```sh
dart pub global activate skills
skills get fxdart
```

よくある疑問: `skills` はサードパーティのパッケージなのに、**どうやって fxdart を知り、インストールできるのか？**

## `skills` CLI は fxdart を「知っている」わけではない — fxdart が規約に従っている

`skills` は**汎用**のスキルインストーラーで、fxdart 専用のコードは一切ありません。`skills get fxdart` が意味するのは、実質的に次のことです:

> 「`fxdart` という名前のパッケージを取得し、その中の `skills/` ディレクトリを探して、自分のエージェントのスキルディレクトリへコピーせよ。」

これだけです。`fxdart` は単に **pub.dev に公開されたパッケージ名**にすぎず、fxdart が [Agent Skills](https://agentskills.io) の規約に従ったファイルを同梱して公開しているため動作します:

```
skills/
└── fxdart-pipelines/
    ├── SKILL.md               ← 規約: <スキル名>/SKILL.md
    └── references/api-reference.md
```

このレイアウトは規約なので、`skills get <名前>` は `skills/` ディレクトリを同梱する**あらゆる**パッケージで機能します — fxdart に限りません。

## git でダウンロード？ それとも pub.dev から抽出？

どちらも「`skills` 自身が fxdart を新規にダウンロードする」わけではありません。CLI は優先順位に従って解決します。

### 優先度 1（主経路）: ローカルの依存ツリーから抽出 — 出所は pub.dev

`skills` はまず **`package_config.json`**（`.dart_tool/package_config.json`）を読み、pub がすでにローカルへ展開済みのパッケージの場所を特定します。実際の流れは:

1. `dart pub get` / `pub global activate` が **pub.dev から** fxdart の tarball をダウンロードし、ローカルの pub キャッシュ（`~/.pub-cache/`）へ展開する。
2. `skills get fxdart` が、その展開済み fxdart ディレクトリを `package_config.json` で解決する。
3. 同梱された `skills/` ディレクトリをコピーする。

**→ `skills` 自身は fxdart のためにネットワークへアクセスしません。** pub がすでに pub.dev から取得したものを再利用します。これは fxdart 自身のインストーラーが `Isolate.resolvePackageUri` でディスク上のパッケージを探すのと同じ原理です。

### 優先度 2（フォールバック）: GitHub レジストリを clone — git を使う唯一の箇所

パッケージが依存ツリーに無い（あるいは `skills/` を同梱していない）場合で、git がインストールされていれば、`skills` は GitHub 上の厳選された**レジストリリポジトリ**を clone/update します:

- `flutter/skills`
- `serverpod/skills-registry`

これらのレジストリは「パッケージ名 → そのパッケージ向けスキル」を対応づけ、`.dart_skills/repos/` の下に clone されます。**`git` が関与するのはこのステップだけです。**

**優先順位ルール:** 同じパッケージについては、ローカル依存ツリーのスキルが常にレジストリのスキルより優先されます。

### まとめ

| 経路 | ソース | 仕組み |
|------|--------|--------|
| 優先度 1 | ローカル pub キャッシュ（出所: **pub.dev**） | ネットワーク無し — `package_config.json` で解決しフォルダをコピー |
| 優先度 2 | GitHub レジストリリポジトリ | **git clone / pull** |

したがって、質問への答えは:

- fxdart は `skills/` を直接同梱して pub.dev に公開しているため、**pub.dev 経路（優先度 1）** でインストールされます — **git は関与しません**。
- **git clone** は、パッケージが自前のスキルを持たず、厳選レジストリから探す必要があるときにのみ使われるフォールバックです。

## fxdart は独自のゼロ依存インストーラーも同梱している

fxdart は `skills` CLI をまったく必要としません。同じコピー処理をローカルで行うゼロ依存インストーラー（`bin/install_skills.dart`）を同梱しています:

```sh
# fxdart に依存するプロジェクトから:
dart run fxdart:install_skills              # プロジェクト内のエージェントディレクトリを自動検出
dart run fxdart:install_skills claude codex # またはエージェントを明示
dart run fxdart:install_skills all --global # ユーザーごとのディレクトリ（~/.claude/skills, ...）

# あるいは単体で:
dart pub global activate fxdart
fxdart_skills --global claude
```

内部では、`_skillsSource()` が `package:fxdart` の場所を解決し、隣接する `skills/` ディレクトリを見つけ、マーカー（`.claude`、`.codex`、`.agents` …）でエージェントを検出し、ツリーをコピーします。`skills` CLI を使っても fxdart 内蔵インストーラーを使っても、本質は同じです: **パッケージに同梱された `skills/` ディレクトリをコピーする。**

## コマンド / オプション リファレンス

### コミュニティ `skills` CLI

```sh
dart pub global activate skills
skills get fxdart
```

### fxdart 内蔵インストーラー

| コマンド | 効果 |
|----------|------|
| `dart run fxdart:install_skills` | プロジェクト内のエージェントディレクトリを自動検出してインストール |
| `dart run fxdart:install_skills claude codex` | 指定したエージェントにインストール |
| `dart run fxdart:install_skills all --global` | ユーザーごとのディレクトリ（`~/.claude/skills` …）へインストール |
| `fxdart_skills --global claude` | 単体実行（`pub global activate fxdart` の後） |
| `... --list` | インストール場所と状態を表示するだけで変更しない |
| `... --remove` | 選択した対象から fxdart スキルを削除 |
| `... --help` | ヘルプを表示 |

### 対応エージェントとスキルディレクトリ

| エージェント | プロジェクトディレクトリ | グローバルディレクトリ |
|--------------|--------------------------|------------------------|
| `claude` | `.claude/skills` | `~/.claude/skills` |
| `codex` | `.agents/skills` | `~/.agents/skills` |
| `antigravity` | `.agents/skills` | `~/.agents/skills` |
| `generic` | `.agents/skills` | `~/.agents/skills` |
| `devin` | `.devin/skills` | `~/.config/devin/skills` |
| `opencode` | `.opencode/skills` | `~/.config/opencode/skills` |
| `pi` | `.pi/skills` | `~/.pi/agent/skills` |

## 一行まとめ

`skills` は fxdart を知りません。fxdart が標準の `skills/*/SKILL.md` 規約に沿ってファイルを同梱し pub.dev に公開しているため、汎用の `skills` CLI が「pub（ローカルキャッシュ）から取得して `skills/` フォルダをコピー」するだけでインストールできるのです。pub.dev + フォルダ規約の組み合わせであり、**git は自前のスキルを持たないパッケージ向けのフォールバックにすぎません。**
