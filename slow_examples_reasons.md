# Why fxdart is slower on the remaining cases

Rewritten 2026-08-09 after the first version's main conclusion turned out to
be **wrong**. Read the method note before the findings — it is the part that
generalises.

## Method, and why the first version failed

The first version blamed "layered iterator dispatch": one shared generic
iterator class per operator, used with every upstream in the library, so the
inner `moveNext` could never be devirtualised. It had a striking measurement
behind it — the same class over one upstream shape ran at 1.01×, and over five
shapes at 1.73×.

It was wrong, and the fix built on it (sync stage fusion) made a 3-stage chain
**20% slower**. The measurement came from a probe that ran every variant in one
binary, which pollutes every shared class in the program — **including the
SDK's**, so the "native" baseline was degraded too. Ratios from that probe were
not transferable to the real benchmark binaries, which run one pipeline each.

Everything below was measured with **one pipeline per compiled binary**, the
way `benchmark/run_benchmarks.dart` does it, varying exactly one thing at a
time. Where that discipline was applied, the diagnosis held; where it wasn't,
four separate attempts were reverted.

**Rules that came out of this, the expensive way:**

- One pipeline per binary. A multi-variant probe measures the probe.
- Vary one thing. The `late current` hypothesis died because the "identical"
  comparison class differed in two ways, not one.
- A fast path is not the pipeline. `map().toList()` at 8.7 ms comes from
  `_MapIterable.toList`'s pre-sizing shortcut; a `uniq` consuming that same
  `_MapIterable` goes through the iterator and gets none of it. Comparing them
  produced a fix that measured exactly nothing.
- Predict, then check. `sortBy`'s boxing fix was predicted at ~30% and
  delivered 9%; the gap was the real cause, and finding it needed another
  measurement, not more confidence.
- The full 53-case suite decides. `price-drop-detection` — a 2.5× regression
  from an otherwise-winning change — appears in no single-case check.

## The one cause that mattered: the `Fx` wrapper object

`Fx<T>` was a class, so `T` lived in its runtime type arguments. Every operator
constructed inside a chain method was allocated with a *runtime* type argument,
and AOT could not specialize the resulting iterator's type checks — the effect
0.7.6 documented and fixed for the async surface only.

Isolated on `dropWhile().head()` over 1M readings:

| | time |
|---|---|
| native | 5.03 ms |
| `Fx` class chain | 11.59 ms |
| extension methods on a wrapper **class** | 11.63 ms |
| **extension type** | **5.29 ms** |
| extension methods on `Iterable` | 5.20 ms |

The wrapper *object* is the cost, not the dispatch — swapping instance methods
for extension methods on a class changed nothing.
`@pragma('vm:prefer-inline')` on the chain methods changed nothing either.

Fixed by making `Fx` an extension type (erases to its representation).
**13 cases faster, none slower**; median fx/native 1.195 → 1.051.

## `sortBy`: decorate-sort-undecorate is shape-dependent

DSU sorts an index list, so each comparison does two random reads into the key
array and the output is gathered through the permutation — cache misses on a
large sort. But replacing it wholesale with a merge regressed
`price-drop-detection` 2.5×, because its keys arrive perfectly reverse-ordered,
where quicksort excels and a non-adaptive merge does maximum work.

Resolved by choosing per call from an O(n) scan. See `enhancement_example.md`.

## What remains, and what it is not

For the 27 cases still slower, the honest split:

- **~9 async.** Bounded by one future per element; the 0.7.4 pass settled this
  (*"what is left is one future per element, which is what a pull protocol
  fundamentally is"*). Not a sync problem, and these are the cases where
  `concurrent(n)` is the actual pitch.
- **The tail below ~1.15×.** Inside twice the run-to-run noise floor. Not
  reliably *ordered*; chasing them individually produces phantom results.
  `valid-emails` was investigated as a regression and settled with a paired
  A/B at 0.992× — it had never moved.
- **A handful of sync cases above ~1.3×.** The genuine remaining targets.

Two whose cause is known and unfixed:

- **`first-visit-merchants` (~1.9×)** — `fx.map(...).toList()` is *faster* than
  native's Set loop (8.7 vs 14.0 ms). The cost is `uniq` consuming the map
  layer through its iterator: a closure call plus `moveNext` per element where
  native reads a field inline. Fusing `uniq().toList()` does not help — tried,
  measured nothing, reverted. It needs real stage fusion, which measured a loss
  on multi-stage chains.
- **`groupBy` materialisation** — largely addressed by `foldBy`, but `foldBy`
  cannot carry two running values (a mean needs sum *and* count) without a
  record per element: 1.17× → 4.27× on `top-category-average`, reverted.

## Open

`sortBy`'s adaptive path covers double keys only. int, String and generic keys
still use DSU, so tie stability holds on one path and not the others. That
inconsistency should be closed before stability is documented as a guarantee.
