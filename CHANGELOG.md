## 0.7.3

### Performance

First pass: AOT-measured, over the operators the 0.7.2 additions and the
DartComparison benchmark #53 (smoothed-zone-changes) exercise; that case's
headline-scale gap vs hand-written Dart shrank from 2.7× to 1.37× with no
API or output change.

* **`uniqAdjacentBy` / `pairwise` / `ifEmpty`** — rewritten from `sync*`
  generators to hand-written iterator classes (the 0.7.2 additions had
  missed the 0.7.1-era conversion; `sync*` `moveNext` is ~4× slower under
  AOT and compounds per chained operator).
* **`windowed` / `chunk`** — the shared sliding core keeps overlap in a
  reused ring buffer, so each emitted window costs exactly one exact-size
  allocation instead of `sublist` + growable `add`. Windows are now
  fixed-length lists (mutating a yielded window with `add` no longer
  works; contents and laziness are unchanged).
* **`sum` / `average`** — indexed fast paths for `List<double>` /
  `List<int>` (no iterator, unboxed loads; results bit-identical to the
  generic path). **`sumBy` / `averageBy`** iterate lists by index.
* **`Fx.sum/average/min/max`** now unwrap the chain's inner iterable
  instead of re-iterating through the `Fx` wrapper, and `fx()` /
  `Fx.average`/`Fx.sum` carry `@pragma('vm:prefer-inline')` so AOT escape
  analysis can erase the wrapper allocation in per-element uses like
  `.map((w) => fx(w).average())`.

Second pass: the same AOT treatment extended to the rest of the sync
surface. DartComparison #7 (top-log-level) now beats its hand-written
Dart baseline outright; every benchmark checksum is unchanged.

* **`takeRight` / `dropRight` / `reverse` / `cycle` / `flat` / `fork` /
  `using` / `split` / `transpose` / `entries`** — the remaining `sync*`
  generators rewritten as hand-written iterators (2.7–8.3× measured per
  operator; `split` also accumulates into a `StringBuffer`).
  **`differenceBy` / `intersectionBy`** fuse their filter-then-`uniq`
  pair into a single pass over the second iterable.
* **List sources are indexed directly** in `reverse` / `takeRight` /
  `dropRight` — no snapshot copy (`reverse` of a 1M-element list 12.8×;
  `takeRight(1000)` of it ~1500×, since the untaken 999,000 elements are
  never copied). Non-List sources use O(length) ring buffers, and
  `dropRight` streams through a delay line instead of materializing:
  `take(2, dropRight(2, xs))` pulls exactly 4 elements, and unbounded
  sources now work. Two visible edges: a negative `length` now throws at
  the call site instead of at the first pull, and mutating a source list
  mid-iteration is no longer masked by an internal copy.
* **`find` / `findIndex`** — direct loops instead of `head(filter(…))` /
  `zipWithIndex` (8.7× / 3.5×: no per-element filter layer or index
  record). **`last` / `nth`** are O(1) on lists, **`size`** on lists and
  sets.
* **`min` / `max`** — indexed fast paths for `List<double>` / `List<int>`
  (10.2× / 8.3×) and a direct loop otherwise (1.8×); empty/NaN/tie
  results identical to the fold they replace.
* **`groupBy` / `countBy` / `uniq`** — per-element closure allocations
  removed (`putIfAbsent`, `Map.update`'s two closures, `uniqBy`'s
  identity key): 1.5× / 2.2× / 1.7×.
* **`map` / `scan` / `scan1`** — `.toList()` fills a pre-sized list when
  the source is a `List` (1.9× / 2.1× / 2.4×); the callback still runs
  exactly once per element, in order. The RxDartComparison
  `running-balance-feed` case (`scan1(…).toList()` end to end) got 2.08×
  faster, widening fxdart's win there to ~10×.
* **`Fx`** delegates `length` / `isEmpty` / `isNotEmpty` / `first` /
  `last` / `single` / `elementAt` / `contains` to the wrapped iterable —
  `fx(list).length` is O(1) instead of an iterator walk.

### Added — the events layer (`FxEvents`)

