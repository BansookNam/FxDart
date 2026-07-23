## 0.5.3

### Added

* **AI agent skill** (`skills/fxdart-pipelines/`) following the
  [Agent Skills](https://agentskills.io) spec — teaches coding assistants
  when to reach for fxdart (collections, bounded-concurrency Futures,
  Streams, complex flow logic) and the patterns/pitfalls that matter.
  Compatible with the community `skills` CLI (`skills get fxdart`).
* **`dart run fxdart:install_skills`** (also `fxdart_skills` via
  `dart pub global activate fxdart`) — zero-dependency installer that copies
  the bundled skills into Claude Code, Codex, Devin, Antigravity, OpenCode,
  pi, or generic `.agents/skills/` directories, project-local or `--global`,
  with `--list` and `--remove`.

## 0.5.2

### Docs

* Documented the full public API — every `fx()` / async chain method, the
  Dart-idiomatic aliases, the async iterator protocol types (`Concurrent`,
  `IterResult`, …), and the `.curried` / `.uncurried` extensions now carry
  dartdoc comments. Coverage went from 65.7 % to ~100 % of the exported API.

### Packaging

* Moved the runnable Dart example to `example/fxdart_example.dart` so pub.dev
  recognises it (was nested under `example/dart_example/`).

## 0.5.1

### Docs

* List the by-key aggregates (`sumBy`, `averageBy`, `minBy`, `maxBy`) in the
  README operator table.

## 0.5.0

### Added

* **`averageBy`** (+ `averageByAsync`, and `.averageBy()` on the `fx()` and
  async chains). The mean of a key over every element — one walk tracking a
  running total and count. Empty input returns `NaN` (the `average`
  contract). Completes the by-key family (`sumBy` / `maxBy` / `minBy`).

## 0.4.0

### Added

* **`sumBy`** (+ `sumByAsync`, and `.sumBy()` on the `fx()` and async
  chains). Sums a key of every element — `map` + `sum` in one terminal, so
  "total this field" is one call. Empty input returns `0` (the `sum`
  contract); the async variant awaits the key extractor per element.
  Dart-native addition in the `maxBy`/`minBy` family (Kotlin's `sumOf`).

## 0.3.0

### Added

* **`maxBy` / `minBy`** (+ `maxByAsync` / `minByAsync`, and `.maxBy()` /
  `.minBy()` on the `fx()` and async chains). Returns the *element* with the
  largest/smallest key in one O(n) walk — the answer to the
  `sortBy(key).head()` anti-pattern, which sorts the whole pipeline to read
  one value. Keys compare like `sortBy` (`Comparable.compare`), ties keep the
  first element encountered, empty input returns `null` (like `head`/`last`).
  Dart-native addition — FxTS ships only the numeric `min`/`max`; the name
  follows Kotlin's `maxByOrNull` shape.

## 0.2.2

### Renamed for Dart idiom

* **`toArray` → `toList`**, **`toArrayAsync` → `toListAsync`** *(breaking)*.
  Dart has no "array" type — these have always returned a `List`, so they now
  carry the Dart-standard name. Applies to the top-level functions and the
  `fx()` / async chain terminals. The old names are **removed outright** (not
  aliased): replace `toArray()` → `toList()` and `toArrayAsync()` →
  `toListAsync()`.

### Dart-idiomatic aliases added (both spellings supported)

Every FxTS operator whose Dart `Iterable`/collection counterpart has a different
established name now exposes **both** names — the FxTS name for parity and the
Dart-idiomatic name as a first-class alias. Nothing is removed (that was
`toArray`'s special case above); existing code keeps working, and the FxDart 101
course teaches the Dart-idiomatic spelling. Aliases exist at every level: the
top-level functions (+ their `*Async` twins), the `fx()` chain, and the async
`FxAsync` chain. On the sync chain several Dart names come for free because
`Fx extends Iterable` (Dart 3): `firstOrNull`, `lastOrNull`, `elementAtOrNull`,
`any`, `forEach`, `length`, `indexed`, `nonNulls`, `contains`.

*Type-name aliases — the FxTS name claims a type Dart doesn't have:*

| FxTS name | Dart-idiomatic alias |
|---|---|
| `unicodeToArray` | `unicodeToList` |
| `isBoolean` | `isBool` |
| `isNumber` | `isNum` |
| `isDate` | `isDateTime` |

*Standard-library vocabulary aliases:*

| FxTS name | Dart-idiomatic alias |
|---|---|
| `head` | `firstOrNull` |
| `last` | `lastOrNull` |
| `nth` | `elementAtOrNull` |
| `find` | `firstWhereOrNull` |
| `findIndex` | `indexWhere` |
| `some` | `any` |
| `size` | `count` (or `.length` on the chain) |
| `each` | `forEach` |
| `filter` | `where` |
| `reject` | `whereNot` |
| `flatMap` | `expand` |
| `flat` | `flattened` |
| `drop` / `dropWhile` | `skip` / `skipWhile` |
| `uniq` / `uniqBy` | `distinct` / `distinctBy` |
| `zipWithIndex` | `indexed` |
| `compact` | `nonNulls` |
| `toSorted` | `sorted` |
| `takeRight` | `takeLast` |

`includes` keeps only its FxTS spelling at the top level — a top-level `contains`
would collide with `package:test`'s matcher; use the inherited `.contains()` on
the chain for the Dart idiom. See `test/dart_aliases_test.dart` for the
both-spellings contract.

*Left as-is* — already Dart-idiomatic or intentionally FP with no stdlib
counterpart: `map`, `take`, `takeWhile`, `reduce`, `fold`, `join`,
`sum`/`min`/`max`/`average`, `every`, `isEmpty`, `isNull`/`isNotNull`,
`isString`/`isList`/`isMap`, and the combinator/`pipe` family (`identity`,
`tap`, `memoize`, `curried`, `pipe`, …).

## 0.2.1
* READEME.md update

## 0.2.0

* Comprehensive docs site overhaul: tutorials for `curried`/`uncurried` and
  `createSeededRandom` now part of the FxDart 101 course with live in-browser
  playground examples.
* Logo and branding refresh for docs site.
* Enhanced playground bundle with full currying extensions support.

## 0.1.3

* Docs site: new tutorials for `curried`/`uncurried` and `createSeededRandom`
  (previously undocumented), wired into the FxDart 101 course; the playground
  bundle now includes the currying extensions.

## 0.1.2

* `.curried` / `.uncurried` extension getters (arity 2–5): a fully typed,
  Dart-native replacement for FxTS `curry`, resolved statically per arity.
  Design rationale in [WHY_CURRIED.md](WHY_CURRIED.md). The untyped `curry`
  stub's deprecation now points at `.curried`.

## 0.1.1

* `concurrentPool` now eagerly keeps its pool full (FxTS behavior): even
  one-pull-at-a-time consumers like `toArray()` get full overlap and
  completion-order results.
* Docs site (GitHub Pages) with a live in-browser playground for every
  function, under `docs/`.

## 0.1.0

* Complete rewrite: port of [FxTS](https://fxts.dev) to Dart.
* Lazy sync operators over plain `Iterable`s (`map`, `filter`, `take`, `chunk`, `zip`, ...).
* Pull-based `FxAsyncIterable` protocol with FxTS-style `concurrent(n)` /
  `concurrentPool(n)` evaluation and `Stream` bridges (`fromStream`, `toStream`).
* Typed `fx()` / `FxAsync` chain API; dynamic `pipe` / `pipeLazy` for parity.
* Strict functions (`reduce`, `groupBy`, `sortBy`, `partition`, ...), Map-based
  object functions (`omit`, `pick`, `evolve`, `isMatch`, ...), and Util
  (`debounce`, `throttle`, `shuffle`).
* Unportable TS APIs kept as `@Deprecated` stubs (`curry`, `isUndefined`,
  `isArray`, `isObject`).
* 850+ tests ported from the FxTS spec suite.

## 0.0.1

* Initial update, Add concept inspired by FxJs
