# fxdart API reference

`import 'package:fxdart/fxdart.dart';` — everything below is exported from
the single entry point. Interactive docs with a runnable playground per
function: https://bansooknam.github.io/FxDart/

## Entry points

| Function | Produces | Notes |
|---|---|---|
| `fx(Iterable<T>)` | `Fx<T>` | Sync chain; `Fx` extends `Iterable` |
| `fxAsync(FxAsyncIterable<T>)` | `FxAsync<T>` | Async chain |
| `fxStream(Stream<T>)` | `FxAsync<T>` | Lift a Stream into an async chain |
| `.toAsync()` on `Fx` | `FxAsync<T>` | Lift a sync chain |
| `toAsync(iterableOrStream)` | `FxAsyncIterable<T>` | Top-level lift |
| `fromStream(stream)` | `FxAsyncIterable<T>` | Top-level Stream bridge |
| `.toStream()` on `FxAsync`/`FxAsyncIterable` | `Stream<T>` | Bridge out |
| `asyncEmpty<T>()` | `FxAsyncIterable<T>` | Empty async source |

Every top-level lazy/aggregate function has a data-last form
(`map(f, iterable)`) and an `*Async` twin on `FxAsyncIterable`
(`mapAsync(f, asyncIterable)`). Chains use the plain names for both.

## Generate

`range(start, [end, step])`, `repeat(n, value)`, `cycle(iterable)`,
`entries(map)`, `keys(map)`, `values(map)`

## Transform (lazy)

`map`, `mapEffect`, `flatMap`, `flat([depth])`, `scan(f, seed)` /
`scan1(f)`, `peek(sideEffect)`, `pluck(key, iterableOfMaps)`

## Filter (lazy)

`filter`, `reject`, `compact` (drop nulls), `uniq`, `uniqBy`,
`difference`, `differenceBy`, `intersection`, `intersectionBy`,
`compress(selectors, iterable)`

## Slice (lazy)

`take`, `takeRight`, `takeWhile`, `takeUntilInclusive` (includes the first
failing element), `drop`, `dropRight`, `dropWhile`, `dropUntil`,
`slice(start, [end])`, `chunk(size)`, `split(predicate)`

## Combine (lazy)

`append(a)`, `prepend(a)`, `concat(a, b)`, `zip(a, b)` → `(A, B)` records,
`zip3`, `zipWith(f, a, b)`, `zipWithIndex()` → `(int, T)`, `transpose`,
`reverse`, `fork` (split one iterable into two independent consumers)

## Aggregate (terminal)

`reduce(f)` (unseeded, throws on empty), `fold(seed, f)` (chain) /
`fold(seed, f, iterable)` (top-level), `reduceLazy`, `toList`, `sum`,
`sumBy(f)`, `average`, `averageBy(f)`, `min`, `max`, `minBy(f)`, `maxBy(f)`
(return `T?`), `size`, `join([sep])`, `groupBy(f)` → `Map<K, List<T>>`,
`indexBy(f)` → `Map<K, T>`, `countBy(f)` → `Map<K, int>`,
`sort(comparator)`, `sortBy(keyFn)`, `toSorted`, `partition(f)` →
`(List<T>, List<T>)`, `each(f)`, `consume([n])`

On `Fx<num>` / `FxAsync<num>`: no-arg `sum()`, `average()`, `min()`, `max()`.

## Access (terminal)

`head()`, `last()`, `nth(i)`, `find(f)`, `findIndex(f)`, `includes(v)`,
`isEmpty`, `every(f)`, `some(f)` — `head`/`last`/`nth`/`find` return `T?`.

## Dart-idiomatic aliases (chains)

`where`=`filter`, `whereNot`=`reject`, `skip`=`drop`,
`skipWhile`=`dropWhile`, `takeLast`=`takeRight`, `distinct`=`uniq`,
`flattened`=`flat`, `firstWhereOrNull`=`find`, `indexWhere`=`findIndex`,
`forEach`=`each` (async chain).

## Object (Map) utilities

`omit(keys, map)`, `pick(keys, map)`, `omitBy(f, map)`, `pickBy(f, map)`,
`prop(key, map)`, `props(keys, map)`, `evolve(transforms, map)`,
`fromEntries(pairs)`, `compactObject(map)`, `resolveProps(mapOfFutures)`,
`isMatch(a, b)`, `matches(spec)`

## Function utilities

`pipe(value, [closures])` (dynamic, FxTS parity — prefer `fx()` chains),
`pipe1`, `pipeLazy`, `identity`, `always(v)`, `tap(f)`, `apply(f, args)`,
`juxt([f, g])`, `memoize(f)`, `negate(f)`, `not(v)`, `when(pred, f)`,
`unless(pred, f)`, `throwError(e)`, `throwIf(pred, e)`, `cases(...)`,
`add`, `gt`, `gte`, `lt`, `lte`, `delay(ms, value)`, `sleep(ms)`,
`unicodeToArray(s)`

Currying: `.curried` / `.uncurried` extension getters on functions of
arity 2–5 — `add.curried(1)` is `int Function(int)`. There is no `curry(f)`
(Dart lacks arity reflection); a `@Deprecated` stub points migrating code
here.

## Predicates

`isNull`, `isNotNull`, `isNil`, `isBoolean`, `isNumber`, `isString`,
`isDate`, `isList`, `isMap`

## Async & concurrency

- `concurrentAsync(n, iter)` / `.concurrent(n)` — evaluate upstream n at a
  time, **order preserved**.
- `concurrentPoolAsync(n, iter)` / `.concurrentPool(n)` — completion order,
  faster first results.
- Protocol types (only needed when writing custom operators):
  `FxAsyncIterable<T>`, `FxAsyncIterator<T>`, `IterResult<T>`, `Concurrent`,
  `FxAsyncIterableToStream`.
- Custom operators must be parallel-safe: overlapping `next()` calls must
  start overlapping upstream pulls, or `concurrent` silently degrades to
  serial.

## Util

`debounce(ms, f)`, `throttle(ms, f)`, `shuffle(iterable, [random])`,
`createSeededRandom(seed)`

## Deprecated stubs (use the replacement)

`curry` → `.curried`, `isUndefined` → `isNull`, `isArray` → `isList`,
`isObject` → `isMap`, `takeUntil` → `takeUntilInclusive`.
