# `skills` CLI가 fxdart 스킬을 설치하는 원리

**언어:** [English](HOW_SKILLS_INSTALL_FX_DART_SKILL.md) · **한국어** · [简体中文](HOW_SKILLS_INSTALL_FX_DART_SKILL.zh-Hans.md) · [日本語](HOW_SKILLS_INSTALL_FX_DART_SKILL.ja.md) · [Español](HOW_SKILLS_INSTALL_FX_DART_SKILL.es.md) · [Português](HOW_SKILLS_INSTALL_FX_DART_SKILL.pt-BR.md) · [Русский](HOW_SKILLS_INSTALL_FX_DART_SKILL.ru.md)

---

```sh
dart pub global activate skills
skills get fxdart
```

흔한 의문: `skills`는 외부(서드파티) 패키지인데 **어떻게 fxdart를 알고 설치하는가?**

## `skills` CLI는 fxdart를 "아는" 게 아니라 — fxdart가 규약을 따른다

`skills`는 **범용** 스킬 인스톨러입니다. fxdart 전용 코드가 하나도 없어요. `skills get fxdart`가 하는 일은 사실상:

> "`fxdart`라는 패키지를 가져와서, 그 안의 `skills/` 폴더를 찾아 내 에이전트 스킬 디렉토리로 복사해줘."

