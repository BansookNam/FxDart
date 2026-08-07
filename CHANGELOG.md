## 0.7.9

### Added — predicate combinators

A unary predicate can now be built out of named pieces instead of nested
lambdas: `isEven.and(isPositive)`, `.or`, `.xor`, `.negate`, and
`.contramap<A>(f)` to move a predicate onto another input type. They
compose anywhere a predicate is expected — `filter`, `reject`,
`takeWhile`, `dropWhile`, `countWhere`, `partition`.

This is not an FxTS port. TypeScript writes the same thing as `&&`
inside an arrow function and keeps its types through inference; in Dart
that costs a lambda and a repeated parameter name per combination, so
the operators earn their names. `.negate` is the extension-getter form
of the existing top-level `negate` — the two are the same function.

`and` and `or` short-circuit like `&&`/`||` and call the right-hand
predicate only when the left one doesn't decide; `xor` always calls
both. Nothing runs until the composed predicate itself is called.

### Added — `Either.map2` … `map5`

Combining independent `Either`s no longer has to go through an
accumulating scope: `parseName(form).map2(parseAge(form), User.new)`
keeps the **leftmost** `Left` and runs `combine` only when every branch
is a `Right`. Arities 2–5, capped where `zipOrAccumulate2..5` and
`Curry2..Curry5` are capped.

The two are not redundant. `zipOrAccumulate` reports an `EitherNel` with
*every* failure and needs an `accumulate` scope; `mapN` reports one
failure and works on plain values, which is what a fallible-lookup chain
wants. What's fail-fast in `mapN` is the *reporting*, not the work — the
branches are already-evaluated values, so all of them ran.

## 0.7.8

### Added — the events layer's second half

`fxEvents` shipped in 0.7.3 with the operators a push chain cannot live
without: `debounce`, `throttle`, `sampleOn`, `combineLatest`,
`withLatestFrom`, `switchMap`, `startWith`, plus `race`/`merge` and
`LiveValue`. This fills in the rest of the rxdart surface that is
genuinely push-only — the things a pull pipeline has no way to express,
because it has no clock and no notion of several live sources at once.

**Gating** — `stopOn(trigger)` closes the chain and cancels both
subscriptions the first time `trigger` fires; `startOn(trigger)` drops
source events until it fires, then passes them for good. The names are
not Rx's `takeUntil`/`skipUntil` because `Fx.takeUntil(predicate)`
already means `takeUntilInclusive` on the pull side, and one name cannot
mean two things in one library. `FxSubscriptions` is the companion for
owner-driven teardown: a bag with `add`/`addAll`/`cancelAll`/`pauseAll`/
`resumeAll`, emptied before its cancellations are awaited so a second
`cancelAll` cannot cancel anything twice.

**Higher-order mapping** — `mergeMap(f, {concurrent})` runs every inner
stream at once, optionally capped, with the extra source values queued;
`concatMap(f)` runs them strictly in order; `exhaustMap(f)` keeps the
first and ignores the rest, which is the double-submit guard. With the
existing `switchMap` that is all four policies for "an event arrived
while the last one is still running". `mergeMap` rather than `flatMap`,
since `flatMap` already means iterable-flattening.

**Batching** — `chunk(count)`, `chunkOn(trigger)`, `chunkEvery(window)`.
The root word is the pull layer's `chunk`; `…On` takes a trigger stream
and `…Every` takes a clock. Both time-driven forms stay silent on an
empty window rather than emitting an empty list, and flush what is
buffered when the source closes.

**Time shaping** — `delay(duration)` shifts the whole stream with its
spacing intact; `spaceBy(gap)` is the lossless counterpart of `throttle`,
queueing a burst and releasing one event per gap; `sample(period)` is
`sampleOn` with the clock built in.

