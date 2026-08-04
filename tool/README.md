# tool/

Build and check scripts for the docs site. All are plain `dart run`, no
dependencies beyond the SDK, and all are run **from the repo root**:

```bash
cd /path/to/FxDart
dart run tool/<script>.dart [args]
```

## rebuild_page.dart — after editing one page's code

Editing a playground snippet changes its content-addressed id. The artifact
under `docs/pg/` that the page was stamped with is now orphaned, so the panel
silently falls back to the DartPad compile service and every reader pays ~2s on
Run. Nothing fails, nothing warns — the page just gets slower.

This script fixes that for one page: it finds the snippets behind the page,
compiles the missing ones, reruns `build_docs.dart` to restamp them, and
commits.

```bash
dart run tool/rebuild_page.dart tutorials/map.html
```

```
tutorials/map
  ✓ content/code/map/0.dart  3fd1194ba418392b
  · content/code/map/1.dart  3d4727960d8e9094  (needs compile)
  · content/code/map/2.dart  d29e5d10bbd32e81  (needs compile)
2 snippet(s) to compile

$ dart run tool/precompile_playgrounds.dart --only=content/code/map/ --prune
compiling 2 of 3 snippets in scope "only=content/code/map/" (4 at a time)…
  2/2
docs/pg: 354 artifact(s), 36.1MB

$ dart run tool/build_docs.dart
built 1786 files across 7 locales

 docs/es/tutorials/map.html     |   4 ++--
 docs/ko/tutorials/map.html     |   4 ++--
 docs/pg/3d4727960d8e9094.js.gz | Bin 0 -> 119408 bytes
 docs/pg/d29e5d10bbd32e81.js.gz | Bin 0 -> 118556 bytes
 docs/tutorials/map.html        |   4 ++--
 …
 9 files changed, 14 insertions(+), 14 deletions(-)

96f77a3a docs: rebuild playgrounds for tutorials/map
not pushed — review, then `git push origin main`
```

A `✓` snippet is already built and costs nothing; only the `·` ones hit the
compile service.

### Naming the page

Give the page however you have it to hand. All of these mean the same thing:

```bash
dart run tool/rebuild_page.dart DartComparison/top-merchants.html
dart run tool/rebuild_page.dart DartComparison/top-merchants
dart run tool/rebuild_page.dart docs/DartComparison/top-merchants.html
dart run tool/rebuild_page.dart ko/DartComparison/top-merchants.html
dart run tool/rebuild_page.dart https://bansooknam.github.io/FxDart/DartComparison/top-merchants.html
```

A **locale prefix is accepted and ignored**: playground code lives in
`content/code*/` and is never translated, so all seven locales of a page share
one artifact. Rebuilding from the Korean URL restamps the English page too.

Pages that have runnable code, and what a rebuild covers:

| Page | Sources | Rebuilds |
| --- | --- | --- |
| `DartComparison/<slug>` | `content/code-comparison/<slug>/` | both panels |
| `RxDartComparison/<slug>` | `content/code-comparison-rx/<slug>/` | both panels |
| `tutorials/<slug>` | `content/code/<slug>/` | every demo on the page |
| `index` | `content/code/_index/` | both home-page snippets |

Several pages at once is fine — they are all resolved before any work starts,
so a typo in the second argument cannot leave the first half-rebuilt:

```bash
dart run tool/rebuild_page.dart tutorials/map.html tutorials/zip.html
```

### Flags

| Flag | Effect |
| --- | --- |
| `--dry-run` | resolve and report which artifacts are missing; touch nothing |
| `--no-commit` | rebuild, leave everything unstaged |
| `--message=…` | commit subject (default `docs: rebuild playgrounds for <page>`) |

### What it will not do

- **Never pushes.** It prints the `git push` command and stops.
- **Refuses to commit over a dirty index.** If something is already staged, it
  exits rather than wording a commit around your work. Commit it, reset it, or
  pass `--no-commit`.
- **Stages narrowly** — `docs/` plus the page's own content dir, so the snippet
  and the artifact it produced land in one commit and unrelated edits stay
  yours.
- **Does not check correctness.** It will happily ship a snippet whose printed
  output drifted. For comparison pages that gate is still
  `dart run tool/check_comparison.dart <slug>`.

It does warn when `lib/` is newer than `docs/assets/fxdart_single.dart`:
snippet ids are keyed on the bundle's hash, so compiling against a stale bundle
only mints ids the next real build orphans. Run `bash tools/build_single_file.sh`
first if you see it.

## The other scripts

| Script | What it does |
| --- | --- |
| `build_docs.dart` | renders `content/` + `i18n/<locale>/` into `docs/`, once per locale. `--check` fails if `docs/` is stale, `--status` reports translation coverage, `--record` marks translations current. |
| `precompile_playgrounds.dart` | compiles snippets into `docs/pg/<id>.js.gz`. `--scope=first\|all\|none`, `--only=<substring,…>`, `--prune` (drop orphans), `--status`, `--limit=N`. |
| `playground_source.dart` | library, not a script: the library+snippet merge and the id function. Must stay byte-identical to `buildSource` in `docs/js/playground.js`. |
| `check_comparison.dart` | runs both panels of every comparison example and requires byte-identical stdout; writes `expected.txt`. `--check` for CI, `--rx` for the RxDart family. |
| `check_translation.dart` | structural diff of a translation against its English source — front matter, placeholders, tags and hrefs must survive. |
| `extract_docs.dart` | one-time migration that produced `content/` from the original hand-written HTML. Kept for history; not part of any build. |

## Build order

`tools/build_single_file.sh` → `precompile_playgrounds.dart` → `build_docs.dart`

Rebuilding the single-file bundle changes **every** fxdart snippet's id, which
is the point — a stale artifact can never outlive the library it was compiled
against — so a full precompile after that takes `--prune` to drop the
superseded artifacts. `deploy.sh` runs this sequence and honours `PG_SCOPE`
(`first` default, `all`, `none`).

For a one-page edit you do not need any of this: `rebuild_page.dart` runs the
last two steps, scoped.
