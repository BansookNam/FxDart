# fxdart API reference

`import 'package:fxdart/fxdart.dart';` — everything below is exported from
the single entry point. Interactive docs with a runnable playground per
function: https://bansooknam.github.io/FxDart/

**Naming.** A top-level function with a one- or two-word name carries an `fx`
prefix (`fxMap`, `fxRange`, `fxGroupBy`, `fxMapAsync`); three or more words
keep the FxTS name (`mapWithIndex`, `takeUntilInclusive`). Chain methods are
never prefixed: `fx(xs).map(f)`.

## Entry points

| Function | Produces | Notes |
|---|---|---|
| `fx(Iterable<T>)` | `Fx<T>` | Sync chain; `Fx` extends `Iterable` |
| `fxAsync(FxAsyncIterable<T>)` | `FxAsync<T>` | Async chain |
| `fxEvents(Stream<T>)` / `.fxEvents` | `FxEvents<T>` | Push chain — time. See **fxdart-events**. |
| `fxStream(Stream<T>)` | `FxAsync<T>` | Pull a Stream into a chain. Preferred when you need chain methods. |
| `.toAsync()` on `Fx` | `FxAsync<T>` | Lift a sync chain |
| `fxToAsync(iterableOrStream)` | `FxAsyncIterable<T>` | Top-level lift |
| `fxFromStream(stream)` | `FxAsyncIterable<T>` | Top-level Stream bridge (pull); no chain methods |
| `.toStream()` on `FxAsync`/`FxAsyncIterable` | `Stream<T>` | Bridge out |
| `fxAsyncEmpty<T>()` | `FxAsyncIterable<T>` | Empty async source |

Every top-level lazy/aggregate function has a data-last form
(`fxMap(f, iterable)`) and an `*Async` twin on `FxAsyncIterable`
(`fxMapAsync(f, asyncIterable)`). Chains use the plain names for both.

## Generate

`fxRange(start, [end, step])`, `fxRepeat(n, value)`, `fxCycle(iterable)`,
`fxEntries(map)`, `fxKeys(map)`, `fxValues(map)`

## Transform (lazy)

`map`, `mapEffect`, `flatMap`, `flat([depth])`, `scan(f, seed)` /
`fxScan1(f)`, `peek(sideEffect)`, `fxPluck(key, iterableOfMaps)`

## Filter (lazy)

`filter`, `reject`, `fxCompact` (drop nulls), `uniq`, `uniqBy`,
`difference`, `differenceBy`, `intersection`, `intersectionBy`,
`fxCompress(selectors, iterable)`

## Slice (lazy)

`take`, `takeRight`, `takeWhile`, `takeUntilInclusive` (includes the first
failing element), `drop`, `dropRight`, `dropWhile`, `dropUntil`,
`slice(start, [end])`, `chunk(size)`, `fxSplit(predicate)`

## Combine (lazy)

`append(a)`, `prepend(a)`, `fxConcat(a, b)`, `zip(a, b)` → `(A, B)` records,
`zip3`, `fxZipWith(f, a, b)`, `zipWithIndex()` → `(int, T)`, `fxTranspose`,
`reverse`, `fxFork` (split one iterable into two independent consumers)

## Aggregate (terminal)

`reduce(f)` (unseeded, throws on empty), `fold(seed, f)` (chain) /
`fxFold(seed, f, iterable)` (top-level), `fxReduceLazy`, `toList`, `sum`,
`sumBy(f)` (→ `num`), `sumByDouble(f)` / `sumByInt(f)` (→ `double` / `int`,
no cast), `average`, `averageBy(f)`, `min`, `max`, `minBy(f)`, `maxBy(f)`
(return `T?`), `quantileBy(q, f)` (nearest-rank element, O(n) quickselect),
`size`, `join([sep])`, `groupBy(f)` → `Map<K, List<T>>`,
`indexBy(f)` → `Map<K, T>`, `countBy(f)` → `Map<K, int>`,
`sort(comparator)`, `sortBy(keyFn)` (stable on every key type), `fxToSorted`, `partition(f)` →
`(List<T>, List<T>)`, `each(f)`, `consume([n])`

On `Fx<num>` / `FxAsync<num>`: no-arg `sum()`, `average()`, `min()`, `max()`,
and `quantile(q)` (median = `quantile(0.5)`; prefer it over sort-then-index).

