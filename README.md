<img src="https://raw.githubusercontent.com/BansookNam/FxDart/main/docs/assets/logo-web.png" alt="FxDart" width="380">

# fxdart

A functional programming library for Dart, ported from **[FxTS](https://github.com/marpple/FxTS)**.
Lazy evaluation, concurrent async iteration, and pipeline-style composition — the FxTS
programming model, rebuilt on Dart's type system.

[![Version](https://img.shields.io/pub/v/fxdart.svg?style=flat-square)](https://pub.dev/packages/fxdart)

**📚 Interactive docs: [FxDart 101](https://bansooknam.github.io/FxDart/)** — a
guided course with a live in-browser playground for every function (served from
this repo's `docs/` folder via GitHub Pages).

## Why fxdart?

- **Lazy evaluation** — operators build a pipeline and do no work until a terminal
  operator runs, so `fx(hugeList).map(f).filter(g).take(3)` only computes 3 results.
- **Concurrency you can dial** — `concurrent(n)` evaluates the *upstream* chain
  `n` items at a time while preserving order, turning six 1-second requests into
  a ~2-second batch with one method call.
- **Type-safe pipelines** — the `fx()` chain keeps full static typing end to end;
  sync operators are plain functions over native `Iterable`s, so everything
  interops with ordinary Dart code.
- **One mental model for sync and async** — the same operator names work on
  `Iterable` (sync) and `FxAsyncIterable` (async), with `Stream` bridges in both
  directions.

## Install

```yaml
dependencies:
  fxdart: ^0.1.0
```

## Usage

### Sync pipelines

Sync operators are data-first functions over lazy `Iterable`s; the `fx()` chain
composes them with full type inference:

```dart
import 'package:fxdart/fxdart.dart';

fx([1, 2, 3, 4, 5])
    .map((a) => a + 10)
    .filter((a) => a % 2 == 0)
    .toArray(); // [12, 14]

// Equivalent with top-level functions:
toArray(filter((a) => a % 2 == 0, map((a) => a + 10, [1, 2, 3, 4, 5])));

// Laziness: only 3 squares are ever computed.
fx(range(1, 1000000)).map((a) => a * a).take(3).toArray(); // [1, 4, 9]
```

### Async pipelines

Async operators work on `FxAsyncIterable<T>` — a pull-based protocol ported from
FxTS's `AsyncIterable` handling. Lift values in with `toAsync` / `fromStream`
(or `.toAsync()` on a chain), and out with `.toArray()` / `.toStream()`:

```dart
await fx([1, 2, 3, 4])
    .toAsync()
    .map((a) async => a + 10) // callbacks may be async
    .filter((a) => a % 2 == 0)
    .toArray(); // [12, 14]

// Streams bridge both ways.
await fxStream(Stream.fromIterable([1, 2, 3])).map((a) => a * 2).toArray();
```

### Concurrency

`concurrent(n)` is FxTS's signature feature, ported faithfully: a concurrency
marker travels *backwards* through the pipeline's iterator protocol, so the
upstream chain evaluates `n` items at once while results stay in order.

```dart
// 6 requests of 1s complete in ~2s instead of ~6s.
await fx([1, 2, 3, 4, 5, 6])
    .toAsync()
    .map((id) => fetchUser(id))
    .concurrent(3)
    .toArray();
```

`concurrentPool(n)` is the completion-order variant (faster first results, no
ordering guarantee). This back-channel protocol is why fxdart has its own
`FxAsyncIterable` instead of building on push-based `Stream`s, which cannot
express it.

## API overview

| Category | Functions |
|---|---|
| **Generate** | `range`, `repeat`, `cycle`, `entries`, `keys`, `values` |
| **Transform (lazy)** | `map`, `mapEffect`, `flatMap`, `flat`, `scan`, `scan1`, `peek`, `pluck` |
| **Filter (lazy)** | `filter`, `reject`, `compact`, `uniq`, `uniqBy`, `difference(By)`, `intersection(By)`, `compress` |
| **Slice (lazy)** | `take`, `takeRight`, `takeWhile`, `takeUntilInclusive`, `drop`, `dropRight`, `dropWhile`, `dropUntil`, `slice`, `chunk`, `split` |
| **Combine (lazy)** | `append`, `prepend`, `concat`, `zip`, `zip3`, `zipWith`, `zipWithIndex`, `transpose`, `reverse`, `fork` |
| **Aggregate** | `reduce`, `fold`, `reduceLazy`, `toArray`, `sum`, `average`, `min`, `max`, `size`, `join`, `groupBy`, `indexBy`, `countBy`, `sort`, `sortBy`, `toSorted`, `partition`, `each`, `consume` |
| **Access** | `head`, `last`, `nth`, `find`, `findIndex`, `includes`, `isEmpty`, `every`, `some` |
| **Object (Map)** | `omit`, `pick`, `omitBy`, `pickBy`, `prop`, `props`, `evolve`, `fromEntries`, `compactObject`, `resolveProps`, `isMatch`, `matches` |
| **Function** | `pipe`, `pipe1`, `pipeLazy`, `identity`, `always`, `tap`, `apply`, `juxt`, `memoize`, `negate`, `not`, `when`, `unless`, `throwError`, `throwIf`, `cases`, `add`, `gt`, `gte`, `lt`, `lte`, `delay`, `sleep`, `unicodeToArray`, `.curried`/`.uncurried` (extension getters, arity 2–5) |
| **Predicates** | `isNull`, `isNotNull`, `isNil`, `isBoolean`, `isNumber`, `isString`, `isDate`, `isList`, `isMap` |
| **Async** | every lazy/aggregate operator has an `*Async` twin (`mapAsync`, `toArrayAsync`, ...), plus `toAsync`, `fromStream`, `concurrentAsync`, `concurrentPoolAsync`, `asyncEmpty` |
| **Util** | `debounce`, `throttle`, `shuffle`, `createSeededRandom` |
| **Chains** | `fx()` (sync, extends `Iterable`), `fxAsync()`, `fxStream()`; `Fx<num>`/`FxAsync<num>` gain `sum`/`average`/`min`/`max` |

## Differences from FxTS

Dart has no function overloads, variadic generics, or conditional types, so some
APIs deliberately deviate:

| FxTS | fxdart |
|---|---|
| curried data-last (`map(f)` inside `pipe`) | `fx()` chain (typed) or dynamic `pipe(value, [closures])` |
| one `map` dispatching sync/async | `map` (Iterable) / `mapAsync` (FxAsyncIterable); chains use plain names |
| `reduce(f, seed, iter)` overload | `fold(seed, f, iter)` (unseeded `reduce(f, iter)` unchanged) |
| tuples (`zip`, `entries`, `partition`) | Dart records: `(A, B)` |
| TS objects (`omit`, `pick`, `evolve`, ...) | `Map`-based equivalents |
| `undefined` | `null` (`head`/`find`/`nth` return `T?`) |
| `AsyncIterable` / `for await` | `FxAsyncIterable` + `toStream()` / `fromStream()` bridges |
| variadic `zip`/`juxt`/`cases` | fixed arities (`zip`/`zip3`) or list/record parameters |
| `curry(f)` | `.curried` / `.uncurried` extension getters — see [WHY_CURRIED.md](WHY_CURRIED.md) |

FxTS's `curry` needs arity reflection and recursive conditional types, which
Dart lacks — so fxdart curries through per-arity extensions instead, resolved
statically and fully typed:

```dart
int add(int a, int b) => a + b;
final addOne = add.curried(1); // int Function(int)
fx([1, 2, 3]).map(addOne).toArray(); // [2, 3, 4]
```

[WHY_CURRIED.md](WHY_CURRIED.md) tells the full design story: why the direct
port is impossible, how static extension resolution stands in for overloading,
why the getter is named `curried`, and how the same port-the-meaning
philosophy resolves the other unportable APIs. Those keep `@Deprecated` stubs
(`curry`, `isUndefined`, `isArray`, `isObject`, `takeUntil`) so migrating code
gets analyzer guidance instead of silent breakage.

## Testing

The FxTS spec suite has been ported alongside the library: **850+ tests**
covering sync/async behavior, error propagation, laziness, and
concurrency timing across every operator.

```sh
dart test
```

## Acknowledgments

Great thanks to **Indong Yoo**, CTO of [Marpple](https://www.marpple.com), the
creator of [FxTS](https://github.com/marpple/FxTS) (and FxJS before it), whose
functional programming model — lazy iteration with first-class, order-preserving
concurrency — this library ports to Dart. All core ideas, operator semantics,
and the original test suite come from the
[marpple/FxTS](https://github.com/marpple/FxTS) repository.

## Author

👤 **Bansook Nam**

* Website: https://github.com/bansooknam
* Github: [@bansooknam](https://github.com/bansooknam)

## 🤝 Contributing

Contributions, issues and feature requests are welcome!
Feel free to check the [issues page](https://github.com/bansooknam/fxdart/issues).

## 📝 License

Copyright © 2023 [Bansook Nam](https://github.com/bansooknam).

This project is [MIT](https://github.com/BansookNam/fxdart/blob/main/LICENSE) licensed.