fxdart's push side: a zero-dependency chain over plain Dart `Stream`s for
the problems that are genuinely *events over time* — the jobs the
RxDartComparison section's Part 4 used to concede. The pull core is
untouched; this is a separate module (`lib/src/stream/events.dart`) that
absorbs the Rx approach where the Rx approach is right, in fxdart style.

* **`fxEvents(stream)` → `FxEvents<T>`** — a wrapper chain (deliberately
  NOT `Stream` extensions, so it can never collide with rxdart or any
  other stream library in the same file).
* Time operators: **`debounce(window)`** (trailing, flush-on-close),
  **`throttle(window, {leading, trailing})`**, **`sampleOn(trigger)`**.
* Combination: **`combineLatest(other, combine)`**,
  **`withLatestFrom(other, combine)`**, **`switchMap(f)`**
  (cancellation-by-newer), **`FxEvents.race(candidates)`** (losers
  cancelled), **`FxEvents.merge(sources)`**, **`startWith(value)`**, plus
  `map`/`where`/`asyncMap` passthroughs.
* **`LiveValue<T>`** — the `BehaviorSubject` counterpart reduced to its
  defining behavior: a current value whose late subscribers get the
  latest value first, then the live updates (`.seeded`, `.value`,
  `.hasValue`, `.live`, `.close`).
* Bridges: **`.pull()`** crosses an event chain into the typed `FxAsync`
  pull world (`fromStream` under the hood); `.stream` unwraps for any
  `Stream` API; `FxAsync.toStream()` remains the other direction.

The RxDartComparison examples #40–47 are rewritten on this layer — the
push-side verdicts that used to read "RxDart's turf" are now honest ties.
RxDart still has the far larger operator surface; what closed is the
model gap, not the catalog.

## 0.7.2

### Added — Rx-inspired pull operators

Operators extracted from an internal comparison against RxDart
(`plans/RXDART_COMPARISON_AND_SUGGESTION_PLAN.md`): the Rx ideas that are
genuinely pull-shaped and time-free, re-designed for the demand-driven
model. None of these exist in FxTS; each doc comment says so and names the
Rx counterpart. Push/temporal operators (`combineLatest`, `switchMap`,
Subjects, time-windowed `debounce`/`buffer`/`sample`, …) remain explicitly
out of scope — bridge to `Stream`/rxdart via `toStream()`/`fromStream` for
those. Each addition ships sync + async + `Fx`/`FxAsync` chain forms,
tests, and a 101 tutorial.

Windowing (one shared sliding core; `chunk` was refactored onto it with
byte-identical behavior):

* **`windowed(size, {step, partial})`** — sliding windows, the
  generalization of `chunk` (`chunk` ≡ `step: size, partial: true`).
  Kotlin's naming; RxDart's `bufferCount(size, startEvery)`.
* **`pairwise()`** — adjacent `(previous, current)` record pairs, the
  window-of-2 special case that deltas/streak examples kept hand-rolling.

Filtering:

* **`uniqAdjacent()` / `uniqAdjacentBy(key)`** — drops only *adjacent*
  duplicates (Rx `distinctUntilChanged`, Dart `Stream.distinct`), so no
  seen-set accumulates; complements the global `uniq`/`uniqBy`.
* **`ifEmpty(fallback)` / `defaultIfEmpty(value)`** — lazily switches to a
  fallback iterable / single default when the source turns out empty
  (Rx `switchIfEmpty` / `defaultIfEmpty`).

Effects (new `lib/src/lazy/effect.dart`):

* **`retry(attempts, f, {delay})`** — runs an effect until it succeeds,
  with a per-failure backoff hook; rethrows the last error with its
  original stack trace. Whole-pipeline retry is its terminal form:
  `retry(3, () => fxAsync(...).toList())`.
* **`mapRetry(attempts, f, {delay})`** — the per-element form, built on
  `mapAsync`, so it is parallel-safe: under `concurrent(n)` each in-flight
  element retries independently while order is preserved.
* **`timeout(limit)`** — fails a pull that takes longer than `limit` with
  a `TimeoutException`. Pull-model semantics: the limit is demand-to-item
  time per pull, not inter-event gaps (documented difference from Rx).
* **`using(acquire, use, release)` / `usingAsync`** — scopes a resource to
  one lazy iteration; `release` runs exactly once on completion or error.
  Abandoning iteration mid-way skips `release` (a pull-model limit the
  docs call out; bound with `take` instead of `break`).