## Access (terminal)

`head()`, `last()`, `nth(i)`, `find(f)`, `findIndex(f)`, `fxIncludes(v)`,
`isEmpty`, `every(f)`, `some(f)`, `atLeast(n, f)` / `atMost(n, f)` (stop at
the deciding match — prefer over `countWhere(f) >= n`) —
`head`/`last`/`nth`/`find` return `T?`.

## Dart-idiomatic aliases (chains)

`where`=`filter`, `whereNot`=`reject`, `skip`=`drop`,
`skipWhile`=`dropWhile`, `takeLast`=`takeRight`, `distinct`=`uniq`,
`flattened`=`flat`, `firstWhereOrNull`=`find`, `indexWhere`=`findIndex`,
`forEach`=`each` (async chain).

## Object (Map) utilities

`fxOmit(keys, map)`, `fxPick(keys, map)`, `fxOmitBy(f, map)`, `fxPickBy(f, map)`,
`fxProp(key, map)`, `fxProps(keys, map)`, `fxEvolve(transforms, map)`,
`fxFromEntries(pairs)`, `fxCompactObject(map)`, `fxResolveProps(mapOfFutures)`,
`fxIsMatch(a, b)`, `fxMatches(spec)`

## Function utilities

`pipe(value, [closures])` (dynamic, FxTS parity — prefer `fx()` chains),
`fxPipe1`, `pipeLazy`, `fxIdentity`, `fxAlways(v)`, `fxTap(f)`, `fxApply(f, args)`,
`fxJuxt([f, g])`, `fxMemoize(f)` (caches every argument),
`fxMemoizeLast(f, {equals = identical})` (one slot, identity — for pure
functions of immutable state), `fxNegate(f)`, `fxNot(v)`, `fxWhen(pred, f)`,
`fxUnless(pred, f)`, `fxThrowError(e)`, `fxThrowIf(pred, e)`, `fxCases(...)`,
`fxAdd`, `fxGt`, `fxGte`, `fxLt`, `fxLte`, `fxDelay(ms, value)`, `fxSleep(ms)`,
`unicodeToArray(s)`

Currying: `.curried` / `.uncurried` extension getters on functions of
arity 2–5 — `add.curried(1)` is `int Function(int)`. There is no `fxCurry(f)`
(Dart lacks arity reflection); a `@Deprecated` stub points migrating code
here.

## Predicates

`fxIsNull`, `isNotNull`, `fxIsNil`, `fxIsBoolean`, `fxIsNumber`, `fxIsString`,
`fxIsDate`, `fxIsList`, `fxIsMap`

## Async & concurrency

- `fxConcurrentAsync(n, iter)` / `.concurrent(n)` — evaluate upstream n at a
  time, **order preserved**.
- `fxConcurrentPoolAsync(n, iter)` / `.concurrentPool(n)` — completion order,
  faster first results.
- Protocol types (only needed when writing custom operators):
  `FxAsyncIterable<T>`, `FxAsyncIterator<T>`, `IterResult<T>`, `Concurrent`,
  `FxAsyncIterableToStream`.
- Custom operators must be parallel-safe: overlapping `next()` calls must
  start overlapping upstream pulls, or `concurrent` silently degrades to
  serial.

## Util

`fxDebounce(f, wait, {leading, maxWait})` → `Debounced` with `cancel()`,
`flush()` (run the pending call now — for dispose/app-pause) and `isPending`;
`fxThrottle(f, wait, {leading, trailing})`; `fxOnChange(f, {equals})` (run
only when the argument changed); `fxConflate(run, {onError})` (one async run
in flight, newest waiting value next — seeks, syncs, previews); each also as
a method on the callback (`save.fxDebounce(wait)`, `setCoins.fxOnChange()`).
`fxShuffle(iterable, [random])`, `createSeededRandom(seed)`.
`fxRetry(attempts, f, {delay, retryIf, onRetry})` / `.mapRetry(...)`:
`retryIf` false rethrows at once.

## Deprecated stubs (use the replacement)

`fxCurry` → `.curried`, `fxIsUndefined` → `fxIsNull`, `fxIsArray` → `fxIsList`,
`fxIsObject` → `fxIsMap`, `fxTakeUntil` → `takeUntilInclusive`.
