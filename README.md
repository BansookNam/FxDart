<img src="https://raw.githubusercontent.com/BansookNam/FxDart/main/docs/assets/logo-web.png" alt="FxDart" width="380">

# fxdart

A functional programming library for Dart, ported from **[FxTS](https://github.com/marpple/FxTS)**.
Lazy evaluation, concurrent async iteration, and pipeline-style composition — the FxTS
programming model, rebuilt on Dart's type system.

[![Version](https://img.shields.io/pub/v/fxdart.svg?style=flat-square)](https://pub.dev/packages/fxdart)
[![codecov](https://codecov.io/gh/BansookNam/FxDart/branch/main/graph/badge.svg)](https://codecov.io/gh/BansookNam/FxDart)

```dart
// 6 requests of 1s complete in ~2s — not ~6s.
await fx(userIds).toAsync().map(fetchUser).concurrent(3).toList();
```

---

## 🚀 Try it in your browser

<a href="https://bansooknam.github.io/FxDart/">
  <img src="https://img.shields.io/badge/%F0%9F%93%9A%20FxDart%20101-Launch%20Interactive%20Docs%20%E2%86%92-6C63FF?style=for-the-badge&labelColor=2D2A6E" alt="Launch FxDart 101 — Interactive Docs" height="56">
</a>

<a href="https://bansooknam.github.io/FxDart/DailyLedger/">
  <img src="https://img.shields.io/badge/%F0%9F%93%92%20Daily%20Ledger-Try%20the%20Live%20Demo%20App%20%E2%86%92-00B894?style=for-the-badge&labelColor=006B54" alt="Try the Daily Ledger — Live Demo App" height="56">
</a>

<a href="https://bansooknam.github.io/FxDart/DartComparison/">
  <img src="https://img.shields.io/badge/%E2%9A%96%EF%B8%8F%20Dart%20vs%20FxDart-50%20Side--by--Side%20Examples%20%E2%86%92-0984E3?style=for-the-badge&labelColor=074B80" alt="Dart vs FxDart — 50 Side-by-Side Examples" height="56">
</a>

<a href="https://bansooknam.github.io/FxDart/RxDartComparison/">
  <img src="https://img.shields.io/badge/%E2%9A%A1%20RxDart%20vs%20FxDart-50%20Push--vs--Pull%20Examples%20%E2%86%92-E64980?style=for-the-badge&labelColor=8B1E4B" alt="RxDart vs FxDart — 50 Push-vs-Pull Examples" height="56">
</a>

**👆 Click any badge above.** Each one is a live, runnable site:

| | Site | What it is |
|---|---|---|
| 📚 | **FxDart 101** | A guided course with an in-browser playground for *every* function |
| 📒 | **Daily Ledger** | A full app built with fxdart, running live |
| ⚖️ | **Dart vs FxDart** | 50 problems solved both ways, with an honest verdict on each |
| ⚡ | **RxDart vs FxDart** | The same 50-example format vs RxDart — push streams vs pull pipelines, *including* the cases where RxDart is simply the right tool |

---

## 📖 Contents

[✨ Why fxdart?](#-why-fxdart) ·
[📦 Install](#-install) ·
[🤖 AI agent skills](#-ai-agent-skills) ·
[🛠️ Usage](#️-usage) ·
[📇 API overview](#-api-overview) ·
[🔀 Differences from FxTS](#-differences-from-fxts) ·
[🧪 Testing](#-testing) ·
[🙏 Acknowledgments](#-acknowledgments)

---

## ✨ Why fxdart?

### 🦥 Lazy evaluation

Operators build a pipeline and do **no work** until a terminal operator runs — so
`fx(hugeList).map(f).filter(g).take(3)` only ever computes 3 results.

### 🔀 Concurrency you can dial

[`concurrent(n)`](https://bansooknam.github.io/FxDart/tutorials/concurrent.html) evaluates the *upstream* chain `n` items at a time **while preserving
order** — turning six 1-second requests into a ~2-second batch with one method call.

### 🛡️ Type-safe pipelines

The [`fx()`](https://bansooknam.github.io/FxDart/tutorials/fx.html) chain keeps full static typing end to end. Sync operators are plain
functions over native `Iterable`s, so everything interops with ordinary Dart code.

### 🧠 One mental model for sync and async

The same operator names work on `Iterable` (sync) and [`FxAsyncIterable`](https://bansooknam.github.io/FxDart/tutorials/asyncVariants.html) (async),
with `Stream` bridges in both directions.

### 🎯 Typed errors

Kotlin Arrow 2.x's [`Raise`](https://bansooknam.github.io/FxDart/tutorials/raise.html)/[`Either`](https://bansooknam.github.io/FxDart/tutorials/either.html) approach, ported: straight-line [`either`](https://bansooknam.github.io/FxDart/tutorials/raise.html) blocks
instead of `flatMap` pyramids, error accumulation with [`NonEmptyList`](https://bansooknam.github.io/FxDart/tutorials/nonEmptyList.html), and validation
fused directly into the concurrent pipelines above.

### ⚡ A push side too, when time matters

Pull pipelines model *data over demand*; [`fxEvents()`](https://bansooknam.github.io/FxDart/tutorials/fxEvents.html) models *events over time* on
plain Dart `Stream`s — `debounce`, `throttle`, `sample`, `switchMap`, `combineLatest`
and friends — then hands you back to the typed pull world with `.pull()`.

### 🧊 Dart names work too

Every FxTS name that Dart's collections already have a word for is *also* callable by
that word: `where`, `expand`, `flattened`, `nonNulls`, `sorted`, `indexed`,
`firstWhereOrNull`. No dialect to learn before you can read the code.

---

## 📦 Install

See the [installation guide](https://pub.dev/packages/fxdart/install) on pub.dev for the latest version.

---

## 🤖 AI agent skills

fxdart ships two [Agent Skills](https://agentskills.io) that teach AI coding
assistants — Claude Code, Codex, Devin, Antigravity, OpenCode, pi, and
anything reading `.agents/skills/` — **when** and **how** to use fxdart:

| Skill | Covers |
|---|---|
| 🔗 `skills/fxdart-pipelines/` | Collections, concurrent Futures, Streams, and complex flow logic |
| 🎯 `skills/fxdart-typed-errors/` | The typed-error system: `either` blocks, error accumulation, Either-aware pipeline validation |

**Option A** — the community [`skills`](https://pub.dev/packages/skills) CLI (auto-detects your IDE/agent):

```sh
dart pub global activate skills
skills get fxdart
```

**Option B** — fxdart's built-in zero-dependency installer:

```sh
# From a project that depends on fxdart:
dart run fxdart:install_skills              # auto-detects agent dirs in the project
dart run fxdart:install_skills claude codex # or name agents explicitly
dart run fxdart:install_skills all --global # per-user dirs (~/.claude/skills, ~/.agents/skills, ...)

# Or standalone:
dart pub global activate fxdart
fxdart_skills --global claude
```

**Supported agents:**

| Agent | Install dir |
|---|---|
| `claude` | `.claude/skills/` |
| `codex` / `antigravity` / `generic` | `.agents/skills/` |
| `devin` | `.devin/skills/` |
| `opencode` | `.opencode/skills/` |
| `pi` | `.pi/skills/` · global `~/.pi/agent/skills/` |

> 💡 `--list` shows install status · `--remove` uninstalls.

---

## 🛠️ Usage

### 🔗 Sync pipelines

Sync operators are data-first functions over lazy `Iterable`s; the [`fx()`](https://bansooknam.github.io/FxDart/tutorials/fx.html) chain
composes them with full type inference:

```dart
import 'package:fxdart/fxdart.dart';

fx([1, 2, 3, 4, 5])
    .map((a) => a + 10)
    .filter((a) => a % 2 == 0)
    .toList(); // [12, 14]

// Equivalent with top-level functions:
toList(filter((a) => a % 2 == 0, map((a) => a + 10, [1, 2, 3, 4, 5])));

// Laziness: only 3 squares are ever computed.
fx(range(1, 1000000)).map((a) => a * a).take(3).toList(); // [1, 4, 9]
```

Every entry point has a getter twin — `.fx` on an `Iterable`, `FxAsyncIterable` or
`Stream`, `.fxAsync` on an iterable of futures, `.fxEvents` on a `Stream` — which
builds the same chain and reads left to right when the source is itself a call:
`orders.where(isPaid).fx.groupBy(...)`. The docs use `fx()` throughout; see the
[`fx()` tutorial](https://bansooknam.github.io/FxDart/tutorials/fx.html) for when
each spelling reads better.

### ⏳ Async pipelines

Async operators work on [`FxAsyncIterable<T>`](https://bansooknam.github.io/FxDart/tutorials/asyncVariants.html) — a pull-based protocol ported from
FxTS's `AsyncIterable` handling. Lift values **in** with [`toAsync`](https://bansooknam.github.io/FxDart/tutorials/toAsync.html) / [`fromStream`](https://bansooknam.github.io/FxDart/tutorials/streams.html)
(or `.toAsync()` on a chain), and **out** with [`.toList()`](https://bansooknam.github.io/FxDart/tutorials/toList.html) / [`.toStream()`](https://bansooknam.github.io/FxDart/tutorials/streams.html):

```dart
await fx([1, 2, 3, 4])
    .toAsync()
    .map((a) async => a + 10) // callbacks may be async
    .filter((a) => a % 2 == 0)
    .toList(); // [12, 14]

// Streams bridge both ways.
await fxStream(Stream.fromIterable([1, 2, 3])).map((a) => a * 2).toList();
```

### ⚡ Concurrency

[`concurrent(n)`](https://bansooknam.github.io/FxDart/tutorials/concurrent.html) is FxTS's signature feature, ported faithfully: a concurrency
marker travels ***backwards*** through the pipeline's iterator protocol, so the
upstream chain evaluates `n` items at once while results stay in order.

```dart
// 6 requests of 1s complete in ~2s instead of ~6s.
await fx([1, 2, 3, 4, 5, 6])
    .toAsync()
    .map((id) => fetchUser(id))
    .concurrent(3)
    .toList();
```

- 🥇 [`concurrentPool(n)`](https://bansooknam.github.io/FxDart/tutorials/concurrentPool.html) — the completion-order variant: faster first results, no ordering guarantee.

> ℹ️ This back-channel protocol is why fxdart has its own `FxAsyncIterable` instead of
> building on push-based `Stream`s, which cannot express it.

### 📡 Events (the push side)

Some problems really are *events over time*, not *data over demand*. [`fxEvents()`](https://bansooknam.github.io/FxDart/tutorials/fxEvents.html)
wraps a plain Dart `Stream` in a chainable, Rx-flavoured API — a thin wrapper, never
an extension, so it coexists with rxdart without member conflicts:

```dart
final results = await fxEvents(keystrokes)
    .debounce(const Duration(milliseconds: 160))
    .switchMap((q) => search(q).asStream()) // cancels the superseded search
    .toList();

// Cross back into the typed pull world at any point:
await fxEvents(ticks).sampleOn(clock).pull().map(load).concurrent(4).toList();
```

[`LiveValue`](https://bansooknam.github.io/FxDart/tutorials/liveValue.html) holds a current-value stream, and [`FxSubscriptions`](https://bansooknam.github.io/FxDart/tutorials/fxSubscriptions.html) cancels a bag of
subscriptions together. See [⚡ RxDart vs FxDart](https://bansooknam.github.io/FxDart/RxDartComparison/)
for 50 worked examples — including the cases where RxDart is the better fit.

### 🎯 Typed errors

The [`either`](https://bansooknam.github.io/FxDart/tutorials/raise.html) builder runs a block in a [`Raise<E>`](https://bansooknam.github.io/FxDart/tutorials/raise.html) scope: each `r.bind` unwraps
a success or short-circuits the whole block with a **typed** failure — the
Kotlin Arrow 2.x model, ported (no `TaskEither`/`IO` wrapper tower, no
`Option`; Dart's `T?` plus the `nullable` builder covers absence):

```dart
Either<String, int> parsePort(String raw) => either((r) {
  final n = r.ensureNotNull(int.tryParse(raw), () => '"$raw" is not a number');
  r.ensure(n > 0 && n < 65536, () => '$n is out of range');
  return n;
});

// Validation accumulates EVERY failure into a NonEmptyList, not just the first:
final user = either<Nel<String>, User>((r) => r.zipOrAccumulate2(
    (r) => validateName(r, input), (r) => validateAge(r, input), User.new));

// And it fuses with pipelines — fail-slow, 8 records in flight, order kept:
final result = await fxStream(records)
    .mapOrAccumulate<String, User>((r, rec) => parseUser(r, rec), concurrency: 8);
```

📚 **Every subject has a detailed tutorial with an in-browser playground:**

[🗺️ overview](https://bansooknam.github.io/FxDart/tutorials/typedErrors.html) ·
[↔️ `Either`](https://bansooknam.github.io/FxDart/tutorials/either.html) ·
[🎬 `either` & the `Raise` scope](https://bansooknam.github.io/FxDart/tutorials/raise.html) ·
[❓ `nullable`](https://bansooknam.github.io/FxDart/tutorials/nullable.html) ·
[📋 `NonEmptyList`](https://bansooknam.github.io/FxDart/tutorials/nonEmptyList.html) ·
[➕ accumulation](https://bansooknam.github.io/FxDart/tutorials/accumulate.html) ·
[🔗 `Either` × pipelines](https://bansooknam.github.io/FxDart/tutorials/eitherPipelines.html)

---

## 📇 API overview

| | Category | Functions |
|---|---|---|
| 🌱 | **Generate** | [`range`](https://bansooknam.github.io/FxDart/tutorials/range.html), [`repeat`](https://bansooknam.github.io/FxDart/tutorials/repeat.html), [`cycle`](https://bansooknam.github.io/FxDart/tutorials/cycle.html), [`entries`](https://bansooknam.github.io/FxDart/tutorials/entries.html), [`keys`](https://bansooknam.github.io/FxDart/tutorials/keys.html), [`values`](https://bansooknam.github.io/FxDart/tutorials/values.html) |
| 🔄 | **Transform** (lazy) | [`map`](https://bansooknam.github.io/FxDart/tutorials/map.html), [`mapWithIndex`](https://bansooknam.github.io/FxDart/tutorials/withIndex.html), [`mapEffect`](https://bansooknam.github.io/FxDart/tutorials/mapEffect.html), [`flatMap`](https://bansooknam.github.io/FxDart/tutorials/flatMap.html), [`flatMapWithIndex`](https://bansooknam.github.io/FxDart/tutorials/withIndex.html), [`flat`](https://bansooknam.github.io/FxDart/tutorials/flat.html), [`scan`](https://bansooknam.github.io/FxDart/tutorials/scan.html), `scan1`, [`peek`](https://bansooknam.github.io/FxDart/tutorials/peek.html), [`pluck`](https://bansooknam.github.io/FxDart/tutorials/pluck.html), [`attach`](https://bansooknam.github.io/FxDart/tutorials/attach.html), [`using`](https://bansooknam.github.io/FxDart/tutorials/using.html) |
| 🔍 | **Filter** (lazy) | [`filter`](https://bansooknam.github.io/FxDart/tutorials/filter.html), [`filterWithIndex`](https://bansooknam.github.io/FxDart/tutorials/withIndex.html), [`reject`](https://bansooknam.github.io/FxDart/tutorials/reject.html), [`compact`](https://bansooknam.github.io/FxDart/tutorials/compact.html), [`uniq`](https://bansooknam.github.io/FxDart/tutorials/uniq.html), [`uniqBy`](https://bansooknam.github.io/FxDart/tutorials/uniqBy.html), [`uniqAdjacent`](https://bansooknam.github.io/FxDart/tutorials/uniqAdjacent.html), [`uniqAdjacentBy`](https://bansooknam.github.io/FxDart/tutorials/uniqAdjacent.html), [`takeUniqBy`](https://bansooknam.github.io/FxDart/tutorials/takeUniqBy.html) *(strict; `filter().uniqBy().take()` in one inlinable call)*, [`difference`](https://bansooknam.github.io/FxDart/tutorials/difference.html), [`differenceBy`](https://bansooknam.github.io/FxDart/tutorials/differenceBy.html), [`intersection`](https://bansooknam.github.io/FxDart/tutorials/intersection.html), [`intersectionBy`](https://bansooknam.github.io/FxDart/tutorials/intersectionBy.html), [`compress`](https://bansooknam.github.io/FxDart/tutorials/compress.html) |
| ✂️ | **Slice** (lazy) | [`take`](https://bansooknam.github.io/FxDart/tutorials/take.html), [`takeRight`](https://bansooknam.github.io/FxDart/tutorials/takeRight.html), [`takeWhile`](https://bansooknam.github.io/FxDart/tutorials/takeWhile.html), [`takeWhileRight`](https://bansooknam.github.io/FxDart/tutorials/takeWhileRight.html), [`takeUntilInclusive`](https://bansooknam.github.io/FxDart/tutorials/takeUntilInclusive.html), [`drop`](https://bansooknam.github.io/FxDart/tutorials/drop.html), [`dropRight`](https://bansooknam.github.io/FxDart/tutorials/dropRight.html), [`dropWhile`](https://bansooknam.github.io/FxDart/tutorials/dropWhile.html), [`dropWhileRight`](https://bansooknam.github.io/FxDart/tutorials/dropWhileRight.html), [`dropUntil`](https://bansooknam.github.io/FxDart/tutorials/dropUntil.html), [`slice`](https://bansooknam.github.io/FxDart/tutorials/slice.html), [`chunk`](https://bansooknam.github.io/FxDart/tutorials/chunk.html), [`windowed`](https://bansooknam.github.io/FxDart/tutorials/windowed.html), [`pairwise`](https://bansooknam.github.io/FxDart/tutorials/pairwise.html), [`split`](https://bansooknam.github.io/FxDart/tutorials/split.html) |
| 🧩 | **Combine** (lazy) | [`append`](https://bansooknam.github.io/FxDart/tutorials/append.html), [`prepend`](https://bansooknam.github.io/FxDart/tutorials/prepend.html), [`concat`](https://bansooknam.github.io/FxDart/tutorials/concat.html), [`zip`](https://bansooknam.github.io/FxDart/tutorials/zip.html), [`zip3`](https://bansooknam.github.io/FxDart/tutorials/zip3.html), [`zipWith`](https://bansooknam.github.io/FxDart/tutorials/zipWith.html), [`zipWithIndex`](https://bansooknam.github.io/FxDart/tutorials/zipWithIndex.html), [`transpose`](https://bansooknam.github.io/FxDart/tutorials/transpose.html), [`reverse`](https://bansooknam.github.io/FxDart/tutorials/reverse.html), [`fork`](https://bansooknam.github.io/FxDart/tutorials/fork.html), [`tee`](https://bansooknam.github.io/FxDart/tutorials/tee.html), [`tee3`](https://bansooknam.github.io/FxDart/tutorials/tee3.html) |
| 📊 | **Aggregate** | [`reduce`](https://bansooknam.github.io/FxDart/tutorials/reduce.html), [`fold`](https://bansooknam.github.io/FxDart/tutorials/fold.html), [`foldWithIndex`](https://bansooknam.github.io/FxDart/tutorials/withIndex.html), [`foldRight`](https://bansooknam.github.io/FxDart/tutorials/foldRight.html), [`foldRightWithIndex`](https://bansooknam.github.io/FxDart/tutorials/withIndex.html), [`reduceLazy`](https://bansooknam.github.io/FxDart/tutorials/reduceLazy.html), [`toList`](https://bansooknam.github.io/FxDart/tutorials/toList.html), [`sum`](https://bansooknam.github.io/FxDart/tutorials/sum.html), [`sumBy`](https://bansooknam.github.io/FxDart/tutorials/sumBy.html), `sumStrings`, [`average`](https://bansooknam.github.io/FxDart/tutorials/average.html), [`averageBy`](https://bansooknam.github.io/FxDart/tutorials/averageBy.html), [`min`](https://bansooknam.github.io/FxDart/tutorials/min.html), [`minBy`](https://bansooknam.github.io/FxDart/tutorials/minBy.html), [`max`](https://bansooknam.github.io/FxDart/tutorials/max.html), [`maxBy`](https://bansooknam.github.io/FxDart/tutorials/maxBy.html), [`size`](https://bansooknam.github.io/FxDart/tutorials/size.html), [`join`](https://bansooknam.github.io/FxDart/tutorials/join.html), [`groupBy`](https://bansooknam.github.io/FxDart/tutorials/groupBy.html), [`indexBy`](https://bansooknam.github.io/FxDart/tutorials/indexBy.html), [`countBy`](https://bansooknam.github.io/FxDart/tutorials/countBy.html), [`sort`](https://bansooknam.github.io/FxDart/tutorials/sort.html), [`sortBy`](https://bansooknam.github.io/FxDart/tutorials/sortBy.html), [`sortByDesc`](https://bansooknam.github.io/FxDart/tutorials/sortByDesc.html), `toSorted`, [`partition`](https://bansooknam.github.io/FxDart/tutorials/partition.html), [`each`](https://bansooknam.github.io/FxDart/tutorials/each.html), [`consume`](https://bansooknam.github.io/FxDart/tutorials/consume.html) |
| 🎯 | **Access** | [`head`](https://bansooknam.github.io/FxDart/tutorials/head.html), [`last`](https://bansooknam.github.io/FxDart/tutorials/last.html), [`nth`](https://bansooknam.github.io/FxDart/tutorials/nth.html), [`find`](https://bansooknam.github.io/FxDart/tutorials/find.html), [`findIndex`](https://bansooknam.github.io/FxDart/tutorials/findIndex.html), [`includes`](https://bansooknam.github.io/FxDart/tutorials/includes.html), [`isEmpty`](https://bansooknam.github.io/FxDart/tutorials/isEmpty.html), [`defaultIfEmpty`](https://bansooknam.github.io/FxDart/tutorials/ifEmpty.html), [`ifEmpty`](https://bansooknam.github.io/FxDart/tutorials/ifEmpty.html), [`every`](https://bansooknam.github.io/FxDart/tutorials/every.html), [`some`](https://bansooknam.github.io/FxDart/tutorials/some.html) |
| 🗂️ | **Object** (Map) | [`omit`](https://bansooknam.github.io/FxDart/tutorials/omit.html), [`pick`](https://bansooknam.github.io/FxDart/tutorials/pick.html), [`omitBy`](https://bansooknam.github.io/FxDart/tutorials/omitBy.html), [`pickBy`](https://bansooknam.github.io/FxDart/tutorials/pickBy.html), [`prop`](https://bansooknam.github.io/FxDart/tutorials/prop.html), [`props`](https://bansooknam.github.io/FxDart/tutorials/props.html), [`evolve`](https://bansooknam.github.io/FxDart/tutorials/evolve.html), [`fromEntries`](https://bansooknam.github.io/FxDart/tutorials/fromEntries.html), `mapKeys`, [`mapValues`](https://bansooknam.github.io/FxDart/tutorials/mapValues.html), `mapEntries`, [`compactObject`](https://bansooknam.github.io/FxDart/tutorials/compactObject.html), [`resolveProps`](https://bansooknam.github.io/FxDart/tutorials/resolveProps.html), [`isMatch`](https://bansooknam.github.io/FxDart/tutorials/isMatch.html), [`matches`](https://bansooknam.github.io/FxDart/tutorials/matches.html) |
| 🧮 | **Function** | [`pipe`](https://bansooknam.github.io/FxDart/tutorials/pipe.html), [`pipe1`](https://bansooknam.github.io/FxDart/tutorials/pipe1.html), `pipeLazy`, [`identity`](https://bansooknam.github.io/FxDart/tutorials/identity.html), [`always`](https://bansooknam.github.io/FxDart/tutorials/always.html), `noop`, [`tap`](https://bansooknam.github.io/FxDart/tutorials/tap.html), [`apply`](https://bansooknam.github.io/FxDart/tutorials/apply.html), [`juxt`](https://bansooknam.github.io/FxDart/tutorials/juxt.html), [`memoize`](https://bansooknam.github.io/FxDart/tutorials/memoize.html), [`negate`](https://bansooknam.github.io/FxDart/tutorials/negate.html), [`not`](https://bansooknam.github.io/FxDart/tutorials/not.html), [`when`](https://bansooknam.github.io/FxDart/tutorials/when.html), [`unless`](https://bansooknam.github.io/FxDart/tutorials/unless.html), [`throwError`](https://bansooknam.github.io/FxDart/tutorials/throwError.html), [`throwIf`](https://bansooknam.github.io/FxDart/tutorials/throwIf.html), [`cases`](https://bansooknam.github.io/FxDart/tutorials/cases.html), [`add`](https://bansooknam.github.io/FxDart/tutorials/add.html), `gt`, `gte`, `lt`, `lte`, [`delay`](https://bansooknam.github.io/FxDart/tutorials/delay.html), `sleep`, [`unicodeToList`](https://bansooknam.github.io/FxDart/tutorials/unicodeToList.html), [`.curried`](https://bansooknam.github.io/FxDart/tutorials/curried.html)/[`.uncurried`](https://bansooknam.github.io/FxDart/tutorials/curried.html) (extension getters, arity 2–5) |
| ✅ | **Predicates** | [`isNull`](https://bansooknam.github.io/FxDart/tutorials/predicates.html), [`isNotNull`](https://bansooknam.github.io/FxDart/tutorials/predicates.html), [`isNil`](https://bansooknam.github.io/FxDart/tutorials/predicates.html), [`isBoolean`](https://bansooknam.github.io/FxDart/tutorials/predicates.html)/[`isBool`](https://bansooknam.github.io/FxDart/tutorials/predicates.html), [`isNumber`](https://bansooknam.github.io/FxDart/tutorials/predicates.html)/[`isNum`](https://bansooknam.github.io/FxDart/tutorials/predicates.html), [`isString`](https://bansooknam.github.io/FxDart/tutorials/predicates.html), [`isDate`](https://bansooknam.github.io/FxDart/tutorials/predicates.html)/[`isDateTime`](https://bansooknam.github.io/FxDart/tutorials/predicates.html), [`isList`](https://bansooknam.github.io/FxDart/tutorials/predicates.html), [`isMap`](https://bansooknam.github.io/FxDart/tutorials/predicates.html) |
| 🧊 | **Dart-idiomatic aliases** | Every FxTS name that Dart's own collections already have a word for is *also* callable by that word: [`where`](https://bansooknam.github.io/FxDart/tutorials/filter.html), [`whereNot`](https://bansooknam.github.io/FxDart/tutorials/reject.html), [`expand`](https://bansooknam.github.io/FxDart/tutorials/flatMap.html), [`flattened`](https://bansooknam.github.io/FxDart/tutorials/flat.html), [`nonNulls`](https://bansooknam.github.io/FxDart/tutorials/compact.html), [`distinct`](https://bansooknam.github.io/FxDart/tutorials/uniq.html), [`distinctBy`](https://bansooknam.github.io/FxDart/tutorials/uniqBy.html), [`sorted`](https://bansooknam.github.io/FxDart/tutorials/sort.html), [`indexed`](https://bansooknam.github.io/FxDart/tutorials/withIndex.html), [`skip`](https://bansooknam.github.io/FxDart/tutorials/drop.html), [`skipWhile`](https://bansooknam.github.io/FxDart/tutorials/dropWhile.html), [`takeLast`](https://bansooknam.github.io/FxDart/tutorials/takeRight.html), [`count`](https://bansooknam.github.io/FxDart/tutorials/size.html), [`countWhere`](https://bansooknam.github.io/FxDart/tutorials/countWhere.html), [`any`](https://bansooknam.github.io/FxDart/tutorials/some.html), [`forEach`](https://bansooknam.github.io/FxDart/tutorials/each.html), [`firstOrNull`](https://bansooknam.github.io/FxDart/tutorials/head.html), [`lastOrNull`](https://bansooknam.github.io/FxDart/tutorials/last.html), [`firstWhereOrNull`](https://bansooknam.github.io/FxDart/tutorials/find.html), [`elementAtOrNull`](https://bansooknam.github.io/FxDart/tutorials/nth.html), [`indexWhere`](https://bansooknam.github.io/FxDart/tutorials/findIndex.html) |
| ⏳ | **Async** | Every lazy/aggregate operator has an `*Async` twin ([`mapAsync`](https://bansooknam.github.io/FxDart/tutorials/asyncVariants.html), [`toListAsync`](https://bansooknam.github.io/FxDart/tutorials/asyncVariants.html), …), plus [`toAsync`](https://bansooknam.github.io/FxDart/tutorials/toAsync.html), [`fromStream`](https://bansooknam.github.io/FxDart/tutorials/streams.html), [`mapConcurrent`](https://bansooknam.github.io/FxDart/tutorials/mapConcurrent.html), [`concurrentAsync`](https://bansooknam.github.io/FxDart/tutorials/concurrent.html), [`concurrentPoolAsync`](https://bansooknam.github.io/FxDart/tutorials/concurrentPool.html), [`asyncEmpty`](https://bansooknam.github.io/FxDart/tutorials/asyncVariants.html) |
| ⚡ | **Events** (push) | [`fxEvents()`](https://bansooknam.github.io/FxDart/tutorials/fxEvents.html) / [`FxEvents`](https://bansooknam.github.io/FxDart/tutorials/fxEvents.html) — an Rx-flavoured chain over plain `Stream`s: [`debounce`](https://bansooknam.github.io/FxDart/tutorials/debounce.html), [`throttle`](https://bansooknam.github.io/FxDart/tutorials/throttle.html), [`sample`](https://bansooknam.github.io/FxDart/tutorials/sampleOn.html), [`sampleOn`](https://bansooknam.github.io/FxDart/tutorials/sampleOn.html), [`delay`](https://bansooknam.github.io/FxDart/tutorials/delay.html), [`spaceBy`](https://bansooknam.github.io/FxDart/tutorials/spaceBy.html), [`startWith`](https://bansooknam.github.io/FxDart/tutorials/fxEvents.html), `startOn`, [`stopOn`](https://bansooknam.github.io/FxDart/tutorials/stopOn.html), [`chunk`](https://bansooknam.github.io/FxDart/tutorials/chunk.html), `chunkEvery`, [`chunkOn`](https://bansooknam.github.io/FxDart/tutorials/chunkOn.html), [`switchMap`](https://bansooknam.github.io/FxDart/tutorials/switchMap.html), [`mergeMap`](https://bansooknam.github.io/FxDart/tutorials/mergeMap.html), `concatMap`, `exhaustMap`, `asyncMap`, [`merge`](https://bansooknam.github.io/FxDart/tutorials/fxEvents.html), [`mergeWith`](https://bansooknam.github.io/FxDart/tutorials/fxEvents.html), [`race`](https://bansooknam.github.io/FxDart/tutorials/race.html), [`raceWith`](https://bansooknam.github.io/FxDart/tutorials/race.html), [`zip`](https://bansooknam.github.io/FxDart/tutorials/zip.html), [`zipWith`](https://bansooknam.github.io/FxDart/tutorials/zipWith.html), [`combineLatest`](https://bansooknam.github.io/FxDart/tutorials/combineLatest.html), [`combineLatestAll`](https://bansooknam.github.io/FxDart/tutorials/combineLatest.html), [`withLatestFrom`](https://bansooknam.github.io/FxDart/tutorials/withLatestFrom.html), [`waitAll`](https://bansooknam.github.io/FxDart/tutorials/waitAll.html), [`share`](https://bansooknam.github.io/FxDart/tutorials/share.html), [`retry`](https://bansooknam.github.io/FxDart/tutorials/retry.html), [`onErrorResume`](https://bansooknam.github.io/FxDart/tutorials/onErrorResume.html), `onErrorReturn`, `scan`, `uniqAdjacent`, `uniqAdjacentBy`, `pairwise`, `take`, `drop`/`skip`, `head`/`firstOrNull`, `pull` (back into the typed pull world). Plus [`LiveValue`](https://bansooknam.github.io/FxDart/tutorials/liveValue.html) and [`FxSubscriptions`](https://bansooknam.github.io/FxDart/tutorials/fxSubscriptions.html) |
| 🎯 | **Typed errors** | [`Either`](https://bansooknam.github.io/FxDart/tutorials/either.html) ([`Left`](https://bansooknam.github.io/FxDart/tutorials/either.html)/[`Right`](https://bansooknam.github.io/FxDart/tutorials/either.html), [`fold`](https://bansooknam.github.io/FxDart/tutorials/eitherCombinators.html), [`map`](https://bansooknam.github.io/FxDart/tutorials/eitherCombinators.html), [`flatMap`](https://bansooknam.github.io/FxDart/tutorials/eitherCombinators.html), [`recover`](https://bansooknam.github.io/FxDart/tutorials/eitherCombinators.html), `Either.catching`, [`toEitherNel`](https://bansooknam.github.io/FxDart/tutorials/eitherCombinators.html)), [`either`](https://bansooknam.github.io/FxDart/tutorials/either.html)/[`eitherAsync`](https://bansooknam.github.io/FxDart/tutorials/either.html), [`eitherCatching`](https://bansooknam.github.io/FxDart/tutorials/raise.html), [`nullable`](https://bansooknam.github.io/FxDart/tutorials/nullable.html)/[`nullableAsync`](https://bansooknam.github.io/FxDart/tutorials/nullable.html), [`catching`](https://bansooknam.github.io/FxDart/tutorials/raise.html), [`foldRaise`](https://bansooknam.github.io/FxDart/tutorials/raise.html), [`NonEmptyList`](https://bansooknam.github.io/FxDart/tutorials/nonEmptyList.html)/[`Nel`](https://bansooknam.github.io/FxDart/tutorials/nonEmptyList.html); in a [`Raise`](https://bansooknam.github.io/FxDart/tutorials/raise.html) scope: `r.bind`, `r.bindNel`, `r.ensure`, `r.ensureNotNull`, `r.accumulate`, `r.zipOrAccumulate2..5`, `r.mapOrAccumulate`; free functions [`rights`](https://bansooknam.github.io/FxDart/tutorials/eitherPipelines.html), [`lefts`](https://bansooknam.github.io/FxDart/tutorials/eitherPipelines.html), [`separateEither`](https://bansooknam.github.io/FxDart/tutorials/eitherPipelines.html), [`sequenceEither`](https://bansooknam.github.io/FxDart/tutorials/eitherPipelines.html), [`mapOrAccumulate`](https://bansooknam.github.io/FxDart/tutorials/accumulate.html), [`flattenOrAccumulate`](https://bansooknam.github.io/FxDart/tutorials/accumulate.html); chain terminals [`rights()`](https://bansooknam.github.io/FxDart/tutorials/eitherPipelines.html), [`lefts()`](https://bansooknam.github.io/FxDart/tutorials/eitherPipelines.html), [`separated()`](https://bansooknam.github.io/FxDart/tutorials/eitherPipelines.html), [`sequence()`](https://bansooknam.github.io/FxDart/tutorials/eitherPipelines.html), [`mapOrAccumulate()`](https://bansooknam.github.io/FxDart/tutorials/accumulate.html) |
| 🧰 | **Util** | [`debounce`](https://bansooknam.github.io/FxDart/tutorials/debounce.html), [`throttle`](https://bansooknam.github.io/FxDart/tutorials/throttle.html), [`retry`](https://bansooknam.github.io/FxDart/tutorials/retry.html), [`shuffle`](https://bansooknam.github.io/FxDart/tutorials/shuffle.html), [`createSeededRandom`](https://bansooknam.github.io/FxDart/tutorials/createSeededRandom.html) |
| ⚙️ | **Config** | `FxDart.config` / `FxConfig` — process-wide switches, read when a pipeline *starts iterating* |
| ⛓️ | **Chains** | [`fx()`](https://bansooknam.github.io/FxDart/tutorials/fx.html) (sync, extends `Iterable`; `.fx` / `.fxAsync` getter twins), [`fxAsync()`](https://bansooknam.github.io/FxDart/tutorials/asyncVariants.html), [`fxStream()`](https://bansooknam.github.io/FxDart/tutorials/streams.html), [`fxEvents()`](https://bansooknam.github.io/FxDart/tutorials/fxEvents.html); `Fx<num>`/`FxAsync<num>` gain [`sum`](https://bansooknam.github.io/FxDart/tutorials/sum.html)/[`average`](https://bansooknam.github.io/FxDart/tutorials/average.html)/[`min`](https://bansooknam.github.io/FxDart/tutorials/min.html)/[`max`](https://bansooknam.github.io/FxDart/tutorials/max.html) |

---

## 🔀 Differences from FxTS

Dart has no function overloads, variadic generics, or conditional types, so some
APIs **deliberately** deviate:

| | FxTS | fxdart |
|---|---|---|
| 🍛 | curried data-last (`map(f)` inside `pipe`) | `fx()` chain (typed) or dynamic `pipe(value, [closures])` |
| 🔄 | one `map` dispatching sync/async | `map` (Iterable) / `mapAsync` (FxAsyncIterable); chains use plain names |
| 📊 | `reduce(f, seed, iter)` overload | `fold(seed, f, iter)` (unseeded `reduce(f, iter)` unchanged) |
| 📦 | tuples (`zip`, `entries`, `partition`) | Dart records: `(A, B)` |
| 🗂️ | TS objects (`omit`, `pick`, `evolve`, …) | `Map`-based equivalents |
| ❓ | `undefined` | `null` (`head`/`find`/`nth` return `T?`) |
| 📋 | `toArray` / `toArrayAsync` | `toList` / `toListAsync` (Dart has no array type) |
| ⏳ | `AsyncIterable` / `for await` | `FxAsyncIterable` + `toStream()` / `fromStream()` bridges |
| 🎛️ | variadic `zip`/`juxt`/`cases` | fixed arities (`zip`/`zip3`) or list/record parameters |
| 🍛 | `curry(f)` | `.curried` / `.uncurried` extension getters — see [WHY_CURRIED.md](WHY_CURRIED.md) |

### 🍛 Why `.curried` instead of `curry`?

FxTS's `curry` needs arity reflection and recursive conditional types, which
Dart lacks — so fxdart curries through **[per-arity extensions](https://bansooknam.github.io/FxDart/tutorials/curried.html)** instead, resolved
statically and fully typed:

```dart
int add(int a, int b) => a + b;
final addOne = add.curried(1); // int Function(int)
fx([1, 2, 3]).map(addOne).toList(); // [2, 3, 4]
```

📖 [**WHY_CURRIED.md**](WHY_CURRIED.md) tells the full design story: why the direct
port is impossible, how static extension resolution stands in for overloading,
why the getter is named `curried`, and how the same port-the-meaning
philosophy resolves the other unportable APIs.

> ⚠️ Those APIs keep `@Deprecated` stubs (`curry`, `isUndefined`, `isArray`,
> `isObject`, `takeUntil`) so migrating code gets analyzer guidance instead of
> silent breakage.

---

## 🧪 Testing

The FxTS spec suite has been ported alongside the library, and grown well past it:
**1,800+ tests** across 170 files, covering sync/async behavior, error
propagation, laziness, typed errors, the events layer, and concurrency timing
across every operator.

```sh
dart test
```

📈 Coverage is measured on every push and pull request and reported to
[Codecov](https://app.codecov.io/gh/BansookNam/FxDart). To reproduce locally:

```sh
dart run coverage:test_with_coverage   # writes coverage/lcov.info
```

---

## 📊 Benchmarks

Two suites back the comparison sites linked at the top:
[Dart vs FxDart](https://bansooknam.github.io/FxDart/DartComparison/) (53 cases)
and [RxDart vs FxDart](https://bansooknam.github.io/FxDart/RxDartComparison/)
(41 cases). Every case is AOT-compiled (`dart compile exe`) and each side runs
as a fresh process, interleaved, so thermal drift lands on both equally.
`./benchmark.sh` is the entry point.

### Which command, when

**1 · While developing — "did my change move this case?"**

```sh
./benchmark.sh --ab ledger-diff               # against HEAD
./benchmark.sh --ab --ref v0.8.5 ledger-diff  # against a tag or commit
```

The one you will reach for most. It builds both variants of `lib/` and runs
them **interleaved in one session**, so drift hits both sides. The `native`
side is the control: it links no fxdart code, so a library-only change must
leave it identical — if it moved, the row is void.

It runs 20 rounds rather than `ab_bench`'s default 12, because 12 is not
enough. Four readings in the 0.8.6 pass looked like solid ±3-4% results
*against clean controls* and every one of them was gone at 20.

**2 · Before merging or releasing — "did anything regress?"**

```sh
./benchmark.sh --ab --all
```

The same instrument across every case, as a gate: if a control drifts past its
limit the run fails rather than printing a number. `--all` exists because
without it every slug had to be typed by hand, which made "nothing regressed
by 3%" a claim rather than a check. Give it an idle machine — it takes a
while.

**3 · Publishing — updating the numbers the site shows**

```sh
./benchmark.sh --docs        # sweep, regenerate the report, rebuild docs/
./benchmark.sh --docs --rx   # the RxDart family
```

The only output fit to publish: native and fxdart are measured in the same
session, so each row's ratio is sound. It writes
`benchmark/results/results.json` (the bar charts), `SUMMARY.md`, and
`perf_ratio_report.md` — every case ordered slowest to fastest. The RxDart
family writes `results-rx.json` and `SUMMARY-RX.md`; its pages carry bars but
no ranking table, so there is no report to regenerate there.

Skip `--docs` and the site keeps showing the old numbers. Skip the report
regeneration — which is why this mode always does it for you — and
`results.json` and the report drift apart silently, which has happened, and
surfaced months later looking like a regression that had just landed.

### ⚠️ Reading the numbers

**Do not compare two sweeps to judge a change.** Cross-run noise is about 5%,
and the proof is built in: the `native` side must be byte-identical across a
library-only change, yet its measured cross-run delta is a median −2.1%,
ranging −27% to +4%. Judge changes with 1, publish with 3.

`--smoke` is for "does this still run" — one un-warmed iteration, and the
script restores `results.json` afterwards precisely so those numbers cannot
leak into anything.

Two checks cost seconds and are worth running freely:

```sh
./benchmark.sh --verify   # is the ratio report in step with results.json?
./benchmark.sh --check    # do the cases still match their published examples?
```

Adding or changing a case? `benchmark/AUTHORING.md` has the rules — the first
being that a case must measure the same pipeline its published example shows,
which CI enforces.

---

## 🙏 Acknowledgments

Great thanks to **Indong Yoo**, CTO of [Marpple](https://www.marpple.com), the
creator of [FxTS](https://github.com/marpple/FxTS) (and FxJS before it), whose
functional programming model — lazy iteration with first-class, order-preserving
concurrency — this library ports to Dart. All core ideas, operator semantics,
and the original test suite come from the
[marpple/FxTS](https://github.com/marpple/FxTS) repository.

---

## 👤 Author

**Bansook Nam**

* 🌐 Website: https://github.com/bansooknam
* 🐙 Github: [@bansooknam](https://github.com/bansooknam)

## 🤝 Contributing

Contributions, issues and feature requests are welcome!
Feel free to check the [issues page](https://github.com/bansooknam/fxdart/issues).

**[CONTRIBUTING.md](https://github.com/BansookNam/fxdart/blob/main/CONTRIBUTING.md)** has the working rules: branch naming and
how to keep a long-running feature from becoming a merge event, what a PR
description has to answer, and the gates a branch passes before review —
`dart analyze`, a 100%-passing `dart test`, the playground-bundle check that
catches wrapper drift, and the docs/translation checks that CI does not run.
Performance claims need a paired A/B, not a sweep; the ~5% noise floor and the
instrument for seeing past it are documented there too.

## 📝 License

Copyright © 2023 [Bansook Nam](https://github.com/bansooknam).

This project is [MIT](https://github.com/BansookNam/fxdart/blob/main/LICENSE) licensed.