**Multi-source** — `FxEvents.waitAll` emits one list of every source's
last value once all have closed (`Future.wait` for streams);
`FxEvents.zip`/`zipWith` pair by index; `FxEvents.combineLatestAll` is
the N-ary `combineLatest`; `FxEvents.concat`/`followedBy` sequence;
`mergeWith`/`raceWith` are the instance forms of the existing statics.

**Fan-out** — `share()` lets many listeners consume one run of a chain.
Every operator here builds its own `StreamController`, so a chain is
single-subscription; `share` connects on the first listener and
broadcasts from there. It deliberately does *not* reconnect the way Rx's
`share` does — the upstream chain has no second run to give — so the
last listener leaving closes it for good. `LiveValue.from(source)` and
`LiveValue.seededFrom(seed, source)` build a hot `LiveValue` straight
from a stream; named constructors rather than an optional seed so a
nullable `T` can still be seeded with null.

**Errors** — `onErrorReturn(value)` substitutes per error and carries on,
since a Dart stream error does not end the subscription;
`onErrorResume(f)` cancels the source on the first error and switches to
a fallback stream for good; `FxEvents.retry(factory, [count])` rebuilds
the stream instead of patching its errors, with the budget counting
re-subscriptions.

### Docs

Eight new FxDart 101 pages in section 14 (`stopOn`, `mergeMap`,
`chunkOn`, `spaceBy`, `waitAll`, `onErrorResume`, `share`,
`fxSubscriptions`), each with three runnable demos, in English and
Korean. Section 14 now runs to fifteen pages.

### Tests

Line coverage stays at **100.00%** (3607/3607, up from 3264).

## 0.7.7

### Added — `tee` / `tee3`

Several folds over a **single** pass of a source, with no buffering.

`fork` can already feed two readers from one pass, but only by buffering:
its cursors advance independently, so draining one before the other holds
every element the lagging cursor has not reached. Expressing the readers as
folds — a `seed` and a `step` — lets both advance on the same element, so
there is never a value one has seen and the other has not, and nothing to
remember. The counterpart of Rx's `publish()`, where attaching both
subscribers before `connect()` is what avoids the buffer.

The two accumulators are independent and need not share a type; `tee3`
takes three; `teeAsync` is the async form. Chain methods on `Fx` and
`FxAsync`. The trade is deliberate: `tee` feeds folds, not pipelines — for
two genuinely independent readers, `fork` and its buffer remain the answer.

On the RxDartComparison's `tee-the-pipeline`, measured paired and
interleaved: time **36.6 → 17.8 ms** (-51%), peak RSS **57.6 → 22.6 MB**
(-61%). That was the section's largest memory loss; fxdart now holds less
than RxDart's 25.4 MB. The example and its benchmark were moved onto
`tee`, matching a multicast primitive against a multicast primitive
rather than a general buffering one.

### Performance — the fused stage list is compiled into a link chain

The four per-element loops (`_mapFrom`, `_applyFrom`, `fxStreamDrive`,
`fxFusedDrive`) walked a `List<FxStage>` by index, and in the drives that
list was a *captured* local — so `stages.length` and `stages[i]` each went
through the closure context object, per stage per element. The list is now
compiled once per `FxFusedAsyncIterable` into a chain of `FxLink` nodes,
each holding its successor: the loops walk pointers, and an asynchronous
stage resumes at `link.next` instead of re-deriving `i + 1`.

Internal only — no signature, laziness, ordering or error-behaviour change.

`stream-into-pipeline`, the RxDartComparison's largest remaining deficit,
goes from **1039 µs against RxDart's 783 µs (1.32×)** to **778 vs 766
(1.02×)** — parity. Across 30 async cases the effect is otherwise small
(median -0.49%, mean -1.24%, 5 cases ≥2% faster, 1 ≥2% slower).

Two changes measured alongside these were **reverted** for failing to pay:
collapsing an adjacent `filter`+`map` into one fused stage (+0.16% median,
-0.8% on its own target case), and an `onErrorResume` operator, which made
`resume-with-cache` **151% slower** — routing the cached tail through the
async chain costs more than the `await for` it replaced.

