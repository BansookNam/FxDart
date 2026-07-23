# How the `skills` CLI installs the fxdart skill

**Language:** **English** · [한국어](HOW_SKILLS_INSTALL_FX_DART_SKILL.ko.md) · [简体中文](HOW_SKILLS_INSTALL_FX_DART_SKILL.zh-Hans.md) · [日本語](HOW_SKILLS_INSTALL_FX_DART_SKILL.ja.md) · [Español](HOW_SKILLS_INSTALL_FX_DART_SKILL.es.md) · [Português](HOW_SKILLS_INSTALL_FX_DART_SKILL.pt-BR.md) · [Русский](HOW_SKILLS_INSTALL_FX_DART_SKILL.ru.md)

---

```sh
dart pub global activate skills
skills get fxdart
```

A common question: `skills` is a third-party package, so **how does it know about fxdart and install it?**

## The `skills` CLI does not "know" fxdart — fxdart follows a convention

`skills` is a **generic** skill installer. It has no fxdart-specific code. `skills get fxdart` means, in effect:

> "Take the package named `fxdart`, look inside it for a `skills/` directory, and copy that into my agent's skill directory."

That's all. `fxdart` is simply a **package name published to pub.dev**, and it works because fxdart ships files that follow the [Agent Skills](https://agentskills.io) convention:

```
skills/
└── fxdart-pipelines/
    ├── SKILL.md               ← convention: <skill-name>/SKILL.md
    └── references/api-reference.md
```

Because the layout is a convention, `skills get <name>` works for **any** package that bundles a `skills/` directory — not just fxdart.

## Git download, or pub.dev extraction?

Neither is a fresh download of fxdart by `skills` itself. The CLI resolves in priority order:

### Priority 1 (primary): extract from the local dependency tree — origin is pub.dev

`skills` first reads **`package_config.json`** (`.dart_tool/package_config.json`) to locate packages that pub has already unpacked locally. The real flow is:

1. `dart pub get` / `pub global activate` downloads the fxdart tarball **from pub.dev** and unpacks it into the local pub cache (`~/.pub-cache/`).
2. `skills get fxdart` resolves that already-unpacked fxdart directory via `package_config.json`.
3. It copies the bundled `skills/` directory out.

**→ `skills` itself does not hit the network for fxdart.** It reuses what pub already fetched from pub.dev. This is the same principle as fxdart's own installer, which uses `Isolate.resolvePackageUri` to find the package on disk.

### Priority 2 (fallback): clone a GitHub registry — this is the only place git is used

If the package is not in the dependency tree (or bundles no `skills/`), and git is installed, `skills` clones/updates curated **registry repositories** on GitHub:

- `flutter/skills`
- `serverpod/skills-registry`

These registries map "package name → skills for that package" and are cloned under `.dart_skills/repos/`. **This is the only step where `git` is involved.**

**Precedence rule:** for the same package, a skill from the local dependency tree always wins over a registry skill.

### Summary

| Path | Source | Mechanism |
|------|--------|-----------|
| Priority 1 | Local pub cache (origin: **pub.dev**) | No network — resolve via `package_config.json`, then copy the folder |
| Priority 2 | GitHub registry repo | **git clone / pull** |

So, for the specific question:

- fxdart bundles `skills/` directly and publishes it to pub.dev, so it installs via the **pub.dev path (Priority 1)** — **git is not involved**.
- **git clone** is only the fallback used when a package does not ship its own skill and must be found in a curated registry.

## fxdart also ships its own zero-dependency installer

fxdart does not require the `skills` CLI at all. It bundles a zero-dependency installer (`bin/install_skills.dart`) that does exactly the same copy operation locally:

```sh
# From a project that depends on fxdart:
dart run fxdart:install_skills              # auto-detect agent dirs in the project
dart run fxdart:install_skills claude codex # or name agents explicitly
dart run fxdart:install_skills all --global # per-user dirs (~/.claude/skills, ...)

# Or standalone:
dart pub global activate fxdart
fxdart_skills --global claude
```

Internally, `_skillsSource()` resolves the `package:fxdart` location, finds the sibling `skills/` directory, detects the agent via markers (`.claude`, `.codex`, `.agents`, ...), and copies the tree. Whether you use the `skills` CLI or fxdart's built-in installer, the essence is identical: **copy the `skills/` directory bundled in the package.**

## Command / option reference

### Community `skills` CLI

```sh
dart pub global activate skills
skills get fxdart
```

### fxdart built-in installer

| Command | Effect |
|---------|--------|
| `dart run fxdart:install_skills` | Auto-detect agent dirs in the project and install |
| `dart run fxdart:install_skills claude codex` | Install for the named agents |
| `dart run fxdart:install_skills all --global` | Install into per-user dirs (`~/.claude/skills`, ...) |
| `fxdart_skills --global claude` | Standalone (after `pub global activate fxdart`) |
| `... --list` | Show install locations and status, change nothing |
| `... --remove` | Remove fxdart skills from the selected targets |
| `... --help` | Show help |

### Supported agents and their skill directories

| Agent | Project directory | Global directory |
|-------|-------------------|------------------|
| `claude` | `.claude/skills` | `~/.claude/skills` |
| `codex` | `.agents/skills` | `~/.agents/skills` |
| `antigravity` | `.agents/skills` | `~/.agents/skills` |
| `generic` | `.agents/skills` | `~/.agents/skills` |
| `devin` | `.devin/skills` | `~/.config/devin/skills` |
| `opencode` | `.opencode/skills` | `~/.config/opencode/skills` |
| `pi` | `.pi/skills` | `~/.pi/agent/skills` |

## One-line summary

`skills` does not know fxdart. fxdart packs its files under the standard `skills/*/SKILL.md` convention and publishes them to pub.dev, so the generic `skills` CLI can install them by simply "fetch from pub (local cache) and copy the `skills/` folder." It is a combination of pub.dev + a folder convention; **git is only a fallback for packages that do not ship their own skill.**
