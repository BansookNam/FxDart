# Native Dart vs fxdart — verified before/after pairs

Distilled from the DartComparison catalog: 50 tasks each implemented twice,
with both versions harness-verified to print byte-identical output. Full
runnable set with in-browser playgrounds:
https://bansooknam.github.io/FxDart/DartComparison/ (sources under
`content/code-comparison/` in the fxdart repo).

Use these as rewrite templates when refactoring existing Dart. Each pair
shows the native shape to recognize and the fxdart shape to produce.

## 1. Bounded, order-preserving concurrency (the highest-value rewrite)

Recognize: a hand-rolled worker pool, a semaphore, or `Future.wait` over
batches — anything answering "call this for each of N items, at most K at a
time, results in order."

```dart
// BEFORE — hand-rolled worker pool: shared cursor, pre-sized slots,
// order bookkeeping. Easy to get subtly wrong.
Future<List<String>> fetchAll(List<int> ids, int limit) async {
  final results = List<String?>.filled(ids.length, null);
  var next = 0;
  Future<void> worker() async {
    while (next < ids.length) {
      final i = next++;
      results[i] = await fetchProfile(ids[i]);
    }
  }
  await Future.wait([for (var i = 0; i < limit; i++) worker()]);
  return results.cast<String>();
}
```

```dart
// AFTER — the concurrency policy is one chain step.
final results = await fx(ids)
    .toAsync()
    .map(fetchProfile)
    .concurrent(2)
    .toList();
```

Also recognize the *broken* variants and fix them the same way:
`Future.wait(ids.map(fetch))` (unbounded — hammers the backend) and
chunk-into-batches + `await Future.wait(batch)` (each batch waits for its
slowest member).

## 2. Running state (`scan`)

Recognize: a mutable accumulator variable threaded through a loop, where the
*intermediate* values matter (running totals, balances, streaks).

```dart
// BEFORE — fold only returns the final value, so the running state
// lives in a mutable variable.
var balance = 250.0;
final lines = <String>['Opening  \$${balance.toStringAsFixed(2)}'];
for (final t in txns) {
  balance += t.amount;
  lines.add('${t.label}  \$${balance.toStringAsFixed(2)}');
}
```

```dart
// AFTER — scan emits its seed first (the opening line), then each step.
final lines = fx(txns)
    .scan((acc, t) => (t.label, acc.$2 + t.amount), ('Opening', 250.0))
    .map((e) => '${e.$1}  \$${e.$2.toStringAsFixed(2)}')
    .toList();
```

## 3. Group → aggregate → rank

Recognize: a `Map<K, List<T>>` built with `putIfAbsent` (or
`groupListsBy`), then sorting/taking from its entries.

```dart
// BEFORE (with package:collection — already decent)
final byMerchant = txns.groupListsBy((t) => t.merchant);
final top = byMerchant.entries
    .sortedBy<num>((kv) => -total(kv.value))
    .take(5);
```

```dart
// AFTER — groupBy is a terminal (returns Map); re-enter the chain
// through the entries. One vocabulary throughout, sync or async.
final byMerchant = fx(txns).groupBy((t) => t.merchant);
final top = fx(byMerchant.entries)
    .sortBy((kv) => -total(kv.value))
    .take(5);
```

Honest note: with `package:collection` this one is close. The fxdart win is
uniformity — the same chain shape extends with `.toAsync().concurrent(n)`
when the aggregation goes async, where the native version restructures.

## 4. One pass, two outputs (`partition`)

Recognize: two lists built in one loop with an `if`/`else`, or two `where`
passes with hand-negated predicates (which drift apart under maintenance).

```dart
final (refunds, charges) = fx(txns).partition((t) => t.amount < 0);
```

## 5. Stream buffering (`fromStream` + `chunk`)

Recognize: `await for` with a manual buffer list that flushes at size N, or
a custom `StreamTransformer` for windowing. This is a Stream *used as a
list* — pull it. Time-shaped work (debounce, switchMap) is `fxEvents`.

```dart
final alerts = fromStream(sensorEvents)
    .chunk(5)                       // windows of 5
    .filter((w) => avg(w) > limit)
    .map(formatAlert)
    .toStream();
```

## Leave these alone (native is fine or tied)

Verified verdicts — rewriting these to fxdart adds an import without adding
clarity:

| Task | Keep the native idiom |
|---|---|
| Simple transform+filter+limit | `xs.map(f).where(p).take(n)` |
| First element after a condition | `xs.skipWhile(p).firstOrNull` |
| Pagination | `xs.skip(page * k).take(k)` |
| Rank/index labels | `for (final (i, x) in xs.indexed)` |
| Dedupe then sort | `xs.toSet().toList()..sort()` |
| Date-window sum over sorted data | `skipWhile/takeWhile/fold` |
| Top-N / average with `package:collection` already in use | `sortedBy<num>` + `take`, `.average` |