### Docs

101 section 6 gains `tee` and `tee3` (between `fork` and `ifEmpty`), both
translated to Korean. The `tee` page carries the name's etymology — the
letter T, after the plumbing T-splitter Unix borrowed for its own `tee` —
and is explicit that Python's `itertools.tee`, which splits one iterable
into independent iterators, is the operation FxDart spells `fork`, not
`tee`. FxDart's `tee` branches the *consumption* one level further
downstream.

### Tests

Library line coverage back to **100%** (3264/3264), the 0.7.4 standard
that 0.7.6's fused drive had left at 98.47%. `test/strict/tee_test.dart`
and `test/lazy/fused_link_test.dart` cover the new operator and the
compiled chain's asynchronous branches — including the pull path (reached
by wrapping a run in `take`, which denies the terminal its push drive) and
the drive's synchronous-throw paths, reachable only when a run's source is
itself a run.

## 0.7.6

### Performance — records stopped costing 2× in async pipelines

`dependent-calls-in-sequence` was the RxDartComparison's worst async loss —
1.29× behind RxDart. Nothing about the pipeline explained it —
the same chain with a `String` accumulator ran at hand-written-loop speed.
The accumulator's **type** was the whole gap: swapping the tuple
`(String, String)` for a two-field class made it disappear, and giving
RxDart's `asyncMap` the same tuple made *RxDart* the slower side (57 ms).

The cause is not records themselves; it is where the operator's iterator gets
allocated. Dart AOT specializes an operator's type checks only when the type
arguments are statically known at the allocation site. Built through a chain
of un-inlined generic factories — `FxAsync.scan` → `scanAsync` →
`DelegateAsyncIterable(() => …)` — the type arguments are runtime values, so
every `x is Future<B>` and `x as B` in the hot loop becomes a real subtype
test. Cheap for an ordinary class; **~1 µs per element** when `B` is a record
type. fxdart hands records out everywhere: `zip`, `attach`, `pairwise`,
`zipWithIndex`, and any tuple `scan` accumulator.

Three fixes, all internal — no signature moves, and `next()` still returns a
`Future`, so a hand-driven `.iterator.next()` loop is unaffected:

* **`vm:prefer-inline` across the async operator surface.** Every `*Async`
  factory and every one-line `FxAsync` chain method now inlines back into the
  caller, so the iterator is allocated where the type arguments are constants
  and the loop's type checks fold away. The chain is only as strong as its
  weakest link — one un-inlined generic hop loses the specialization for the
  whole operator — which is why this is applied across the surface rather
  than case by case. Measured on record-carrying async pipelines:
  `scan` **2.26×**, `attach` **2.49×**.
* **`scan` is a fusable stage.** `scanAsync` is one-in-one-out like `map`,
  only stateful, so it now joins the `map`/`filter`/`takeWhile` stage run
  instead of layering a pull on top of it. `scan(…).map(…)` is one iterator,
  not two — one future and one microtask hop per element saved. At most one
  scan per run (the accumulator has one slot); a second scan starts a new run.
  The seed is emitted through the stages that follow the scan, as it always
  was. A `Concurrent` marker still falls back to the unfused layering.
* **`fxFusedDrive`, the third push terminal.** Beside `fxStreamDrive`
  (0.7.4) and `fxPoolDrive` (0.7.5): when an all-consuming serial terminal
  (`toListAsync` / `eachAsync` / `foldAsync`) owns a fused stage run, the
  stages execute inside the stage future's own callback and hand the value
  straight to the terminal — the pull's second future and its `IterResult`
  wrapper are gone. A plain-`Iterable` source (`toAsync`) is stepped with
  `moveNext()` directly, so it allocates nothing per element either.
  **2.0 → 1.0 microtasks per element.**

Together, per element (AOT, 200,000 elements, the example's per-call
`Future.delayed` replaced by a microtask so what is measured is the pipeline
and not the platform timer):

