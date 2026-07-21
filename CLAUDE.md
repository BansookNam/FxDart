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

- `docs/` is **generated output — never edit by hand**. Sources: `content/` (English truth), `i18n/<locale>/` (translations, mirror content/, fall back to English), `tool/build_docs.dart` (generator).
- `content/code/` (playground code) and `sig.txt` are shared across locales — **never translated**.
- After translating, run `dart run tool/build_docs.dart --record` to mark it current.
- `deploy.sh` stages only docs-related paths (`docs content i18n tool tools deploy.sh DEPLOY.md`) — commit `lib/`/`test/` changes separately first.
