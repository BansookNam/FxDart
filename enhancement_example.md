# Examples improved so far

Moved out of `slow_examples.md` once a change actually measured. Ratios are
fxdart/native median at the headline scale (1,000,000), AOT, fresh processes.

## 0.8.0 — `foldBy`

New operator: folds the values under each key in one pass instead of
materializing per-group lists. Measured in isolation at 3.23x -> 1.32x.
The native column was never grouping — it accumulates into a map — so this
is also the more honest example code.

| case | before | after | fxdart ms | change | status |
|---|---|---|---|---|---|
| budget-alerts | 2.50x | **1.27x** | 27.6 ms | `groupBy` + per-group `fold` -> `foldBy` | much better; still 1.27x |
| invoice-summary | 2.29x | **1.06x** | 26.5 ms | `groupBy` + per-group `sumBy` -> `foldBy`; the duplicate pass for the grand total remains | resolved (1.06x is inside the tie band) |
| monthly-ledger-report | 1.15x | **0.56x** | 83.1 ms | two `groupBy` + per-group `sumBy` -> two `foldBy` | **fxdart now wins** |
| monthly-category-report | 2.46x | **2.17x** | 24.8 ms | `groupBy` + per-group `fold` -> `foldBy` | improved but **still slow** — the fold was never the bottleneck here |

## 0.8.0 — List-range fast paths

`take`/`drop`/`takeRight`/`dropRight` over a List resolve to a range of the
backing list, and `zip`/`zip3`/`windowed` index it directly. Shipped in
commit ec2caf46.

| case | before | after | change |
|---|---|---|---|
| consecutive-over-limit | 4.79x (78.8 ms) | **1.34x (23.0 ms)** | list-range fast paths + the example moved onto `Fx.zip3` |

## Tried and reverted

Recorded so they are not re-attempted.

- **`late current` -> stored/delegating field** (44 iterator classes). No gain on
  `food-spending`, and a **25% regression** on `consecutive-over-limit`: the record
  iterators then paid a `(A, B)` type-test per element. Reverted.
- **`top-category-average` onto `foldBy`** with a `(double, int)` record
  accumulator. 1.17x -> **4.27x** — a record allocated per element. Reverted;
  a mean needs sum+count, which `foldBy` cannot carry without allocating.
- **Sync stage fusion** (composed-closure prototype). +13% on `filter -> sum`,
  **-20%** on a 3-stage chain. Not pursued; see `slow_examples_reasons.md`.
- **`vm:prefer-inline` on the 87 sync `Fx` members**. No measurable change.
  Reverted.

## 0.8.0 — `Fx` became an extension type

The single biggest lever found. As a class, `Fx<T>` carried `T` in its runtime
type arguments, so every operator built inside a chain method was allocated with
a *runtime* type argument and AOT could not specialize its type checks — the
same effect 0.7.6 fixed for async only. An extension type erases to its
representation, so `T` is a compile-time constant at each call site and no
wrapper is allocated.

Isolated on `dropWhile().head()` over 1M readings: **11.6 ms as a class, 5.3 ms
as an extension type**, against 5.0 ms for the hand-written loop. Extension
*methods* on a wrapper class measured 11.6 ms — so it is the wrapper object,
not the dispatch.

Full 53-case suite: **13 cases improved, zero regressions.** Headline verdicts
moved to **16 fxdart / 11 tie / 26 native**; median fx/native **1.195 -> 1.051**.

| case | before | after | now |
|---|---|---|---|
| anomaly-context | 4.00x | **1.66x** | native |
| first-over-limit | 2.37x | **1.05x** | tie |
| recent-errors | 2.50x | **1.61x** | native |
| monthly-category-report | 2.17x | **1.49x** | native |
| date-window-spend | 1.38x | **0.74x** | fxdart |
| category-rank | 1.22x | **0.95x** | fxdart |
| smoothed-zone-changes | 1.20x | **0.94x** | fxdart |
| sparse-timeseries | 1.13x | **0.88x** | fxdart |
| top-category-average | 1.21x | **1.00x** | tie |
| bounded-concurrency | 1.26x | **1.12x** | native |
| weekly-sensor-averages | 1.12x | **1.00x** | tie |
| alert-digest | 1.54x | **1.44x** | native |
| valid-emails | 1.05x | **0.96x** | tie |

### Also in this round

- **`anomaly-context` 4.00x -> 1.67x** — the example walked `zipWithIndex()`, allocating
  a record for all 1,000,000 readings to keep the ~8,000 (0.8%) that are anomalies.
  It now walks `range(0, readings.length)` and indexes the list, so only ints flow.
  Still `native`, not a tie: two lazy layers over 1M cannot quite match a raw
  indexed loop.
- **`first-over-limit` 2.37x -> 1.05x (tie)** and **`food-spending` 1.79x -> 1.06x**
  came entirely from the extension type, with no example change.

## 0.8.0 — `sortBy` picks a strategy from the key shape

`sortBy` over a double key ran decorate-sort-undecorate unconditionally: it
sorted an *index* list, so every comparison did two random reads into the key
array and the result was gathered back through the permutation. It now scans
the keys once (O(n)) and picks: already ordered returns as-is, exactly
reversed reverses, anything else takes a stable dual-array merge.

| case | before | after | fxdart ms |
|---|---|---|---|
| paginated-products | 1.81x | **1.25x** | 188.2 -> 128.4 |
| top-expenses | 0.65x | **0.42x** | 337.9 -> 218.0 |
| ledger-diff | 1.42x | **1.30x** | 343.9 -> 330.7 |
| price-drop-detection | 0.58x | **0.56x** | 712.0 -> 676.8 |

The ordered shortcut is why `price-drop-detection` ended up *faster than
before*: its keys arrive perfectly reversed, so it now costs O(n).

Scope: the double-key path only. int / String / generic keys keep DSU, so
tie stability currently holds on one path and not the others — a wart, and
the reason stability is not documented as a guarantee yet.

### Also tried and reverted

- **Non-adaptive dual-array merge** (no shape scan). Won big on random data
  but was a **2.5x regression** on `price-drop-detection`, whose keys arrive
  reverse-ordered — the worst case for a merge, the best for quicksort.
  The shape scan exists because of this.
- **`uniq().toList()` fusion.** No measurable effect (51.5 -> 51.7 ms on
  `first-visit-merchants`). The cost there is the `map` layer's per-element
  iterator, not `uniq`.
