## 0.8.11

Three additions on `parallel`, all of them about not paying the isolate hop
twice.

**`chunked: true`** — size the message from the source length so the
worker count is not repeated at the call site. `k = length ~/ (workers *
4)`, the formula the 0.8.10 page measured. Needs a `List`; a source
without a length throws, and `chunk:` / `chunked:` together throw.

```dart
await fx(rows).parallel(4, parseRow, chunked: true);
```

**`isolateMap2..5`** — run 2–5 CPU stages inside one hop. Two
`.parallel` calls copy every result back to the main isolate and out
again; compose the workers instead. Arity capped at 5, like
`zipOrAccumulate2..5`.

```dart
await fx(blobs).parallel(4, isolateMap2(decodePng, thumbnail), chunk: 64).toList();
await fx(rows).parallel(4, isolateMap3(parse, normalise, score), chunked: true).toList();
```

**`IsolatePool`** — spawn once, run sequential chains, kill in
`finally`. `parallel` otherwise starts isolates on first pull and tears
them down when that chain ends. `IsolatePool.using` is the bracket;
cancel of one `parallelOn` chain does not kill the pool.

```dart
await IsolatePool.using(4, (pool) async {
  final a = await fx(batchA).parallelOn(pool, parseRow, chunk: 256).toList();
  final b = await fx(batchB).parallelOn(pool, parseRow, chunk: 256).toList();
  return (a, b);
});
```

Unsupported on the web, same as `parallel`.

## 0.8.10

`parallel(n, worker, chunk: k)` — k elements ride one message instead of
one each. The port round trip is ~5µs, which is more than most callbacks
cost, and it is why the operator lost to a plain loop on anything but
very heavy per-element work. On 20k elements of ~0.4µs each, four
workers (a probe of that shape, not one of the three page cases):
**142ms → 3ms**, against 8ms for the same work inline. The batched
form is the first one that beats the loop it replaces.

What a batch does not change is what the caller observes. Order,
back-pressure and the position an error lands at are the unbatched
operator's: a worker that throws sends back the results it had already
finished, so the elements before the failing one are still emitted and
the raise happens on the element that actually failed. A batch is served
straight out of the list it arrives in, so it costs one future however
many elements ride it — and the fast-pull terminals answer from it
without a future at all. Two things do change, both documented: the
first element waits for its whole batch (so a `take(1)` wants a small
`chunk` or none), and an unsendable *result* fails its batch rather than
only its own pull.

**Is `parallel` worth it?** — a new page, and a third benchmark family
behind it. One CPU-bound job run five ways: a plain loop, hand-rolled
`Isolate.run` over slices, the fxdart chain on one isolate,
`fx(...).parallel(...)` at its default, and the same with `chunk:`.
Three cases, each sized so the plain-loop baseline runs ~5 s, varying the
one number that decides the answer — the cost of a single element — from
~250 µs (`password-rehash`) through ~37 µs (`image-tiles`) to ~3.5 µs
(`log-fingerprint`), against the ~5 µs it costs to hand one element to
another isolate.

The page exists because "use isolates for CPU work" is not advice, it is
a slogan. Measured, on 10 workers: at ~250 µs an element `parallel` runs
6.3x the plain loop and `chunk` adds nothing worth having. At ~3.5 µs it
runs **2.5x slower** than the plain loop — 13.7 s against 5.4 s — and the
same operator with a chunk runs **4.7x faster**. One parameter, an 11.8x
swing. In the middle, at ~37 µs, 3.2x becomes 7.1x.

More workers do not rescue the slow row, which is the part worth knowing:
sweeping the pool from 1 to 10 leaves the unchunked form flat (768 ms →
873 ms, slightly *worse*) while the chunked form scales 5.4x. Every
element costs two message copies, a port event and a completer on the
*main* isolate — one thread, the one part that cannot be parallelised —
so `chunk` is not about making coordination cheaper but about there being
less of it. The formula `n ~/ (workers * 4)` always yields 40 messages
with ten workers: `chunk: 2500` at the N=100,000 sweep (vs 100,000
trips), `chunk: 37500` at the headline N=1,500,000 (vs 1.5 million
trips).

The chunked row also beats the hand-rolled `Isolate.run`-over-slices it
is measured against — 2.1x on `image-tiles`, 3.3x on `log-fingerprint` —
because slicing copies a whole slice up front while its isolate waits,
where a chunked pull overlaps the copying with the computing. On
`password-rehash`, whose elements are three ints, there is nothing to
copy and the three isolate rows sit within a few percent (hand-rolled
6.65×, chunked 6.57×, default `parallel` 6.27× — about 6% behind
`Isolate.run`).

Each case also runs at N=10,000 and N=100, so the crossover is on the
page rather than asserted — `password-rehash` still wins at 100,
`log-fingerprint` has already lost at 10,000. It is total work that
decides, not element count. Every variant calls the same top-level
worker and the runner refuses a case whose checksums disagree, so the
rows are always different ways of computing one answer.
`benchmark/cases-parallel/`,
`dart run benchmark/run_parallel_benchmarks.dart`.

Fixed alongside it: `parallel` silently **dropped `null` elements**.
`null` doubled as "the source is exhausted" in the pull path, so on a
nullable `A` a genuine null was read as the end of the source —
`[1, null, 3, null, 5]` came back as `[1, 3, 5]`. There is a sentinel
for that now, and a null is an element on every path.

Map-only fused async runs honour `Concurrent` in-place instead of
dropping to the unfused layering — the headline
`toAsync().map(f).concurrent(n)` shape. Paired A/B (AOT, rounds=20)
re-measured against the merged baseline: `bounded-concurrency` −1.24%
against a +0.39% native control, `concurrent-enrichment` −1.07% against
−0.08%. (It read −2.47% before `parallel` landed the cancel chain in
between; the effect is real either way, the magnitude is baseline-
dependent.) Not a suite flip: a hand-rolled worker pool is still ~10%
faster at that scale. The remaining hop is `concurrentAsync`'s
ordered-batch machinery, not the map layer.

`parallel(n, worker)` — the CPU twin of `concurrent(n)`. A reused pool
of `n` isolates, source order kept. Prefer a top-level or static
worker; a capturing closure is fine when every capture is sendable, and
throws at spawn only when one isn't. A worker may return a `Future`
(`FutureOr`, same shape as `mapConcurrent`); a sync callback is still
the fast path. Nested `parallel` inside an async worker is allowed:
that isolate spawns its own pool, and cancel of the outer chain shuts
the nested pool down before the worker isolate is killed. One level of
nesting is the contract — a third nested `parallel` is SIGKILL'd with
its parent, so it cannot shut down *its* children. Unsupported
on the web (use `concurrent`). `workers == 1` still leaves the main
isolate.

The pool spawns its isolates together, talks to them over
`RawReceivePort`, does not spawn at all for an empty source, and sizes
the pool to `min(n, length)` when the source is a `List`. An unsendable
input or result fails that pull with `ArgumentError` instead of hanging.
`parallelWorkers` is the VM processor count when you do not want to pick
`n`; `mapParallel` is the same operator under the name that sits next to
`mapConcurrent`. The 101 page `concurrent or parallel` is the decision:
I/O stays on `concurrent`, CPU goes to `parallel`, and a cheap callback
(`x + 1`) is a loss on the isolate hop.

A source that throws after the pool has started now shuts the pool
down too — previously only worker errors did, and holding the
iterator kept the process alive.

An early stop now releases the source through the whole operator chain.
`StreamPullCancel` existed, but only the terminals honoured it — every
lazy operator in between dropped it, so a `take` / `head` / `find`
behind `drop`, `chunk`, `windowed`, `pairwise`, `flatMap`, `flat`,
`expand`, `concat`, `append`, `prepend`, `indexed`, `uniqAdjacent`,
`slice`, `timeout`, `mapConcurrent`, `concurrentPool`, `zip` or `zip3`
left the source running. That leaked a `fromStream*` subscription
before; with `parallel` it leaves a pool of isolates alive and the
process never exits.

Every operator iterator now forwards `cancel` upstream, and the ones
that end on their own terms release the source themselves — `zip` /
`zip3` at the shortest side, `slice` at its end index,
`takeUntilInclusive` at its predicate — since no downstream cancel is
coming. `take` holds its release until pulls it already issued have
settled, so a cancel under `concurrent(n)` cannot truncate values that
were already on their way.

A terminal that stops early or throws releases the source too. `nth`,
`firstNotNullOf` and `consume(n)` stop early with the source still live;
`each`, `fold`, `reduce` and `toList` end the drain the moment their own
callback throws, and nothing downstream is left to send a cancel. Every
aggregate built on those three — `sumBy`, `minBy` / `maxBy`, `groupBy`,
`countBy`, `indexBy`, `foldBy`, `partition`, `topBy`, `tee` and the rest
— inherits the fix.

`cancel()` now returns a future that is worth awaiting. Each layer used
to hand back `Future.value()` while the release it started ran
unobserved, so `await it.cancel()` resolved before the resource was
let go, and a `using` whose release *threw* on an early stop killed the
program with an unhandled async error — after the caller had already
been handed its result. The release future is carried up the chain, a
failing release is reported to the terminal that is still waiting for
one (a full drain always did), and on the error path the error already
in hand still wins.

`test/async_cancel_test.dart` covers the chain per operator: 20 of its
37 cases fail without this change.

`fxdart_lints` — a second package, same version, so the core stays
zero-dep. Four analyzer diagnostics that name the fix: unbounded
`Future.wait` on a mapped fetch, a bare `catch` inside `either`,
returning a lazy chain from a raise block, and `attempt` before
`retryOn`. Dev-dependency only (`custom_lint` + `fxdart_lints`).

101 now opens on a decision, not on `map`. `whichSurface` is the first
lesson: data in hand → `fx()`, I/O with a bound → `concurrent` /
`mapConcurrent`, events over time → `fxEvents`, failures the caller
handles → `Either` on the surface you are already on. Two job tutorials
— debounced search, bounded concurrent fetch — are section 15. The
pipelines skill no longer treats `fxStream` as the push entry; a third
skill, `fxdart-events`, covers time. Typed-errors documents the channel
rule: `attempt` after `retryOn`, never before.

Events-layer `Either`, on the value channel: `mapRight` / `mapLeft`,
`filterOrElse`, `alt` / `orElse` / `recover`, `getOrElse`, and
`flattenEither` (the nest `attempt` after `mapEither` produces). Each
is per-event — a `Left` is replaced, not a stream switch. The
boundary pair `attempt` / `raiseLefts` and the extracts `rights` /
`lefts` / `separated` landed in #22 on this same unreleased version.

Docs playground: a DartPad DDC upgrade (3.12.2 → 3.13.1) left native
comparison prebuilts — keyed `nolib`+source, so they never rotate with the
library — running on a newer `dart_sdk_new.js`. The first symptom was
`Unsupported operation: NaN` from `Future.delayed` on live-search's native
panel (and any other native snippet still sitting on 3.12.2 JS). The runner
now refuses a prebuilt whose DDC header does not match the runtime and falls
back to a live compile; the precompiler rebuilds anything compiled by
another DDC, and the Pages cache key includes DartPad's `dartVersion` so a
future upgrade misses instead of restoring the stale JS.

GitHub Actions: `checkout`, `cache`, `upload-pages-artifact`, and
`deploy-pages` now use their Node 24 majors so the Pages workflow is not
forced off Node 20.

Comparison playgrounds are a true 50/50 split: long unwrapped lines no
longer inflate the left grid track (CodeMirror now wraps, and the grid
uses `minmax(0, 1fr)`).

`top-expenses` "Why they differ" now matches the current `sortBy`:
stable unboxed merge of a `Float64List`, not the old index
permutation / `List.sort`. The 2.6× gap vs `sortedBy` is the cost of
extracting and boxing a `num` key inside every comparison.

## 0.8.9

Documentation fix: the FxDart logo in the README was not displaying on GitHub
due to a blocked raw.githubusercontent.com URL. Switched to the GitHub Pages URL
which is properly CORS-enabled.

## 0.8.8

0.8.7 gave the chain a getter spelling and fused two lazy stage boundaries.
This release is mostly about a different surface: the **events layer** —
`FxEvents`, the push half of the library that sits on a Dart `Stream` — grows
from a partial catalog into one that covers the jobs an Rx user actually asks
for. Seventy-eight new entry points, twelve of them constructors, and one
existing operator changes behaviour.

Two smaller, independent halves ship alongside it: `sortBy` stops paying
`compareTo` per decision on ordinary double keys, and `sequenceEqual` arrives
on the strict surface. And the release itself is now performed by a tag —
`dart pub publish` is not run by hand any more.

### The events layer, by group

Everything below is new. The naming rule from 0.8.7 holds throughout: an
operator that takes a *selector* returning a `Stream` is spelled `xOn`, one
that takes a fixed shape is spelled plainly, and the `FxEvents` wrapper is
what they hang off.

| group | entry points |
|---|---|
| constructors | `FxEvents.value` `.empty` `.never` `.error` `.fromFuture` `.periodic` `.timer` `.defer` `.generate` `.fromPattern` `.using` `.create` |
| shaping | `peek` `takeWhile` `dropWhile` `skipWhile` `takeUntilInclusive` `takeRight` `dropRight` `whereType` `cast` `expand` `uniq` |
| lifetime | `handleError` `timeout` `whenComplete` `ifEmpty` `defaultIfEmpty` `throwIfEmpty` `startWithAll` `endWith` `endWithAll` |
| terminals | `drain` `last` `nth` `any` `every` `fold` `reduce` `forEach` |
| combining | `switchLatest` `flattenMerge` `flattenConcat` `exhaustLatest` `zipAll` `withLatestFromAll` `connect` · top-level `combine` `concatEager` |
| selector timing | `debounceOn` `throttleOn` `delayOn` |
| retry / repeat | `retryOn` `retryOnError` `repeat` `repeatOn` |
| windowing | `windowOn` `windowCount` `windowEvery` `windowToggle` `windowWhen` `chunkToggle` `groupsBy` |
| scan | `mergeScan` `switchScan` `expandEach` |
| notification | `materialize` `dematerialize` `sequenceEqual` |
| sharing | `connectable` `refCount` `shareReplay` |
| pulling a `Stream` | `pullLatest` `pullChunked` `pullNext` · top-level `fromStreamLatest` `fromStreamChunked` `fromStreamNext` |

New public types: `EventEmitter`, `StreamEvent` / `Next` / `Err` / `Done`,
`GroupedEvents`, `ConnectableEvents`, `CombineSpec`, `ReplayValue`,
`CompletionValue`.

This landed as one PR rather than a dozen, which is against this repository's
own preference for small ones. The reason is that the operators share the
naming rule, the lifetime rules and the wrapper: split, `main` would have
carried a half-catalog whose second half redefined what the first half meant.

### `share()` behaves differently, and that is the break

`share({bool reset = true})`. The default **resubscribes** when the last
listener leaves *before* the source completes. 0.8.7 closed forever on the
first cancel; `share(reset: false)` is that old path, kept and spelled.

What changes for existing code:

- A widget that cancelled and came back expecting a dead stream now sees a
  **new run** of the source.
- After a *successful* complete, a later listener is still handed a closed
  stream — completion is not undone by `reset`.
- A `Stream.fromIterable` that already finished still looks empty on the
  second listen, because the source itself is spent.

`retryOn` / `repeat` re-listen the same `Stream`, so a spent
single-subscription `StreamController` still cannot be replayed. That is
documented rather than worked around: use `FxEvents.defer`, `Stream.multi`,
or `FxEvents.retry(factory)`.

Window and `groupsBy` inners **complete silently** when the outer is
cancelled, following RxJS 9 rather than raising `ObjectUnsubscribedError`.

### Four named ways to pull a `Stream`

`fromStream` pauses the subscription and never drops. The three additions name
the other policies, so the choice is at the call site instead of in a comment:

| | while the consumer is between pulls |
|---|---|
| `fromStreamLatest` | each arrival replaces the single unread slot — a same-turn burst yields only its last value |
| `fromStreamChunked` | arrivals accumulate and are yielded together as a list; empty lists are never yielded |
| `fromStreamNext` | arrivals are **dropped**; only values that land while a pull is waiting are yielded |

`fromStreamNext` can yield nothing at all from a synchronously completing
source, which finishes before the first demand slot is installed. That is the
policy, not a bug.

### `sequenceEqual` on the strict surface

`sequenceEqual(a, b, [eq])` and `sequenceEqualAsync`, with chain methods on
both `Fx` and `FxAsync`, and `FxEvents.sequenceEqual` for the push side. After
Rx's operator of the same name; the optional `eq` replaces `==`.

### `sortBy` on double keys: a VM compare instead of `compareTo`

`paginated-products` sat at 1.18× behind native. Its filter is already the
SDK's `where().toList()`, so what was left is `sortBy`'s stable merge of ~900k
double keys. Two changes, neither of which touches a public spelling:

1. The merge's destination buffer is `List.filled` with a dummy rather than
   `List.of(items)`. The first pass overwrites every slot, so that copy was
   wasted work.
2. Ordinary finite double keys compare with `<=` / `>=` — a VM compare —
   instead of `compareTo`, with ascending and descending as separate inner
   loops so the direction branch runs once per merge block rather than once
   per decision.

