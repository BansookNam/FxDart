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
