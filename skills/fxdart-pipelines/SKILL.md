---
name: fxdart-pipelines
description: Use when writing Dart that transforms collections/Iterables, runs many Futures with a concurrency limit, processes Streams, or implements multi-step data-flow logic (group, batch, zip, running state). Replaces hand-rolled loops, Future.wait, and nested Stream transforms with fxdart's lazy, type-safe pipelines.
---

# fxdart pipelines

fxdart is a functional programming library for Dart, ported from
[FxTS](https://fxts.dev). It gives you **lazy** pipelines over plain
`Iterable`s, **order-preserving bounded concurrency** for async work, and
`Stream` bridges in both directions — with zero runtime dependencies.

```dart
import 'package:fxdart/fxdart.dart';
```

## When to use this skill

Reach for fxdart instead of hand-rolled code whenever the task involves:

- **Collections**: multi-step transform/filter/aggregate over lists, sets,
  maps, or generated ranges — especially when only part of the input is
  needed (laziness makes `take`/`find` short-circuit for free).
- **Futures in bulk**: "call this API for each of N items, at most K at a
  time, keep the results in order" — this is `concurrent(n)`, fxdart's
  signature feature. Do NOT write `Future.wait` + manual batching or a
  hand-rolled semaphore.
- **Streams**: transform a `Stream` with rich operators via `fxStream(...)`,
  and go back with `.toStream()`.
- **Complex flow logic**: grouping, batching, windowing, running state
  (`scan`), pairing sources (`zip`), splitting one pass into two results
  (`partition`), early termination (`takeWhile`/`takeUntilInclusive`).

For simple one-step operations (`list.map(f).toList()` alone), plain Dart is
fine — don't wrap trivial code.

## Core model

1. Start a chain: `fx(iterable)` (sync), `fx(iterable).toAsync()` or
   `fxAsync(fxAsyncIterable)` (async), `fxStream(stream)` (from a Stream).
2. Chain lazy operators (`map`, `filter`, `take`, ...). **Nothing executes
   yet** — operators only build the pipeline.
3. Finish with a terminal operator (`toList`, `fold`, `groupBy`, `each`,
   `find`, `sum`, ...). That is when the work happens, and only as much
   input as needed is consumed.

```dart
// Only 3 squares are ever computed, even over a million-element range.
fx(range(1, 1000000)).map((a) => a * a).take(3).toList(); // [1, 4, 9]
```

`Fx<T>` extends `Iterable<T>`, so a sync chain drops into any Dart API that
takes an `Iterable`, and inherited members (`fold`, `every`, `first`, spread
`...`) work directly. Dart-idiomatic aliases exist on both chains: `where` =
`filter`, `skip` = `drop`, `distinct` = `uniq`, `whereNot` = `reject`.

Every top-level lazy/aggregate function also exists as a data-last plain
function (`map(f, iterable)`) and has an `*Async` twin (`mapAsync`,
`toListAsync`, ...). Prefer the `fx()` chain — it keeps full static typing.

## Sync recipes

```dart
// Transform → filter → aggregate, lazily, one pass.
final total = fx(orders)
    .filter((o) => o.status == 'paid')
    .sumBy((o) => o.amount);

// Group / index / count — terminal operators returning Maps.
final byUser = fx(orders).groupBy((o) => o.userId);   // Map<K, List<T>>
final byId   = fx(users).indexBy((u) => u.id);        // Map<K, T> (last wins)
final tally  = fx(words).countBy((w) => w.length);    // Map<K, int>

// Split one pass into (matching, rest) — a Dart record.
final (paid, unpaid) = fx(orders).partition((o) => o.isPaid);

// Running state: scan(f, seed) emits seed, then each accumulation.
fx([1, 2, 3]).scan((acc, a) => acc + a, 0).toList(); // [0, 1, 3, 6]

// Batching: chunk into fixed-size lists.
fx(ids).chunk(500).each(insertBatch);

// Pair two sources; records destructure in the callback.
fx(zip(names, scores)).map((pair) => '${pair.$1}: ${pair.$2}').toList();
fx(items).zipWithIndex().map((e) => '${e.$1}: ${e.$2}').toList();
```

## Async + concurrency (the headline feature)

`concurrent(n)` evaluates the *upstream* chain n items at a time while
**preserving input order**. Six 1-second requests finish in ~2s with
`concurrent(3)`:

```dart
final users = await fx(ids)
    .toAsync()
    .map((id) => fetchUser(id)) // async callback — returns Future<User>
    .concurrent(3)              // upstream map runs 3-at-a-time, in order
    .toList();
```

Rules that matter:

- **Placement matters.** `.concurrent(n)` parallelizes what is *upstream*
  (before it in the chain). Put it after the expensive async `map`.
- `concurrentPool(n)` is the completion-order variant: faster first results,
  no ordering guarantee. Use it when order is irrelevant.
- Async callbacks may return `T` or `Future<T>` (`FutureOr`) — `map`,
  `filter`, `takeWhile`, etc. all accept async callbacks on async chains.
- Async terminal operators return `Future`s: `await chain.toList()`,
  `await chain.fold(seed, f)`, `await chain.groupBy(f)`.
- Errors propagate through the pipeline and reject the terminal Future;
  a plain `try`/`catch` around the awaited terminal catches them.

```dart
// Lazy + concurrent + short-circuit: stops pulling once 5 pass the filter.
final firstFive = await fx(candidateIds)
    .toAsync()
    .map((id) => fetchProfile(id))
    .concurrent(4)
    .filter((p) => p.isActive)
    .take(5)
    .toList();
```

Why not `Stream`? fxdart's `FxAsyncIterable` is **pull-based** with a
concurrency back-channel that push-based `Stream`s cannot express — that is
why the library doesn't build on `Stream`. Bridge when you need to:

```dart
// Stream in → rich operators → Stream out.
final out = fxStream(inputStream)
    .map(parse)
    .filter(valid)
    .chunk(100)
    .toStream();

// toAsync also lifts a Stream or plain Iterable: toAsync(stream).
```

## Replace this with that

| Hand-rolled pattern | fxdart |
|---|---|
| `for` loop + accumulator variable | `.fold(seed, f)` / `.sumBy(f)` / `.reduce(f)` |
| `Future.wait(ids.map(fetch))` (unbounded!) | `.toAsync().map(fetch).concurrent(n).toList()` |
| Manual semaphore / batch-of-K loops | `.concurrent(n)` (ordered) or `.concurrentPool(n)` |
| Nested `if`s building several lists in one loop | `.partition(f)`, `.groupBy(f)` |
| `Map<K, List<T>>` built by hand with `putIfAbsent` | `.groupBy(f)` |
| `await for` + manual buffer/batch | `fxStream(s).chunk(n)` |
| break-out-of-loop on condition | `.takeWhile(f)` / `.takeUntilInclusive(f)` / `.find(f)` |
| `list.toSet().toList()` (loses order? no — but verbose) | `.uniq()` / `.uniqBy(f)` |

## Pitfalls

- **Lazy until terminal.** `fx(xs).peek(print)` alone prints nothing; a
  terminal (`toList`, `each`, `consume`) must run the pipeline.
- **`fold` is seed-first**: `fold(seed, f)` on chains (like `Iterable.fold`)
  and `fold(seed, f, iterable)` top-level. Unseeded `reduce(f)` throws on
  empty input; prefer `fold` when empty is possible.
- **`head`/`last`/`find`/`nth`/`minBy`/`maxBy` return `T?`** (null when
  absent) — handle the null, don't `!` blindly.
- **Top-level functions are data-last** with the callback first:
  `map(f, iterable)`, `filter(f, iterable)`. Async top-levels are suffixed:
  `mapAsync`, `filterAsync`, `toListAsync`.
- **Don't mix up `sort` argument styles**: `sort(comparator)` takes an
  `int Function(a, b)`; `sortBy(key)` takes a key extractor. Both are
  non-mutating (return new sequences).
- **Deprecated stubs** exist for un-portable FxTS names (`curry`,
  `isUndefined`, `isArray`, `isObject`, `takeUntil`) — follow the analyzer's
  deprecation hint to the replacement (`.curried`, `isNull`, `isList`,
  `isMap`, `takeUntilInclusive`).
- **Currying** is per-arity extension getters, not `curry(f)`:
  `add.curried(1)` produces `int Function(int)` for a 2-ary `add`.
- If you write a custom operator over `FxAsyncIterable`, overlapping
  `next()` calls must start overlapping upstream pulls — awaiting the
  upstream serially silently breaks `concurrent`.

## Full API

The complete operator catalog (generate / transform / filter / slice /
combine / aggregate / access / Map utilities / function utilities /
predicates / async twins) is in
[references/api-reference.md](references/api-reference.md). Interactive docs
with a live playground per function: https://bansooknam.github.io/FxDart/