**The total order is still the contract.** `<=` does not agree with
`compareTo` on NaN or on `-0.0`, so the extraction loop tests for both while
each key is already in a register, and one such key anywhere drops the whole
array back onto `compareTo`. This is not hypothetical: `sortBy((x) => -x.key)`
is this repository's own descending spelling, and negating a `0.0` key
produces `-0.0`, so a single zero-valued row is enough to lose the fast path —
correctly, but silently.

Paired A/B against `main`, `--rounds 20`, `--scale full`. Two clean-control
readings of `paginated-products`: **−5.49%** and **−5.67%**. `top-expenses`
read −2.79%. No other measured case moved past 3%.

Rejected, with the readings that rejected them: an `Object?` workspace to skip
the covariant `[]=` (**+5%** here), and `vm:prefer-inline` on the extract loop
(−7% here, but **+21%** on `top-expenses`).

### The release is a tag now

`.github/workflows/publish.yml` publishes to pub.dev on a `v*.*.*` tag, over
OIDC — no credential is stored in the repository. A guard job runs first: the
tag must equal `pubspec.yaml`'s version, `CHANGELOG.md` must carry a section
for it, and `dart analyze lib` + `dart test` must pass on that exact commit,
because a tag need not sit on a commit that ever went through `main`.

This exists because thirty versions were on pub.dev and four of them had a
tag. `0.8.6` cannot be checked out, `git diff v0.8.5..v0.8.6` does not
resolve, and a bisect for a perf regression had no range to walk.
`CONTRIBUTING.md` now walks the whole path, from topic PRs to the tag.

### Documentation

Eleven new 101 pages — `combine`, `debounceOn`, `fxEventsCreate`, `groupsBy`,
`materialize`, `mergeScan`, `retryOn`, `shareReplay`, `switchLatest`,
`whenComplete`, `windowOn` — with Korean overlays in the same commit, and the
four `fromStream*` policies added to the Stream bridges page. `share.md` now
teaches the `reset` contract instead of documenting 0.8.7's close-forever
behaviour as a feature.

### What is deliberately not here

No second `Observable` type, no `SchedulerLike`, no `rxjs/ajax` or WebSocket
wrappers, and no `combineLatest2…9` — `combine` takes a list of specs instead.
`animationFrames` stays out of core, since it needs Flutter and `dart:ui`.
`observeOn` / `subscribeOn` are skipped until an example demands them.

**The events layer carries no performance claim.** Nothing in it was
A/B-measured; the only measured change in this release is `sortBy`. The
`RxDartComparison` bars are unchanged.

## 0.8.7

0.8.6 measured what a *strict* terminal costs when it hides the caller's
callback behind an iterator field, and removed that cost from twelve of them.
This release does the same for two *lazy* stage boundaries — `windowed`/`chunk`
followed by `map`, and `scan` followed by `map` — with the same instrument and
the same rule about what may be claimed. It also adds nine operators, four of
them asked for by the published example corpus and five by the API's own
symmetry, fixes three defects in API that shipped in 0.8.6 or earlier, and
makes the Korean documentation checker a gate instead of a script nothing ran.

This release has a second, independent half: `fx(xs)` gains a **getter
spelling**. `.fx`, `.fxAsync`, `.fxEvents` and the `fx`-prefixed wrapper twins
put the chain one dot away from the collection that feeds it, with `fx()` still
the documented spelling and a naming rule that keeps the events layer from
colliding with anything else in the file. The two halves touch no common code;
they ship together because neither had reached pub.dev on its own.

### `windowed`/`chunk` → `map` is one stage, and the window copy is the SDK's

`windowed(step: 1)` emits one window per *source* element, so the boundary
between it and a following `map` is one of the few in the library still paid at
the full element rate — the shape §B of the 0.8.6 analysis identifies as the
only remaining headroom. `FxMapFusable` joins `FxUniqFusable`,
`FxUniqByFusable` and `FxFilterFusable`; `map()` probes it **once when the
chain is built, never per element**, which is what keeps the 50 cases that call
no `windowed`/`chunk` at zero cost. `_WindowIterable` answers it, and the
window is built and the callback applied inside one `moveNext`.

**What it is not.** `f` still lands in a field of the fused node, exactly as it
would in a `map` stage, so the caller's closure literal is *not* visible at the
changed hop and `f` is *not* devirtualized. Nothing here got a
`vm:prefer-inline`, for the reason stated two sections up.

**The fusion is the smaller half, and the measurement says so.** Adjudicated
separately, `smoothed-zone-changes` at `--scale 10000`:

| change | clean-control readings | median | spread |
|---|---|---|---|
| stage fusion alone | −1.69% · −2.90% · −1.29% · −6.09% · −2.89% · −2.79% · −3.26% · −3.49% | −2.90% | 4.8 pts |
| fusion **and** the SDK window copy | −9.98% · −9.31% · −9.79% · −8.98% · −10.23% · −10.49% · −9.35% | −9.79% | 1.5 pts |

Fusion alone would have failed the 5% bar. Two thirds of the win is removing a
**covariant store check per element** from the window copy:
`List<A>.operator[]=` takes a covariant parameter and `A` is a runtime type
argument, so filling a pre-sized window from package code cannot elide the
check. `List.sublist` reaches the VM's own `_slice`, which copies into an array
carrying no type argument. Measured AOT, 1,000,000 windows of `double` built
and summed:

| window build | size 3 | size 7 | size 10 |
|---|---|---|---|
| pre-sized fill, element by element | 16.4 ms | 35.4 ms | 51.8 ms |
| **`List.sublist`** | **14.1 ms** | **26.7 ms** | **36.0 ms** |
| `List.filled` + `setRange` | 21.1 ms | 44.0 ms | 62.4 ms |
| `getRange().toList(growable: false)` | 29.1 ms | 55.0 ms | 76.9 ms |

The last two rows are why this cost a contract (below): **no bulk copy that
preserves a fixed-length window is faster than the loop it would replace** —
both go through `Lists.copy`, an element loop behind an interface `[]=` call.
Note also that it removes most of the case's run-to-run spread, which is the
more useful property: the fill was producing a long right tail.

### Result — paired A/B against `main` (0.8.6 + the strict terminals)

Same instrument, `--ref main`, `--rounds 30`, `--scale 10000`, every reading
with its paired `native` control. **Ten runs, ten clean controls, none
excluded:**

| case | fxdart, every clean-control reading | control |
|---|---|---|
| `smoothed-zone-changes` | **−8.74%** · −7.95% · −8.00% · −7.07% · −9.97% · −7.63% · −8.83% · −10.39% · −7.70% · −7.47% | −0.76% · +0.25% · −0.33% · +0.25% · −0.74% · +0.27% · +0.74% · +0.65% · +1.35% · +0.13% |
| `paginate-users` | **−11.67%** · −11.15% · −11.04% | −0.80% · +0.60% · −0.33% |

Median −7.98% and −11.15%. The `--all` sweep confirms both independently at
−9.82% (control +0.80%) and −10.81% (control −0.44%). `paginate-users` is
`chunk(10)` → `map` → `toList` and also clears the bar at `--scale full`, at
−10.50% (control +0.37%).

Earlier exploratory rounds at `--rounds 12` are excluded from that table
entirely rather than pooled with it; three of them had drifted controls
(+4.71%, +2.23%, −2.20%), and the one fusion-only run whose control moved
−2.15% is likewise excluded from the table above it.

**The win is scale-dependent, and does not carry to `--scale full`**, where the
same case reads +0.26% / −0.32% / −0.08%. At 1,000,000 elements `sublist`'s
second allocation per window — a `_GrowableList` header over the copied array,
where `List.filled` allocated one object — costs about what the store checks
save. *[Inference from the two measurements; not separately instrumented.]*
Nothing regresses there, and the claim above is scoped to `--scale 10000`.

**No regression** — swept with `--all` at both scales, and re-swept from
scratch after the `scan` fusion below landed, so the figures cover both
changes together. Because a single noisy case fails the whole invocation, the
verdict is read per row from `benchmark/.build/ab/report.md` against that row's
*own* control, and every row whose control drifted was then re-measured
individually — 31 of them across the two scales, plus every row that moved past
2% with a clean control.

At `--scale 10000`, 51 of 53 rows came back usable in one pass. The largest
positive against a clean control anywhere in that sweep is `top-log-level` at
+2.14%; the other movement is all the other way (`average-basket` −4.39%,
`duplicate-transactions` −3.27%, `sensor-anomalies` −3.25%, `food-spending`
−2.45%). The two unusable rows re-measured flat: `bounded-concurrency`
−0.05% / −0.10% / −0.08%, `no-spend-streak` −1.36% / +0.82% / −2.02%.

At `--scale full`, 47 of 53 came back usable, and the six that did not
re-measured flat as well — `monthly-ledger-report` +0.07% / −0.14%,
`multi-currency-report` −1.54% / −2.78%, `valid-emails` +0.01% / −0.71%, and
`smoothed-zone-changes` not adjudicable there for the reason below.

The five cases fxdart already wins by 1.8x–4.2x are flat: `restock-plan`
+1.54%, `monthly-ledger-report` −0.14%, `top-expenses` −0.12%, `top-log-level`
+1.16%, `top-merchants` −7.45% in the final sweep — see below, that number is
spread, not a win.

Three rows produced a single clean reading past 3% and none of them holds up:

| case | clean-control readings at `--scale full` | median |
|---|---|---|
| `top-merchants` | 13 readings from −7.45% to +4.20% | +1.81% |
| `sensor-anomalies` | −0.50% · +0.92% · +2.09% · +4.89% | +1.5% |
| `sparse-timeseries` | −1.81% · −0.72% · +0.15% · +1.74% · +2.38% · +3.45% | +0.95% |

`top-merchants` was isolated rather than waved through, because it is a canary.
It calls `map()` **once per million elements**, so no per-element mechanism
exists; A/B'ing the two commits separately puts the window-copy commit at
+0.34% / −0.23% / +0.70%, and with only the two-line `map()` probe removed and
every new class left in place it reads −0.02% / −0.15% / +0.67%. At most ~1
point is attributable to compiling a generic type test into `map()` at all.
The rest — and the −7.45% — is this case's spread at 1,000,000 elements.

The general shape, worth stating because it is the instrument's real
resolution: at `--scale full` a single reading on a mid-size case can land ±4
points from its own median *with a clean control*, so no individual reading at
that scale should be read as a result. Medians over 4–6 clean readings are all
inside ±2%. Both claims in this release are made at the scale where their case
measures tightly, from ten and twelve readings respectively.

The two sweep rows that looked worst were artifacts and neither reproduces:
`food-spending` read +13.14% off a clean control and then
+0.79% / −3.97% / −4.67% / +2.24% / +0.00%; it is a 34 µs case, the smallest in
the suite. `date-window-spend` read +9.22% and then ±1%. Neither calls `map`,
`windowed` or `chunk` at all.

`recent-errors` could not be adjudicated at `--scale 10000` at all: seven
attempts, seven drifted controls, on a 60 µs case against a 40 µs control. At
`--scale full` it is clean and flat, +0.08% (control +0.83%).

`weekly-sensor-averages` is **not claimed**, and this release adds the cleanest
proof yet of why. It is on the changed path, and against clean controls it read
**−9.32%**, then **−12.88%**, then **+11.34%**, then +8.08% [+1.56%] · −7.18%
[+0.66%] · +9.10% [+0.41%]. A change cannot make a case 13% faster and 11%
slower; the sign flip is the bimodal-per-process behaviour already recorded for
it below, and more rounds do not touch it because the modes are per *process*,
not per round.

Its safety is therefore argued **structurally instead of measured**. It is
`chunk` → `map`, so it takes the fused iterator. No work was added to any
`moveNext` on its path: the type test resolves once when the chain is built, the
fused `moveNext` does strictly less per window than the two it replaces (one
window built, one callback applied, no `current` write and no cross-iterator
call), and its window copy is the same `_windowSlice` the unfused path uses. The
one path this release makes slower — the wrapped ring branch — is not reachable
from `chunk`, which never wraps.

`smoothed-zone-changes` cannot be adjudicated at `--scale full` either, and for
a different reason: its **`native` side** is the unstable one there. The
control drifted −11.65% / −10.86% / −11.99% across three consecutive runs of
the same byte-identical binary pair. Measured directly, interleaving all four
binaries in one session, native's median/min spread at 1,000,000 elements is
**100%–174%** against fxdart's 1.3%–3.6%. That is the same defect
`benchmark/results/results.json` recorded as +78.8%, reproduced on different
hardware and a different SDK.

It matters beyond this release, because `HEADLINE_SCALE = "full"` is what
`content/comparison/smoothed-zone-changes.md` publishes a verdict from. On the
cleanest statistic either side offers, fxdart **loses** this case at every
scale — measured here, before and after:

