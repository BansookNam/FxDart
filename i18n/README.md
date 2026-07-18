# Translating the FxDart docs

The docs site is generated. `docs/` is **build output** — never edit it by hand.
Everything you translate lives here in `i18n/`, and English lives in `content/`.

```
content/                     English source of truth
  chrome.arb                   UI strings (nav, buttons, footer, banners)
  sections.json                the 12 course section titles + blurbs
  course.json                  section → function list (structure, not prose)
  locales.json                 which languages the site builds
  pages/index.md               landing page
  pages/101.md                 course intro
  tutorials/<fn>.md            one per function
  code/<fn>/*.dart             playground code — SHARED, never translated
  code/<fn>/sig.txt            type signature — SHARED, never translated

i18n/<locale>/               your translations, mirroring content/
  chrome.arb
  sections.json
  pages/index.md
  pages/101.md
  tutorials/<fn>.md
  sources.json                 generated — don't hand-edit
```

## Currently built

| Locale    | Language             | URL prefix |
| --------- | -------------------- | ---------- |
| `en`      | English (source)     | *(root)*   |
| `ko`      | 한국어                | `/ko/`     |
| `zh-Hans` | 简体中文              | `/zh/`     |
| `ja`      | 日本語                | `/ja/`     |
| `es`      | Español              | `/es/`     |
| `pt-BR`   | Português (Brasil)   | `/pt-br/`  |
| `ru`      | Русский              | `/ru/`     |

## How to translate a page

Copy the English file to the same path under your locale and translate the
prose in place:

```bash
cp content/tutorials/map.md i18n/ko/tutorials/map.md
$EDITOR i18n/ko/tutorials/map.md

dart run tool/build_docs.dart          # regenerate docs/
dart run tool/build_docs.dart --record # mark it current as of today's English
```

To see your work in a browser, `./run.sh` builds the site and serves it with a
URL printed for every locale.

**You do not have to translate everything.** Any file you don't provide falls
back to English automatically, with a banner telling the reader so and a
`rel="canonical"` pointing at the English page (so the untranslated copy never
competes with the original in search results). Partial translations are useful —
start with `pages/index.md` and `pages/101.md`, which get the most traffic.

Check where things stand at any time:

```bash
dart run tool/build_docs.dart --status
```

## Rules

1. **Never translate code.** Anything in `<code>`, in a `{{playground:N}}`
   block, or in `{{signature}}` is Dart. Function and type names (`map`,
   `filter`, `concurrent`, `Iterable`, `FxAsyncIterable`) stay in English in
   prose too — readers type them.
2. **Keep every `{{…}}` placeholder** exactly as it appears, in the same order.
   The build fails if a placeholder is dropped or renumbered, because that would
   silently delete a code sample. `{{root}}` is the site root — shared assets
   live once at `docs/assets/`, not per locale, so `{{root}}assets/logo-web.png`
   is the only way to reference one that resolves from every language.
3. **Keep the HTML structure identical** — same tags, nesting, `class`, `href`,
   and `id` values. Translate text nodes only.
4. **Keep the front matter fences and the `slug:` value.** Translate `title:`
   and `description:` — they're the browser tab title and the search snippet, so
   make them idiomatic rather than literal.
5. **In `chrome.arb`**, keep `"@@locale"` first and translate only the string
   values. Don't copy the `@key` metadata blocks from the English file — those
   are translator notes, and they explain what each string does. Read them.
   Watch the trailing spaces in `prevPrefix`/`nextPrefix`: a function name is
   concatenated directly after them.
6. **Leave URLs alone**, including `contributeUrl`.

## Adding a new language

1. Add an entry to `content/locales.json` (`code` is a BCP 47 tag used for
   `hreflang` and `<html lang>`; `name` is the endonym shown in the switcher;
   `path` is the URL prefix; set `dir` to `rtl` for right-to-left scripts).
2. Create `i18n/<code>/` and translate at least `chrome.arb`.
3. Run the build.

An RTL locale will need a CSS pass — the stylesheet uses logical properties
(`margin-inline-start`) in the places that matter, but nothing has been tested
against an RTL language yet.

## Staleness

`sources.json` records the hash of the English file each translation was made
from. When the English page later changes, that translation is flagged as
outdated — a banner appears on the page and `--status` counts it — but the
translation is still shown, since a slightly dated translation beats no
translation. After refreshing it, run `--record` again.
