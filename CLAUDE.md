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
./deploy.sh                            # build + commit + push docs (GitHub Pages serves docs/ off main)
dart run tool/build_docs.dart          # regenerate docs/ from content/ + i18n/  (--status, --check, --record)
bash tools/build_single_file.sh        # regenerate docs/assets/fxdart_single.dart (playground bundle)
dart run tool/precompile_playgrounds.dart  # build docs/pg/ artifacts (--scope, --status, --prune, --limit)
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

- Most of `docs/` is **generated output — never edit by hand**: every `*.html` + `sitemap.xml` (from `content/` English truth + `i18n/<locale>/` overlays, which fall back to English, via `tool/build_docs.dart`), `docs/assets/fxdart_single.dart` (from `lib/` via `tools/build_single_file.sh`), and `docs/pg/*.js.gz` (via `tool/precompile_playgrounds.dart`).
- These files under `docs/` are **hand-maintained sources** and are meant to be edited directly: `docs/css/site.css`, `docs/js/*.js`, `docs/frame.html`, `docs/assets/logo*.png`.
- `content/code/` (playground code) and `sig.txt` are shared across locales — **never translated**.
- After translating, run `dart run tool/build_docs.dart --record` to mark it current.
- `deploy.sh` stages only docs-related paths (`docs content i18n tool tools deploy.sh DEPLOY.md`) — commit `lib/`/`test/` changes separately first.

### Playground execution path

A Run resolves the snippet's JS from the cheapest available source: a build-time
artifact in `docs/pg/` (stamped on the `.playground` div as `data-pg`), then the
reader's Cache Storage, then the DartPad compile service. `tool/playground_source.dart`
holds the library+snippet merge and **must stay byte-identical to `buildSource` in
`docs/js/playground.js`** — if you touch either, verify by capturing the real compile
POST body from a browser and comparing.

Build order matters: `build_single_file.sh` → `precompile_playgrounds.dart` →
`build_docs.dart`. Rebuilding the bundle changes every fxdart snippet's id, so
precompiling takes `--prune` to drop the superseded artifacts. `deploy.sh` honours
`PG_SCOPE` (`first` default, `all`, `none`).

The 17MB DDC runtime is fetched by the **parent page**, not the sandboxed frame, and
kept in Cache Storage keyed by the compile service's `dartVersion`; frames are handed
the source text and booted ahead of the click. Neither DDC artifact is an AMD module,
which is what makes this possible — do not reintroduce a script loader.
