# Deploying the FxDart site

The site is served by GitHub Pages straight off the default branch — there is
no build artifact branch. Deploying is building the playground bundle,
precompiling the playgrounds, regenerating `docs/`, and pushing.

Most of `docs/` is **generated output — never edit it by hand.** The sources are:

| Path | What it is |
| --- | --- |
| `content/` | English source of truth: prose, front matter, course structure |
| `content/code/` | Playground code and type signatures — shared by every locale |
| `i18n/<locale>/` | Translations; anything absent falls back to English |
| `tool/build_docs.dart` | The generator that renders the above into `docs/` |
| `tools/build_single_file.sh` | Concatenates `lib/src/` into `docs/assets/fxdart_single.dart` |
| `tool/precompile_playgrounds.dart` | Compiles playground snippets into `docs/pg/*.js.gz` |

`docs/` is now **entirely generated**; nothing in it is edited by hand. The
hand-written half of the site lives in `web/` — `web/css/*.css`, `web/js/*.js`,
`web/frame.html`, `web/assets/logo*.png` and `web/DailyLedger/` — and
`build_docs.dart` copies that tree verbatim into `docs/`, so `web/css/site.css`
is served as `docs/css/site.css`.

`docs/` is **not tracked** — it is in `.gitignore`. The site is built and
published by `.github/workflows/pages.yml` on a push to `main`, and nothing
generated is committed back. `./deploy.sh` builds the identical output locally
so it can be inspected, and `./run.sh -s` serves that build; neither commits.
To publish without a source change, run `gh workflow run pages.yml`.

The site builds in 7 languages (English at the root, plus `ko`, `zh-Hans`,
`ja`, `es`, `pt-BR`, `ru` under their own prefixes). See
[`i18n/README.md`](i18n/README.md) for the translation workflow.

## Previewing locally

```bash
./run.sh              # build, serve, print a URL per locale
./run.sh -o           # ...and open the browser
./run.sh -p 4000      # pick a port (auto-advances if busy)
./run.sh -s           # skip the build, serve what's already in docs/
```

Links are relative throughout, so the local preview behaves exactly like the
deployed site — including the language switcher.

## Deploying

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

### `PG_SCOPE` — how many playgrounds to precompile

Precompiled snippets let an unedited Run skip the DartPad compile service
entirely (~2.5s → under 100ms). The artifacts are committed, so the choice is a
trade between how many playgrounds are instant and how much the repo carries.

```bash
PG_SCOPE=first ./deploy.sh    # default — first demo per tutorial + both comparison panels
PG_SCOPE=all ./deploy.sh      # every playground on the site
PG_SCOPE=none ./deploy.sh     # precompile nothing new; keep what is already built
```

| Scope | Artifacts | Size | Notes |
| --- | --- | --- | --- |
| `first` | 224 | ~12 MB | The block a reader is most likely to click first |
| `all` | 476 | ~28 MB | Every playground instant on the first click |
| `none` | — | — | Existing artifacts are kept and still used |

Anything not precompiled still works — it compiles over the network on first
Run, then stays in the reader's browser cache.

Rebuilding `docs/assets/fxdart_single.dart` changes the id of every snippet
that imports fxdart, so a library change rewrites ~90% of the artifacts and
adds that much to git history again. Drop to `first` if that churn starts to
hurt. (The 50 native-Dart comparison panels are keyed without the library hash
and survive a bundle rebuild untouched.)

## What the script does

1. Runs `tools/build_single_file.sh`, which regenerates
   `docs/assets/fxdart_single.dart` — a single-file concatenation of `lib/src/`
   that the browser playground prepends to user code before sending it to the
   DartPad compile service — and analyzes it.
2. Runs `dart analyze lib`.
3. Runs `dart run tool/precompile_playgrounds.dart --scope="$PG_SCOPE" --prune`,
   compiling snippets into `docs/pg/` and dropping artifacts no snippet maps to
   any more. Incremental — an artifact that already exists costs nothing. A
   snippet that fails to compile is a broken demo, and stops the deploy.
4. Runs `dart run tool/build_docs.dart`, regenerating every page in every
   locale from `content/` and `i18n/`, and stamping `data-pg` on each
   playground that has an artifact. (With `-s`, it instead runs `--check`,
   which fails if `docs/` has drifted from its sources — so a skip-build deploy
   can never ship stale HTML.)
5. Checks that the required page resources exist (`docs/index.html`,
   `docs/101/index.html`, `docs/css/site.css`, `docs/js/playground.js`,
   `docs/frame.html`, `docs/assets/fxdart_single.dart`).
6. Prints per-locale translation coverage.
7. Stages `docs/`, `content/`, `i18n/`, `tool/`, `tools/`, `deploy.sh`, and
   `DEPLOY.md` — and nothing else — then commits and pushes to
   `origin/<current branch>`. Output and its sources ship together; committing
   one without the other would make the next `--check` fail.

Step 3 must come before step 4: the generator only stamps `data-pg` on
snippets whose artifact is already on disk.

Staging is by path on purpose: a docs deploy will **not** pick up in-progress
changes in `lib/` or `test/`. If a library change belongs in the same push,
commit it yourself first, then run `./deploy.sh`.

If the build produces no changes, the script stops with
`nothing to deploy` and exits 0.

## Notes

- **Never hand-edit the generated parts of `docs/`** — the HTML and
  `sitemap.xml` from `content/` + `i18n/`, `fxdart_single.dart` from `lib/src/`,
  and `pg/*.js.gz` from the precompiler. Everything else under `docs/` is
  copied in from `web/`, which is where those files are edited.
- `tool/playground_source.dart` reimplements the library+snippet merge that
  `web/js/playground.js` performs, so that precompiled output is built from
  exactly the text the browser would have sent. The two must stay
  byte-identical; if they drift, every page silently falls back to compiling
  over the network. Verify by capturing a real compile POST body from the
  browser and comparing it against the Dart merge.
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
