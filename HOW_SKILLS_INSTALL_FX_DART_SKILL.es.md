# Cómo el CLI `skills` instala la skill de fxdart

**Idioma:** [English](HOW_SKILLS_INSTALL_FX_DART_SKILL.md) · [한국어](HOW_SKILLS_INSTALL_FX_DART_SKILL.ko.md) · [简体中文](HOW_SKILLS_INSTALL_FX_DART_SKILL.zh-Hans.md) · [日本語](HOW_SKILLS_INSTALL_FX_DART_SKILL.ja.md) · **Español** · [Português](HOW_SKILLS_INSTALL_FX_DART_SKILL.pt-BR.md) · [Русский](HOW_SKILLS_INSTALL_FX_DART_SKILL.ru.md)

---

```sh
dart pub global activate skills
skills get fxdart
```

Una duda habitual: `skills` es un paquete de terceros, entonces **¿cómo sabe de fxdart y lo instala?**

## El CLI `skills` no "conoce" fxdart — fxdart sigue una convención

`skills` es un instalador de skills **genérico**. No tiene código específico de fxdart. `skills get fxdart` significa, en la práctica:

> "Toma el paquete llamado `fxdart`, busca dentro un directorio `skills/` y cópialo en el directorio de skills de mi agente."

Eso es todo. `fxdart` es simplemente un **nombre de paquete publicado en pub.dev**, y funciona porque fxdart incluye archivos que siguen la convención de [Agent Skills](https://agentskills.io):

```
skills/
└── fxdart-pipelines/
    ├── SKILL.md               ← convención: <nombre-skill>/SKILL.md
    └── references/api-reference.md
```

Como el diseño es una convención, `skills get <nombre>` funciona con **cualquier** paquete que empaquete un directorio `skills/` — no solo fxdart.

## ¿Descarga por git o extracción desde pub.dev?

Ninguna de las dos es una descarga nueva de fxdart hecha por el propio `skills`. El CLI resuelve por orden de prioridad:

### Prioridad 1 (ruta principal): extraer del árbol de dependencias local — el origen es pub.dev

`skills` lee primero **`package_config.json`** (`.dart_tool/package_config.json`) para ubicar los paquetes que pub ya ha desempaquetado localmente. El flujo real es:

1. `dart pub get` / `pub global activate` descarga el tarball de fxdart **desde pub.dev** y lo desempaqueta en la caché local de pub (`~/.pub-cache/`).
2. `skills get fxdart` resuelve ese directorio de fxdart ya desempaquetado mediante `package_config.json`.
3. Copia el directorio `skills/` incluido.

**→ El propio `skills` no accede a la red por fxdart.** Reutiliza lo que pub ya obtuvo de pub.dev. Es el mismo principio que usa el instalador propio de fxdart, que emplea `Isolate.resolvePackageUri` para hallar el paquete en disco.

### Prioridad 2 (respaldo): clonar un registro de GitHub — el único punto donde se usa git

Si el paquete no está en el árbol de dependencias (o no incluye `skills/`) y git está instalado, `skills` clona/actualiza **repositorios de registro** curados en GitHub:

- `flutter/skills`
- `serverpod/skills-registry`

Estos registros mapean "nombre de paquete → skills para ese paquete" y se clonan bajo `.dart_skills/repos/`. **Este es el único paso donde interviene `git`.**

**Regla de precedencia:** para el mismo paquete, una skill del árbol de dependencias local siempre gana frente a una del registro.

### Resumen

| Ruta | Origen | Mecanismo |
|------|--------|-----------|
| Prioridad 1 | Caché local de pub (origen: **pub.dev**) | Sin red — resolver vía `package_config.json` y copiar la carpeta |
| Prioridad 2 | Repositorio de registro en GitHub | **git clone / pull** |

Así que, respondiendo a la pregunta:

- fxdart incluye `skills/` directamente y lo publica en pub.dev, por lo que se instala por la **ruta de pub.dev (Prioridad 1)** — **git no interviene**.
- **git clone** es solo el respaldo que se usa cuando un paquete no trae su propia skill y hay que buscarla en un registro curado.

## fxdart también incluye su propio instalador sin dependencias

fxdart no requiere el CLI `skills` en absoluto. Incluye un instalador sin dependencias (`bin/install_skills.dart`) que hace exactamente la misma operación de copia en local:

```sh
# Desde un proyecto que depende de fxdart:
dart run fxdart:install_skills              # detecta directorios de agentes en el proyecto
dart run fxdart:install_skills claude codex # o nombra los agentes explícitamente
dart run fxdart:install_skills all --global # directorios por usuario (~/.claude/skills, ...)

# O de forma independiente:
dart pub global activate fxdart
fxdart_skills --global claude
```

Internamente, `_skillsSource()` resuelve la ubicación de `package:fxdart`, encuentra el directorio `skills/` contiguo, detecta el agente mediante marcadores (`.claude`, `.codex`, `.agents`, ...) y copia el árbol. Ya uses el CLI `skills` o el instalador integrado de fxdart, la esencia es idéntica: **copiar el directorio `skills/` incluido en el paquete.**

## Referencia de comandos / opciones

### CLI comunitario `skills`

```sh
dart pub global activate skills
skills get fxdart
```

### Instalador integrado de fxdart

| Comando | Efecto |
|---------|--------|
| `dart run fxdart:install_skills` | Detecta los directorios de agentes del proyecto e instala |
| `dart run fxdart:install_skills claude codex` | Instala para los agentes indicados |
| `dart run fxdart:install_skills all --global` | Instala en directorios por usuario (`~/.claude/skills`, ...) |
| `fxdart_skills --global claude` | Independiente (tras `pub global activate fxdart`) |
| `... --list` | Muestra ubicaciones y estado de instalación, sin cambiar nada |
| `... --remove` | Elimina las skills de fxdart de los destinos seleccionados |
| `... --help` | Muestra la ayuda |

### Agentes compatibles y sus directorios de skills

| Agente | Directorio del proyecto | Directorio global |
|--------|-------------------------|-------------------|
| `claude` | `.claude/skills` | `~/.claude/skills` |
| `codex` | `.agents/skills` | `~/.agents/skills` |
| `antigravity` | `.agents/skills` | `~/.agents/skills` |
| `generic` | `.agents/skills` | `~/.agents/skills` |
| `devin` | `.devin/skills` | `~/.config/devin/skills` |
| `opencode` | `.opencode/skills` | `~/.config/opencode/skills` |
| `pi` | `.pi/skills` | `~/.pi/agent/skills` |

## Resumen en una línea

`skills` no conoce fxdart. fxdart empaqueta sus archivos bajo la convención estándar `skills/*/SKILL.md` y los publica en pub.dev, de modo que el CLI genérico `skills` puede instalarlos con solo "obtener de pub (caché local) y copiar la carpeta `skills/`". Es una combinación de pub.dev + una convención de carpetas; **git es solo un respaldo para paquetes que no traen su propia skill.**
