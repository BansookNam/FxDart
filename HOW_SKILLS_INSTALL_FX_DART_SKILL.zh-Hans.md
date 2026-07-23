# `skills` CLI 如何安装 fxdart 技能

**语言：** [English](HOW_SKILLS_INSTALL_FX_DART_SKILL.md) · [한국어](HOW_SKILLS_INSTALL_FX_DART_SKILL.ko.md) · **简体中文** · [日本語](HOW_SKILLS_INSTALL_FX_DART_SKILL.ja.md) · [Español](HOW_SKILLS_INSTALL_FX_DART_SKILL.es.md) · [Português](HOW_SKILLS_INSTALL_FX_DART_SKILL.pt-BR.md) · [Русский](HOW_SKILLS_INSTALL_FX_DART_SKILL.ru.md)

---

```sh
dart pub global activate skills
skills get fxdart
```

一个常见问题：`skills` 是第三方包，**它怎么会知道 fxdart 并安装它？**

## `skills` CLI 并不"认识" fxdart —— 是 fxdart 遵循了约定

`skills` 是一个**通用**技能安装器，里面没有任何 fxdart 专属代码。`skills get fxdart` 实际上的含义是：

> "把名为 `fxdart` 的包取来，在其中找到 `skills/` 目录，并复制到我的智能体技能目录中。"

仅此而已。`fxdart` 只是一个**发布到 pub.dev 的包名**，之所以能工作，是因为 fxdart 打包了遵循 [Agent Skills](https://agentskills.io) 约定的文件：

```
skills/
└── fxdart-pipelines/
    ├── SKILL.md               ← 约定：<技能名>/SKILL.md
    └── references/api-reference.md
```

由于这种布局是一种约定，`skills get <名称>` 对**任何**打包了 `skills/` 目录的包都有效 —— 不仅仅是 fxdart。

## 是通过 git 下载，还是从 pub.dev 提取？

两者都不是由 `skills` 自己重新下载 fxdart。CLI 按优先级顺序解析：

### 优先级 1（主路径）：从本地依赖树中提取 —— 源头是 pub.dev

`skills` 首先读取 **`package_config.json`**（`.dart_tool/package_config.json`）来定位 pub 已在本地解包的包。真实流程为：

1. `dart pub get` / `pub global activate` **从 pub.dev** 下载 fxdart 的 tarball，并解压到本地 pub 缓存（`~/.pub-cache/`）。
2. `skills get fxdart` 通过 `package_config.json` 解析出那个已解包的 fxdart 目录。
3. 复制其中打包的 `skills/` 目录。

**→ `skills` 自身不会为了 fxdart 而访问网络。** 它复用 pub 已从 pub.dev 取得的内容。这与 fxdart 自带安装器用 `Isolate.resolvePackageUri` 在磁盘上查找包的原理相同。

### 优先级 2（回退）：克隆 GitHub 注册表 —— 这是唯一用到 git 的地方

如果该包不在依赖树中（或没有打包 `skills/`），并且安装了 git，`skills` 会克隆/更新 GitHub 上经过筛选的**注册表仓库**：

- `flutter/skills`
- `serverpod/skills-registry`

这些注册表把"包名 → 该包的技能"映射起来，克隆到 `.dart_skills/repos/` 下。**只有这一步涉及 `git`。**

**优先级规则：** 对于同一个包，本地依赖树中的技能始终优先于注册表中的技能。

### 小结

| 路径 | 来源 | 机制 |
|------|------|------|
| 优先级 1 | 本地 pub 缓存（源头：**pub.dev**） | 无网络 —— 通过 `package_config.json` 解析后复制文件夹 |
| 优先级 2 | GitHub 注册表仓库 | **git clone / pull** |

因此，针对该问题：

- fxdart 直接打包了 `skills/` 并发布到 pub.dev，所以它通过 **pub.dev 路径（优先级 1）** 安装 —— **不涉及 git**。
- **git clone** 只是回退方案，用于包本身不携带技能、必须从筛选注册表中查找的情况。

## fxdart 也自带零依赖安装器

fxdart 完全不需要 `skills` CLI。它自带一个零依赖安装器（`bin/install_skills.dart`），在本地执行完全相同的复制操作：

```sh
# 在依赖 fxdart 的项目中：
dart run fxdart:install_skills              # 自动检测项目中的智能体目录
dart run fxdart:install_skills claude codex # 或显式指定智能体
dart run fxdart:install_skills all --global # 用户级目录（~/.claude/skills, ...）

# 或独立运行：
dart pub global activate fxdart
fxdart_skills --global claude
```

在内部，`_skillsSource()` 解析 `package:fxdart` 的位置，找到相邻的 `skills/` 目录，通过标记（`.claude`、`.codex`、`.agents`……）检测智能体，然后复制整个目录树。无论你用 `skills` CLI 还是 fxdart 内置安装器，本质都相同：**复制包中打包的 `skills/` 目录。**

## 命令 / 选项参考

### 社区 `skills` CLI

```sh
dart pub global activate skills
skills get fxdart
```

### fxdart 内置安装器

| 命令 | 作用 |
|------|------|
| `dart run fxdart:install_skills` | 自动检测项目中的智能体目录并安装 |
| `dart run fxdart:install_skills claude codex` | 为指定的智能体安装 |
| `dart run fxdart:install_skills all --global` | 安装到用户级目录（`~/.claude/skills`……） |
| `fxdart_skills --global claude` | 独立运行（在 `pub global activate fxdart` 之后） |
| `... --list` | 仅显示安装位置和状态，不做更改 |
| `... --remove` | 从所选目标中移除 fxdart 技能 |
| `... --help` | 显示帮助 |

### 支持的智能体及其技能目录

| 智能体 | 项目目录 | 全局目录 |
|--------|----------|----------|
| `claude` | `.claude/skills` | `~/.claude/skills` |
| `codex` | `.agents/skills` | `~/.agents/skills` |
| `antigravity` | `.agents/skills` | `~/.agents/skills` |
| `generic` | `.agents/skills` | `~/.agents/skills` |
| `devin` | `.devin/skills` | `~/.config/devin/skills` |
| `opencode` | `.opencode/skills` | `~/.config/opencode/skills` |
| `pi` | `.pi/skills` | `~/.pi/agent/skills` |

## 一句话总结

`skills` 并不认识 fxdart。是 fxdart 按照标准的 `skills/*/SKILL.md` 约定打包文件并发布到 pub.dev，通用的 `skills` CLI 才能通过"从 pub（本地缓存）取得并复制 `skills/` 目录"来安装它。这是 pub.dev + 目录约定的组合；**git 只是针对不自带技能的包的回退方案。**