| | before | after |
|---|---|---|
| `scan(tuple).map(…).toList()` | 1966 ns | 887 ns |
| `map(async).toList()` | 1114 ns | 863 ns |
| `attach(async).toList()` | 2210 ns | 888 ns |

`dependent-calls-in-sequence`, measured before and after on the same machine
in the same session, goes from **47.4 ms against RxDart's 36.7 ms (a loss)**
to **34.9 ms against 36.8 ms (a win)** — 1.36× faster than before, and the
last async case where the pull model was visibly behind a push `Stream` for
ordinary sequential work.

Across the whole RxDartComparison suite at the headline scale, the speed
tally moves from **31 FxDart / 7 tie / 3 RxDart** to **34 / 7 / 0** — RxDart
no longer wins a case. `latency-extremes` and `pipeline-into-stream` move
from RxDart wins to ties; `bound-the-stall` and `price-or-fallback` move from
ties to FxDart wins. Nothing moves the other way. In the DartComparison
suite, where the same async machinery is measured against hand-written Dart,
`price-lookup-fallback` (1.35× → 1.01×) and `sequential-configs` (1.12× →
1.01×) move from native wins to ties, taking that tally from 41 native /
3 tie / 9 FxDart to **39 / 5 / 9**.

### Tests

`test/lazy/fused_scan_test.dart` pins the combinations the fusion creates:
scan before and after map/filter/takeWhile, the seed flowing through the
later stages (and being dropped or ending the run there), two scans in a
chain, a `Future` seed, an empty source, sync and async accumulator errors,
a `Future` element in the source, a throwing source, the `concurrent`
fallback to the unfused layering, a stream source keeping the pull path, and
`each` / `fold` / an async `emit` seeing exactly what `toList` sees.

## 0.7.5

### Fixed — `concurrentPool` went quadratic on a fast source

`concurrentPoolAsync` refills its pool on every completion instead of on
demand — the 0.1.1 "eagerly keep the pool full" behavior, which is what lets
a one-pull-at-a-time terminal like `toList` still overlap `n` requests. The
consequence went unnoticed: when the source resolves *faster* than the
consumer drains, the ready-results buffer runs ahead without bound, and that
buffer was a growable `List` dequeued with `removeAt(0)` — O(length) per
element. The pipeline as a whole was O(n²).

It takes an effectively-instant source to show — cached lookups,
`Future.value`, futures that are already complete. Any real per-element
latency holds the buffer at the pool size, which is why the benchmark suite
never caught it. Both internal buffers (settled results waiting for a
consumer, and consumer pulls waiting for a result) are now `Queue`s, O(1) at
each end. Measured AOT over an all-resolved source with a pool of 3:

| N | before | after |
|---|---|---|
| 2,000 | 6.5 ms | 1.8 ms |
| 4,000 | 22.0 ms | 5.5 ms |
| 8,000 | 84.8 ms | 7.0 ms |
| 16,000 | 724.1 ms | 12.9 ms |

Completion ordering, laziness, the eager refill itself, and error
propagation are unchanged, and the async benchmark suite is unmoved — with
real latency the buffers never grow, so there was nothing there to win.

### Added — `FxDart.config`

A namespace for process-wide settings, holding one switch so far:

* **`FxDart.config.optimizeMemoryForConcurrentPool`** (default `false`) —
  puts `concurrentPoolAsync` back on the `List` buffers described above. The
  trade it names is smaller than it sounds: a `Queue` keeps a power-of-two
  backing store and so can hold up to ~2× the elements' worth of slots, but
  on the `completion-order-pool` benchmark the two forms measured the same
  peak RSS to within 0.1 MB. It is there as an escape hatch — to reproduce a
  measurement taken against an earlier version, or to pin the old behavior
  if some workload turns out to prefer it.

Settings are read when a pipeline **starts iterating**, not when it is
built, so flipping one affects pipelines started afterwards and leaves an
already-running iteration on the behavior it began with.

