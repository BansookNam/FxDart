# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
dart test                              # all tests
dart test test/lazy/map_test.dart      # one file
dart test -n "substring of test name"  # one test by name
dart analyze lib                       # lint (lints/recommended)
dart run coverage:test_with_coverage   # coverage (what CI runs)

./run.sh                               # build docs site + serve locally (-o opens browser, -s skips build)
./deploy.sh                            # build docs/ locally to inspect it (commits nothing; CI publishes)
dart run tool/build_docs.dart          # regenerate docs/ from content/ + i18n/  (--status, --check, --record)
bash tools/build_single_file.sh        # regenerate docs/assets/fxdart_single.dart (playground bundle)
dart run tool/precompile_playgrounds.dart  # build docs/pg/ artifacts (--scope, --status, --prune, --limit, --only)
dart run tool/rebuild_page.dart DartComparison/top-merchants.html  # optional: rebuild one page's artifacts for a local preview
./benchmark.sh                             # sweep + regenerate the ratio report (--docs also rebuilds docs/)
./benchmark.sh --ab <slug…> | --ab --all   # paired A/B — the only way to read a change under ~5%
./benchmark.sh --verify                    # is the ratio report in step with results.json?
./benchmark.sh --check | --report-only | --smoke | --rx
dart run benchmark/run_benchmarks.dart     # the raw runner benchmark.sh wraps (--smoke, --rounds N, [slugs…])
dart run benchmark/run_benchmarks.dart --rx # RxDartComparison perf benchmarks (RxDart vs FxDart)
```

## Architecture

fxdart is a port of **FxTS** (TypeScript FP library). API names, semantics, and laziness follow FxTS faithfully; where Dart makes a direct port impossible (no variadic generics, no arity reflection), a Dart-native replacement is designed instead — `WHY_CURRIED.md` documents this philosophy. Zero runtime dependencies; keep it that way.

- `lib/src/lazy/` — lazy operators over plain `Iterable` (`sync*`), signature `op(callback, iterable)`.
- `lib/src/strict/` — eager functions (aggregate, access, object, predicates, `.curried` extensions).
- `lib/src/async_iterable.dart` — `FxAsyncIterable`, a **pull-based** async protocol with a concurrency back-channel: `concurrent(n)` passes a marker backwards through `iterator.next(concurrent)` so upstream evaluates n items at once, in order. This back-channel is why the library does not build on push-based `Stream`s (bridges: `toAsync`, `fromStream`, `toStream()`).
- `lib/src/fx.dart` — typed `Fx`/`FxAsync` chains that wrap the top-level operators (the Dart replacement for FxTS's curried `pipe`). `lib/src/pipe.dart` is the dynamic, untyped `pipe` kept for FxTS parity.
- Public API is the explicit export list in `lib/fxdart.dart`.

**Adding an operator touches all of:** top-level sync fn + `Async` variant in `lib/src/`, chain method on `Fx`/`FxAsync`, export in `lib/fxdart.dart`, test at `test/{lazy,strict,util}/<fn>_test.dart` (one file per function), and a tutorial in `content/tutorials/<fn>.md` + `content/code/<fn>/`.

Async operator callbacks in `mapAsync`-style code must stay parallel-safe: overlapping `next()` calls must start overlapping upstream pulls — awaiting the upstream serially breaks `concurrent`.

## Docs site (content/ → docs/)

- **`docs/` is entirely generated — never edit anything in it.** Every `*.html`
  + `sitemap.xml` comes from `content/` (English truth) + `i18n/<locale>/`
  overlays via `tool/build_docs.dart`; `docs/assets/fxdart_single.dart` from
  `lib/` via `tools/build_single_file.sh`; `docs/pg/*.js.gz` via
  `tool/precompile_playgrounds.dart`; and everything else is copied in from
  `web/`.
- **`web/` is the hand-written half of the site** and is what you edit:
  `web/css/*.css`, `web/js/*.js`, `web/frame.html`, `web/assets/logo*.png`,
  `web/DailyLedger/` (the built Flutter demo). `build_docs.dart` copies the
  tree verbatim into `docs/`, so `web/css/site.css` is served as
  `docs/css/site.css` and every relative link in a rendered page is unchanged.
- The site is **built and published by `.github/workflows/pages.yml`**, not by
  a developer. Nothing generated is committed back; the run uploads `docs/` as
  a Pages artifact. `./deploy.sh` still exists for a manual publish, and
  `./run.sh` still builds locally for preview.
- The bundle is **comment-stripped** (`tool/strip_dart_comments.dart`). A
  snippet's playground artifact id hashes the bundle, so while `lib/`'s dartdoc
  was in there a comment-only edit rotated every id and rewrote `data-pg` on
  ~1,900 pages — which is what made two branches touching `lib/` conflict on
  ~1,900 files that carry no information. Analyzer `// ignore` directives are
  kept, because CI analyzes the bundle.
- `content/code/` (playground code) and `sig.txt` are shared across locales — **never translated**.
- `./benchmark.sh` is the entry point for both families, and exists because the
  steps fail quietly on their own: a sweep writes `results.json` but the ratio
  report is a separate script (leave it and the two disagree until someone
  regenerates months later, at which point it reads as a regression); `--smoke`
  writes un-warmed numbers into `results.json` like any other run; and a sweep
  cannot resolve a change under ~5%, so `--ab` (`--all` for every case) is the
  instrument for "did my change do anything" — it runs 20 rounds because at
  ab_bench's default 12, four readings in the 0.8.6 pass looked solid against
  *clean* controls and vanished at 20. `--verify` catches the
  report-vs-results drift directly.
- **Two benchmark families** exist and must be maintained separately:
  - **DartComparison** (`docs/DartComparison/`, `benchmark/results/results.json`): native Dart vs FxDart perf comparison. Run with `dart run benchmark/run_benchmarks.dart`. Compares `benchmark/cases/<slug>/native.dart` against `benchmark/cases/<slug>/fxdart.dart`. Measures 3 scales (N=100, 10k, headline 1M or case-specific).
  - **RxDartComparison** (`docs/RxDartComparison/`, `benchmark/results/results-rx.json`): RxDart vs FxDart perf comparison. Run with `dart run benchmark/run_benchmarks.dart --rx`. Compares `benchmark/cases/<slug>/rxdart.dart` against `benchmark/cases/<slug>/fxdart.dart`. Measures 2 scales (N=100, headline 1M for sync / case-specific for async).
- Both result files are build_docs **inputs**, rendering Benchmark bar-chart sections on their respective comparison pages. Benchmark cases in `benchmark/cases/<slug>/` must stay faithful to their `content/code-comparison/<slug>/` and `content/code-comparison-rx/<slug>/` examples — see `benchmark/AUTHORING.md`.
- After translating, run `dart run tool/build_docs.dart --record` to mark it current.
- Staleness is a hash of the **English file only**, so *any* edit to it — including a
  mechanical front-matter bump applied to the overlays in the same commit — marks every
  translation of that page outdated and grows a "may be outdated" banner. `--record`
  belongs in the same commit as the edit. Before recording in bulk, confirm the English
  diff really is prose-free (`git show <sha> -- content/comparison | grep -v '^[-+]order:'`),
  since recording is what silences a *genuine* staleness too.
- **`docs/` is untracked** (`.gitignore`). It is built and published by
  `.github/workflows/pages.yml` on a push to `main`; nothing generated is ever
  committed. `./deploy.sh` builds the same output locally for inspection and
  `./run.sh -s` serves it — neither commits. To publish without a source
  change: `gh workflow run pages.yml` (`-f pg_scope=all` for every playground).

### Theory textbook (content/theory/ → docs/theory/)

A paged book viewer — the FP theory companion to 101, modelled on the
`fxdart-book` manuscript format. Sources:

- `content/theory/book.md` — front-matter pages (preface). `content/theory/NN-slug.md`
  — one chapter each, with front matter `slug`, `chapter`, `part`, `title`,
  `description`. `content/theory/parts.json` — part titles (translated like
  `sections.json`). `content/theory/diagrams/*.svg` — figures, **shared across
  locales, never translated**, inlined at build time with ids namespaced.
- `tool/theory_markdown.dart` converts a chapter to *blocks*; the whole book
  renders into one page per locale (`docs/theory/index.html`, `docs/ko/theory/…`).
  Pagination is **runtime** work: `web/js/theorybook.js` measures blocks against
  the real page box and flows them, because page capacity depends on the viewport.
  `web/js/theorybook.js` + `web/css/theorybook.css` are the hand-written sources.
- The viewer renders **only the current spread** — two `.page-slot` divs, no 3D,
  no stacked sheets. An earlier version flipped every page in 3D; at 300 pages
  the compositor bled stale layers through the current spread (page 6 visible
  under an "8–9" indicator) and no z-index scheme fixed it. Turning a page is
  now a synchronous re-render (~0.4ms), so the DOM holds two pages and what is
  on screen always matches the indicator. Do not reintroduce the flip.
- Under ~880px wide (or ~520px tall) the viewer switches to **single-page
  mode**: no spread, no fixed paper — `measureGeometry()` writes `--page-w` /
  `--page-h` from what the stage leaves over and the flow fills that box, so
  the page is as large as the screen allows. The nav arrows and the page
  indicator move into a bar under the paper (back · page picker · forward) and
  the language row into a sheet of its own behind a globe button (`#lang-btn`,
  tagged with the edition being read); `#book-crumb` names the chapter the
  spread used to show for free. The switcher links are *moved* into that sheet,
  never copied — they carry the handler that hands the reading position to the
  other edition.
- The book's switcher lists **only locales that have `i18n/<code>/theory/`**
  (plus the one being read, so a reader who landed on an untranslated edition
  can still see where they are) — a 300-page manuscript is not translated by a
  locale directory that has no theory book, and offering it lands the reader on
  the same English pages. Its last row is `.book-contribute` → `contributeUrl`
  (the i18n guide on GitHub); it carries no `hreflang`, which is what keeps the
  reading-position handler off it. Because the box is measured, a resize or a
  rotation **re-runs the flow** — the reader is restored by anchor, never by
  page number, and the box is read off the *stage* (not `#scaler`, whose width
  follows `#book`, which is sized from the box). The stage is `100svh` there:
  a collapsing mobile toolbar must not re-flow 300 pages.
- Blocks taller than a page are **split** before the flow: listings by line
  (continuation marked `⋯`, the whole program kept on the wrapper's `data-src`
  so ▶ Run still compiles the full file), tables by row with the header
  repeated, lists and blockquotes by item. Anything measured must be measured in
  its final form — labels, markers and attributes that affect height go on
  *before* the fit check, or the page renders taller than it measured.
- The book page is **standalone by design** — it links `css/theorybook.css` and
  nothing else (no `site.css`, no site header, no footer), fills the viewport,
  and is left through the ✕ close button (locale-root-relative, back to 101);
  the bottom HUD carries the page indicator, Contents and the language links.
  That isolation is deliberate: sharing chrome with the site meant the site's
  theme tokens repainted the paper, and the header's height (which changes when
  the nav wraps) decided whether the page scrolled the nav out of view. Keep the
  page self-contained — every style it needs belongs in `theorybook.css`.
- Markdown extras: ```` ```dart run ```` marks a listing runnable (adds ▶ Run;
  the viewer wraps a snippet with no `main` and prepends the fxdart import).
  A `> 🎓 …` quote is a depth box, `> **In this chapter**` the goals box, an
  all-italic line a figure caption. `## Exercises` starts on a recto and
  `## Solutions` after a page turn, so answers cannot be seen from the questions.
- **Code blocks are locale-invariant** — the ko overlay carries the English
  listing verbatim (comments included); only prose is translated. The checker
  enforces it: a translated chapter whose fenced blocks differ from English
  fails the run.
- `dart run tool/check_theory.dart [NN …]` is the gate for any edit: it runs
  every ```` ```dart run ```` listing against this package, prints its real
  output (paste it back into the prose), and enforces the ≤ 66-column rule that
  keeps listings from wrapping in the page box. The book asserts what programs
  print, so a failing listing is a factual error, not a style nit.
- Running uses the 101 playground engine: `web/js/playground.js` exposes
  `window.FxDartPlayground.run(source, handlers, {prebuiltId})`, so compile
  caching, the DDC runtime download and frame lifetime are shared with the
  tutorials' playgrounds.
- **Book listings are precompiled.** Every listing is a complete program, so the
  text between the fences is exactly what compiles: `playground_source.dart`
  enumerates them (`theoryListings`), `precompile_playgrounds.dart` builds
  `docs/pg/<id>.js.gz`, and build_docs stamps `data-pg` on the runwrap. A warm
  run then prints in ~200ms instead of ~2.5s. They count as first-on-page, so
  the default `PG_SCOPE=first` covers them; after editing any listing run
  `dart run tool/precompile_playgrounds.dart --only=content/theory` (74
  compiles, ~1 min, ~8MB) — only if you want the fast path locally; CI builds
  them on publish either way. `dart run tool/check_theory.dart` is the gate
  that matters, and it is a CI step.
- **✎ Edit** opens the whole program in an overlay editor (a page is a fixed
  box, so typing cannot happen in place). Edits live in a JS map keyed by
  chapter+listing — never in the DOM, which is re-rendered on every page turn —
  are badged on the printed listing, and bypass the artifact so the edited text
  is compiled.
- Reading position is stored in the location hash as `#ch7-3` (chapter 7, its
  third page), never as a page number: page numbers differ per translation.
  The language links carry that anchor, so switching locale mid-book lands on
  the same content in the other edition.
- The writing plan (chapter list, per-chapter briefs, conventions) is
  `content/theory/PLAN.md`.

### Playground execution path

A Run resolves the snippet's JS from the cheapest available source: a build-time
artifact in `docs/pg/` (stamped on the `.playground` div as `data-pg`), then the
reader's Cache Storage, then the DartPad compile service. `tool/playground_source.dart`
holds the library+snippet merge and **must stay byte-identical to `buildSource` in
`web/js/playground.js`** — if you touch either, verify by capturing the real compile
POST body from a browser and comparing.

Build order matters: `build_single_file.sh` → `precompile_playgrounds.dart` →
`build_docs.dart`. Editing **any** snippet changes its id, so it orphans the
artifact its page was stamped with and the panel falls back to the compile
service; rebuilding the bundle re-keys every fxdart snippet at once, which is
why precompiling takes `--prune`.

**This is CI's job, not yours.** `pages.yml` runs the three in order on every
push to `main`. Nothing generated is committed, so there is no artifact to keep
in step by hand and no reason for a `lib/` change to touch `docs/` at all.
`tool/rebuild_page.dart <page>` still exists for a local preview of one page
(both comparison panels, or all of a tutorial's demos; locale prefixes are
accepted and ignored, since artifacts are shared across locales). `deploy.sh` honours
`PG_SCOPE` (`first` default, `all`, `none`).

The 17MB DDC runtime is fetched by the **parent page**, not the sandboxed frame, and
kept in Cache Storage keyed by the compile service's `dartVersion`; frames are handed
the source text and booted ahead of the click. Neither DDC artifact is an AMD module,
which is what makes this possible — do not reintroduce a script loader.