이게 전부입니다. `fxdart`는 그냥 **pub.dev에 published된 패키지 이름**일 뿐이고, fxdart가 [Agent Skills](https://agentskills.io) 규약을 따르는 파일들을 담아 배포했기 때문에 동작합니다:

```
skills/
└── fxdart-pipelines/
    ├── SKILL.md               ← 규약: <스킬이름>/SKILL.md
    └── references/api-reference.md
```

이 레이아웃이 규약이므로, `skills get <이름>`은 `skills/` 폴더를 번들한 **어떤 패키지든** 동작합니다 — fxdart만의 이야기가 아니에요.

## git으로 다운로드? pub.dev에서 추출?

둘 다 "`skills`가 fxdart를 새로 다운로드하는 것"은 아닙니다. CLI는 우선순위 순으로 resolve합니다.

### 1순위 (주 경로): 로컬 의존성 트리에서 추출 — 원천은 pub.dev

`skills`는 먼저 **`package_config.json`**(`.dart_tool/package_config.json`)을 읽어 pub이 이미 로컬에 풀어둔 패키지 위치를 찾습니다. 실제 흐름은:

1. `dart pub get` / `pub global activate`가 **pub.dev에서** fxdart tarball을 받아 로컬 pub 캐시(`~/.pub-cache/`)에 풂.
2. `skills get fxdart`가 그 이미 풀린 fxdart 디렉토리를 `package_config.json`으로 resolve.
3. 번들된 `skills/` 폴더를 복사.

**→ `skills` 자체는 fxdart를 받으려고 네트워크를 쓰지 않습니다.** pub이 이미 pub.dev에서 받아둔 걸 재사용합니다. 이는 fxdart 자체 인스톨러가 `Isolate.resolvePackageUri`로 디스크 상의 패키지를 찾는 것과 같은 원리입니다.

### 2순위 (fallback): GitHub 레지스트리 clone — git이 쓰이는 유일한 지점

패키지가 의존성 트리에 없거나(혹은 `skills/`를 번들하지 않았고) git이 설치돼 있으면, `skills`는 GitHub의 큐레이션 **레지스트리 저장소**를 clone/update합니다:

- `flutter/skills`
- `serverpod/skills-registry`

이 레지스트리는 "패키지 이름 → 그 패키지용 스킬"을 매핑하며 `.dart_skills/repos/` 아래에 clone됩니다. **git이 관여하는 것은 이 단계뿐입니다.**

**우선순위 규칙:** 같은 패키지라면 로컬 의존성 트리의 스킬이 항상 레지스트리 스킬보다 우선합니다.

### 요약

| 경로 | 소스 | 방식 |
|------|------|------|
| 1순위 | 로컬 pub 캐시 (원천: **pub.dev**) | 네트워크 없음 — `package_config.json`으로 resolve 후 폴더 복사 |
| 2순위 | GitHub 레지스트리 repo | **git clone / pull** |

따라서 질문에 답하면:

- fxdart는 `skills/`를 직접 번들해 pub.dev에 올렸으므로 **pub.dev 경로(1순위)** 로 설치됩니다 — **git은 관여하지 않음**.
- **git clone**은 패키지가 자체 스킬을 담지 않아 큐레이션 레지스트리에서 찾아야 할 때만 쓰이는 fallback입니다.

## fxdart는 자체 zero-dependency 인스톨러도 제공한다

fxdart는 `skills` CLI가 전혀 필요 없습니다. 동일한 복사 작업을 로컬에서 수행하는 zero-dependency 인스톨러(`bin/install_skills.dart`)를 함께 배포합니다:

```sh
# fxdart에 의존하는 프로젝트에서:
dart run fxdart:install_skills              # 프로젝트 내 에이전트 디렉토리 자동 감지
dart run fxdart:install_skills claude codex # 또는 에이전트를 명시
dart run fxdart:install_skills all --global # 유저 디렉토리 (~/.claude/skills, ...)

# 또는 단독으로:
dart pub global activate fxdart
fxdart_skills --global claude
```

내부적으로 `_skillsSource()`가 `package:fxdart` 위치를 resolve하고, 옆의 `skills/` 디렉토리를 찾아, 마커(`.claude`, `.codex`, `.agents`, ...)로 에이전트를 감지한 뒤 트리를 복사합니다. `skills` CLI를 쓰든 fxdart 내장 인스톨러를 쓰든, 본질은 동일합니다: **패키지에 번들된 `skills/` 디렉토리를 복사한다.**

## 명령 / 옵션 레퍼런스

### 커뮤니티 `skills` CLI

```sh
dart pub global activate skills
skills get fxdart
```

### fxdart 내장 인스톨러

| 명령 | 효과 |
|------|------|
| `dart run fxdart:install_skills` | 프로젝트 내 에이전트 디렉토리 자동 감지 후 설치 |
| `dart run fxdart:install_skills claude codex` | 지정한 에이전트에 설치 |
| `dart run fxdart:install_skills all --global` | 유저 디렉토리(`~/.claude/skills`, ...)에 설치 |
| `fxdart_skills --global claude` | 단독 실행 (`pub global activate fxdart` 이후) |
| `... --list` | 설치 위치와 상태만 표시, 변경 없음 |
| `... --remove` | 선택한 대상에서 fxdart 스킬 제거 |
| `... --help` | 도움말 표시 |

### 지원 에이전트와 스킬 디렉토리

| 에이전트 | 프로젝트 디렉토리 | 글로벌 디렉토리 |
|----------|-------------------|-----------------|
| `claude` | `.claude/skills` | `~/.claude/skills` |
| `codex` | `.agents/skills` | `~/.agents/skills` |
| `antigravity` | `.agents/skills` | `~/.agents/skills` |
| `generic` | `.agents/skills` | `~/.agents/skills` |
| `devin` | `.devin/skills` | `~/.config/devin/skills` |
| `opencode` | `.opencode/skills` | `~/.config/opencode/skills` |
| `pi` | `.pi/skills` | `~/.pi/agent/skills` |

## 한 줄 요약

`skills`는 fxdart를 알지 못합니다. fxdart가 표준 `skills/*/SKILL.md` 규약대로 파일을 담아 pub.dev에 올렸기 때문에, 범용 `skills` CLI가 "pub(로컬 캐시)에서 받아 `skills/` 폴더 복사"만으로 설치할 수 있는 것입니다. pub.dev + 폴더 컨벤션의 조합이며, **git은 자체 스킬을 담지 않은 패키지를 위한 fallback일 뿐입니다.**