### Performance — push execution reaches the pool and the stream bridge

0.7.4 gave stream-*sourced* chains a subscription execution model; the two
places that still round-tripped every element through a `Completer` or an
async generator now follow it. Both are internal — no signature moves, and
`next()` still returns a `Future`, so a hand-driven `.iterator.next()` loop
is unaffected.

* **`concurrentPool` drained by push.** `concurrentPoolAsync` returns a
  marker iterable, and `fxPoolDrive` sits beside `fxStreamDrive` in
  `toListAsync` / `eachAsync` / `foldAsync`: when an all-consuming terminal
  owns the pool, each element is emitted from inside the pull's own
  continuation instead of crossing a per-element `Completer`. Completion
  ordering, eager refill, error position, and the slow-consumer buffer are
  unchanged; a pool used mid-chain keeps the pull path. **2.0 → 1.0
  microtasks per element**, and `completion-order-pool` goes from 1.07×
  behind RxDart to parity — the section's speed tally moves from 31 FxDart /
  6 tie / 4 RxDart to **31 / 7 / 3**.
* **`toStream()` without `async*`.** It was the last `async*` in `lib/`, and
  every `yield` crossed `_AsyncStarStreamController`. It is now a
  hand-written `sync` controller, every `add` issued from a future
  continuation or a controller callback. The generator's lock-step is
  preserved exactly — one element produced per element consumed, a paused
  subscription stops pulling, `break` in an `await for` stops production for
  good, nothing pulled before the stream is listened to. **`toStream()` now
  adds 0.0 microtasks per element.**

The second one did not move its benchmark, and the reason is worth
recording: `pipeline-into-stream` stays at ~1.06× because a stage-by-stage
count shows `chunk` and `toStream` each cost nothing per element and all
3.0 of that chain's microtasks belong to `mapConcurrent` — that is,
`concurrentAsync`'s ordered batching. That is the next target, and a larger
one, since `mapConcurrent` is the most repeated async idiom in the
comparison suite.

### Tests

`test/util/config_test.dart` runs `concurrentPool`'s completion ordering,
full drain of a fast source, and error propagation against *both* buffer
implementations, and guards the fix directly: quadrupling N must cost less
than 8× the time, which the `List` form fails at ~16×.

`test/stream/to_stream_test.dart` covers the two rewrites: the stream
bridge's lock-step, pause/resume, cancel, lazy start, error delivery and
single-subscription contract, and the pool terminals' element coverage,
completion order under a slow consumer, and error propagation — including
that the manual pull path still works while the push drive exists.

## 0.7.4

### Performance — the async pull machinery

An investigation of the RxDartComparison benchmarks RxDart was winning found
no algorithmic problem: all of them are async cases, and the entire gap was
per-element overhead in the pull protocol — microtask hops and future
allocations that a push `Stream`'s synchronous event dispatch never pays.
Three design fixes, identical API, laziness, ordering, and error behavior:

* **Wasted `await`s on synchronous callback results.** Every async operator
  awaited its callback's `FutureOr` result; in Dart, awaiting an
  already-synchronous value still schedules a microtask — one wasted hop per
  element *per operator layer*. Hot serial paths are now then-based with
  bare returns and an `is Future` guard, so synchronous results complete the
  pull directly (measured 1.4× on a sync-callback map, 1.8× on three
  stacked maps): `mapAsync`, `filterAsync`, `takeWhileAsync`,
  `dropWhileAsync` / `dropUntilAsync`, `scanAsync` / `scan1Async`,
  `flatMapAsync`, `ifEmptyAsync`, and the terminals `eachAsync` /
  `foldAsync` / `reduceAsync` (so `sumAsync`, `minAsync`, `countAsync`, …
  inherit it).
* **`SerialAsyncIterator` idle fast path.** The overlap serializer chained
  every pull off the previous pull's future even when nothing overlaps —
  the common serial consumer paid a hop per element for a guarantee it
  never used. An idle pull now enters the state machine directly; the chain
  only forms while a pull is actually in flight.
