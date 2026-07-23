# Как CLI `skills` устанавливает скилл fxdart

**Язык:** [English](HOW_SKILLS_INSTALL_FX_DART_SKILL.md) · [한국어](HOW_SKILLS_INSTALL_FX_DART_SKILL.ko.md) · [简体中文](HOW_SKILLS_INSTALL_FX_DART_SKILL.zh-Hans.md) · [日本語](HOW_SKILLS_INSTALL_FX_DART_SKILL.ja.md) · [Español](HOW_SKILLS_INSTALL_FX_DART_SKILL.es.md) · [Português](HOW_SKILLS_INSTALL_FX_DART_SKILL.pt-BR.md) · **Русский**

---

```sh
dart pub global activate skills
skills get fxdart
```

Частый вопрос: `skills` — это сторонний пакет, так **откуда он знает про fxdart и как его устанавливает?**

## CLI `skills` не «знает» про fxdart — это fxdart следует соглашению

`skills` — это **универсальный** установщик скиллов. В нём нет никакого кода, специфичного для fxdart. `skills get fxdart` по сути означает:

> «Возьми пакет с именем `fxdart`, найди внутри него каталог `skills/` и скопируй его в каталог скиллов моего агента.»

Вот и всё. `fxdart` — это просто **имя пакета, опубликованного на pub.dev**, и это работает потому, что fxdart поставляет файлы, следующие соглашению [Agent Skills](https://agentskills.io):

```
skills/
└── fxdart-pipelines/
    ├── SKILL.md               ← соглашение: <имя-скилла>/SKILL.md
    └── references/api-reference.md
```

Поскольку такая структура — это соглашение, `skills get <имя>` работает с **любым** пакетом, который включает каталог `skills/`, а не только с fxdart.

## Загрузка через git или извлечение из pub.dev?

Ни то, ни другое не является новой загрузкой fxdart самим `skills`. CLI разрешает пакет по порядку приоритета:

### Приоритет 1 (основной путь): извлечение из локального дерева зависимостей — источник pub.dev

Сначала `skills` читает **`package_config.json`** (`.dart_tool/package_config.json`), чтобы найти пакеты, которые pub уже распаковал локально. Реальный процесс таков:

1. `dart pub get` / `pub global activate` скачивает tarball fxdart **с pub.dev** и распаковывает его в локальный кеш pub (`~/.pub-cache/`).
2. `skills get fxdart` находит этот уже распакованный каталог fxdart через `package_config.json`.
3. Копирует включённый каталог `skills/`.

**→ Сам `skills` не обращается к сети ради fxdart.** Он переиспользует то, что pub уже получил с pub.dev. Это тот же принцип, что и в собственном установщике fxdart, использующем `Isolate.resolvePackageUri` для поиска пакета на диске.

### Приоритет 2 (запасной путь): клонирование реестра на GitHub — единственное место, где используется git

Если пакета нет в дереве зависимостей (или он не включает `skills/`), а git установлен, `skills` клонирует/обновляет курируемые **репозитории-реестры** на GitHub:

- `flutter/skills`
- `serverpod/skills-registry`

Эти реестры сопоставляют «имя пакета → скиллы для этого пакета» и клонируются в `.dart_skills/repos/`. **Это единственный шаг, где задействован `git`.**

**Правило приоритета:** для одного и того же пакета скилл из локального дерева зависимостей всегда важнее скилла из реестра.

### Итог

| Путь | Источник | Механизм |
|------|----------|----------|
| Приоритет 1 | Локальный кеш pub (источник: **pub.dev**) | Без сети — разрешение через `package_config.json` и копирование папки |
| Приоритет 2 | Репозиторий-реестр на GitHub | **git clone / pull** |

Итак, отвечая на вопрос:

- fxdart включает `skills/` напрямую и публикует его на pub.dev, поэтому устанавливается по **пути pub.dev (Приоритет 1)** — **git не задействован**.
- **git clone** — это лишь запасной вариант, применяемый, когда пакет не поставляет собственный скилл и его нужно искать в курируемом реестре.

## У fxdart также есть собственный установщик без зависимостей

fxdart вообще не требует CLI `skills`. Он включает установщик без зависимостей (`bin/install_skills.dart`), который выполняет ровно ту же операцию копирования локально:

```sh
# Из проекта, зависящего от fxdart:
dart run fxdart:install_skills              # автоопределение каталогов агентов в проекте
dart run fxdart:install_skills claude codex # или явно укажите агентов
dart run fxdart:install_skills all --global # каталоги пользователя (~/.claude/skills, ...)

# Или отдельно:
dart pub global activate fxdart
fxdart_skills --global claude
```

Внутри `_skillsSource()` разрешает расположение `package:fxdart`, находит соседний каталог `skills/`, определяет агента по маркерам (`.claude`, `.codex`, `.agents`, ...) и копирует дерево. Используете ли вы CLI `skills` или встроенный установщик fxdart, суть одинакова: **скопировать каталог `skills/`, включённый в пакет.**

## Справочник команд / опций

### Сообщественный CLI `skills`

```sh
dart pub global activate skills
skills get fxdart
```

### Встроенный установщик fxdart

| Команда | Действие |
|---------|----------|
| `dart run fxdart:install_skills` | Автоопределение каталогов агентов в проекте и установка |
| `dart run fxdart:install_skills claude codex` | Установка для указанных агентов |
| `dart run fxdart:install_skills all --global` | Установка в пользовательские каталоги (`~/.claude/skills`, ...) |
| `fxdart_skills --global claude` | Отдельный запуск (после `pub global activate fxdart`) |
| `... --list` | Показать места и статус установки, ничего не меняя |
| `... --remove` | Удалить скиллы fxdart из выбранных целей |
| `... --help` | Показать справку |

### Поддерживаемые агенты и их каталоги скиллов

| Агент | Каталог проекта | Глобальный каталог |
|-------|-----------------|--------------------|
| `claude` | `.claude/skills` | `~/.claude/skills` |
| `codex` | `.agents/skills` | `~/.agents/skills` |
| `antigravity` | `.agents/skills` | `~/.agents/skills` |
| `generic` | `.agents/skills` | `~/.agents/skills` |
| `devin` | `.devin/skills` | `~/.config/devin/skills` |
| `opencode` | `.opencode/skills` | `~/.config/opencode/skills` |
| `pi` | `.pi/skills` | `~/.pi/agent/skills` |

## Итог одной строкой

`skills` не знает про fxdart. Это fxdart упаковывает свои файлы по стандартному соглашению `skills/*/SKILL.md` и публикует их на pub.dev, так что универсальный CLI `skills` может установить их, просто «получив из pub (локального кеша) и скопировав папку `skills/`». Это сочетание pub.dev + соглашения о папках; **git — лишь запасной вариант для пакетов, не поставляющих собственный скилл.**
