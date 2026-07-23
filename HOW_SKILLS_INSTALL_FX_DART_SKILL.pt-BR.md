# Como o CLI `skills` instala a skill do fxdart

**Idioma:** [English](HOW_SKILLS_INSTALL_FX_DART_SKILL.md) · [한국어](HOW_SKILLS_INSTALL_FX_DART_SKILL.ko.md) · [简体中文](HOW_SKILLS_INSTALL_FX_DART_SKILL.zh-Hans.md) · [日本語](HOW_SKILLS_INSTALL_FX_DART_SKILL.ja.md) · [Español](HOW_SKILLS_INSTALL_FX_DART_SKILL.es.md) · **Português** · [Русский](HOW_SKILLS_INSTALL_FX_DART_SKILL.ru.md)

---

```sh
dart pub global activate skills
skills get fxdart
```

Uma dúvida comum: `skills` é um pacote de terceiros, então **como ele sabe do fxdart e o instala?**

## O CLI `skills` não "conhece" o fxdart — o fxdart segue uma convenção

`skills` é um instalador de skills **genérico**. Ele não tem código específico do fxdart. `skills get fxdart` significa, na prática:

> "Pegue o pacote chamado `fxdart`, procure dentro dele um diretório `skills/` e copie-o para o diretório de skills do meu agente."

É só isso. `fxdart` é apenas um **nome de pacote publicado no pub.dev**, e funciona porque o fxdart inclui arquivos que seguem a convenção do [Agent Skills](https://agentskills.io):

```
skills/
└── fxdart-pipelines/
    ├── SKILL.md               ← convenção: <nome-da-skill>/SKILL.md
    └── references/api-reference.md
```

Como o layout é uma convenção, `skills get <nome>` funciona com **qualquer** pacote que empacote um diretório `skills/` — não apenas o fxdart.

## Download via git ou extração do pub.dev?

Nenhum dos dois é um novo download do fxdart feito pelo próprio `skills`. O CLI resolve por ordem de prioridade:

### Prioridade 1 (caminho principal): extrair da árvore de dependências local — a origem é o pub.dev

O `skills` primeiro lê o **`package_config.json`** (`.dart_tool/package_config.json`) para localizar os pacotes que o pub já desempacotou localmente. O fluxo real é:

1. `dart pub get` / `pub global activate` baixa o tarball do fxdart **do pub.dev** e o desempacota no cache local do pub (`~/.pub-cache/`).
2. `skills get fxdart` resolve esse diretório do fxdart já desempacotado via `package_config.json`.
3. Copia o diretório `skills/` incluído.

**→ O próprio `skills` não acessa a rede por causa do fxdart.** Ele reutiliza o que o pub já obteve do pub.dev. Esse é o mesmo princípio do instalador próprio do fxdart, que usa `Isolate.resolvePackageUri` para localizar o pacote no disco.

### Prioridade 2 (fallback): clonar um registro do GitHub — o único ponto em que o git é usado

Se o pacote não estiver na árvore de dependências (ou não empacotar `skills/`) e o git estiver instalado, o `skills` clona/atualiza **repositórios de registro** curados no GitHub:

- `flutter/skills`
- `serverpod/skills-registry`

Esses registros mapeiam "nome do pacote → skills daquele pacote" e são clonados sob `.dart_skills/repos/`. **Esta é a única etapa em que o `git` participa.**

**Regra de precedência:** para o mesmo pacote, uma skill da árvore de dependências local sempre vence uma skill do registro.

### Resumo

| Caminho | Origem | Mecanismo |
|---------|--------|-----------|
| Prioridade 1 | Cache local do pub (origem: **pub.dev**) | Sem rede — resolver via `package_config.json` e copiar a pasta |
| Prioridade 2 | Repositório de registro no GitHub | **git clone / pull** |

Então, respondendo à pergunta:

- o fxdart empacota `skills/` diretamente e o publica no pub.dev, portanto ele é instalado pelo **caminho do pub.dev (Prioridade 1)** — **o git não participa**.
- **git clone** é apenas o fallback usado quando um pacote não traz sua própria skill e precisa ser encontrado em um registro curado.

## O fxdart também traz seu próprio instalador sem dependências

O fxdart não exige o CLI `skills` de forma alguma. Ele inclui um instalador sem dependências (`bin/install_skills.dart`) que faz exatamente a mesma operação de cópia localmente:

```sh
# A partir de um projeto que depende do fxdart:
dart run fxdart:install_skills              # detecta os diretórios de agentes no projeto
dart run fxdart:install_skills claude codex # ou nomeie os agentes explicitamente
dart run fxdart:install_skills all --global # diretórios por usuário (~/.claude/skills, ...)

# Ou de forma independente:
dart pub global activate fxdart
fxdart_skills --global claude
```

Internamente, `_skillsSource()` resolve a localização de `package:fxdart`, encontra o diretório `skills/` vizinho, detecta o agente por marcadores (`.claude`, `.codex`, `.agents`, ...) e copia a árvore. Quer você use o CLI `skills` ou o instalador embutido do fxdart, a essência é idêntica: **copiar o diretório `skills/` incluído no pacote.**

## Referência de comandos / opções

### CLI comunitário `skills`

```sh
dart pub global activate skills
skills get fxdart
```

### Instalador embutido do fxdart

| Comando | Efeito |
|---------|--------|
| `dart run fxdart:install_skills` | Detecta os diretórios de agentes do projeto e instala |
| `dart run fxdart:install_skills claude codex` | Instala para os agentes indicados |
| `dart run fxdart:install_skills all --global` | Instala em diretórios por usuário (`~/.claude/skills`, ...) |
| `fxdart_skills --global claude` | Independente (após `pub global activate fxdart`) |
| `... --list` | Mostra locais e status de instalação, sem alterar nada |
| `... --remove` | Remove as skills do fxdart dos destinos selecionados |
| `... --help` | Mostra a ajuda |

### Agentes suportados e seus diretórios de skills

| Agente | Diretório do projeto | Diretório global |
|--------|----------------------|------------------|
| `claude` | `.claude/skills` | `~/.claude/skills` |
| `codex` | `.agents/skills` | `~/.agents/skills` |
| `antigravity` | `.agents/skills` | `~/.agents/skills` |
| `generic` | `.agents/skills` | `~/.agents/skills` |
| `devin` | `.devin/skills` | `~/.config/devin/skills` |
| `opencode` | `.opencode/skills` | `~/.config/opencode/skills` |
| `pi` | `.pi/skills` | `~/.pi/agent/skills` |

## Resumo em uma linha

O `skills` não conhece o fxdart. É o fxdart que empacota seus arquivos segundo a convenção padrão `skills/*/SKILL.md` e os publica no pub.dev, de modo que o CLI genérico `skills` consegue instalá-los apenas "obtendo do pub (cache local) e copiando a pasta `skills/`". É uma combinação de pub.dev + uma convenção de pastas; **o git é apenas um fallback para pacotes que não trazem sua própria skill.**