* **`fromStream` is a direct subscription bridge.** The old bridge stacked
  `StreamIterator` + the serializer + an async closure (~3 future layers
  per element). The new one listens once, completes the waiting pull
  straight from `onData`, and pauses whenever no pull is waiting — same
  contract (lazy subscribe on first pull, backpressure via pause, an error
  answers the pull that met it and ends the iteration), 2.1× on a drain.
* `usingAsync` caches its resolved iterator instead of re-chaining through
  the acquire future on every pull.

Then three structural changes, all internal — the public protocol, operator
signatures, laziness, ordering, and error behavior are unchanged:

* **Stage fusion.** A run of `map` / `filter` / `takeWhile` no longer stacks
  one iterator (and one future) per operator: the run collapses into a
  single fused pipeline that applies every stage inline on each pulled
  element. When a `Concurrent` marker arrives on a fresh iterator, the
  whole iteration is handed to the original unfused layering, so
  `concurrent(n)` behaves exactly as before.
* **An internal fast-pull path.** Iterators that can answer a pull
  synchronously now do (`FutureOr`, library-internal — the public
  `next()` still returns a `Future`), and the serial terminals
  (`toListAsync`, `eachAsync`, `foldAsync`, `reduceAsync`, `toStream`)
  loop on it. A fused chain over a synchronous source runs with no
  per-element futures at all. `flatMapAsync`, `scanAsync`, `usingAsync`,
  `timeoutAsync` and the stream bridge all participate; `timeoutAsync`
  additionally skips arming a timer for a pull that answered synchronously.
* **Subscription execution for stream-sourced chains.** When an
  all-consuming terminal sits on a chain whose source is a plain `Stream`,
  the chain now runs by subscription — stages execute in `onData`, an
  asynchronous stage pauses the subscription (the `asyncMap` discipline), a
  failing `takeWhile` cancels it — instead of pulling element by element.
  This is the push execution model applied under an unchanged pull API,
  and it is observably identical for a terminal that consumes everything.
* `concurrentAsync` fills its batch with one continuation per pull instead
  of `settleAll`'s `Future.wait` plus two wrapper futures per element.

Measured effects (AOT, N=10,000, RxDartComparison). Of the ten cases RxDart
led in 0.7.2, **six now tie or win** and none regressed:
`stream-into-pipeline` 12.63× → **1.34×** (tie), `crawl-the-pages` 2.94× →
**0.96×** (tie), `bound-the-stall` 1.31× → **1.01×** (tie), `cursor-lifetime`
1.14× → **1.01×** (tie), `price-or-fallback` 1.07× → **1.00×** (tie),
`per-row-retry` 1.08× → **0.93× (FxDart wins)**. The RxDart-faster count
across the section drops from 10 to 4 (31 FxDart / 6 tie / 4 RxDart).
DartComparison's async cases improved as well: `stream-windowed-alerts`
3.13× → 1.63× behind native, `paged-feeds-dedupe` 2.17× → 2.02×,
`rate-limited-import` 2.10× → 1.80×, `concurrent-enrichment` 1.36× → 1.24×.

The four still behind — `dependent-calls-in-sequence` (1.27×),
`latency-extremes` (1.11×), `completion-order-pool` (1.08×),
`pipeline-into-stream` (1.06×) — are dominated by genuinely asynchronous
per-element work (a real `await` per step, a completion-order pool, an
outbound `Stream` controller), where no amount of protocol trimming helps:
what is left is one future per element, which is what a pull protocol
fundamentally is.

### Tests

Library line coverage is now **100%** (2999/2999). A new
`test/async_fast_paths_test.dart` covers the machinery above as white-box
behavior: fused stages and their effect order, the `Concurrent` fallback on
every fused operator, subscription-drive error/cancel paths, the stream
bridge's buffering and error handling, and each operator's legacy path.

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