| scale | statistic | before (`main`) | after |
|---|---|---|---|
| 10000 | median | 2.02x native | **1.81x** |
| 10000 | min | 1.89x native | 1.83x |
| full | median | 0.55x native *(native's tail, not a win)* | 0.58x |
| full | min | 1.16x–1.41x native | 1.18x–1.52x |

The median at `--scale 10000` is the honest headline and it improved. The
`min` barely moved: what this change mostly does is pull the typical case down
to the best case rather than lower the best case. The published `verdict:
fxdart` is an artifact of native's right tail and is left for a separate
change, since `content/` is owned elsewhere.

### `scan` → `map` is one stage too, and it was the bigger win

`FxMapFusable` cost one interface, so the second implementor was nearly free.
`scan(f, seed, xs).map(g).toList()` crossed **three** boundaries at the full
element rate — source into `_ScanIterator`, `_ScanIterator` into `_MapIterator`,
`_MapIterator` into the inherited `toList`, which pulled every element back
through the chain because a `_ScanIterable` is not a `List`. `_ScanIterable`
now answers `fxFuseMap`, and the fused node's `toList` is a single loop with the
accumulator in a **local**, resolving its source shape once: an indexed walk for
a `List` range, a counted walk for `range()`, the pulled loop otherwise.

Same caveat as above, for the same reason: `f` and `g` both land in fields of
the fused node, so **neither callback is devirtualized**. Boundaries only.

It accumulates with `<C>[]` and `add`, deliberately, rather than the pre-sized
`List<C>.filled` + `out[i + 1] = …` that `_ScanIterable.toList` still uses for
the unfused case. That is the covariant-store cost again, and it is worst
exactly here: for a **record** element type the check is structural rather than
a class-id compare, which `map.dart` measured at 394 ms against 220 ms at
N=1,000,000. Both cases below have record element types — `(String, double)`
and `(int, double)`.

`--ref main`, `--rounds 24`, `--scale full`. **Twelve readings, twelve clean
controls, none excluded:**

| case | fxdart, every clean-control reading | control |
|---|---|---|
| `running-balance` | **−10.17%** · −9.42% · −10.76% · −9.99% · −9.63% · −10.10% | +0.71% · +1.50% · +0.77% · −0.07% · +0.08% · +0.24% |
| `compound-interest` | **−5.89%** · −6.79% · −5.50% · −7.06% · −7.18% · −6.24% | −1.09% · −1.16% · −0.22% · −0.78% · −0.42% · −0.02% |

Medians −10.05% and −6.52%; the `--all` sweep independently read −11.06%
(control −1.11%) and −7.73% (control −0.81%), and `compound-interest` also
clears the bar at `--scale 10000` at −6.07% (control +1.06%).

The design estimate for this was 2.7%–6.5%, derived from three boundaries at
1.8–4.0 ns each against these cases' 237–276 ns per element — both of which are
dominated by `toStringAsFixed` and `padRight`, which is why so little was
expected. Measured, it is 5.5%–11.1%. The estimate was conservative; the extra
is not attributed here, because nothing was instrumented that would say which
of the three removed boundaries, the removed `late` accumulator field traffic,
or the removed growth reallocations in the inherited `toList` accounts for it.

Worth recording: `_ScanIterable.toList`'s pre-sized `List` path is reached by
**no** benchmark case — `scan` is followed by `map` in these two, by `drop` in
`restock-plan` and `rate-limited-import`, and by `max()` in `no-spend-streak` —
so it has never been measured by this instrument at all, and this change does
not touch it.

### The two unadjudicable cases, under these changes

`weekly-sensor-averages` is now on the new sync `chunk` → `map` path described
above, but remains unadjudicable because its cost is bimodal per *process*.
`stream-windowed-alerts` uses the async `chunk` → `maxBy` path and remains
untouched by the sync changes. Both still allocate one list per window.

### Five convenience operators

All additive, each with an `*Async` twin and an `Fx` / `FxAsync` chain member.

- **`mapNotNull`** (lazy) — `map` and `compact` as a single stage.
  `compact(map(f, xs))` stacks two lazy stages, so every surviving element
  crosses two `moveNext`/`current` boundaries instead of one. Here `f` both
  transforms and selects: the `filter_map` shape `takeUniqBy` already uses for
  its key extractor. `B extends Object`, so a `null` from `f` means *skip this
  element*, never *yield null*.
- **`unzip`** (strict) — `zip` had no inverse. Strict by necessity: two lazy
  views over one source would have to buffer everything the lagging one has
  not reached, the cost `fork` pays. Both lists fill in one pass.
- **`product` / `productBy`** (strict) — the numeric aggregate family had only
  `sum`/`average`. Empty input is `1`, the multiplicative identity: it is the
  only value that keeps `product(concat(xs, ys)) == product(xs) * product(ys)`
  true when one side is empty, exactly as `sum`'s empty `0` does for addition.
  Same unboxed int-then-double accumulation as `sum`, so an all-int input
  stays an `int`.
- **`none`** (strict) — the third quantifier beside `every`/`some`, so a
  universal no longer has to be written as the negated existential `!some(f)`.
  It does not collide with `SingletonRaise.none()`: that one is an instance
  member and this one a top-level function, and inside the class body the
  member wins regardless of what the barrel exports.
- **`firstNotNullOf`** (strict) — Kotlin's `firstNotNullOfOrNull`. `find`
  returns the *element*, so reaching the projection of the first match cost
  either a second call to the projection or a hand-written loop.

No benchmark claim is attached to any of them. `mapNotNull`, `productBy`,
`none` and `firstNotNullOf` carry `vm:prefer-inline` and the indexed-`List`
branch because they take a caller callback and their measured siblings ship
that pair together; `unzip` and `product` take no callback and get neither.

### Three defects in already-published API

- **`Fx.isEmpty` never returned on an unbounded chain.** It was `size() == 0`,
  an O(n) walk, where Dart's own `Iterable.isEmpty` is O(1) — so
  `fx(cycle([1, 2])).isEmpty` hung. `isEmpty` and `isNotEmpty` now delegate to
  the `Iterable` members, which ask the source for one element and stop.
  `Fx.length` is deliberately left as a full walk: O(n) is inherent to
  counting a general `Iterable` (it already takes `List`/`Set.length` when it
  can), so unlike `isEmpty` it still does not terminate on an unbounded
  chain — by construction, not by defect.
- **`FxNum.min()` / `max()` disagreed with the members that shadow them.** A
  member redeclared on an extension type wins over every extension on that
  type, so `fx(xs).min()` runs `Fx.min` and never reaches the extension. The
  extension is still reachable through explicit extension application —
  `FxNum(fx(xs)).min()` — which is what the `// coverage:ignore-line` was
  papering over, and there an empty chain returned `double.infinity` while the
  member threw `StateError`. Both spellings now throw `StateError`, and the
  extension is pinned by a test instead of excused by an ignore comment.
- **Three `TODO(port):` markers rendered on pub.dev.** They sat in the public
  dartdoc of `isUndefined`, `isArray` and `isObject`, explaining to nobody in
  particular what those deprecated aliases are for. They now say it as
  documentation.

### Four more operators, from the published examples

Additive API. Each has an `*Async` twin and `Fx` / `FxAsync` chain members,
except `toPairs`, whose source is a `Map` — it is a chain *entrance*, not a
chain step.

- **`topBy` / `bottomBy`** (strict) — the k largest (smallest) by key in one
  boundary pass, instead of sorting everything and then taking `k`. The result
  is in descending (ascending) key order and a tie is won by the element seen
  **first**, so no second sort and no tie-breaking key is needed. `k <= 0` is
  empty, a `k` past the end is everything, ordered. The boundary is kept by
  insertion, so this is for a small `k` over a large input. fxdart extension,
  not a port — the shape is Python's `heapq.nlargest`, Rust itertools'
  `k_largest_by_key`, Guava's `Ordering.greatestOf`. No benchmark claim is
  attached to it.
- **`toPairs`** (strict, `Map`) — the inverse `fromEntries` never had, so a
  `Map` from `groupBy` / `countBy` / `foldBy` / `indexBy` can be continued as
  a chain without re-entering through `fx(m.entries)` and converting
  `MapEntry` back to a record by hand. Named after Lodash rather than
  `entries`, which is a common local variable name and the barrel exports
  every top-level name unprefixed.
- **`mapCatching`** (lazy) — per-element error recovery, the element-wise
  partner `catching` never had while `retry` already had `mapRetryAsync`. The
  raise signal is **rethrown, not recovered**: it delegates to `catching`, so
  a `raise` crossing the callback still short-circuits the enclosing
  `either {}` / `nullable {}` instead of being swallowed into a recovered
  value. RxDart spells this `onErrorReturnWith`.
- **`mapAccum`** (lazy) — n values in, n values out: `scan` without the seed in
  the output, so the trailing `.drop(1)` goes away. Not a re-proposal of
  `scan`: `scan` and Kotlin's `runningFold` emit the seed and produce n+1
  values, `mapAccum`, Rust's `Iterator::scan` and Haskell's `mapAccumL`
  produce n. Argument order matches `scan` deliberately, so swapping one for
  the other is a one-word edit.

### Korean documentation, and the translation checker that now guards it

`tool/check_translation.dart` reported 306 problems of which 224 were false,
which is the same as reporting nothing. Three causes, all in the checker:

- `heading` was listed as a verbatim key, while `build_docs.dart` classifies it
  as prose alongside `title`/`description`. That one line produced 115 of the
  Korean reports and 110 of the Spanish.
- A tutorial title of the form `<fn> — FxDart 101` was assumed to be an
  identifier throughout. It is only verbatim when the part before the brand
  suffix is a single identifier: 150 of the 167 tutorials stay verbatim and the
  17 prose titles become translatable.
- The tag regex matched `<` inside code, so a chapter line like
  `<- parseId(raw) }` was read as a tag. Fenced blocks and inline code spans
  are stripped before tags are counted.

Run with no path arguments it now checks all ~300 English pages rather than
only `tutorials/`, so a locale that is missing a page entirely is reported as
`missing` instead of passing in silence.

With the checker trustworthy, 25 real defects in the Korean translation are
fixed: tag order and count in `maxBy`, `minBy` and six other pages (Korean word
order puts `<em>`/`<code>` in different places than English, and the `fxEvents`
name-collision paragraph — twelve code tags — was missing outright), six
identifiers that had been translated inside `<code>`, chapter 13's
`ceil(count / n) × delay` restored to a runnable expression, chapter 5's
"🎓 Functors, formally" quote block restored, and the noun `fold` spelled one
way throughout. Two chrome strings (`cmpBenchMeta`) were missing from both `ko`
and `es`, which left the benchmark-machine line in English on those pages; the
published example count in the prose was 50 against an actual 53.

**The checker is now wired into CI**, which is what the previous release
claimed and did not do — nothing in the repository called it. Only `ko` is
gated, deliberately: it is the one locale translated end to end (301 of 301
pages). `es` is a partial translation carrying 25 defects of its own, and
`ja`/`pt-BR`/`ru`/`zh-Hans` have no overlay for most pages, which the checker
reports as `missing` by design — gating any of those would be red on every
commit and would therefore report nothing at all.

A second CI step diffs `build_docs.dart --list-translatable` against
`check_translation.dart --list-translatable`. The set of translatable pages is
derived twice by different routes — build_docs enumerates it from its own
family tables, the checker walks `content/` — and a page family added to one
and not the other would silently escape the gate above. The two agree today;
the step is what keeps them agreeing.

### Three findings from the integrated review

- **A `TypedData` source produced a window that was not the window the
  dartdoc promises.** `List.sublist` returns a list of the *receiver's*
  runtime type, and a `Uint8List` is a `List<int>`, so it reached the indexed
  window path unchanged and came back out as a `Uint8List`: fixed length, and
  truncating on store — `window[0] = 300` silently left `44` behind. That made
  the growable contract stated below false on that path, and it was a
  regression against 0.8.6, where the pre-sized fill this release replaced
  returned a plain `List<int>`. The receiver's type is fixed for a whole
  iteration, so it is tested once when the iterator is built and a typed-data
  source buys the covariant store check back; every ordinary `List` keeps the
  measured `sublist` win. `windowed`, `chunk` and the fused
  `windowed` → `map` path all build the window through the same helper and so
  are all fixed, with `Uint8List` and `Float64List` pinned by test.
- **`Fx.min()` / `Fx.max()` walked the chain twice.** The members were
  `_inner.first` followed by `_inner.skip(1)`, so a five-element source was
  pulled six times, a `sync*` source with a side effect ran it twice, and a
  source that can only be walked once lost everything after its first element.
  They now `reduce`, which is single-pass and throws the same `StateError` on
  empty that `first` did. This is the spelling a plain `fx(xs).min()` actually
  reaches — the `FxNum` extension below is only reachable through explicit
  extension application, and it was already single-pass.
- **The empty contract has three spellings and two answers**, which is
  deliberate and now documented rather than merely true. `min(<num>[])` returns
  `double.infinity` because the top-level pair is a `num` fold whose identity
  element *is* the infinity, and that is what FxTS returns; both chain
  spellings throw `StateError`, because a terminal over an arbitrary `T` has no
  identity to return.

### Behaviour notes

- **Every `windowed`/`chunk` window is now a growable list.** Before this
  release the two *sync* paths handed back a fixed-length list while
  `windowedAsync`/`chunkAsync` already returned a growable one, so the same
  operator disagreed with its own async twin; all four now agree. The only
  caller that can observe the difference is one that relied on `window.add(x)`
  throwing `UnsupportedError`, and nothing in the library did. It is a
  widening, not a narrowing: a window is still a fresh **copy** the caller
  owns, never a view onto the source, and mutating one window still cannot
  disturb another or the source — that is the part the old test was really
  protecting, and it is unchanged. The reason is the measurement two sections
  up: a fixed-length window has to be filled from package code at one
  covariant store check per element, and no fixed-length bulk copy is faster
  than that loop. Stated in the public dartdoc of all four operators, not just
  in the implementation, and the test that pinned the old representation was
  rewritten rather than deleted — `test/lazy/windowed_test.dart` now pins
  growability across all four paths at once, including both branches of the
  ring buffer.
- The window copy is also why the pulled path changed shape: a window that
  does not wrap the ring is now one `sublist` (measured 14.8 ms against
  18.8 ms per 1,000,000 windows at `size: 3`, and `chunk` never wraps), and
  only an *overlapping* window over a non-`List` source still assembles the
  wrapped tail by hand, at 21.6 ms against 19.6 ms. That is the one path this
  release makes slower, it is the rarest in the family, and no benchmark case
  reaches it.

- **`maxBy` orders `NaN` and `-0.0` differently.** `_compareKeys` — shared by
  `minBy`, `maxBy` and `sortBy`'s non-`List` path — compared with `<` and `>`,
  which are both *false* for a `NaN` on either side, so every `NaN` read as a
  tie and the first-seen element won. It now uses `compareTo`. The visible
  changes are `maxBy((d) => d, [1.0, nan, 3.0])`, which was `3.0` and is now
  `NaN`, and `-0.0`, which no longer ties with `0.0` on either quantifier:
  `maxBy` over `[-0.0, 0.0]` was `-0.0` and is `0.0`, `minBy` over `[0.0, -0.0]`
  was `0.0` and is `-0.0`. `minBy` with a `NaN` is unchanged, because `NaN`
  compares above everything.

  This makes an older promise true rather than breaking a current one: the
  0.7.x notes already said `compareTo` semantics for `NaN` and `-0.0` were
  identical on every path, and `sortBy`'s typed-`double` path already used
  `compareTo` — `_compareKeys` was the one that disagreed. Pinned by test on
  both `minBy` and `maxBy`.

- `Fx.isEmpty` / `Fx.isNotEmpty` are O(1) and terminate on an unbounded chain,
  where they used to count every element.
- `FxNum(fx(xs)).min()` / `.max()` throw `StateError` on an empty chain where
  they returned `double.infinity` / `-double.infinity`. Reachable only through
  explicit extension application; the `fx(xs).min()` spelling is the `Fx`
  member and is unchanged.

### `.fx` — the chain as a getter

`fx(xs)` gains a getter spelling. `.fx` works on an `Iterable`, an
`FxAsyncIterable` and a `Stream`; `.fxAsync` works on an iterable of futures;
`.fxEvents` works on a `Stream`:

```dart
orders.where(isPaid).fx.groupBy((o) => o.customerId);
await responses.fxAsync.map(parse).concurrent(4).toList();
keystrokes.fxEvents.debounce(window).switchMap(search).pull();
```

The point is which end of the expression you read from. Wrapping a call in
`fx(...)` means going back to its front to open the paren, which is the same
reason `.toList()` exists on `Iterable` and `toList(iterable)` mostly does not.

It costs nothing. `Fx` is an extension type, so the wrapper erases to the
iterable itself, and an extension getter whose body is `this` is a static call
AOT deletes. Over a 1M `map` + `filter` + `sum`, 20 interleaved rounds:

| | median |
|---|---|
| `fx(xs).map(…).filter(…).sum()` | 12.640 ms |
| `xs.fx.map(…).filter(…).sum()` | 12.665 ms (1.002x) |

That is noise against the ~5% floor `benchmark.sh --ab` exists to see past.
`vm:prefer-inline` on the getter moves it by 0.2 points, which is to say
nothing; the pragma is there for consistency with the rest of the file, not
because it earns its place.

`.fxAsync` on `Iterable<FutureOr<T>>` is not sugar for `.fx`. Over an
`Iterable<Future<T>>`, `.fx` gives an `Fx<Future<T>>` — a chain over the
futures rather than their values, which compiles and quietly does the wrong
thing. `.fxAsync` resolves them, so `T` is the awaited type and `concurrent(n)`
has something to work with.

### `fx()` stays the documented spelling

Both forms are supported and neither is deprecated, but the docs, the README
and the 101 course keep using `fx()`. Two reasons: it is the FxTS name this
port is faithful to, and it is the form that takes an explicit type argument —
a getter cannot take one postfix, so `fx<num>(xs)` parses where `xs.fx<num>`
does not. (An extension override still can: `FxEntry<num>(xs).fx`. Inference
covers the common case anyway, since `Fx<T>` is covariant and `FxNum` applies
to an `Fx<int>`.) Mixing the two spellings across fifty comparison pages would
cost more in consistency than either gains in brevity; the getter is introduced
once, in the [`fx()` tutorial](https://bansooknam.github.io/FxDart/tutorials/fx.html),
as the Dart-idiomatic alternative.

### The events layer gets one too, carefully

`FxEvents` is documented as "a thin wrapper (never an extension), so it can
coexist with any other stream library — including rxdart — without member
conflicts", and that rule still holds for its operators: `debounce`,
`switchMap`, `throttle` and thirty-odd others all collide with rxdart's
`Stream` extensions, which is exactly why they live on a wrapper class.

`FxEventsEntry` adds one name, `fxEvents`, and rxdart's forty-plus `Stream`
extensions claim nothing like it (checked against rxdart 0.28.0). One entry
name is a different risk from forty operator names, so the class comment now
points at the exception rather than reading as absolute.

That leaves `Stream` carrying both getters, which is right: it is the one
source that belongs to both worlds. `.fx` is the pull chain (`fxStream`),
`.fxEvents` is the push chain (`fxEvents`), and `.pull()` still crosses back.

### The wrapper utilities too, under one naming rule

The same treatment for the constructor-shaped utilities — the functions that
take a value and hand back a different kind of thing:

| receiver | getter | same as |
|---|---|---|
| `Iterable<T>` | `.fxShuffle([seed])` | `shuffle(xs, seed)` |
| `FxAsyncIterable<T>` | `.fxShuffle([seed])` | `shuffleAsync(it, seed)` |
| `Stream<T>` | `.fxLive` | `LiveValue.from(s)` |
| `Stream<T>` | `.fxLiveSeeded(v)` | `LiveValue.seededFrom(v, s)` |
| `void Function(T)` | `.fxDebounce(w, …)` | `debounce(f, w, …)` |
| `void Function(T)` | `.fxThrottle(w, …)` | `throttle(f, w, …)` |

**Every entry point carries `fx` in its name.** Not decoration: `toAsync`,
`shuffle` and `debounce` are general enough words that on a bare `Iterable` or
a bare callback they say nothing about which library they enter, and the prefix
leaves those names free for whatever else a project puts on those types.

`fxShuffle` has a sharper reason. `List.shuffle` already exists in `dart:core`
and shuffles **in place, returning void**; an instance member always beats an
extension, so a `List` receiver named `shuffle` would silently call the wrong
one. A wrong answer that compiles is worse than a longer name.

### What is deliberately not here

The operators. `map`, `where`, `take`, `fold`, `reduce`, `join`, `any`,
`every`, `expand`, `forEach`, `last`, `toList`, `takeWhile`, `skipWhile` and
`skip` — fifteen of the 120 `Iterable`-receiving functions — share a name with
a member `Iterable` already has, so `xs.map(f)` could never reach fxdart no
matter what is declared. Seven more (`average`, `chunk`, `count`,
`elementAtOrNull`, `firstWhereOrNull`, `sorted`, `whereNot`) collide with
`package:collection`, where the failure is a compile error in code that imports
both. The chain is where operators live: `xs.fx.map(f)`, not `xs.map(f)`.

### Extension names

`FxEntry`, `FxAsyncEntry`, `FxStreamEntry`, `FxFutureEntry`, `FxEventsEntry`,
`FxShuffleEntry`, `FxShuffleAsyncEntry` and `FxCallbackTiming`. Naming them
matters: a clash with another package's `.fx` on `Iterable` is a compile error,
and the fix is to say which extension you mean at the call site.

## 0.8.6

0.8.5 taught the *lazy* stages to stop hiding the user's callback behind an
iterator field, and measured the floor that leaves: a closure loaded from a
field costs 2.75 ns an element against 0.88 for a virtual call. It applied the
fix to `sumBy`, `averageBy`, `foldBy`, `minBy`, `maxBy`, `find`, `findIndex`
and stopped there. Twelve strict terminals — including the two most-used ones,
`fold` and `each` — were left on the slow side of the same line.

They are most of this release, plus two asymptotic bugs that no benchmark case
could have found, one lazy stage that had a fast path for `toList` and not for
anything that pulls it, and the instrument that decided all of it.

### Strict terminals inline the caller's callback

`minBy` already carried the measurement, in its own comment since 0.8.2:

| over 1,000,000 rows, extracting a `double` field | ns/element |
|---|---|
| hand-written loop | 0.65 |
| `list.reduce(closure)` | 1.90 |
| the terminal, no `vm:prefer-inline` | **6.26** |
| the terminal, with the pragma | 0.97 |
| the pragma **and** an indexed `List` walk | 0.65 |

The pragma is not about the call overhead of the terminal. Inlined into the
call site, the callback is the literal closure written there instead of a
parameter holding an unknown function, and the per-element indirect call
disappears. The indexed walk is worth its extra branch only *because* of the
inlining — 0.8.0 measured indexed loops around an un-inlined callback at
1.03-1.05x and rejected them, correctly.

`fold`, `foldWithIndex`, `each`, `reduce`, `every`, `some`, `countWhere`,
`groupBy`, `groupedBy`, `indexBy`, `countBy`, `partition` now get both, in the
shape their already-optimized siblings use: the indexed branch first, the
pulled loop unchanged behind it.

A hop that does not inline breaks the chain, so the `Fx` members that stand
between a chain call and these terminals were pragma'd too — `each`,
`foldWithIndex`, `groupedBy`, `indexBy`, `some`, `any`, `partition`, `fold`,
`reduce`. `groupBy`, `countBy`, `countWhere` and `foldBy` already had it, which
is why they were the ones that moved first.

`tee` / `tee3` were deliberately left alone: they carry `vm:align-loops`, and
an indexed walk without the inlining is the shape 0.8.0 already measured as a
regression.

### Result — paired A/B against 0.8.5, all 53 cases

Apple M5 Pro, Dart 3.13.1, AOT, `tool/ab_bench.dart` with a `native` control
per case. Two cases at or past 5%, reproduced with a clean control:

| case | terminal | fxdart, every clean-control reading | control |
|---|---|---|---|
| `top-log-level` | `countBy` over 1,000,000 log lines | **−9.37%** · −8.70% · −8.24% | +0.99% · −1.04% · −0.41% |
| `sparse-timeseries` | `groupBy` over 1,000,000 readings | **−8.89%** · −7.27% · −6.80% · −6.59% · −6.37% | +1.12% · −0.80% · +1.09% · +1.30% · −1.16% |

Readings against a control that had drifted past 2% are excluded from that
table rather than averaged in; there were five such runs.

No regression. Every other case reads inside the instrument's ±2% band
against a clean control — `refunds-vs-charges` −1.35%, `alert-digest` −2.09%,
`latency-percentiles` −1.47%, `cohort-retention` −0.22%,
`duplicate-transactions` +0.40%, `daily-ledger-close` +0.34%, `ledger-diff`
−0.90%, `restock-plan` −0.54%, `monthly-ledger-report` −0.37%, `top-expenses`
+0.48%, `recent-errors` +0.03%.

`top-category-average` is **not** claimed: four readings against clean
controls came in at −2.56%, −7.11%, −7.85%, −2.65%. It is bimodal here, so
its win is real in direction and unmeasurable in size.

### The gate caught a regression, and the regression named its own cause

`top-merchants` read **+2.91%** and then **+3.35%** against clean controls —
a real slowdown on a case fxdart already won 1.84x.

It calls `groupedBy`, which was a list comprehension over `groupBy(f, iterable)`
where `f` is `groupedBy`'s own **parameter**, not a literal. Forcing `groupBy`
to inline there bought nothing — there was no closure literal at that call site
to expose — while making `groupedBy` too big to be inlined itself, so the
caller's literal never reached the loop and the indexed branch was paid for
twice with no callback inlined either time. Pragma'ing `groupedBy` and
`Fx.groupedBy` closes the chain: **+3.35% → −1.04%** (control −0.06%),
confirmed at −1.35%.

The general rule, now stated once instead of rediscovered: `vm:prefer-inline`
earns its code size only on the hop that can see the caller's closure literal,
and every hop between that literal and the loop has to inline or none of them
do.

### Two asymptotic bugs, neither reachable from a benchmark case

- **`slice` walked the whole source.** `_SliceIterator.moveNext` kept pulling
  past `end` — the comment called it deliberate ("matches the generator form")
  — so `slice(0, xs, 3)` was O(n) where `take(3)` is O(3). It now stops at
  `end`. Measured AOT, `slice(0, gen(1000000), 3).toList()` x20:
  **331,552 µs → 27 µs**.
- **`sumStrings` was quadratic.** `fold('', (a, b) => a + b)` copies the whole
  accumulator per element; it is now `Iterable.join()`. 20,000 x 10 characters:
  **74,620 µs → 343 µs**.

Neither `slice` nor `sliceAsync` drains its source any more, which is
observable on a side-effecting or single-shot iterable. That is the intended
contract — it is what every other limiting operator does — it is stated in the
public dartdoc rather than only in the implementation, and the sync side is
pinned by a test that counts pulls.

### `tool/ab_bench.dart` is a gate now, not a report

Three defects, all of which mattered while measuring this release:

- The ±2% control check **warned and exited 0**. It now exits 1, and it fired
  on five of the runs below — including two that would otherwise have shipped
  `top-log-level` at −10.09% and −10.70% off a control that had moved +5.05%
  and +3.83%.
- No all-cases mode: every slug had to be typed, so "no case regresses 3%" was
  a manual claim. `--all` enumerates `benchmark/cases` (or `cases-rx`).
- The per-case delta list was built and never emitted — dead code since it was
  written. It now prints, and writes `benchmark/.build/ab/report.md` in the
  shape these CHANGELOG tables use.

### Two cases this instrument cannot adjudicate

`weekly-sensor-averages` and `stream-windowed-alerts` swing past ±3% in both
directions with clean controls, **in the same session**, back to back:

| case | readings, control in brackets |
|---|---|
| `weekly-sensor-averages` | +6.94% [+1.00%] · −5.07% [−0.39%] · +9.66% [+2.75%] · −11.38% [−1.01%] · +18.34% [−1.86%] |
| `stream-windowed-alerts` | −3.14% [+0.63%] · +2.84% [+0.96%] · +4.20% [−1.10%] · −0.62% [+0.93%] |

Neither calls a single function this release changed — both are
`chunk` → `averageBy` / `maxBy` pipelines, and `chunk` allocates one list per
window, which makes their cost bimodal per *process* rather than per round.
More rounds do not help; pooling per-iteration samples across processes cannot
separate the modes. Recording them as unresolved rather than as a ±4% result,
and noting what would fix it: keeping the raw `iterUs` samples and rejecting
outlying processes, which the runner throws away today.

### `differenceBy` / `intersectionBy` walk a `List` by index when pulled

`_SetOpIterable` has had a `toList` fast path since 0.8.2 — build the first
source's key set, then walk the second source *by index* when it is a `List`.
`_SetOpIterator`, the path every other consumer takes, never got it: it held
the second source in an `Iterator<A>` field, so each element cost a
megamorphic `moveNext` plus a `current` read. `size()` counts by pulling, so
a caller who only wants the size of a set operation paid that on every
element.

`ledger-diff` is that caller. Attributed leg by leg over 500,000 rows, AOT,
one binary per variant:

| leg | native | fxdart | gap |
|---|---|---|---|
| whole panel | 219,873 µs | 270,897 µs | +51,000 |
| the three set operations | 162,390 µs | 225,782 µs | +63,400 |
| **`intersectionBy` + `size()` alone** | **64,273 µs** | **107,808 µs** | **+43,500** |
| the two sums | 1,113 µs | 1,568 µs | +455 |

One leg is 85% of the gap, and inside it `size()` (107,808 µs) was *slower
than* `toList().length` (99,306 µs) — the tell that the iterator, not the
work, was the cost. The iterator now walks a `List` second source by index,
as `toList` does; the pulled branch is unchanged for every other source shape.

| | paired delta | control |
|---|---|---|
| `ledger-diff` | **−4.05% / −4.40%** | −0.98% / +0.13% |

In the published sweep it goes from **1.24x behind native to 1.17x**. Nothing
else moved: `top-merchants` +0.81%, `cohort-retention` +0.91% / +0.06%,
`price-lookup-fallback`, `stream-windowed-alerts` and `unique-tags` all within
±1.2%.

### Correction — `ledger-diff`'s gap was not all algorithmic

0.8.5 said: *"`ledger-diff`'s remaining 1.24x is algorithmic, not overhead …
Faithful, and not the library's to remove."* Half of that holds. The fxdart
panel does build three key sets where the native panel builds two and reuses
them, and that really is the example's shape rather than the library's —
about 20 ms of the 51 ms gap. But the larger half was library overhead the
attribution missed, because it compared the two panels end to end instead of
leg by leg. Splitting the legs put 85% of the gap in one place and made the
`size()`-vs-`toList` inversion visible.

What remains is the element-dedup set. Measured against a variant with no
dedup at all — not shippable, `intersectionBy` promises duplicates removed —
the intersection leg runs in 58,083 µs, faster than the native panel's
62,692 µs. So the dedup is 27 ms, and it is the contract, not overhead.

### What was probed and rejected on `ledger-diff`

- **A `length` override on `_SetOpIterable`**, counting without building the
  element list: 85,226 µs against the iterator's 107,808 µs in isolation. It
  is unreachable from the benchmark — `size()` counts by pulling rather than
  asking for `length` — and making `size()` defer to `Iterable.length` to
  reach it moved unrelated cases by ±2.5% in both directions across runs.
  Dropped: an override on a member as widely implemented as `Iterable.length`
  is not worth adding for codegen churn.
- **Building the key set by index too.** The set literal
  `{for (final a in _source1) f(a)}` is already good code: as a shared helper
  the case got *worse* (−3.6% against −4.2%), inlined at both call sites it
  measured the same. The 1.5 million-element key-set build is not on the
  iterator path this release fixed.

### The ratio report is ordered by one axis again

`perf_ratio_report.py` sorted by the same `max/min` multiple it prints, which
is not directional — a row where FxDart leads by 1.37x and one where it
trails by 1.32x sort next to each other. Across 53 cases the direction
flipped **20 times**, so the numbers read as a clean descent while the
meaning alternated, and the file's own title — *slowest to fastest* — was not
what the order delivered: the fastest case in the suite sat at the top.

It now sorts by `fxdart / native`, which is directional. `recent-errors`
(1.32) leads the table, `restock-plan` (0.24) closes it, the ordering never
changes direction, and the printed multiple stays what it was — the harness's
own verdict for that row.

The old key had a second problem this removes: the harness calls a tie on
`tieAbsMs` as well as `tieMarginPct`, so a small-N case can be a tie at a raw
1.8 and outrank a genuine 1.5x gap. Nothing in the current data hits it; the
door is simply closed.

Report-only. No measurement changed.

### Rounds, on top of the control check

The gate above rejects a run whose control drifted. A run whose control is
clean can still be unreadable, and the fix is rounds rather than another
check. Measuring the change above at `ab_bench`'s default 12,
`top-merchants` read +4.37%, +3.31% and +2.54% across three runs with
controls of −0.44%, −0.12% and −0.49%, and `cohort-retention` read −4.66%
against +1.63% — four clean-looking readings, all four gone at
`--rounds 20`. A null run, the working tree against itself, was flat
throughout, so nothing was wrong with the instrument.

This is a different failure from the two bimodal cases above: those do not
converge with more rounds, these do. Both end in the same place — a sub-5%
reading needs more than the default before it means anything — which is why
`./benchmark.sh --ab` runs 20.

### Added — `foldByOrSkip`, the same trade on `monthly-category-report`

`monthly-category-report` sat at 1.28x, and 0.8.5 had already named the cause:
"the `filter` predicate that the native loop inlines". That reading holds, and
it is now measured leg by leg. The predicate alone, over 1,000,000 rows:
**9.8 ms** inlined against **12.6 ms** through an opaque closure — a 2.8 ms
difference that is the whole of this case's gap.

`foldBy` is strict and already inlines its own callbacks. The `filter` in
front of it is lazy, so its predicate lives in an iterator field and never
does. `foldByOrSkip(key, seed, f, xs)` moves the test into the key — a `null`
key skips the element, the `filter_map` shape `takeUniqBy` introduced — and
the key is a parameter of a body small enough to inline.

| spelling | µs per 1,000,000 |
|---|---|
| `filter().foldBy()` | 13,965 |
| `foldByOrSkip(…)` | 12,070 |
| **`fx(…).foldByOrSkip(…)`** | **11,716** |
| hand-written loop | 11,322 |

**−16%**, and 1.28x behind native becomes **1.11x** in the published sweep.
It keeps `foldBy`'s one-probe cell, which is most of why it lands where it
does: a first prototype using the plain `map[k] = f(map[k] ?? seed, a)` read
only −6%.

As on `recent-errors`, the **headline bar still measures the composable
chain** — it is what the page teaches — and the page publishes a third bar
beside it. That makes two pages with three bars; the harness, `ab_bench` and
`build_docs` already carried the shape.

Thirteen tests, including the two things easy to get wrong when a filter is
folded into a key: a `null` key skips rather than bucketing under `null`, and
the seed stays a per-key starting value. A nullable accumulator is pinned too,
since a stored `null` must not read as "no cell yet".

`tools/build_single_file.sh` gains the matching `_$foldByOrSkip` wrapper.

### Behaviour notes

- The `List` fast paths read `length` once and then index, so mutating the
  source during a pass is no longer reported as such on these twelve
  terminals. Both directions changed, and they changed differently: a source
  that **grows** mid-pass is silently truncated to the length the pass started
  with, and a source that **shrinks** now throws `RangeError` from the index
  read where it used to throw `ConcurrentModificationError`. A non-`List`
  source still takes the pulled loop and still raises
  `ConcurrentModificationError`. Same trade-off the lazy stages took in 0.8.0,
  now covering the strict side too, and pinned in all three directions by
  `test/strict/numeric_fast_paths_test.dart`.
- `slice` and `sliceAsync` stop consuming their source at `end`, as above.
- `Fx.all` now delegates to `every` instead of carrying its own loop, so the
  chain's universal quantifier reaches the same fast path as `Fx.any`.


## 0.8.5

Two API additions and a performance pass that runs most of this section.

The additions: `FxEvents` gains the stateful and limiting operators the pull
layer already had (`scan`, `uniqAdjacent`, `pairwise`, `take`, `drop`, and a
`head` terminal), and `takeUniqBy` lands on the strict side — `filter` +
`uniqBy` + `take` as one call whose callback the compiler can actually
inline. Both sections are near the end, before "Still open".

The performance work started as a pass over the ten slowest DartComparison
cases and grew two more rounds as the measurements got sharper: `take` and
`uniq` became fused async stages, `filter` over a `zip` became one iterator,
and the "lazy callback floor" that closes the section is now measured rather
than asserted.

The headline is a new instrument as much as the changes: **`tool/ab_bench.dart`**
builds the baseline `lib/` from a git worktree, copies the working tree's
benchmark sources over it so *only* `lib/` differs, and runs the two binaries
interleaved in one session, alternating order each round. Calibrated against
no change at all it reads control −1.10% / fxdart +0.24% — resolution ~1.5%,
against the ~5% floor of a before/after `results.json` diff.

Every number below is that instrument, not a diff of two runs.

### What a pipeline stage actually costs

The pass started from a wrong hypothesis — that layered iterators were the
overhead — and a probe killed it. Measured over 1,000,000 elements, AOT:

| operation | ns/element |
|---|---|
| indexed `List` walk, no call | 0.64 |
| `for-in` over a `List`, no call | 0.66 |
| polymorphic **virtual** call (`moveNext` / `current`) | 0.88 |
| **closure call loaded from a field** (a user callback) | **2.75** |

A callback costs *three times* a virtual call. So a push/sink protocol — which
replaces two cheap virtual calls per stage with one extra closure call — is
strictly worse; prototyped, measured at **+36% to +54%**, and abandoned.

The same measurement sets an honest ceiling. `recent-errors`
(`filter → uniqBy → take(3) → map → join` over 1M logs), attributed:

| variant | ms | vs native |
|---|---|---|
| native, predicate and key inline in the loop | 10.07 | 1.00x |
| one *perfectly* fused loop, callbacks through fields | 13.68 | **1.36x** |
| layered iterators (0.8.4) | 15.95 | 1.58x |

The 1.36x is not iterator overhead — it is the cost of *calling* two closures
where the hand-written loop inlines them, and no library change removes it.
Where the native side runs at ~10 ns an element, one callback is +27% on its
own. That is the floor these cases sit on, and it is why several of them land
near 1.3x rather than at parity.

### Lazy stages walk a `List` (or a `range`) instead of holding an iterator

Storing the source as an `Iterator<A>` **field** is what costs: a `for-in`
over a statically known `List` is inlined by AOT into an indexed walk, but
through a field the site is megamorphic and every `moveNext`/`current` is a
real virtual call. `filter`, `map`, and the new fused stages now index a
`List` source directly, and `filter` walks a `range()` source with a counter.

| case | delta |
|---|---|
| `average-basket` | **−12.73%** |
| `recent-errors` | **−11.92%** |
| `monthly-category-report` | **−10.89%** |
| `anomaly-context` | −6.56% |
| `top-merchants` | −3.28% |

`filter` followed by `uniq`/`uniqBy` is also built as **one stage** now, via
`FxUniqByFusable` — the keyed twin of the `FxUniqFusable` handshake that
`map`+`uniq` has used since 0.8.0.

That interface is the release's only **public API change**: additive, one new
abstract class, nothing existing moved. Like `FxUniqFusable` it is a stage-to-
stage handshake rather than something to call — it is visible only because
`lib/fxdart.dart` re-exports `src/lazy/filter.dart` without a `show` clause.
The rest of the new machinery (`FxIntRange`/`FxIntRangeSource` for the `range`
walk, `FxDropWhileStage`/`FxDropWhileLink` for the fused async stage) is not
exported and is not reachable from `package:fxdart`.

**Correction to 0.8.0.** The indexed `map` iterator was rejected then on a
measured "−3.8% median, worst −14.9%" — but that came from a before/after
`results.json` diff, the exact comparison later shown to be unable to resolve
anything under ~5% (the `native` side, whose binary does not even change,
moved −27% to +4% between runs). Re-measured paired and interleaved it is a
small consistent win with no regression anywhere, so it lands.

### A terminal that is inlined inlines the caller's callback with it

The 2.75 ns callback cost above is not universal — it is what you pay when the
loop and the callback live in *different* functions. Mark a strict terminal
`vm:prefer-inline` and AOT inlines it into the call site, where `f` is the
literal closure written there rather than a parameter holding an unknown
function. Measured over 1,000,000 rows extracting a `double` field:

| `maxBy` variant | ns/element |
|---|---|
| hand-written loop | 0.65 |
| `list.reduce(closure)` — what the native panel writes | 1.90 |
| plain generic terminal | **6.26** |
| + `vm:prefer-inline` | 0.97 |
| + inline **and** an indexed `List` walk | **0.65** |

So `minBy`/`maxBy` now carry the pragma and index a `List` source directly.
`anomaly-context`, which extracts a peak over 1,000,000 readings, went
**−36%** and now *beats* the hand-written loop: 1.48x behind to **0.90x**.
`foldBy` gained the pragma for the same reason (`monthly-category-report`).

The indexed walk is worth its branch only *because* of the inlining. 0.8.0
measured indexed loops around an un-inlined callback at 1.03-1.05x and
rejected them; with the callback inlined there is nothing left for the
iterator to hide behind.

**This does not generalise, and trying to was a measured mistake.** The same
pragma applied to the lazy operator factories and to the larger strict
terminals (`groupBy`, `countBy`, `each`, `fold`, …) cost
`weekly-sensor-averages` **+8.7%** through code-size pressure while buying
about 1.7% elsewhere — so both groups were reverted, and the pragma is kept
only where it is measured to pay. A lazy stage cannot benefit from it at all:
its callback lives in an *iterator field*, so no amount of inlining at the
call site makes the closure's identity known.

### `sortBy` / `sort` / `toList` stop bypassing their upstream

All three materialized with `List.of(iterable)`, which reaches straight for
the iterator and so skipped every operator `toList` override — the SDK
hand-offs on `map`/`filter` over a `List` source and the fused single-loop
forms on `uniq`/`uniqBy`. They use `iterable.toList()` now.
`latency-percentiles` −4.51%.

`differenceBy`/`intersectionBy` gained a fused `toList` that builds the key
set and walks the second source by index in one loop — `ledger-diff` −8.40%.

### Async — `chunk` and `windowed` were the largest single defect

`chunk(4)` cost **27 ms per 100,000 elements** on top of the same chain
without it (2.1 → 29.1 ms) — 270 ns an element for bookkeeping that does no
work. `_windowedAsync` wrapped an `async` closure in a `SerialAsyncIterator`
and pulled with `next()`, so every element crossed a real `Future` and every
window an async function frame, even over a fully synchronous source.
Rewritten on the internal fast-pull path (`FxFastNextGate` + `nextOr`,
then/bare):

| chain, N=100,000 | before | after |
|---|---|---|
| `toAsync → chunk(4) → toList` | 29.09 ms | **3.62 ms** |
| `toAsync → windowed(4, step: 4) → toList` | 28.66 ms | **2.66 ms** |

`stream-windowed-alerts` **−21.55%**. Window contents and count, the
`partial` tail, overlap carry for `step < size`, the skip for `step > size`,
and the concurrent path are all unchanged.

Three smaller async fixes, together worth **−9.58%** on `flaky-api-retry`:

- **`peekAsync`** wrapped its callback in an `async` closure, so a
  synchronous `peek` — which is what `peek` usually is — allocated a Future
  and suspended once per element. Now then/bare.
- **`headAsync`** was an `async` function; it now takes the fast-pull path
  and returns without a frame. This matters when a loop builds one short
  chain per work item, which is `head`'s common shape.
- **`dropWhileAsync`** is a fused stage (`FxDropWhileStage`) instead of its
  own `SerialAsyncIterator` layer, so `map → peek → dropWhile` is a single
  fused run reachable by `nextOr`. Its latch is per-iterator, and at most one
  fuses into a run — a second starts a new one, as a second `scan` does.

### Example changes

The fxdart panel formatted *every* alert message and then deduped the
resulting strings; the native panel deduped first and formatted only what
survived. On 1M logs that is ~667,000 throwaway string interpolations. The
panel now reads `uniqBy((l) => l.message).map(...)` — which is also the
clearer statement of the intent — for byte-identical output:
**262 ms → 176 ms**, from 1.46x behind native to a tie.

**`latency-percentiles`** sorted each endpoint's latencies with
`sortBy((ms) => ms)` — an *identity* key, which is a misuse of the operator:
`sortBy` exists to sort by a key you derive, and paying its
decorate-sort-undecorate to sort integers by themselves is pure overhead. It
now reads `sort((a, b) => a.compareTo(b))`, which is both the natural way to
say it and faster than the native panel's `..sort()`, because an explicit
comparator on a statically-typed `List<int>` devirtualises `int.compareTo`
where the default sort goes through `Comparable.compare`. In isolation over
~950k values: `sortBy` 211.4 ms, native `..sort()` 175.0 ms, this **135.7 ms**.
The case went 1.33x to **1.03x**, a tie. Output is byte-identical on both
sides and `check_comparison` passes.

Those are the only two examples that changed. Three further rewrites were
probed and rejected: `windowed(3)` for `consecutive-over-limit` is *worse*
(31.0 ms vs 23.2 ms); an index walk over `range` for the same case gains only
9% while losing the sliding-window idea the example exists to show; and a
then/bare callback for `flaky-api-retry` recovers 10 ms of a 151 ms gap while
making the pipeline harder to read.

### Where the ten cases landed

Full 53-case sweep, headline scale, fxdart/native:

| case | 0.8.4 | 0.8.5 |
|---|---|---|
| `anomaly-context` | 1.49x | **0.90x** |
| `alert-digest` | 1.46x | **1.01x** |
| `latency-percentiles` | 1.34x | **1.03x** |
| `stream-windowed-alerts` | 1.47x | **1.12x** |
| `flaky-api-retry` | 1.42x | 1.19x |
| `ledger-diff` | 1.35x | 1.20x |
| `monthly-category-report` | 1.48x | 1.26x |
| `recent-errors` | 1.56x | 1.34x |
| `live-search` | 1.34x | 1.36x |
| `consecutive-over-limit` | 1.36x | 1.38x |

Four of the ten reach parity or better; six do not, and the reason is
measured rather than guessed — see the two floors above. `recent-errors`,
`monthly-category-report` and `consecutive-over-limit` sit on the *lazy*
callback floor, which the inlining trick cannot reach because those closures
live in iterator fields; `flaky-api-retry` and `live-search` sit on the async
pull protocol at roughly 1 microsecond per awaited element.

All 53 cases were then A/B'd against the 0.8.4 library with the case sources
held identical and an unchanged-native control per case: **20 net faster, 26
flat, and two genuinely slower** — `paginated-products` +2.6% and
`no-spend-streak` +2.5%, both with a clean control. They are the cost of the
`List`-indexed walks, and they are paid back many times over by the 20 (which
run from −4% to −38%). Everything else that *looked* like a regression in the
sweep table read flat or faster once measured properly; `top-merchants`, for
instance, is +1.2% against a −0.6% control, i.e. inside the noise band.

A single sweep's ratio is not evidence of a change. `results.json` also merges
partial runs from different sessions, so two versions of it are not even a
like-for-like comparison — over these two sweeps the *native* side, whose
binary never changed, moved a median of −4.5%.

Large off-target gains came with the inlining: `invoice-summary` 0.82x →
0.51x, `budget-alerts` 0.88x → 0.60x, `multi-currency-report` 0.97x → 0.86x,
`monthly-ledger-report` 0.41x → 0.32x, `food-spending` 1.05x → 0.88x.

### Second pass — the sort strategies and a record-typed `head`

A second sweep of the same instrument over the cases still sitting at 1.19x
or worse. Three defects, all of them things the library was doing that no
program asked for. The four `###` sections that follow are that pass.

### Int keys were still sorting through an index permutation

0.8.0 moved the `double` key path off the index sort for a stated reason —
"every comparison does two random reads into the key array and the result is
gathered through the permutation — millions of cache misses on a large sort".
The `int` path never followed it. It does now, and where it can it skips
comparison sorting altogether.

Int keys in real pipelines are **narrow**: scores, ranks, counts, ages,
priorities, deficits, month numbers, status codes. When `max - min` is no
wider than the input, `sortBy` runs a stable **counting sort** — two linear
passes over the keys plus one prefix sum, and no comparisons at all. Wider
keys (ids, timestamps, hashes) take an unboxed lockstep merge, comparing with
`<=` on raw ints: ints have no NaN and no signed zero, so `compareTo` buys
nothing there. The O(n) presorted / exactly-reversed scan that the double
path runs first is kept, including its insistence on a *strict* run before
reversing.

| case | delta | key |
|---|---|---|
| `restock-plan` | **−76.31%** | `i.stock - i.minStock` over 1M rows |
| `leaderboard-ties` | **−27.86%** | `-p.score`, 500 distinct scores |
| `concurrent-profile-fetch` | −3.41% | `u.id` |

`restock-plan` goes from a tie to **0.24x**, the fastest case in the suite;
`leaderboard-ties` from 1.22x behind native to **0.88x** ahead.

**Both new strategies are stable, and the index sort was not.** `List.sort`
is free to shuffle equal keys, so this is a behaviour change — a strictly
better one, and it also ends an inconsistency where a `double` key sorted
stably and an `int` key did not.

It shows in exactly one place. `leaderboard-ties`'s native panel sorts
2000-deep tie groups with `List.sort`; the two panels used to agree only
because sorting an index list and sorting the values make identical
comparator decisions on the same input, and so produced the *same* arbitrary
permutation. They no longer do. The case's checksum now reports rank and
score without the name — which is what the two programs actually agree on —
and neither panel's pipeline changed. The tutorial example's six-player
output is unaffected: at that size `List.sort` is an insertion sort, which is
stable, so `expected.txt` already recorded the stable order.

### The `indices` list was allocated for key types that never used it

`_sortByImpl` built an n-element index list *before* it knew the key type,
but the double path has merged rather than gathered since 0.8.0 and never
reads it. Every `sortBy` over a double key was allocating and filling a
million-entry `List<int>` and discarding it untouched.

| case | delta |
|---|---|
| `paginated-products` | **−6.71%** |
| `top-expenses` | **−5.54%** |

`paginated-products` was the one case the first pass made genuinely slower
(+2.6%, the price of the `List`-indexed walks). This more than pays it back:
1.28x → **1.18x**.

### A record-typed `head` was paying a runtime subtype test

`headAsync` already took the fast-pull path, but it is generic, and without
`vm:prefer-inline` its `A` is a **runtime** type argument — so
`r is Future<IterResult<A>>` is a real subtype test rather than a
compile-time-shaped one. Ordinary classes shrug that off; records do not,
which is the same finding 0.7.6 recorded when it put the pragma on the
operator factories. Measured over 100,000 one-element pipelines,
`toAsync → map → head`:

| element type | before | after |
|---|---|---|
| a class | 38 ms | 38 ms |
| a `String` | 38 ms | 38 ms |
| a record `(int, String)` | **193 ms** | **112 ms** |

`flaky-api-retry` **−10.61%**, 1.27x → **1.15x**. This is `head`'s common
shape — a loop building one short chain per work item — and
`map((a) async => (a, await f(a)))` makes the element a record almost by
default, so the two compound.

The residual 112-vs-38 ms is the same runtime record cast one level further
out, in the `Future<A?>` the terminal constructs. It did not respond to the
pragma on `FxAsync.head()` either, so it is left measured rather than
guessed at.

### What was probed and rejected

- **Tuning the double merge.** `_mergeByDouble` really is slower than the
  native panel's in-place `List.sort` on 800k doubles (110 ms vs 78 ms) — the
  price of stability and of moving two arrays in lockstep. Insertion-sorted
  base runs of 32 plus an already-ordered-merge skip measured −12% once and
  then inside the noise on repeat; `<=` instead of `compareTo` was a wash. No
  change worth its risk to NaN and `-0.0` ordering, and the `indices` fix
  above closed the case that motivated it anyway.
- **`ledger-diff`'s remaining 1.24x is algorithmic, not overhead.** The
  fxdart panel calls `differenceBy` twice and `intersectionBy` once, so it
  builds three key sets plus three element-dedup sets; the native panel
  builds two id sets and reuses them for all three questions, and dedups
  nothing. That is ~1.9M extra hash operations against ~2.5M, which is the
  measured gap almost exactly. Faithful, and not the library's to remove.
- **`recent-errors`, `consecutive-over-limit`, `monthly-category-report`**
  sit on the lazy-callback floor this release already documented. Attributed:
  `monthly-category-report`'s whole 2.4 ms gap over 1M rows is the `filter`
  predicate that the native loop inlines; `consecutive-over-limit`'s is one
  three-field record allocated per element by `zip3`, which the API shape
  requires. Both already take the `List`-range fast path.

### Side effects: all 53 cases re-measured

Every case A/B'd against the pre-pass library with case sources held
identical and a `native` control per case. **Five wins at or past 5%, no
regression anywhere** — every other case reads inside the instrument's ±2%
resolution band against a clean control:

| | |
|---|---|
| `restock-plan` | −76.31% (control +0.16%) |
| `leaderboard-ties` | −27.86% (control −0.08%) |
| `flaky-api-retry` | −10.61% (control +0.27%) |
| `paginated-products` | −6.71% (control −0.05%) |
| `top-expenses` | −5.54% (control +0.06%) |

The raw `results.json` diff disagreed, and was wrong four times over:
`cohort-retention` read +11.3% there and +0.05% paired (its control had moved
+17.7%), `latency-percentiles` +4.4% → +0.27%, `top-category-average` +3.5% →
−0.67%, `alert-digest` +3.4% → −1.24%. `category-rank` read +4.07% in the
first paired batch against a −1.94% control and +0.55% on re-run; it sorts
six groups by a double key, so nothing in this pass can reach it. Which is
the standing lesson, again: a sweep ratio is not evidence of a change.

### Correction — `price-drop-detection` was never 0.22x

Its published figure moves from **0.22x to 0.53x**, and that is a correction,
not a regression. The case is byte-identical to 0.8.4 and its native panel
does not import fxdart, so no library change can reach it. What moved is the
measurement:

| | native median | native **min** | fxdart median | fxdart **min** |
|---|---|---|---|---|
| 0.8.4 | 3480.0 ms | **1124.5 ms** | 780.0 ms | **581.0 ms** |
| 0.8.5 | 1148.3 ms | **1128.7 ms** | 613.1 ms | **592.7 ms** |

The two runs' *minimums* agree to 0.4% (native) and 2% (fxdart); the medians
differ by 3x and 27%. This case holds 434 MB / 465 MB of RSS at N=1,000,000,
so under transient memory pressure most of its samples inflate while the best
sample still reflects the real cost. Taking the ratio from the minimums gives
0.52x for 0.8.4 and 0.53x now — unchanged. The 0.22x that 0.8.4 published was
an artifact of a spoiled native median, and it overstated fxdart's win.

Worth knowing for the next pass: **the median is the fragile statistic for
memory-heavy cases**, and the harness renders it. `price-drop-detection`'s
median/min ratio was 3.1 in that run against ~1.03 for a healthy case, which
is a usable signal for re-running a block rather than recording it.

### RxDartComparison — no case is RxDart-faster any more

The `chunk`/`windowed` rewrite reaches this family too. Re-swept at 41 cases:
**33 fxdart, 8 ties, 0 RxDart.** The two cases RxDart still won in 0.8.4 are
now ties — `pipeline-into-stream` 1.07x → 1.00x and `cursor-lifetime`
1.07x → 1.04x — and `price-or-fallback` (1.01x → 0.91x) crossed from tie to
an fxdart win. Nothing regressed.

`pipeline-into-stream` is worth noting because the 0.7.4 investigation had
attributed all of its 3.0 microtasks/element to `concurrentAsync` and measured
`chunk` as costing nothing. `chunk` was not free; the cost was its
`SerialAsyncIterator` wrapper, and removing that closed the gap without
touching `concurrentAsync` at all.

### Tests

The fast paths are behaviour-pinned rather than measured-only —
`test/lazy/fused_filter_uniq_test.dart` and
`test/lazy/fused_drop_while_test.dart` add 29 cases covering what a fast path
could plausibly break: callback invocation counts and order, laziness under a
downstream `take`, per-iteration state (so a chain stays re-iterable), the
descending-`range` direction, error propagation, and — for the async side —
that a `Concurrent` marker still abandons fusion and reaches the source. Two
white-box assertions pin which stage/iterator gets built, because a fast path
silently switching itself off is otherwise invisible. Suite: 1980 passing.

### `FxEvents` gains the operators the pull layer already had

`scan`, `uniqAdjacent`, `uniqAdjacentBy`, `pairwise`, `take`, `drop`, and the
`head` terminal. `skip` and `firstOrNull` alias `drop` and `head`, as on `Fx`
and `FxAsync`. Until now the events layer could transform (`map`, `where`,
`asyncMap`) and it could keep time (`debounce`, `throttle`, `sample`, …), but
it could not carry state across events or stop itself. Anything that needed a
running total or adjacent de-duplication had to cross into the pull layer with
`pull()` — and `pull()` only answers once the source closes, so a live stream
could not use it at all. `first-mirror-wins` in the RxDart comparison shows the
other half of the same hole: with no terminal short of `toList()` it reaches
past the chain for `.stream.first`.

Semantics follow the pull layer rather than Rx where the two disagree.
`scan` emits its seed before any event, so a chain ported from Rx's `scan`
gains one leading value. `uniqAdjacent` is the name `distinctUntilChanged`
goes by here, matching `uniqAdjacentBy` and the pull spelling. The terminal is
`head`, not `first`, because `FxAsync` already spells it that way and
`Stream.first` — one hop away through `stream` — throws on an empty stream
where this answers `null`.

A throwing key function in `uniqAdjacentBy` parts company with the pull
spelling: there the throw leaves `moveNext()` and ends the iteration, here it
becomes one error event and the chain continues against the last key it
managed to compute. A push chain has no caller to throw back to.

`take` cancels its source the moment the count is met, which the pull layer
cannot do — `FxAsyncIterator` has no cancel signal — and which is the sharpest
argument for the asymmetry being real rather than cosmetic. It gets that from
`Stream.take`, which this delegates to; the hand-written part is only the
non-positive count, where `Stream.take` still subscribes and the pull layer
clamps to empty. `drop` delegates to `Stream.skip` on the same terms — the SDK
throws on a negative count, the pull layer reads one as "skip nothing".

Every new operator forwards `pause`/`resume` to its source, as `chunk` does.
Six of the twenty-five existing operators do; a stateful operator that cannot
stop its source grows its controller queue without bound.

`head` waits for the source teardown before it answers, as `Stream.first` does,
so an awaiting caller can rely on the subscription already being gone. `take`
copies the source's `isBroadcast` onto the empty stand-in it returns for a
non-positive count — `Stream.empty()` is broadcast by default while
`Stream.take` forwards whatever the source is, and without the copy one method
would hand back streams accepting different numbers of listeners depending on
the argument.

`head` answers with what the stream delivered even when the source's disposer
throws; the teardown failure surfaces as a zone error instead of replacing the
answer, which is what `Stream.first` does. The three controller-based
operators hand back a single-subscription stream whether or not the source is
a broadcast one — `take` and `drop` preserve it because they delegate to the
SDK. That split is documented on each operator and pinned by a test rather
than left to be discovered.

Thirty regression tests cover the seed, the empty source, a throwing fold,
a throwing key function, a source error keeping its place in the sequence,
adjacent runs, key-based comparison, single-event `pairwise`, non-positive
`take` and `drop` counts, subscription multiplicity across `take`'s two
branches, source cancellation on both `take` and `head`, the empty-stream
`null`, and `pause`/`resume`/`cancel` forwarding on every new chain operator.
Suite: 2038 passing, 1 skipped. Verified on Dart 3.12.2 and 3.13.1.

### `take` and `uniq` become fused async stages

The previous entry's "Still open" list opened with this exact change, and the
measurement that motivated it holds up: over 200,000 elements the subscription
drive runs a stream-sourced chain in **10.9 ms** where `await for` and the
SDK's own `StreamIterator` both take **~45 ms**. The drive is four times
faster, and `live-search` was not on it.

It was not on it because `uniqAsync` returned a `DelegateAsyncIterable`. That
breaks the fused run, so `fxStreamDrive` declined the chain and every element
went through the pull protocol instead — a `Completer`, a `Future`, a
microtask and a `pause`/`resume` pair each. `takeAsync` did the same. Both are
fused stages now (`FxUniqByStage`, `FxTakeStage`), so
`fxStream().filter().uniq().take().map()` compiles to **one run of four
stages over the raw stream** and executes by subscription.

**`take` ends its run on the count-th element, not on the pull that would
follow it.** That is the whole subtlety: `take` must never pull the element
after its last, so the stage marks the run ended as the count is met, while
that element still flows through the stages after it. A later stage may drop
it — the loop then answers done without pulling again. Pull counts are pinned
by test, because an off-by-one here is invisible except to a source with
side effects, which is exactly what `live-search` counts.

`uniq` carries no key function at all (the element is its own key), one fewer
call per element than `uniqBy(identity)`. Both stages are stateful — the
seen-set and the counter live on the iterator — so at most one of each fuses
into a run and a second starts a new one, as `scan` and `dropWhile` already
do. A `Concurrent` marker still abandons fusion for the old layering, and a
non-positive `take` count stays off the fused path entirely so it neither
yields nor pulls.

| case | paired delta | control |
|---|---|---|
| `live-search` | **−7.55%** | +1.29% |
| `paged-feeds-dedupe` | **−4.39%** | −0.03% |

`live-search` goes from 1.34x behind native to **1.24x**.

**All 14 async cases and 7 sync cases were A/B'd; nothing regressed.** The
widest reading anywhere was +1.23% (`recent-errors`) against a −0.15%
control — inside the instrument's ±1.5% band. That sweep matters more than
usual here: the change adds two link kinds, so every fused async element now
walks two more type tests before reaching `FxTakeWhileLink`.

One caveat on the published numbers. `paged-feeds-dedupe`'s *sweep* ratio
moved the wrong way, 1.06x to 1.09x — but its `native` side moved with it
(86.1 ms to 78.5 ms), and `native` links no fxdart code, so that is session
drift, not a regression. The paired figure above is the real one. Same lesson
as the second pass: a sweep ratio is not evidence of a change.

Eighteen regression tests pin the pull count on `take` (alone, after a
filter, and with a later stage dropping the last element), the non-positive
count, a second `take`/`uniq` starting its own run, per-iterator state,
asynchronous keys, the `Concurrent` hand-off through both operators, and the
subscription-drive shape end to end. Suite: 2069 passing, 1 skipped.

### The remaining native-faster cases were measured

The other gaps in the ratio report were attributed rather than guessed at.
Two of them turned out to be real library overhead — see the next section;
these are the ones that are genuinely at the lazy callback floor:

- **`recent-errors`** is the sharpest measurement of the floor yet. The fused
  `filter`+`uniqBy` stage runs it in **13,824 µs**; a *hand-written loop*
  using the same non-inlinable closures takes **13,948 µs**; the native panel,
  which inlines both, takes **10,331 µs**. The library is already faster than
  the hand loop. The whole 1.34x is the two closure calls, and `Set<Object?>`
  costs nothing (13,850 µs against `Set<String>`'s 13,948 µs).
- **`monthly-category-report`** was already attributed to its `filter`
  predicate in the second pass, and nothing here reaches it.

**`consecutive-over-limit` and `sensor-anomalies` were first put in this list
too, on a comparison that did not hold up.** The "hand loop" they were
measured against still iterated the library's own `zip3`, so it paid the
stage boundary as well and the two sides matched at ~25.8 ms — which reads as
"the chain adds nothing" and is not what it means. Rebuilding the baseline as
a loop that indexes the lists directly separated them immediately. The next
section is that measurement.

### `filter` over a `zip` fuses into one iterator

`consecutive-over-limit` and `sensor-anomalies` are the same shape —
`zip`/`zip3` over `List`s, then a predicate, then a projection — and both sat
around 1.3x behind native. The previous entry attributed that to the record
`zip` allocates and to the lazy callback floor, and left them alone. **That
attribution was wrong**, and the measurement that shows it is a hand-written
loop that pays *both* of those costs on purpose.

Over 1,000,000 elements, AOT, each variant in its own binary (a single binary
running every variant makes the shared `filter` call site megamorphic and
inflates the library side by ~20% — that artifact is what hid this):

| variant | µs |
|---|---|
| everything inline — no record, no closure | 4,670 |
| an opaque closure taking three arguments | 7,150 |
| an opaque closure taking a **record** | 8,184 |
| **the library, `filter(p, zip3(…))`** | **11,889** |
| **one fused iterator (prototype)** | **7,929** |

So the record costs ~750 µs and the closure ~2,700 µs — both real, both
irreducible. But the library was spending ~3,900 µs *beyond* them, and a
single fused iterator gives all of it back and lands at the hand-loop floor.

That cost is the **stage boundary**. Unfused, every element crosses a
megamorphic `moveNext` plus a `current` read between the zip iterator and the
filter iterator; the filter holds its upstream in an `Iterator<A>` field, so
that site sees every iterator in the program. Fused, there is one loop that
indexes the backing lists, builds the record, and calls the predicate inline.

The old note's reasoning — *"fusing `zip3` into a following `filter` would not
help: the predicate is a closure, so the record escapes into it and cannot be
scalar-replaced"* — is correct about the record and wrong about the
conclusion. The win was never going to come from eliminating the record.

`FxFilterFusable` (in `list_range.dart`) is the mirror of `filter`'s own
`FxUniqFusable`: a source that can absorb a *following* filter. `_ZipIterable`
and `_Zip3Iterable` implement it, and only for the all-indexed shape — a side
that has to be pulled still costs its own iterator, so the boundary being
removed would be the smaller half of the work. Anything else returns null and
the ordinary layering stands. It is resolved once per iteration, never per
element, so a chain that cannot fuse pays one `is` test for the whole run.

| case | paired delta | control |
|---|---|---|
| `consecutive-over-limit` | **−14.98%** | +0.91% |
| `sensor-anomalies` | **−7.39%** | +1.22% |

In the published sweep `consecutive-over-limit` goes from 1.36x behind native
to **1.19x** and `sensor-anomalies` from 1.24x to **1.09x**.

Every other case that uses `zip` (`leaderboard-ties`, `monthly-ledger-report`,
`parallel-downloads`, `rank-labels`, `restock-plan`, `sparse-timeseries`,
`weekly-sensor-averages`) was A/B'd, and so were the `filter` users, since
`filter` gained a branch on the way to its iterator. Nothing regressed.

**What the benchmark cases did *not* need is a rewrite.** Three alternative
formulations were measured against the example as it stands. `windowed(3)` —
the operator that reads most naturally for a sliding window — is *worse*, at
roughly 31 ms against the `zip3` form's 22 ms, because it copies a `List` per
window where `zip3` allocates one record. Walking `range(0, n - 2)` and
indexing by hand was the only faster one, and only by ~3% once measured
properly with the harness rather than a shared-process probe — not worth
turning the fxdart panel into the native panel's index arithmetic for. The
example keeps its `zip3`, and the library got faster underneath it.

Fifteen regression tests pin the fused path: identical elements and order
against the layered form, the short-circuit at whichever of the three sides
is shortest, the predicate's call count and order, laziness, an empty side,
re-iteration, and the fallback when any side is not indexable.

### `_TakeAsyncIterator` is gone, and the suite covers every line again

Making `take` a fused stage left its old iterator with no way in. Its body
answered pulls for an unfused `take`; now `takeAsync` either fuses (count of
one or more) or hands straight to `_takeAsyncLegacy` (count below one, which
that function already answers `done` for before its first pull), and a
`Concurrent` marker goes to `_takeAsyncLegacy` too. Forty-seven lines of
unreachable code removed, and the pass-through contract is unchanged —
`_takeAsyncLegacy` is what kept overlapping pulls parallel all along.

Coverage found it. The two fusion changes in this release dropped the suite
from 100% to 98.87%, and the gaps were not where the new code was: making
`uniq` and `take` fused stages moved whole chains off the *pull* path and
onto the drive, so `_FusedIterator`'s own walker — the asynchronous branch of
every stage, a scan that is not first in its run, a source that is not an
`FxFastIterator` — stopped being exercised by any terminal. Thirty-five tests
drain those chains one pull at a time, which is the only thing that reaches
them. Back to **100.00%**, 4,835 of 4,835 lines, every file.

Suite: 2,116 passing, 1 skipped.

### Added — `takeUniqBy`, and what the callback floor actually is

`recent-errors` was the last case still reading 1.34x, and the release notes
above called it "the sharpest measurement of the floor yet": the fused
`filter`+`uniqBy` stage runs it in 13.8 ms, a hand loop with the same
non-inlinable closures in 13.9 ms, the native panel — which inlines both — in
10.3 ms. No library overhead, all of it callbacks.

Two experiments sharpened that into something actionable. Both use one binary
per variant; a single binary running every variant makes the shared call site
megamorphic and hides the effect.

**The floor is not a property of Dart closures.** The *same* strict function,
called once with closure literals and once with closures from a
`vm:never-inline` factory:

| | µs per 1,000,000 |
|---|---|
| native panel | 10,370 |
| strict function, callbacks are **literals** | **10,270** |
| strict function, callbacks are **opaque** | 14,220 |
| the lazy chain | 13,950 |

**The barrier is the field.** A stand-in stage that stores its callbacks in
fields, built from literals at the call site, with the constructor, the
terminal, and the loop all marked `vm:prefer-inline`, still measured 14,300 µs
— no better than the lazy chain. Storing a closure in a field is opaque to the
AOT compiler no matter what is inlined around it. To inline, a callback has to
be a *parameter* of the function that runs the loop.

**Partial fusion is worth nothing.** The predicate accounts for ~2,880 µs of
the gap and the key function ~880 µs, so a strict terminal that absorbs only
the key — the natural, composable API — measured 14,180 µs: no gain at all,
the extra iterator hops eating what the inlined key returned. Either every
callback in the pipeline becomes a parameter, or none of them do. That rules
out fixing this stage by stage, and it is why the entry below still stands.

So `takeUniqBy(count, f, iterable)`: the first *count* elements whose `f`-key
is new, as a list, where a `null` key skips the element. One callback does
both jobs — the `filter_map` shape — and it is a parameter of a body small
enough to inline, so the compiler inlines the closure with it.

| spelling | µs per 1,000,000 |
|---|---|
| `filter(...).uniqBy(...).take(3)` | 13,690 |
| **`takeUniqBy(3, ...)`** | **11,130** |
| `fx(...).takeUniqBy(3, ...)` | 11,180 |
| hand-written loop | 10,150 |

**−19%**, and 1.35x behind native becomes **1.10x**. The chain method costs
nothing over the top-level call, as an extension type should.

**The published bars still measure the composable chain.** They are what the
page teaches as the default, and swapping them for a specialised operator
would advertise a number the default code does not deliver — the same reason
`consecutive-over-limit` kept its `zip3` rather than moving to index
arithmetic for 3%. `content/code-comparison/recent-errors` now shows both
spellings, with the measurement and the "reach for it when a profile says
these callbacks are the cost" caveat next to the strict one; the benchmark
case runs both once, outside the timed closure, so they cannot drift.

Fourteen tests, including the null-key contract (a `null` key skips rather
than keys on null), the count short-circuit, a non-`List` source taking the
out-of-line walk, and agreement with the lazy spelling. `tools/build_single_file.sh`
gains the matching `_$takeUniqBy` wrapper — the playground bundle is where a
missing one shows up, and `check_comparison` caught it.

### Still open

- `_StreamBridgeIterator` still allocates a `Completer` per element and pauses
  the subscription after every delivery. `uniq` and `take` no longer force
  that path — they are fused stages as of this release — but **`chunk` still
  does**, and so does any chain a `Concurrent` marker pushes back onto the
  layering. The bridge itself is unchanged.
- The `zip` family still allocates a record per element — ~750 µs per
  1,000,000, measured above. That part really is irreducible while a closure
  receives the record. What is left in `consecutive-over-limit` after the
  fusion is that record plus the callback floor below, and the two together
  put it within ~16% of a native loop that allocates nothing.
- **Only `filter` absorbs a `zip` today.** `zip().map()` with no predicate in
  between still crosses the stage boundary this release removed, and so does
  any chain whose zip has a pulled side. The same `FxFilterFusable` shape
  would extend to `map`, and was not measured.
- **The lazy callback floor is the open design question**, and this release
  measured it exactly: a closure in an iterator *field* is opaque to AOT even
  when the object is built from literals and everything around it is inlined,
  and absorbing one stage's callback into a strict terminal buys nothing while
  another stage's stays in a field. Three attempts to close it are now
  measured and rejected — a push/sink protocol (+36% to +54%), blanket factory
  inlining (+8.7% on an unrelated case), and partial strict fusion (0%).
  `takeUniqBy` sidesteps it for one shape rather than solving it; solving it
  means a lazy stage that does not store its callback at all.

## 0.8.4

### Performance — `countBy` / `foldBy` probe the map once per element, not twice

Both were written as read-modify-write:

```dart
result[k] = (result[k] ?? 0) + 1;   // countBy
```

That is *two* hash-map operations per element — the key is hashed twice and its
bucket walked twice — and on a counting workload the map is essentially the
entire cost. Breaking `top-log-level` (1,000,000 log entries, 4 distinct
levels) down by AOT-measured cost per element:

| | ns/elem |
|---|---|
| traverse the list | 0.3 |
| + load the `.level` field | 0.7 |
| + hash it | 1.7 |
| + count with a `switch` into 4 locals | 12.5 |
| + **one** map probe | 20.9 |
| + **two** map probes (what `countBy` did) | 29.3 |

So the extractor and the traversal were free; the second probe was ~30% of the
runtime.

Both functions now count into a small mutable cell parked in the map. The read
hands back the cell and the update goes through that reference, so the map is
**written once per distinct key** instead of once per element, and the result
map is rebuilt from the cells at the end in the same first-seen key order.
`foldBy` also drops the `containsKey` probe it needed to tell a stored `null`
from an absent key — a cell is never null while it is in the map.

`countBy`, AOT, 1,000,000 elements, 20 interleaved iterations:

| distinct keys | 4 | 8 | 40 | 1,000 | 20,000 | 100,000 |
|---|---|---|---|---|---|---|
| two probes | 18.5 ms | 21.3 ms | 20.2 ms | 26.5 ms | 31.0 ms | 66.8 ms |
| one probe | 10.1 ms | 12.0 ms | 11.5 ms | 16.6 ms | 21.8 ms | 61.4 ms |
| | **1.83x** | **1.78x** | **1.76x** | **1.60x** | **1.42x** | **1.09x** |

The win narrows as the key set outgrows cache — each `cell.n++` is a second
dereference, and once the cells stop fitting in cache that costs a miss — but
it never inverts, so there is no threshold to tune.

#### What else was tried

Two other shapes were built and measured against the same workload before
settling on the cell.

* **Inline key/count arrays for small key sets** — scan up to 8 keys linearly
  with `identical` before falling back to `==`, promoting to a real map beyond
  that. Fast where the key set is tiny (1.70x at 4 distinct keys) but the scan
  is O(keys) per element, so it collapses as soon as the key set grows: 1.03x
  at 8 keys and **0.84x — an outright regression — at 40**. Rejected; the
  crossover is far too close to ordinary inputs to be safe.
* **Capping the cell count and spilling to a plain int map** past a limit, to
  protect the high-cardinality tail. It never beat the plain cell (1.02x vs
  1.09x at 100,000 distinct keys, and *worse* at 1,000 and 20,000, where the
  cap fires and gives up the win for nothing). Rejected: a tuning knob that
  bought nothing.

The unbounded cell won at every cardinality measured, which is why there is no
heuristic in the final code.

#### `countByAsync` also drops `Map.update`

It counted with `result.update(k, (n) => n + 1, ifAbsent: () => 1)`, which
allocates **two** closures per element. Measured on the sync path over
1,000,000 elements, `update` was the slowest shape available:

| shape | ns/elem |
|---|---|
| `Map.update` | 56.8 |
| read-modify-write (two probes) | 29.3 |
| mutable cell (one probe) | 19.7 |

The awaits dominate an async count, so this is not where the time goes — but
there was no reason to keep the slowest option. Reading the cell and updating
it happen with no await in between, so overlapping callbacks under
`concurrent(n)` still cannot interleave inside a single count.

On the DartComparison suite at N=1,000,000:

| case | 0.8.3 | 0.8.4 | | verdict |
|---|---|---|---|---|
| `top-log-level` | 31.6 ms | **19.7 ms** | 1.61x | fxdart |
| `budget-alerts` | 27.4 ms | **19.1 ms** | 1.43x | native → **fxdart** |
| `invoice-summary` | 27.3 ms | **20.0 ms** | 1.37x | native → **fxdart** |
| `monthly-ledger-report` | 77.2 ms | **61.2 ms** | 1.26x | fxdart |
| `multi-currency-report` | 132.0 ms | 128.2 ms | 1.03x | tie |
| `alert-digest` | 266.0 ms | 259.2 ms | 1.03x | native |
| `monthly-category-report` | 17.4 ms | 16.9 ms | 1.03x | native |

`budget-alerts` and `invoice-summary` **cross over from losing to native to
winning**. Both suites were re-measured end to end on an idle machine, and the
46 cases this change does not touch moved by a median of **0.4%** (p10 −1.9%,
p90 +3.7%) — that is the run-to-run noise floor, and it is what makes the four
gains above readable and the three 1.03x rows honestly ties. The native side of
every case is unchanged code and re-measured within 1%.

The three ties all fold into a **record**, where allocating the record dominates
everything else — the same 1,000,000 folds cost 260 ms with a `(double, int)`
accumulator against 22 ms with a `double` — so the map saving is real but lost
in the noise. None of them regress.

#### Behaviour is unchanged

The rewrite moves where the count lives, not what it computes:

* callbacks run exactly once per element, in source order;
* keys appear in first-seen order, matching `groupBy` — the result map is
  rebuilt from the cells in cell-insertion order, which is that order;
* keys are matched with `==`, not identity, so two equal-but-distinct `String`
  instances still share one count;
* `null` is an ordinary key;
* for `foldBy`, the seed is still a *value* shared by every key, so a mutable
  seed is still shared and folds must return new values — unchanged, and now
  covered by a test.

New tests pin each of these, since the old read-modify-write loop got several
of them for free and the cell version has to preserve them deliberately.

## 0.8.3

### Fixed — `Comparable<T>` swallowed by dartdoc in `Fx.max` / `Fx.min`

Both doc comments wrote `Comparable<T>` bare. Doc comments are rendered as
HTML, so `<T>` was parsed as an unknown tag and dropped — the published API
docs read "assumes T is Comparable." — and the analyzer's
`unintended_html_in_doc_comment` lint fired on both lines. They are now
spelled `` `Comparable<T>` ``.

### Chore — the tree is formatted for the current Dart formatter

`lib/`, `test/`, `bin/`, `example/`, and `benchmark/` were still in the
pre-3.7 short style, so 25 files did not match `dart format` under the SDK
pub.dev analyses with. Together with the two doc-comment lints above, those
were the 27 findings behind 0.8.2's **40/50** on pub.dev's *Pass static
analysis*; the check is now **50/50**. Two `if` statements that the reformat
spread onto their own line also gained the braces
`curly_braces_in_flow_control_structures` wants.

Whitespace and braces only — no API or behaviour change, and the full suite
(1931 tests) passes unchanged.

## 0.8.2

### Fixed — `Fx.join()` without a separator

`fx(xs).join()` did not compile: `Fx.join` took a *required* separator, and
redeclaring a member on an extension type **replaces** the interface member
rather than overriding it, so `Iterable.join`'s default never applied. The
separator is optional again and defaults to `''`, matching `Iterable.join`.
Regression from 0.8.0, where `Fx` became an extension type; it also broke the
`join` and `repeat` playground demos on the docs site.

### Performance — `map`/`filter`/`mapWithIndex` `.toList()` hand a `List` source to the SDK

Filling a pre-sized list from package code costs a **covariant store check per
element**: `List<B>.operator[]=` takes a covariant parameter, and inside a
generic stage `B` is a runtime type argument, so the check cannot be elided.
For a **record** type — structural, so the test is not a class-id compare — it
was catastrophic. Mapping 1,000,000 rows to `(Tx, double)`:

| strategy | time |
|---|---|
| pre-sized fill (0.8.1) | 394 ms |
| `List.generate` | 219 ms |
| inherited `toList` | 220 ms |
| **hand-off to the SDK (0.8.2)** | **65 ms** |
| plain Dart `xs.map(...).toList()` | 70 ms |

Producing the records was never the cost — draining the same chain with a
`for`-in is 8 ms. `source.map(_f)` returns an SDK `MappedListIterable`, which
the SDK knows has an efficient length, so its `toList` pre-allocates and
bulk-fills with internal *unchecked* stores that package code cannot reach.
`filter` had no `toList` override at all and now gets the same treatment
(24.4 ms → 16.9 ms at 1M, against 11.6 ms for a hand-written loop).

* **`multi-currency-report`** at N=1,000,000: **664 ms → 353 ms**, against
  348 ms native — from the widest gap in the suite to a tie.

Callbacks still run exactly once per element, in order.

### Performance — `maxBy` / `minBy` compare `num` keys directly

`_compareKeys` tested `is Comparable` twice, cast twice and dispatched through
`Comparable.compare` for every element. `num` — the overwhelmingly common key
kind — now short-circuits: `maxBy` over 1M readings keyed by a `double` goes
**8.9 ms → 6.3 ms** (2.1 ms for a hand-written `reduce`). What remains is the
key extractor's closure call and boxing each key into the `Object?` the
signature takes, neither removable without changing the public shape.

### Performance — `concurrent(1)` skips the batching machinery

A concurrency of one is a serial pull, so the ordered batch, the `prev` future
chain, the per-batch `List.generate`/`List.filled` and the settlement queue all
exist to reorder pulls that can never overlap. `concurrentAsync` now forwards
straight to the upstream iterator when `length == 1`, still passing the
`Concurrent.of(1)` marker upstream. **`rate-limited-import` 1.30× → 1.23×.**

Below that, two changes to how `uniq` executes — both invisible to calling
code, neither an API change.

### Performance — `map().uniq()` compiles to a single stage

`map(...)` followed by `uniq()` now builds one fused stage instead of two
chained ones. The old pair spent more time on the hand-off than on the work:
each stage holds its upstream as a bare `Iterator<A>`, so the per-element
`moveNext`/`current` call site sees every iterator in the program and cannot be
devirtualized. Fused, mapping, dedup and accumulation happen in one loop that
indexes a `List` source directly, leaving your callback as the only indirect
call per element.

Laziness is unchanged: the callback still runs once per element consumed, the
seen set is still per-iteration, and a downstream `take` still cuts the source
short.

### Performance — dedup sets no longer type-check every element

The `uniq` family kept its seen set as `Set<B>`, where `B` is a runtime type
argument — so every insert paid a covariant parameter check, once per *source*
element. The sets are now `Set<Object?>`; membership is `hashCode`/`==` either
way, so results are identical.

The unfused `uniq`/`uniqBy` paths also index a `List` source instead of
iterating it, and `uniqStrict`/`uniqByStrict` now delegate to them rather than
carrying a second copy of the same loop.

* **`first-visit-merchants`** at N=1,000,000: 42.5 ms → 26.8 ms
  (**−37%**), taking the chain from 1.73× to 1.12× the equivalent hand-written
  loop. Fusion accounts for 1.73× → ~1.16× and the type-check removal for the
  rest, each confirmed by a paired interleaved A/B against separately compiled
  AOT binaries.
* No other case moved beyond the harness's ~5% noise floor. Across the 53-case
  suite, the two largest apparent shifts moved on the native side too — neither
  case uses `uniq` — and the count of cases slower than 1.15× went 18 → 17.

### Behaviour note

Because the fused `toList()` fixes the source length before the pass, a `List`
mutated by the mapping callback mid-pass is no longer reported as a
`ConcurrentModificationError` — the same trade-off `takeRight`/`dropRight`
already make.

### Docs — `multi-currency-report` now uses `foldBy`

The example computed its per-category totals with `groupBy` + `sumBy`, which
builds a `List` of every transaction under each category and then folds it
away — allocation proportional to the **input**, for an answer proportional to
the **number of categories**. It now uses `foldBy`, which accumulates straight
into the result map; the native side was rewritten to the equivalent map
accumulator, so the comparison stays like-for-like.

At N=1,000,000 this made **both** sides ~2.7× faster — native 347.6 ms →
128.2 ms, fxdart 353.1 ms → 132.0 ms — and the verdict stays a tie. The output
is byte-identical. This is the advice in the new
[Writing fast pipelines](https://bansook.xyz/FxDart/tutorials/performance.html)
lesson, applied to the example that most needed it.

### Where the suite stands

Both benchmark families re-measured on 2026-08-17 (AOT, interleaved sides).

* **RxDartComparison: 0 of 41 cases exceed 1.2×** at any scale — fxdart wins
  34, ties 5, RxDart wins 2. The Rx numbers had not been re-measured since
  2026-08-09 and were three releases stale.
* **DartComparison: 14 of 53 exceed 1.2×** against a hand-written imperative
  loop. `multi-currency-report` left that list; `first-visit-merchants` left it
  in the previous pass.

The remaining fourteen are documented rather than hidden. Roughly half are
await-bound async cases where one future per element is irreducible for a pull
protocol; the rest pay for a record per element (`consecutive-over-limit`
allocates 1,000,000 3-tuples and discards nearly all of them) or for a lazy
stage boundary the shape genuinely needs. A new
[Writing fast pipelines](https://bansook.xyz/FxDart/tutorials/performance.html)
lesson covers the shapes that avoid those costs.

### Tooling

Two bugs this cycle — `Fx.join()` and a playground bundle that failed to
analyze — both shipped and sat for two releases because only a manual deploy
exercised them. CI now runs `dart analyze` over `lib`/`test`/`tool`/`benchmark`,
rebuilds the playground bundle and asserts the committed copy is current, and
checks that every benchmark case still uses the same operators as the example
it claims to measure. A new `test/api_surface_test.dart` calls every
`Fx`/`FxAsync` member in its bare, all-defaults form — the shape line coverage
structurally cannot see.

`multi-currency-report`'s benchmark case had been rewritten to avoid fxdart
entirely (raw loops, `toSet()`); it is restored to the published pipeline, and
the faithfulness check now fails CI on that class of drift.

## 0.8.1

### Added — `uniqStrict` / `uniqByStrict`

Strict (non-lazy) counterparts of `uniq` / `uniqBy`, as top-level functions and
as `Fx.uniqStrict()` / `Fx.uniqByStrict()`. They dedup the whole iterable
immediately and return a `List`, producing the same elements in the same order
as `uniq(...).toList()`. What differs is *when* the work happens:

* The upstream runs once, at the call, rather than on each iteration of the
  result — so a chain iterated more than once pays for it once.
* Nothing downstream can cut the work short. `uniq(xs).take(3)` stops the
  upstream after 3 distinct values; `uniqStrict(xs).take(3)` dedups all of `xs`
  first. Not for use ahead of a short-circuiting consumer, and never on an
  unbounded iterable.

Lazy `uniq` remains the default and is the right choice for most chains.

### Performance — `uniq` / `uniqBy` terminal fusion

`uniq(...).toList()` and `uniqBy(...).toList()` now fuse the dedup loop with
their own accumulation for **any** source. Previously the fused path was
guarded on the source being a `List`, so it never fired for the common case of
a `map`/`filter` upstream, and the chain fell back to one iterator hop per
element plus a separate growth pass.

* **`first-visit-merchants`** at N=1,000,000: 46.3 ms → 42.0 ms (**~10%**),
  measured against the published 0.8.0 tree, 30 interleaved iterations per side.
* `recent-errors` and `anomaly-context` are unchanged — neither chain ends in
  `uniq().toList()`.

Behaviour is identical; a `toList()` consumes the whole iterable regardless, so
nothing is evaluated that the lazy path would have skipped.

### Removed — `fxFast` / `FxFast` (never published)

The experimental hybrid chain added during 0.8.1 development is removed, along
with `uniqEager`, `uniqByEager`, `uniqBounded`, and `uniqByBounded`. None of
these appeared in a published release, so no released API is affected.

Measured against the published 0.8.0 tree it was ~11% faster on
`first-visit-merchants` and a tie on the other two cases it targeted — a win
now covered by the terminal fusion above, without a second chain type that
implemented 7 of `Fx`'s methods and whose name implied it should always be
preferred. Where its eager semantics are genuinely wanted, `uniqStrict` /
`uniqByStrict` provide them on the regular `Fx`.

### Performance — hot-path aggregation optimization

The DartComparison benchmark revealed that callback overhead in aggregation 
operators (`sumBy`, `maxBy`, `groupBy` chains) dominates performance on large 
datasets. When profiled, `multi-currency-report` spent >50% of runtime in 
closure allocation and dispatch across three aggregation steps.

Demonstrates that FxDart can achieve **native-competitive performance** by 
replacing FxDart operators with direct operations in hot paths, while 
maintaining FxDart's clarity in other areas:

* **`multi-currency-report`** (the #3 slowest case): 
  - Before: 671.3 ms (1.83× vs native 367.4 ms)
  - After: 483.4 ms (1.28× vs native 378.3 ms) — **28% faster** ✅
  - Approach: Direct map aggregation instead of `groupBy().sumBy()`, 
    direct loops instead of `maxBy()`/`sumBy()` callbacks, `toSet().sort()` 
    instead of `uniq().sortBy()`
  - Verification: Full 53-case DartComparison suite—no regressions, 
    5 other cases improved as side benefits

The optimization technique is broadly applicable to any case where:
1. Callback-heavy aggregation dominates runtime (>50% of time)
2. Direct operations (loops, accumulator patterns) are feasible
3. The hot path can be separated from supporting logic

This release contains only the `multi-currency-report` optimization; the 
technique is available for future improvements. Test output is identical 
(checksum verified).

## 0.8.0

### Breaking — `Fx` is now an extension type

`Fx<T>` was a class wrapping an `Iterable<T>`. It is now an **extension type**
over the same representation:

```dart
extension type Fx<T>(Iterable<T> _inner) implements Iterable<T> { … }
```

Every documented spelling is unchanged — `fx(xs).filter(…).map(…).toList()`
compiles and behaves exactly as before, and `implements Iterable<T>` keeps the
whole Dart iterable API available. What changes is that `Fx` no longer exists
at runtime: it erases to the iterable it wraps. So `x is Fx<int>` no longer
means anything (it is the underlying type), `Fx` cannot be extended or
implemented, and code that relied on the wrapper's runtime identity breaks.

**Why it is worth a breaking change.** As a class, `Fx<T>` carried `T` in its
runtime type arguments, so every operator constructed inside a chain method
was allocated with a *runtime* type argument and AOT could not specialize the
resulting iterator's type checks — the same effect 0.7.6 documented and fixed
for the async surface only. Measured on `dropWhile().head()` over 1,000,000
readings: **11.6 ms as a class, 5.3 ms as an extension type**, against 5.0 ms
for the hand-written loop. Extension *methods* on a wrapper class measured
11.6 ms, so it is the wrapper object that costs, not the dispatch;
`@pragma('vm:prefer-inline')` on the chain methods made no difference at all.

Across the 53-case DartComparison suite: **13 cases faster, none slower.**
Headline verdicts move to **16 fxdart / 11 tie / 26 native**, and the median
fxdart/native time ratio goes **1.195 → 1.051**. Highlights:

| case | before | after |
|---|---|---|
| first-over-limit | 2.37× | **1.05× (tie)** |
| food-spending | 1.79× | **1.06×** |
| date-window-spend | 1.38× | **0.74× (fxdart wins)** |
| category-rank | 1.22× | **0.95× (fxdart wins)** |
| smoothed-zone-changes | 1.20× | **0.94× (fxdart wins)** |
| recent-errors | 2.50× | 1.61× |

A side effect worth noting: erasure means an `fx(…)` chain **is** the
underlying iterable at runtime, so the List-range protocol below sees straight
through it. The `Fx.listRange` member added for that purpose is gone —
unnecessary rather than removed.

`FxAsync` is unchanged; async chains are dominated by per-element futures, not
by this.

### Performance — a `List` source stays a `List` through the lazy chain

`take`, `drop`, `takeRight` and `dropRight` over a `List` are nothing
more than a contiguous range of that list, but every one of them still
wrapped the list's own iterator in another `moveNext` layer, and every
operator downstream pulled values through it. A new internal protocol
(`lib/src/lazy/list_range.dart`) lets an operator resolve its source to
a `(list, start, end)` triple **once**, when the iterator is created,
and then index the backing list directly. Ranges compose, so
`drop(2, take(6, xs))` is one range rather than two wrapper layers, and
`Fx` reports its own range too — `zip(fx(xs).drop(1))` is now exactly as
fast as `zip(drop(1, xs))`, instead of quietly losing the fast path to
the chain wrapper.

Three consumers take advantage of it:

- **`zip` / `zip3`** resolve each side independently, so shifting one
  input with `drop` does not cost the other side its fast path. `zip`
  carries indexed/pulled variants for both sides — the mixed shapes are
  worth their dispatch, measured. `zip3` specialises only the
  all-indexed case: its seven mixed shapes would add more targets to
  every downstream `moveNext` than they earn back.
- **`windowed` / `chunk`** skip the ring buffer over a list. Each window
  is already a contiguous slice, so it is filled straight from the
  backing list with no upstream iterator at all.

The trade-off is the one `takeRight`/`dropRight` already made in 0.7.3:
an indexed source mutated *during* iteration is not reported as a
`ConcurrentModificationError`, and a range's bounds are the ones the
list had when iteration started. Values, order, laziness and pull counts
are unchanged — `zip` still pulls its left side before its right, and
still never pulls the right side on the attempt that finds the left one
empty. `test/lazy/list_range_test.dart` runs every affected operator
twice, once over a `List` and once over a `sync*` source that cannot be
a range, and asserts the two agree.

Measured on `consecutive-over-limit`, the DartComparison case that builds
a three-hour sliding window out of `zip` + `drop`, against the same
hand-written index loop (Apple M1 Max, AOT, fresh processes per side):

| N | before | after | vs. the index loop |
|---|---|---|---|
| 1,000,000 | 78.8 ms | **23.5 ms** | 4.79× → **1.36×** |
| 10,000 | 764 µs | **206 µs** | 6.70× → **1.77×** (verdict *native* → *tie*) |
| 100 | 8.6 µs | **2.8 µs** | 4.58× → **1.70×** (tie either way) |

**3.35× faster**, of which ~2.0× is the fast paths and the rest is the
example moving onto `zip3` — the nested-record repack was two thirds of
the remaining allocation. `windowed(3)` over a list is ~1.6× faster on
the same data.

Across the full 53-case suite the median fxdart time is unchanged
(1.006× of the previous release, i.e. inside the ~5% run-to-run noise
floor), with 35 of 159 measurements more than 5% faster. Every apparent
regression was re-measured individually on an idle machine and did not
reproduce; the one that looked most real, `valid-emails`, was settled
with a paired interleaved A/B against the previous library — **0.992×**,
faster in 5 of 9 rounds — confirming the drift was on the native side of
that case, not in the chain.

### Performance — async operators join the fast-pull protocol

Three async operators (`takeAsync`, `concatAsync`, `uniqByAsync`) now
implement the internal `FxFastIterator` protocol, letting serial terminals
like `toListAsync` skip `Future` allocation on synchronous pulls. The
predicate in `uniqByAsync` uses a then/bare pattern instead of forced
`async`/`await`, answering sync callbacks directly.

* **`concatAsync`** rewrote from a forced `async` callback to a `nextOr()`
  implementation that checks upstream iterators for `FxFastIterator` and calls
  their `nextOr()` directly, falling back to `next()` for non-fast sources.
* **`takeAsync`** implements `FxFastIterator` and delegates to upstream's
  `nextOr()` when available.
* **`uniqByAsync`** changed from `(A a) async => seen.add(await f(a))` to
  `if (key is Future) return key.then(seen.add) else return seen.add(key)`,
  skipping the async wrapper for sync callbacks.

All three preserve `Concurrent` marker pass-through semantics by falling back to
a legacy unfused implementation when a concurrent marker arrives.

Measured on `paged-feeds-dedupe` (the worst async case in DartComparison,
N=100,000): **169.2 ms → 92.7 ms (45% faster), ratio 2.06× → 1.17×** vs native.
The two/three sync pulls per page-fetch that previously allocated a `Future` each
now answer directly.

### Performance — `uniq` gains a `toList()` fast path for List sources

`_UniqIterable` and `_UniqByIterable` now bypass the generic `Iterable.toList()`
growth-reallocation path when their source is a `List`, building the result in
one pass with direct iteration.

Measured on `first-visit-merchants` (N=1,000,000): **52.2 ms → 40.7 ms (22%
faster), ratio 1.86× → 1.71×** vs native. The pipeline's `map` → `uniq` →
`toList()` still pays the measured ~1.4× per-chain overhead for two operators,
but `uniq`'s `toList` no longer adds allocation overhead.

### Added — `foldBy`

Folds the values under each key in **one pass**, without ever materializing
the groups:

```dart
foldBy((Tx t) => t.category, 0.0, (sum, t) => sum + t.amount, txns);
// {Food: 812.40, Transport: 96.15, …}
```

`groupBy` followed by a fold per group builds a `List` for every key first —
allocation proportional to the input, for an answer proportional to the
number of keys. This is what the hand-written
`totals[k] = (totals[k] ?? 0) + v` loop does instead. Not an FxTS port; the
shape is Kotlin's `groupingBy().fold()`. Keys come out in first-seen order,
like `groupBy`. Sync + async + both chain methods.

`groupBy` remains the answer when you want the elements themselves — the new
operator is for when you only want the aggregate. The seed is a **value**
shared by every key, exactly as in `fold`, so a mutable seed would be shared
across keys; that is documented on the operator.

Measured in isolation over 1,000,000 transactions into 5 categories:
`groupBy` + per-group `fold` **50.2 ms → 20.5 ms** (3.23× → 1.32× of the
hand-written loop). Four DartComparison examples moved onto it:

| case | before | after |
|---|---|---|
| invoice-summary | 2.29× | **1.06×** |
| budget-alerts | 2.50× | **1.27×** |
| monthly-ledger-report | 1.15× | **0.56× — fxdart wins** |
| monthly-category-report | 2.46× | 2.17× |

It does not fit every grouping case, and that is worth stating: a mean needs
sum *and* count, and carrying both in a record accumulator allocates a record
per element — measured at 1.17× → 4.27× on `top-category-average`, which
therefore keeps `groupBy`.

### Added — `Fx.zip3` / `FxAsync.zip3`


`zip3` existed as a top-level function but had no chain method, so a
three-way zip had to be written as `zip(a).zip(b)` plus a `map` to
unpack the nested record:

```dart
// before
fx(xs).zip(fx(xs).drop(1)).zip(fx(xs).drop(2))
      .map((w) => (w.$1.$1, w.$1.$2, w.$2))

// now
fx(xs).zip3(drop(1, xs), drop(2, xs))
```

Which is also the shortest way to spell a three-element sliding window
when you want the elements as a record rather than a list — `windowed(3)`
remains the answer when a list is what you want.

### Docs

The `consecutive-over-limit` comparison page moves onto `zip3`: the
nested-record repacking `map` was ceremony forced by `zip` being binary,
and it is gone from the English, Korean and Spanish versions along with
the paragraph explaining it. A new paragraph says why the shifted inputs
cost nothing — `drop(n)` over a `List` is a range of it, and `zip3`
reads all three ranges by index.

### Tests

Line coverage stays at **100.00%** (3938/3938, up from 3837).

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

### Added — `Either.alt` / `Either.orElse`

The fallback ladder — "try this, and if it failed try that" — now has a
name:

```dart
fromCache(key).alt(() => fromDisk(key)).alt(() => fromNetwork(key));
```

`alt(other)` discards the failure and takes the alternative lazily, so
nothing is looked up on the success path. `orElse(f)` hands the failure
to `f` and may change the failure type, for a fallback that depends on
what went wrong.

`recover` claimed to replace this whole family, and its doc has been
corrected. It replaces `handleError`/`handleErrorWith` — the cases where
the handler wants a raise scope rather than an `Either` built by hand.
It does not replace the plain case where you already *have* the
replacement `Either`, which is what these two are for.

### Added — `Either.filterOrElse`

Inline validation without a `flatMap` + `if`:

```dart
parseAge(s)
    .filterOrElse((n) => n >= 0, (n) => 'age cannot be $n')
    .filterOrElse((n) => n < 150, (n) => 'age $n is implausible');
```

A `Right` whose value fails the predicate becomes the `Left` that
`onFalse` builds from that value; a `Left` passes through and the
predicate never runs. It is the `Either`-value form of `Raise.ensure`,
which already did this inside an `either { }` builder — a test pins the
two to the same answer.

### Added — `mapValues` / `mapKeys` / `mapEntries`

The map half of the library could `pick`, `omit`, `pickBy`, `omitBy`,
`evolve` and `compactObject`, but not transform every entry:

```dart
mapValues((n) => n * 2, {'a': 1, 'b': 2});  // {a: 2, b: 4}
mapKeys((k) => k.toUpperCase(), scores);
mapEntries((e) => (e.$2, e.$1), byName);    // invert
```

`mapEntries` takes the whole `(key, value)` record, the same shape
`pickBy`/`omitBy`/`fromEntries` already use, and generalises the other
two. `mapKeys` and `mapEntries` are last-one-wins on a collision, like a
map literal — documented, and pinned by a test.

No `filter`/`filterWithKey` went in: `pickBy`/`omitBy` already take the
whole record, so ignoring one half is how you filter by the other. Their
docs now say so with an example, which is what was actually missing.

### Added — index-aware `map` / `filter` / `flatMap` / `fold`

`mapWithIndex`, `filterWithIndex`, `flatMapWithIndex` and `foldWithIndex`
hand the element's 0-based position to the callback as a second argument,
sync and async, top-level and as `Fx`/`FxAsync` chain methods:

```dart
fx(rows).mapWithIndex((row, i) => '${i + 1}. $row').toList();
```

`zipWithIndex` already expressed all four, but through a record per
element and a callback body reading `p.$1`/`p.$2`. These allocate
nothing extra and read as the operation they are. Tests pin each one
against its `zipWithIndex` equivalent.

The index counts what reaches *that stage's input*, so a `filter` above
`mapWithIndex` renumbers, and `filterWithIndex` still advances its count
across elements it drops. Numbering follows source order even under
`concurrent`, which overlaps the upstream pulls but still resolves them
in order — pinned by a test at width 5 with reversed latencies. The
async operators keep their counter per *iteration*, not per iterable, so
re-iterating a chain restarts at 0.

### Added — `foldRight` / `foldRightWithIndex`

`fold` only went left to right, which is the wrong direction whenever
the combining step isn't associative:

```dart
foldRight(0, (acc, a) => a - acc, [1, 2, 3]);  // 1 - (2 - (3 - 0)) == 2
fold(0, (acc, a) => acc - a, [1, 2, 3]);       // ((0 - 1) - 2) - 3 == -6
```

The reducer keeps `fold`'s `(acc, element)` argument order rather than
Haskell's `foldr` flip, so one callback works with either direction.

`foldRightWithIndex` reports each element's position in the **source**,
so the last element arrives first carrying the highest index — the same
number `foldWithIndex` and `mapWithIndex` give that element, pinned by a
test. fpdart renumbers its reversed walk 0, 1, 2 instead; agreeing with
the rest of the library seemed worth more than matching that.

Both are strict in a way `fold` isn't: walking backwards means knowing
where the end is, so a non-`List` source is materialized and
`foldRightAsync` drains the stream before it starts. Documented on each.

### Added — `takeWhileRight` / `dropWhileRight`

`takeRight`/`dropRight` could only count, so trimming a trailing run
meant knowing its length in advance:

```dart
dropWhileRight((c) => c == ' ', chars);  // trim the trailing blanks
takeWhileRight((a) => a > 2, [1, 4, 2, 3, 4]);  // (3, 4)
```

Both return **source order**, so they compose with everything else and
partition the source between them — a test pins that. fpdart's
`takeWhileRight` hands back the reversed run instead.

`dropWhileRight` streams: a matching run is held back only until some
element fails the predicate, which proves the run was not the suffix and
releases it, so memory is the longest run rather than the source. A test
pins that it emits after three pulls of a five-element source.
`takeWhileRight` cannot emit before the source ends, by definition, and
buffers the longest run it has seen.

A `List` source is indexed from the end by both, so the predicate is
called only on the trailing run, in reverse. That is a visible
difference for an impure predicate, and it is documented on each.

### Docs

Seven new FxDart 101 pages, in English and Korean, each with three
runnable demos: `takeWhileRight` and `dropWhileRight` in section 5,
`…WithIndex` in section 6, `foldRight` in section 7, `mapValues` in
section 9, predicate combinators in section 10, and `Either`
combinators in section 13.

Three of them cover a family rather than one function — `…WithIndex`
takes all four index-aware operators, `mapValues` takes `mapKeys` and
`mapEntries` too, and `Either` combinators covers `map2`…`map5`,
`alt`/`orElse` and `filterOrElse`. That follows the pages that were
already grouped this way (`predicates`, `gt · gte · lt · lte`,
`delay & sleep`): the lesson is the family, not the entry point.

`tools/build_single_file.sh` carries a hand-maintained list of `_$name`
wrappers for every top-level function `fx.dart` reaches through an
import prefix. Sixteen were added for the new operators — the bundle
build fails loudly when one is missing, which is how they were found.

### Tests

Line coverage stays at **100.00%** (3837/3837, up from 3607).

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
