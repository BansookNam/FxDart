# Deploying the FxDart site

The site is served by GitHub Pages straight off the default branch — there is
no build artifact branch. Deploying is building the playground bundle,
regenerating `docs/`, and pushing.

`docs/` is **generated output — never edit it by hand.** The sources are:

| Path | What it is |
| --- | --- |
| `content/` | English source of truth: prose, front matter, course structure |
| `content/code/` | Playground code and type signatures — shared by every locale |
| `i18n/<locale>/` | Translations; anything absent falls back to English |
| `tool/build_docs.dart` | The generator that renders the above into `docs/` |

The site builds in 7 languages (English at the root, plus `ko`, `zh-Hans`,
`ja`, `es`, `pt-BR`, `ru` under their own prefixes). See
[`i18n/README.md`](i18n/README.md) for the translation workflow.

## One command

```bash
./deploy.sh
```

| Command | What it does |
| --- | --- |
| `./deploy.sh` | Build, commit as `docs: update GitHub Pages site`, push |
| `./deploy.sh "tweak 101 intro"` | Same, with your commit message |
| `./deploy.sh -n` | Dry run — build and print the diffstat, no commit |
| `./deploy.sh -s "msg"` | Skip the build; just commit and push |

Pages takes roughly a minute to rebuild after the push:
<https://bansooknam.github.io/FxDart/>

## What the script does

1. Runs `tools/build_single_file.sh`, which regenerates
   `docs/assets/fxdart_single.dart` — a single-file concatenation of `lib/src/`
   that the browser playground prepends to user code before sending it to the
   DartPad compile service — and analyzes it.
2. Runs `dart analyze lib`.
3. Runs `dart run tool/build_docs.dart`, regenerating every page in every
   locale from `content/` and `i18n/`. (With `-s`, it instead runs
   `--check`, which fails if `docs/` has drifted from its sources — so a
   skip-build deploy can never ship stale HTML.)
4. Checks that the required page resources exist (`docs/index.html`,
   `docs/101/index.html`, `docs/css/site.css`, `docs/js/playground.js`,
   `docs/assets/fxdart_single.dart`).
5. Prints per-locale translation coverage.
6. Stages `docs/`, `content/`, `i18n/`, `tool/`, `tools/`, `deploy.sh`, and
   `DEPLOY.md` — and nothing else — then commits and pushes to
   `origin/<current branch>`. Output and its sources ship together; committing
   one without the other would make the next `--check` fail.

Staging is by path on purpose: a docs deploy will **not** pick up in-progress
changes in `lib/` or `test/`. If a library change belongs in the same push,
commit it yourself first, then run `./deploy.sh`.

If the build produces no changes, the script stops with
`nothing to deploy` and exits 0.

## Notes

- **Never hand-edit anything under `docs/`.** It is all generated — the HTML
  from `content/` + `i18n/`, and `fxdart_single.dart` from `lib/src/`. The two
  exceptions are the static assets `docs/css/site.css` and
  `docs/js/playground.js`, which are edited directly.
- The untracked `example/_snip_*.dart` files are scratch snippets from writing
  the tutorials. The script stages by path rather than using `git add -A`, so
  they are deliberately left out of deploy commits.
- Pages must be configured to serve `/docs` from the default branch
  (Settings → Pages → Source: *Deploy from a branch*, `main` + `/docs`).

## Adding a tutorial page

1. Write `content/tutorials/<name>.md` — copy an existing one for the front
   matter. Front matter carries `slug`, `title`, `description`, `heading`,
   `section`, `crumb`, and the `prev`/`next` links; the body is prose with
   `{{signature}}` and `{{playground:N}}` placeholders where code goes.
2. Put the code in `content/code/<name>/` — `sig.txt` for the type signature,
   `0.dart`, `1.dart`, … for the playgrounds. These are shared by every
   locale, so a snippet is written and fixed exactly once.
3. Add it to the right section list in `content/course.json` so it appears in
   the 101 index.
4. Run `./deploy.sh -n` to confirm, then `./deploy.sh "docs: add <name> tutorial"`.

The header, breadcrumb, footer, language switcher, `hreflang` tags, and
`sitemap.xml` are all generated — there is no boilerplate to copy.

## Translating

See [`i18n/README.md`](i18n/README.md). In short:

```bash
cp content/tutorials/map.md i18n/ko/tutorials/map.md   # then translate it
dart run tool/build_docs.dart --status                 # coverage per locale
dart run tool/build_docs.dart --record                 # after a translation pass
```

Untranslated pages fall back to English automatically, with a banner and a
`rel="canonical"` pointing at the English original.