## 0.7.1

### Added — pre-combined operators

Convenience operators that collapse the multi-operator idioms observed
across the DartComparison examples and the daily_ledger typed-error rounds.
Each ships sync + async + `Fx`/`FxAsync` chain forms, tests, and a 101
tutorial. All are composition over existing operators — laziness, effect
order, and parallel-safety are inherited, not re-implemented.

Pipeline:

* **`mapConcurrent(n, f)`** — `toAsync().map(f).concurrent(n)` as one step,
  on both sync and async sources. The single most repeated async idiom in
  the comparison suite (6 of the 11 hardest examples).
* **`groupedBy(key)`** — groups as chainable `(key:, items:)` named
  records in first-seen key order; per-group aggregation continues in the
  same chain instead of re-entering through `Map.entries`.
* **`sortByDesc(key)`** — descending `sortBy` for any comparable key
  (dates and strings have no `-key` negation), sharing `sortBy`'s
  extract-once machinery and unboxed fast paths.
* **`countWhere(pred)`** — `filter` + `size` fused into one walk.
* **`attach(f)`** — lazily pairs each value with `f(value)` so the input
  stays beside its (possibly async) result; the async form is
  parallel-safe and composes with `concurrent`.
* **Chain methods for the set ops** — `differenceBy` / `difference` /
  `intersectionBy` / `intersection` on `Fx` and `FxAsync` (the receiver is
  the free function's source argument), so example 40's triple chain-break
  disappears.

Typed errors:

* **`flattenOrAccumulate`** (port of Arrow 2.x's name) — collects every
  success or EVERY failure from an existing collection of `Either`s; the
  fail-slow twin of `sequence`, completing the terminal trio with
  `separated`. Top-level + async + chain terminals.
* **`eitherCatching` / `eitherCatchingAsync`** — `either` with an
  exception boundary: thrown exceptions map into the typed error via
  `onThrow`; the raise signal is never handed to it. Replaces the
  4-layer `either(catching(...))` envelope.
* **`RaiseOps.recover` gained `onThrow:`** — Arrow 2.x's three-clause
  `recover(block, recover, catch)`, non-breaking.
* **`Accumulator.dependent(block)`** — runs only when no branch has
  failed, making sibling `Accumulated.value` reads safe by construction;
  names the manual `if (!acc.hasErrors)` guard that dependent-field
  validation always needed. (Dart-native addition; no Arrow counterpart.)
* **`Iterable.toNelOrNull()`** (port of Arrow's `toNonEmptyListOrNull`) —
  any iterable → `Nel?` without the `.toList()` shuffle.
* **Async `Either` extracts** — `rightsAsync` / `leftsAsync` /
  `separateEitherAsync` and `FxAsync<Either>.rights()` / `.lefts()` /
  `.separated()`, giving the async chain the same extract family the sync
  chain already had.

### Changed

* `lib/fxdart.dart` now exports `src/typed/fx_either.dart` through an
  explicit `show` list (it was the one unfiltered typed export).

### Performance

* **Lazy sync operators rewritten from `sync*` generators to dedicated
  iterator classes** (`map`, `filter`, `peek`, `flatMap`, `scan`, `scan1`,
  `compact`, `uniqBy`, `take`, `drop`, `takeWhile`, `dropWhile`, `dropUntil`,
  `takeUntilInclusive`, `slice`, `chunk`, `zip`, `zip3`, `zipWithIndex`,
  `range`, `repeat`, `concat`, `append`, `prepend`). A `sync*` `moveNext`
  costs ~4× more than a plain iterator class under AOT and the penalty
  compounds per chained operator. Laziness, effect order, and per-iteration
  state are unchanged; the whole test suite passes as-is.
* **`sortBy` extracts each key exactly once** (decorate–sort–undecorate;
  previously the key extractor ran twice per comparison) and uses unboxed
  fast paths when every key is `double`, `int`, or `String`. `compareTo`
  semantics (NaN, `-0.0`) are identical on every path; ordering is
  unchanged.
* **`maxBy` / `minBy` cache the running best's key** — the key extractor now
  runs exactly once per element.
* **`sum` / `sumBy` / `average` accumulate unboxed**, switching from int to
  double accumulation at the first double value — bit-identical results to
  the previous boxed `num` fold on every input sequence.

Measured on the DartComparison benchmark suite (`benchmark/`, Apple M1 Max,
AOT): median fxdart/native time ratio improved from ~1.8× to ~1.5×, the
worst case from 18.4× to 5.9×, and four cases (`top-expenses`,
`top-merchants`, `unique-tags`, `price-drop-detection`) are now faster than
the hand-written native implementation.

## 0.7.0

### Added — Dart 3.10 dot shorthands for `Either`

* **`Either.left` / `Either.right`** — `const` redirecting factories on the
  sealed base type. They exist so dot shorthands resolve: wherever the
  context type is `Either`, you can now write `return .left(err)` /
  `return .right(value)` — in return positions, switch-expression arms,
  and `==` comparisons (`result == .right(3)`).

### Changed

* SDK floor raised from `>=3.3.0` to `>=3.10.4` (dot shorthands; also
  null-aware collection elements, repeatable `_` wildcards, digit
  separators). Requires a toolchain from Nov 2025 or later.
* `compactObject` internals: the explicit null check + `as V` cast is now a
  single null-aware map element (`e.key: ?e.value`). Behavior unchanged.

## 0.6.2

### Docs

* Version-agnostic wording across README, the docs site, and the agent
  skills: feature descriptions no longer name the release that introduced
  them (versions live here in the CHANGELOG).

## 0.6.1

### Docs

* README: added typed errors description

## 0.6.0

### Added — typed errors (the Kotlin Arrow 2.x approach, ported)

* **`Raise<E>` + builders** (`either`, `eitherAsync`, `nullable`,
  `nullableAsync`, `foldRaise`, `foldRaiseAsync`): write straight-line Dart
  inside a scope that can short-circuit with a *typed* error; `Either` appears
  only at the boundary. No `TaskEither`/`IO` wrapper tower — Dart's own
  `Future`/`throw` is the effect system, exactly as Arrow uses Kotlin's.
  Foreign-scope signals rethrow (nesting is safe), leaked scopes throw a
  descriptive `RaiseLeakedError`, and the signal is an `Error` so
  `on Exception` never swallows it.
* **Scope vocabulary** (`RaiseOps`): `bind`, `bindAll`, `ensure`,
  `ensureNotNull` (null-promoting), `recover`, `withError`.
* **`catching` / `catchingAsync`** and **`Either.catching` /
  `Either.catchingWith`** — exception boundaries that always rethrow the
  raise signal first.
* **`Either<L, R>`** (sealed `Left`/`Right`, exhaustive `switch`), with a
  curated Arrow 2.x method set: `fold`, `map`, `mapLeft`, `flatMap`, `swap`,
  `getOrNull`, `getOrElse`, `onLeft`/`onRight`, `recover`, `toEitherNel`.
* **`NonEmptyList<T>` / `Nel<T>`** — zero-cost extension type (needs SDK
  ≥ 3.3, hence the floor bump), the error carrier for accumulation.
* **Error accumulation** (the Arrow replacement for `Validated`):
  `r.accumulate` with lazily-detonating `Accumulated`s, `r.mapOrAccumulate`,
  `r.zipOrAccumulate2..5`, `r.bindNel`.
* **Pipeline integration**: `rights`, `lefts`, `separateEither`,
  `sequenceEither(Async)`, `mapOrAccumulate(Async)` as top-level ops and as
  `Fx`/`FxAsync` chain terminals — fail-slow concurrent validation rides the
  existing `concurrent(n)` back-channel.

* **New agent skill** (`skills/fxdart-typed-errors/`) teaching AI coding
  assistants the typed-error system — when to reach for `either` blocks vs
  plain Dart, accumulation recipes, fpdart migration mappings, and the
  safety pitfalls. The existing `fxdart-pipelines` skill cross-references it.

### Changed

* SDK floor raised from `>=3.0.0` to `>=3.3.0` (extension types).

## 0.5.4

### Docs

* README: new CTA badge linking to the **Dart vs FxDart** comparison site —
  50 side-by-side native-Dart vs fxdart examples with an honest verdict on each.

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
