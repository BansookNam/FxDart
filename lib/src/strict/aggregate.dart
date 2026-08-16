import 'dart:async';
import 'dart:typed_data';

import '../async_iterable.dart';

/// Materializes any iterable into a [List].
///
/// Port of FxTS `toArray` (sync); named `toList` to match Dart's
/// `Iterable.toList` (Dart has no "array" type — this always returns a [List]).
List<A> toList<A>(Iterable<A> iterable) => List.of(iterable);

/// Materializes an [FxAsyncIterable] into a [List].
///
/// Port of FxTS `toArray` (async); named `toListAsync` for Dart idiom.
Future<List<A>> toListAsync<A>(FxAsyncIterable<A> iterable) async {
  final result = <A>[];
  // Push execution where it applies — a stream source, a concurrency pool,
  // or a fused stage run — instead of pulling element by element. All three
  // are observably identical for an all-consuming terminal.
  final drive =
      fxStreamDrive<A>(iterable, result.add) ??
          fxPoolDrive<A>(iterable, result.add) ??
          fxFusedDrive<A>(iterable, result.add);
  if (drive != null) {
    await drive;
    return result;
  }
  final iterator = iterable.iterator;
  // Terminals own their iterator and consume serially, so they may use the
  // internal fast-pull path: synchronously answered pulls (fused stages
  // over a sync source) collect with no futures at all.
  if (iterator is FxFastIterator<A>) {
    while (true) {
      final ro = iterator.nextOr();
      final r = ro is Future<IterResult<A>> ? await ro : ro;
      if (r.done) return result;
      result.add(r.value);
    }
  }
  while (true) {
    final r = await iterator.next();
    if (r.done) return result;
    result.add(r.value);
  }
}

/// Iterates over [iterable], applying [f] to each value.
///
/// Port of FxTS `each` (sync).
void each<A>(void Function(A a) f, Iterable<A> iterable) {
  for (final a in iterable) {
    f(a);
  }
}

/// Async counterpart of [each]; awaits [f] per element.
Future<void> eachAsync<A>(
    FutureOr<void> Function(A a) f, FxAsyncIterable<A> iterable) async {
  // Stream-sourced chains run by subscription (see [toListAsync]).
  final drive = fxStreamDrive<A>(iterable, f) ??
      fxPoolDrive<A>(iterable, f) ??
      fxFusedDrive<A>(iterable, f);
  if (drive != null) return drive;
  final iterator = iterable.iterator;
  // Fast-pull loop where available (see [toListAsync]); awaits only
  // genuinely asynchronous pulls and callback results.
  if (iterator is FxFastIterator<A>) {
    while (true) {
      final ro = iterator.nextOr();
      final r = ro is Future<IterResult<A>> ? await ro : ro;
      if (r.done) return;
      final v = f(r.value);
      if (v is Future) await v;
    }
  }
  while (true) {
    final r = await iterator.next();
    if (r.done) return;
    // Await only genuinely asynchronous callbacks — awaiting a sync one
    // would cost a microtask hop per element.
    final v = f(r.value);
    if (v is Future) await v;
  }
}

/// Consumes up to [n] items of [iterable] (all of them when [n] is null),
/// discarding the values — useful to force side effects of a lazy pipeline.
///
/// Port of FxTS `consume`.
void consume<A>(Iterable<A> iterable, [int? n]) {
  final iterator = iterable.iterator;
  var remaining = n;
  while ((remaining == null || remaining-- > 0) && iterator.moveNext()) {}
}

/// Async counterpart of [consume].
Future<void> consumeAsync<A>(FxAsyncIterable<A> iterable, [int? n]) async {
  final iterator = iterable.iterator;
  var remaining = n;
  while (remaining == null || remaining-- > 0) {
    final r = await iterator.next();
    if (r.done) return;
  }
}

/// Folds [iterable] through [f] using its first element as the seed.
/// Throws a [StateError] on an empty iterable.
///
/// Port of FxTS `reduce(f, iterable)`. For the seeded form use [fold].
A reduce<A>(A Function(A acc, A a) f, Iterable<A> iterable) {
  final iterator = iterable.iterator;
  if (!iterator.moveNext()) {
    throw StateError("'reduce' of empty iterable with no initial value");
  }
  var acc = iterator.current;
  while (iterator.moveNext()) {
    acc = f(acc, iterator.current);
  }
  return acc;
}

/// Folds [iterable] through [f], starting from [seed].
///
/// Port of FxTS `reduce(f, seed, iterable)` (named after Dart's
/// `Iterable.fold` since Dart cannot overload by arity).
Acc fold<A, Acc>(Acc seed, Acc Function(Acc acc, A a) f, Iterable<A> iterable) {
  var acc = seed;
  for (final a in iterable) {
    acc = f(acc, a);
  }
  return acc;
}

/// Like [fold], but the callback also receives the element's 0-based
/// position.
///
/// ```dart
/// foldWithIndex(0, (acc, a, i) => acc + a * i, [1, 2, 3]); // 8
/// ```
Acc foldWithIndex<A, Acc>(Acc seed,
    Acc Function(Acc acc, A a, int index) f, Iterable<A> iterable) {
  var acc = seed;
  var i = 0;
  for (final a in iterable) {
    acc = f(acc, a, i++);
  }
  return acc;
}

/// Folds [iterable] **from the last element to the first**, starting from
/// [seed] — the right-associative counterpart of [fold].
///
/// Use it when the combining step is not associative and has to nest from
/// the right: `foldRight(0, (acc, a) => a - acc, [1, 2, 3])` is
/// `1 - (2 - (3 - 0))`, where [fold] would give `((0 - 1) - 2) - 3`.
///
/// The reducer keeps [fold]'s `(acc, element)` argument order rather than
/// Haskell's `foldr` flip, so the same callback works with either
/// direction. A non-[List] source is materialized first — walking backwards
/// requires knowing where the end is.
Acc foldRight<A, Acc>(
    Acc seed, Acc Function(Acc acc, A a) f, Iterable<A> iterable) {
  var acc = seed;
  final list = iterable is List<A> ? iterable : iterable.toList(growable: false);
  for (var i = list.length - 1; i >= 0; i--) {
    acc = f(acc, list[i]);
  }
  return acc;
}

/// Like [foldRight], but the callback also receives the element's position.
///
/// The index is the element's 0-based position in the **source**, so the
/// last element arrives first carrying the highest index. That is the
/// position [foldWithIndex] and [mapWithIndex] would give the same element;
/// it deliberately does not renumber the reversed walk 0, 1, 2.
Acc foldRightWithIndex<A, Acc>(Acc seed,
    Acc Function(Acc acc, A a, int index) f, Iterable<A> iterable) {
  var acc = seed;
  final list = iterable is List<A> ? iterable : iterable.toList(growable: false);
  for (var i = list.length - 1; i >= 0; i--) {
    acc = f(acc, list[i], i);
  }
  return acc;
}

/// Async counterpart of [foldRight].
///
/// There is no way to start from the end of a stream without reaching it,
/// so this drains [iterable] into a list first — unlike [foldAsync], it
/// holds every element in memory and cannot short-circuit.
Future<Acc> foldRightAsync<A, Acc>(FutureOr<Acc> seed,
    FutureOr<Acc> Function(Acc acc, A a) f, FxAsyncIterable<A> iterable) async {
  var acc = seed is Future<Acc> ? await seed : seed;
  final list = await toListAsync(iterable);
  for (var i = list.length - 1; i >= 0; i--) {
    // Sync accumulators continue without an await hop, as in [foldAsync].
    final v = f(acc, list[i]);
    acc = v is Future<Acc> ? await v : v;
  }
  return acc;
}

/// Async counterpart of [foldRightWithIndex].
Future<Acc> foldRightWithIndexAsync<A, Acc>(
    FutureOr<Acc> seed,
    FutureOr<Acc> Function(Acc acc, A a, int index) f,
    FxAsyncIterable<A> iterable) async {
  var acc = seed is Future<Acc> ? await seed : seed;
  final list = await toListAsync(iterable);
  for (var i = list.length - 1; i >= 0; i--) {
    final v = f(acc, list[i], i);
    acc = v is Future<Acc> ? await v : v;
  }
  return acc;
}

/// Async counterpart of [reduce].
Future<A> reduceAsync<A>(
    FutureOr<A> Function(A acc, A a) f, FxAsyncIterable<A> iterable) async {
  final iterator = iterable.iterator;
  final first = await iterator.next();
  if (first.done) {
    throw StateError("'reduce' of empty iterable with no initial value");
  }
  var acc = first.value;
  // Fast-pull loop where available (see [toListAsync]).
  if (iterator is FxFastIterator<A>) {
    while (true) {
      final ro = iterator.nextOr();
      final r = ro is Future<IterResult<A>> ? await ro : ro;
      if (r.done) return acc;
      final v = f(acc, r.value);
      acc = v is Future<A> ? await v : v;
    }
  }
  while (true) {
    final r = await iterator.next();
    if (r.done) return acc;
    // Sync accumulators continue without an await hop, as in [eachAsync].
    final v = f(acc, r.value);
    acc = v is Future<A> ? await v : v;
  }
}

/// Async counterpart of [fold].
Future<Acc> foldAsync<A, Acc>(FutureOr<Acc> seed,
    FutureOr<Acc> Function(Acc acc, A a) f, FxAsyncIterable<A> iterable) async {
  var acc = seed is Future<Acc> ? await seed : seed;
  // Stream-sourced chains fold by subscription (see [toListAsync]).
  FutureOr<void> accumulate(A a) {
    final v = f(acc, a);
    if (v is Future<Acc>) {
      return v.then((next) {
        acc = next;
      });
    }
    acc = v;
  }

  final drive = fxStreamDrive<A>(iterable, accumulate) ??
      fxPoolDrive<A>(iterable, accumulate) ??
      fxFusedDrive<A>(iterable, accumulate);
  if (drive != null) {
    await drive;
    return acc;
  }
  final iterator = iterable.iterator;
  // Fast-pull loop where available (see [toListAsync]).
  if (iterator is FxFastIterator<A>) {
    while (true) {
      final ro = iterator.nextOr();
      final r = ro is Future<IterResult<A>> ? await ro : ro;
      if (r.done) return acc;
      final v = f(acc, r.value);
      acc = v is Future<Acc> ? await v : v;
    }
  }
  while (true) {
    final r = await iterator.next();
    if (r.done) return acc;
    // Sync accumulators continue without an await hop, as in [eachAsync].
    final v = f(acc, r.value);
    acc = v is Future<Acc> ? await v : v;
  }
}

/// Async counterpart of [foldWithIndex].
///
/// A fold is a terminal that consumes its source strictly in order, so the
/// counter lives in the accumulator and every one of [foldAsync]'s fast
/// paths still applies.
@pragma('vm:prefer-inline')
Future<Acc> foldWithIndexAsync<A, Acc>(
    FutureOr<Acc> seed,
    FutureOr<Acc> Function(Acc acc, A a, int index) f,
    FxAsyncIterable<A> iterable) {
  var i = 0;
  return foldAsync<A, Acc>(seed, (acc, a) => f(acc, a, i++), iterable);
}

/// Returns a reducer section for use in a pipeline: `reduceLazy(f, seed)`
/// gives a function `Iterable<A> -> Acc`.
///
/// Port of FxTS `reduceLazy`.
Acc Function(Iterable<A>) reduceLazy<A, Acc>(
        Acc Function(Acc acc, A a) f, Acc seed) =>
    (iterable) => fold(seed, f, iterable);

/// Adds every number in the iterable.
///
/// Port of FxTS `sum`.
@pragma('vm:prefer-inline')
num sum(Iterable<num> iterable) {
  // Monomorphic lists take an indexed loop: no iterator, and the element
  // loads stay unboxed. Values match the generic path exactly (same
  // accumulation order; empty stays the int 0).
  if (iterable is List<double>) {
    var acc = 0.0;
    final len = iterable.length;
    if (len == 0) return 0;
    for (var i = 0; i < len; i++) {
      acc += iterable[i];
    }
    return acc;
  }
  if (iterable is List<int>) {
    var acc = 0;
    final len = iterable.length;
    for (var i = 0; i < len; i++) {
      acc += iterable[i];
    }
    return acc;
  }
  // Unboxed accumulators with the boxed `num acc += v` sequence's exact
  // semantics: ints accumulate in an int until the first double arrives,
  // then accumulation switches to double seeded with the int total — the
  // same value the num fold would hold at every step.
  var iacc = 0;
  var dacc = 0.0;
  var isInt = true;
  for (final v in iterable) {
    if (isInt) {
      if (v is int) {
        iacc += v;
        continue;
      }
      dacc = iacc.toDouble();
      isInt = false;
    }
    dacc += v;
  }
  return isInt ? iacc : dacc;
}

/// Sums the key [f] of every element — `map` + [sum] in one step, so a
/// pipeline that only needs a field total doesn't spell out the projection.
///
/// Empty input returns `0` (the [sum] contract).
///
/// Dart-native addition (FxTS has only the numeric `sum`); named after
/// [maxBy]/[minBy] — Kotlin spells it `sumOf`.
@pragma('vm:prefer-inline')
num sumBy<A>(num Function(A a) f, Iterable<A> iterable) {
  // Same unboxed int-then-double accumulation as [sum]; lists iterate by
  // index so no iterator is allocated.
  var iacc = 0;
  var dacc = 0.0;
  var isInt = true;
  if (iterable is List<A>) {
    final len = iterable.length;
    for (var i = 0; i < len; i++) {
      final v = f(iterable[i]);
      if (isInt) {
        if (v is int) {
          iacc += v;
          continue;
        }
        dacc = iacc.toDouble();
        isInt = false;
      }
      dacc += v;
    }
    return isInt ? iacc : dacc;
  }
  for (final a in iterable) {
    final v = f(a);
    if (isInt) {
      if (v is int) {
        iacc += v;
        continue;
      }
      dacc = iacc.toDouble();
      isInt = false;
    }
    dacc += v;
  }
  return isInt ? iacc : dacc;
}

/// Async counterpart of [sumBy].
Future<num> sumByAsync<A>(
        FutureOr<num> Function(A a) f, FxAsyncIterable<A> iterable) =>
    foldAsync<A, num>(0, (acc, a) async => acc + await f(a), iterable);

/// Async counterpart of [sum].
Future<num> sumAsync(FxAsyncIterable<num> iterable) =>
    foldAsync<num, num>(0, (a, b) => a + b, iterable);

/// Concatenates every string in the iterable.
String sumStrings(Iterable<String> iterable) =>
    fold('', (a, b) => a + b, iterable);

/// Returns the average of the numbers. `NaN` for an empty iterable.
///
/// Port of FxTS `average`.
@pragma('vm:prefer-inline')
double average(Iterable<num> iterable) {
  // Monomorphic-list fast paths, as in [sum].
  if (iterable is List<double>) {
    final len = iterable.length;
    if (len == 0) return double.nan;
    var acc = 0.0;
    for (var i = 0; i < len; i++) {
      acc += iterable[i];
    }
    return acc / len;
  }
  if (iterable is List<int>) {
    final len = iterable.length;
    if (len == 0) return double.nan;
    var acc = 0;
    for (var i = 0; i < len; i++) {
      acc += iterable[i];
    }
    return acc / len;
  }
  // Same unboxed int-then-double accumulation as [sum].
  var size = 0;
  var iacc = 0;
  var dacc = 0.0;
  var isInt = true;
  for (final v in iterable) {
    size++;
    if (isInt) {
      if (v is int) {
        iacc += v;
        continue;
      }
      dacc = iacc.toDouble();
      isInt = false;
    }
    dacc += v;
  }
  if (size == 0) return double.nan;
  return isInt ? iacc / size : dacc / size;
}

/// Async counterpart of [average].
Future<double> averageAsync(FxAsyncIterable<num> iterable) async {
  var size = 0;
  num total = 0;
  await eachAsync((num a) {
    size++;
    total += a;
  }, iterable);
  return size == 0 ? double.nan : total / size;
}

/// Averages the key [f] of every element — `map` + [average] in one step.
///
/// Empty input returns `double.nan` (the [average] contract).
///
/// Dart-native addition completing the by-key family
/// ([sumBy] / [maxBy] / [minBy]).
@pragma('vm:prefer-inline')
double averageBy<A>(num Function(A a) f, Iterable<A> iterable) {
  if (iterable is List<A>) {
    final len = iterable.length;
    if (len == 0) return double.nan;
    var total = 0.0;
    for (var i = 0; i < len; i++) {
      total += f(iterable[i]);
    }
    return total / len;
  }
  var total = 0.0;
  var count = 0;
  for (final a in iterable) {
    total += f(a);
    count++;
  }
  return count == 0 ? double.nan : total / count;
}

/// Async counterpart of [averageBy].
Future<double> averageByAsync<A>(
    FutureOr<num> Function(A a) f, FxAsyncIterable<A> iterable) async {
  var total = 0.0;
  var count = 0;
  await eachAsync((A a) async {
    total += await f(a);
    count++;
  }, iterable);
  return count == 0 ? double.nan : total / count;
}

num _minOf(num acc, num a) => a.isNaN || acc.isNaN
    ? double.nan
    : a < acc
        ? a
        : acc;

num _maxOf(num acc, num a) => a.isNaN || acc.isNaN
    ? double.nan
    : a > acc
        ? a
        : acc;

/// Returns the smallest number; `infinity` for an empty iterable, `NaN` if
/// any element is `NaN` — mirroring FxTS `min`.
@pragma('vm:prefer-inline')
num min(Iterable<num> iterable) {
  // Monomorphic-list fast paths, as in [sum]; results match the [_minOf]
  // fold exactly (empty → infinity, any NaN → NaN, strict < keeps the
  // first of equal values).
  if (iterable is List<double>) {
    final length = iterable.length;
    var acc = double.infinity;
    var hasNaN = false;
    for (var i = 0; i < length; i++) {
      final v = iterable[i];
      if (v.isNaN) hasNaN = true;
      if (v < acc) acc = v;
    }
    return hasNaN ? double.nan : acc;
  }
  if (iterable is List<int>) {
    final length = iterable.length;
    if (length == 0) return double.infinity;
    var acc = iterable[0];
    for (var i = 1; i < length; i++) {
      final v = iterable[i];
      if (v < acc) acc = v;
    }
    return acc;
  }
  num acc = double.infinity;
  for (final v in iterable) {
    acc = _minOf(acc, v);
  }
  return acc;
}

/// Async counterpart of [min].
Future<num> minAsync(FxAsyncIterable<num> iterable) =>
    foldAsync(double.infinity, _minOf, iterable);

/// Returns the largest number; `-infinity` for an empty iterable, `NaN` if
/// any element is `NaN` — mirroring FxTS `max`.
@pragma('vm:prefer-inline')
num max(Iterable<num> iterable) {
  // Mirror image of [min]'s fast paths.
  if (iterable is List<double>) {
    final length = iterable.length;
    var acc = -double.infinity;
    var hasNaN = false;
    for (var i = 0; i < length; i++) {
      final v = iterable[i];
      if (v.isNaN) hasNaN = true;
      if (v > acc) acc = v;
    }
    return hasNaN ? double.nan : acc;
  }
  if (iterable is List<int>) {
    final length = iterable.length;
    if (length == 0) return -double.infinity;
    var acc = iterable[0];
    for (var i = 1; i < length; i++) {
      final v = iterable[i];
      if (v > acc) acc = v;
    }
    return acc;
  }
  num acc = -double.infinity;
  for (final v in iterable) {
    acc = _maxOf(acc, v);
  }
  return acc;
}

/// Async counterpart of [max].
Future<num> maxAsync(FxAsyncIterable<num> iterable) =>
    foldAsync(-double.infinity, _maxOf, iterable);

/// Returns the element whose key [f] is smallest, or `null` when empty.
///
/// Keys are compared like [sortBy] compares them ([Comparable.compare]);
/// on ties the **first** encountered element wins. One O(n) walk — no sort.
///
/// Dart-native addition (FxTS has only numeric `min`); named after Kotlin's
/// `minByOrNull` shape, nullable like [head]/[last].
A? minBy<A>(Object? Function(A a) f, Iterable<A> iterable) {
  A? best;
  Object? bestKey;
  var seen = false;
  for (final a in iterable) {
    // The key of the running best is extracted once and cached; [f] runs
    // exactly once per element.
    final key = f(a);
    if (!seen || _compareKeys(key, bestKey) < 0) {
      best = a;
      bestKey = key;
      seen = true;
    }
  }
  return best;
}

/// Async counterpart of [minBy].
Future<A?> minByAsync<A>(
    Object? Function(A a) f, FxAsyncIterable<A> iterable) async {
  A? best;
  var seen = false;
  await eachAsync((A a) {
    if (!seen || _compareBy(f, a, best as A) < 0) {
      best = a;
      seen = true;
    }
  }, iterable);
  return best;
}

/// Returns the element whose key [f] is largest, or `null` when empty.
///
/// Keys are compared like [sortBy] compares them ([Comparable.compare]);
/// on ties the **first** encountered element wins. One O(n) walk — no sort.
///
/// Dart-native addition (FxTS has only numeric `max`); named after Kotlin's
/// `maxByOrNull` shape, nullable like [head]/[last].
A? maxBy<A>(Object? Function(A a) f, Iterable<A> iterable) {
  A? best;
  Object? bestKey;
  var seen = false;
  for (final a in iterable) {
    final key = f(a);
    if (!seen || _compareKeys(key, bestKey) > 0) {
      best = a;
      bestKey = key;
      seen = true;
    }
  }
  return best;
}

/// Async counterpart of [maxBy].
Future<A?> maxByAsync<A>(
    Object? Function(A a) f, FxAsyncIterable<A> iterable) async {
  A? best;
  var seen = false;
  await eachAsync((A a) {
    if (!seen || _compareBy(f, a, best as A) > 0) {
      best = a;
      seen = true;
    }
  }, iterable);
  return best;
}

/// Returns the number of elements.
///
/// Port of FxTS `size`. O(1) for a [List] or [Set].
@pragma('vm:prefer-inline')
int size<A>(Iterable<A> iterable) {
  if (iterable is List || iterable is Set) return iterable.length;
  var n = 0;
  for (final _ in iterable) {
    n++;
  }
  return n;
}

/// Async counterpart of [size].
Future<int> sizeAsync<A>(FxAsyncIterable<A> iterable) async {
  var n = 0;
  await eachAsync((_) => n++, iterable);
  return n;
}

/// Counts the values [f] holds for — `filter` + `size` in one walk.
///
/// Dart-native addition (Kotlin's `count { }`).
int countWhere<A>(bool Function(A a) f, Iterable<A> iterable) {
  var n = 0;
  for (final a in iterable) {
    if (f(a)) n++;
  }
  return n;
}

/// Async counterpart of [countWhere].
Future<int> countWhereAsync<A>(
    FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) async {
  var n = 0;
  await eachAsync((A a) async {
    if (await f(a)) n++;
  }, iterable);
  return n;
}

/// Returns all elements joined into a string, separated by [sep].
///
/// Port of FxTS `join`.
String join<A>(String sep, Iterable<A> iterable) => iterable.join(sep);

/// Async counterpart of [join].
Future<String> joinAsync<A>(String sep, FxAsyncIterable<A> iterable) async =>
    (await toListAsync(iterable)).join(sep);

/// Splits values into groups keyed by [f].
///
/// Port of FxTS `groupBy` (TS objects become Dart Maps).
Map<K, List<A>> groupBy<A, K>(K Function(A a) f, Iterable<A> iterable) {
  final result = <K, List<A>>{};
  // `??=` instead of putIfAbsent: putIfAbsent allocates an ifAbsent closure
  // per element.
  for (final a in iterable) {
    (result[f(a)] ??= []).add(a);
  }
  return result;
}

/// Async counterpart of [groupBy].
Future<Map<K, List<A>>> groupByAsync<A, K>(
    FutureOr<K> Function(A a) f, FxAsyncIterable<A> iterable) async {
  final result = <K, List<A>>{};
  await eachAsync(
      (A a) async => result.putIfAbsent(await f(a), () => []).add(a), iterable);
  return result;
}

/// Groups values into `(key, items)` records, in first-seen key order —
/// the chainable view of [groupBy], so per-group aggregation continues in
/// the same pipeline instead of re-entering through `Map.entries`.
///
/// Dart-native addition (no FxTS counterpart).
///
/// ```dart
/// groupedBy((w) => w.length, ['ab', 'cd', 'e']);
/// // [(key: 2, items: [ab, cd]), (key: 1, items: [e])]
/// ```
List<({K key, List<A> items})> groupedBy<A, K>(
        K Function(A a) f, Iterable<A> iterable) =>
    [
      for (final e in groupBy(f, iterable).entries) (key: e.key, items: e.value)
    ];

/// Async counterpart of [groupedBy].
Future<List<({K key, List<A> items})>> groupedByAsync<A, K>(
        FutureOr<K> Function(A a) f, FxAsyncIterable<A> iterable) async =>
    [
      for (final e in (await groupByAsync(f, iterable)).entries)
        (key: e.key, items: e.value)
    ];

/// Indexes values by [f]; later duplicates overwrite earlier ones.
///
/// Port of FxTS `indexBy`.
Map<K, A> indexBy<A, K>(K Function(A a) f, Iterable<A> iterable) {
  final result = <K, A>{};
  for (final a in iterable) {
    result[f(a)] = a;
  }
  return result;
}

/// Async counterpart of [indexBy].
Future<Map<K, A>> indexByAsync<A, K>(
    FutureOr<K> Function(A a) f, FxAsyncIterable<A> iterable) async {
  final result = <K, A>{};
  await eachAsync((A a) async => result[await f(a)] = a, iterable);
  return result;
}

/// Counts occurrences of each key produced by [f].
///
/// Port of FxTS `countBy`.
Map<K, int> countBy<A, K>(K Function(A a) f, Iterable<A> iterable) {
  final result = <K, int>{};
  // Read-modify-write instead of Map.update: update allocates two closures
  // per element.
  for (final a in iterable) {
    final k = f(a);
    result[k] = (result[k] ?? 0) + 1;
  }
  return result;
}

/// Async counterpart of [countBy].
Future<Map<K, int>> countByAsync<A, K>(
    FutureOr<K> Function(A a) f, FxAsyncIterable<A> iterable) async {
  final result = <K, int>{};
  await eachAsync(
      (A a) async => result.update(await f(a), (n) => n + 1, ifAbsent: () => 1),
      iterable);
  return result;
}

/// Folds the values under each key [key] returns, in **one pass**, without
/// ever materializing the groups.
///
/// `groupBy` followed by a fold per group builds a `List` for every key first
/// — allocation proportional to the input for an answer proportional to the
/// number of keys. [foldBy] accumulates straight into the result map, which
/// is what the hand-written `totals[k] = (totals[k] ?? 0) + v` loop does:
///
/// ```dart
/// foldBy((Tx t) => t.category, 0.0, (sum, t) => sum + t.amount, txns);
/// // {Food: 812.40, Transport: 96.15, …}
/// ```
///
/// Not an FxTS port; the shape is Kotlin's `groupingBy().fold()`. Keys appear
/// in first-seen order, like [groupBy]. Reach for [groupBy] when you actually
/// want the elements — this is for when you only want the aggregate.
///
/// [seed] is a **value**, shared as the starting point for every key, exactly
/// as in [fold]. A mutable seed would therefore be shared across keys: fold
/// into new values (`sum + t.amount`), or use [groupBy] if you need to
/// accumulate into a mutable structure per group.
Map<K, Acc> foldBy<A, K, Acc>(K Function(A a) key, Acc seed,
    Acc Function(Acc acc, A a) f, Iterable<A> iterable) {
  final result = <K, Acc>{};
  // Read-modify-write instead of Map.update or putIfAbsent, both of which
  // allocate a closure per element (see [countBy], [groupBy]).
  if (iterable is List<A>) {
    final length = iterable.length;
    for (var i = 0; i < length; i++) {
      final a = iterable[i];
      final k = key(a);
      final acc = result[k];
      // The containsKey probe only runs when the stored value is null, which
      // is impossible unless Acc itself is nullable.
      result[k] =
          f(acc == null && !result.containsKey(k) ? seed : acc as Acc, a);
    }
    return result;
  }
  for (final a in iterable) {
    final k = key(a);
    final acc = result[k];
    result[k] = f(acc == null && !result.containsKey(k) ? seed : acc as Acc, a);
  }
  return result;
}

/// Async counterpart of [foldBy]. [key] and [f] may each return a [Future];
/// values are folded in source order.
Future<Map<K, Acc>> foldByAsync<A, K, Acc>(
    FutureOr<K> Function(A a) key,
    FutureOr<Acc> seed,
    FutureOr<Acc> Function(Acc acc, A a) f,
    FxAsyncIterable<A> iterable) async {
  final result = <K, Acc>{};
  final start = await seed;
  await eachAsync((A a) async {
    final k = await key(a);
    final acc = result[k];
    result[k] =
        await f(acc == null && !result.containsKey(k) ? start : acc as Acc, a);
  }, iterable);
  return result;
}

/// Returns a **new** sorted list ordered by the comparator [f].
///
/// Port of FxTS `sort`. Unlike the TS version (which mutates arrays in
/// place), the Dart port never mutates its input.
List<A> sort<A>(int Function(A a, A b) f, Iterable<A> iterable) =>
    List.of(iterable)..sort(f);

/// Async counterpart of [sort].
Future<List<A>> sortAsync<A>(
        int Function(A a, A b) f, FxAsyncIterable<A> iterable) async =>
    (await toListAsync(iterable))..sort(f);

/// Alias of [sort]; FxTS added `toSorted` as the non-mutating variant, which
/// the Dart [sort] already is.
List<A> toSorted<A>(int Function(A a, A b) f, Iterable<A> iterable) =>
    sort(f, iterable);

int _compareKeys(Object? fa, Object? fb) {
  // `num` first: it is the overwhelmingly common key kind, and a direct
  // comparison skips two `is Comparable` tests, two casts and
  // `Comparable.compare`'s virtual dispatch. Measured on `maxBy` over 1M
  // readings keyed by a double: 8.9 ms → 6.3 ms, against 2.1 ms for a
  // hand-written `reduce`. The rest of that gap is the key extractor's
  // closure call plus boxing each key into the `Object?` the signature
  // takes — neither removable without changing the public shape.
  if (fa is num && fb is num) {
    if (fa < fb) return -1;
    if (fa > fb) return 1;
    return 0;
  }
  if (fa is Comparable && fb is Comparable) {
    return Comparable.compare(
        fa as Comparable<Object?>, fb as Comparable<Object?>);
  }
  return 0;
}

int _compareBy<A>(Object? Function(A a) f, A a, A b) => _compareKeys(f(a), f(b));

/// Returns a new list sorted by the key extractor [f] (ascending).
///
/// Port of FxTS `sortBy`.
List<A> sortBy<A>(Object? Function(A a) f, Iterable<A> iterable) =>
    _sortByImpl(f, iterable, false);

/// Returns a new list sorted by the key extractor [f], descending.
///
/// The symmetric twin of [sortBy] (Kotlin's `sortedByDescending`) — works
/// for any comparable key, unlike the numeric-only `sortBy((a) => -key)`
/// negation trick.
List<A> sortByDesc<A>(Object? Function(A a) f, Iterable<A> iterable) =>
    _sortByImpl(f, iterable, true);

List<A> _sortByImpl<A>(
    Object? Function(A a) f, Iterable<A> iterable, bool desc) {
  // Decorate-sort-undecorate: extract each key once, sort an index list, and
  // read the permutation back. Sorting the values directly with a
  // `_compareBy` comparator would call [f] twice per comparison —
  // 2·n·log n extractions instead of n. The permutation is identical to the
  // direct sort's: sort decisions depend only on comparator outcomes, and
  // the index comparator returns exactly what the direct comparator would.
  final items = List.of(iterable);
  final length = items.length;
  if (length < 2) return items;
  final indices = [for (var i = 0; i < length; i++) i];

  // Homogeneous key types get an unboxed key array and a devirtualized
  // compareTo — the generic path pays an `is Comparable` test and a dynamic
  // compareTo on every comparison. compareTo semantics (NaN, -0.0) are the
  // same on every path. No Int64List: the playground build targets JS.
  // Descending picks a swapped-operand comparator once per sort, so the
  // per-comparison cost is identical to ascending.
  //
  // Keys go STRAIGHT into the typed array. Collecting them into a
  // `List<Object?>` first — as this did until 0.8.0 — boxes every double on
  // the way, which measured ~1.5x on a million-row `sortBy` over a double
  // key. The type is decided by the first key; a later key that disagrees
  // spills what has been read so far into a boxed list and finishes in the
  // generic path, so [f] still runs exactly once per element, in order.
  final first = f(items[0]);

  if (first is double) {
    final dk = Float64List(length);
    dk[0] = first;
    for (var i = 1; i < length; i++) {
      final k = f(items[i]);
      if (k is! double) return _sortSpilled(f, items, indices, dk, i, k, desc);
      dk[i] = k;
    }
    return _sortDoubleKeys(dk, items, desc);
  }

  if (first is int) {
    final ik = List<int>.filled(length, 0);
    ik[0] = first;
    for (var i = 1; i < length; i++) {
      final k = f(items[i]);
      if (k is! int) return _sortSpilled(f, items, indices, ik, i, k, desc);
      ik[i] = k;
    }
    indices.sort(desc
        ? (i, j) => ik[j].compareTo(ik[i])
        : (i, j) => ik[i].compareTo(ik[j]));
    return [for (final i in indices) items[i]];
  }

  if (first is String) {
    final sk = List<String>.filled(length, '');
    sk[0] = first;
    for (var i = 1; i < length; i++) {
      final k = f(items[i]);
      if (k is! String) return _sortSpilled(f, items, indices, sk, i, k, desc);
      sk[i] = k;
    }
    indices.sort(desc
        ? (i, j) => sk[j].compareTo(sk[i])
        : (i, j) => sk[i].compareTo(sk[j]));
    return [for (final i in indices) items[i]];
  }

  final keys = List<Object?>.filled(length, null);
  keys[0] = first;
  for (var i = 1; i < length; i++) {
    keys[i] = f(items[i]);
  }
  return _sortByKeys(items, indices, keys, desc);
}

/// The typed run broke at [at], where [f] returned [current] instead of the
/// type [typed] holds. Copies the keys read so far out of [typed], keeps
/// [current], and reads the rest — so every element's key is extracted
/// exactly once overall.
List<A> _sortSpilled<A>(Object? Function(A a) f, List<A> items,
    List<int> indices, List<Object?> typed, int at, Object? current, bool desc) {
  final keys = List<Object?>.filled(items.length, null);
  for (var i = 0; i < at; i++) {
    keys[i] = typed[i];
  }
  keys[at] = current;
  for (var i = at + 1; i < items.length; i++) {
    keys[i] = f(items[i]);
  }
  return _sortByKeys(items, indices, keys, desc);
}

List<A> _sortByKeys<A>(
    List<A> items, List<int> indices, List<Object?> keys, bool desc) {
  indices.sort(desc
      ? (i, j) => _compareKeys(keys[j], keys[i])
      : (i, j) => _compareKeys(keys[i], keys[j]));
  return [for (final i in indices) items[i]];
}

/// Sorts [items] by the unboxed keys [k], choosing a strategy from the shape
/// of the keys.
///
/// A single O(n) scan first: data that is already in the requested order
/// needs no sort at all, and data in the exact opposite order needs only a
/// reverse. That is not a contrived case — `sortBy((d) => -d.amount)` over
/// rows built in amount order arrives perfectly reversed, and the benchmark
/// suite has one. Both shortcuts are O(n), so they beat any comparison sort.
///
/// Everything else goes to a stable bottom-up merge over the keys and the
/// items together ([_mergeByDouble]). The decorate-sort-undecorate
/// alternative sorts an *index* list, so every comparison does two random
/// reads into the key array and the result is gathered through the
/// permutation — millions of cache misses on a large sort. Merging touches
/// both arrays sequentially.
///
/// The scan compares with `compareTo`, not `<=`: `0.0 <= -0.0` is true while
/// `0.0.compareTo(-0.0)` is positive, so a `<=` scan would call an unsorted
/// run sorted. NaN makes every comparison non-ordering, which fails both
/// runs and falls through to the merge — where `compareTo` places it last, as
/// before.
List<A> _sortDoubleKeys<A>(Float64List k, List<A> items, bool desc) {
  final n = items.length;
  var nonDec = true, nonInc = true, strictInc = true, strictDec = true;
  for (var i = 1; i < n; i++) {
    final c = k[i - 1].compareTo(k[i]);
    if (c > 0) {
      nonDec = false;
      strictInc = false;
    } else if (c < 0) {
      nonInc = false;
      strictDec = false;
    } else {
      strictInc = false;
      strictDec = false;
    }
    if (!nonDec && !nonInc) break;
  }
  // Ties are why the reverse shortcuts demand a STRICT run: reversing a run
  // with equal keys would reverse their source order, and this sort is
  // stable.
  if (desc) {
    if (nonInc) return items;
    if (strictInc) return [for (var i = n - 1; i >= 0; i--) items[i]];
  } else {
    if (nonDec) return items;
    if (strictDec) return [for (var i = n - 1; i >= 0; i--) items[i]];
  }
  return _mergeByDouble(k, items, desc);
}

/// Stable bottom-up merge sort of [items] by the unboxed keys [k], moving
/// both arrays in lockstep. Stable by construction: a tie takes the left run,
/// so equal keys keep their source order.
List<A> _mergeByDouble<A>(Float64List k, List<A> items, bool desc) {
  final n = items.length;
  var srcK = k;
  var dstK = Float64List(n);
  var srcV = items;
  var dstV = List<A>.of(items);
  for (var width = 1; width < n; width <<= 1) {
    for (var lo = 0; lo < n; lo += width << 1) {
      var mid = lo + width;
      if (mid > n) mid = n;
      var hi = mid + width;
      if (hi > n) hi = n;
      var i = lo, j = mid, t = lo;
      while (i < mid && j < hi) {
        final a = srcK[i];
        final b = srcK[j];
        if (desc ? a.compareTo(b) >= 0 : a.compareTo(b) <= 0) {
          dstK[t] = a;
          dstV[t] = srcV[i];
          i++;
        } else {
          dstK[t] = b;
          dstV[t] = srcV[j];
          j++;
        }
        t++;
      }
      while (i < mid) {
        dstK[t] = srcK[i];
        dstV[t] = srcV[i];
        i++;
        t++;
      }
      while (j < hi) {
        dstK[t] = srcK[j];
        dstV[t] = srcV[j];
        j++;
        t++;
      }
    }
    final tk = srcK;
    srcK = dstK;
    dstK = tk;
    final tv = srcV;
    srcV = dstV;
    dstV = tv;
  }
  return srcV;
}

/// Async counterpart of [sortBy].
Future<List<A>> sortByAsync<A>(
        Object? Function(A a) f, FxAsyncIterable<A> iterable) =>
    sortAsync((a, b) => _compareBy(f, a, b), iterable);

/// Async counterpart of [sortByDesc].
Future<List<A>> sortByDescAsync<A>(
        Object? Function(A a) f, FxAsyncIterable<A> iterable) =>
    sortAsync((a, b) => _compareBy(f, b, a), iterable);

/// Splits values into `(pass, fail)` lists by predicate [f].
///
/// Port of FxTS `partition` (TS tuple becomes a Dart record).
(List<A>, List<A>) partition<A>(bool Function(A a) f, Iterable<A> iterable) {
  final pass = <A>[];
  final fail = <A>[];
  for (final a in iterable) {
    (f(a) ? pass : fail).add(a);
  }
  return (pass, fail);
}

/// Async counterpart of [partition].
Future<(List<A>, List<A>)> partitionAsync<A>(
    FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) async {
  final pass = <A>[];
  final fail = <A>[];
  await eachAsync((A a) async => (await f(a) ? pass : fail).add(a), iterable);
  return (pass, fail);
}

// --- tee: several folds over one pass -------------------------------------

/// One reduction in a [tee] / [tee3] pass: where it starts, and how each
/// element advances it.
typedef Fold<A, R> = ({R seed, R Function(R acc, A a) step});

/// Runs two folds over a **single** pass of [iterable], returning both
/// results.
///
/// [fork] can also feed two readers from one pass, but only by buffering:
/// its cursors advance independently, so draining one before the other holds
/// every element the lagging cursor has not reached. Expressing the readers
/// as folds instead lets both advance on the same element, so the pass costs
/// no memory at all — the counterpart of Rx's `publish()`, where attaching
/// both subscribers before `connect()` is what avoids the buffer.
///
/// The source is iterated exactly once, so a side-effecting or single-shot
/// iterable is safe. Both steps see every element, in order.
///
/// fxdart extension (not part of FxTS).
///
/// ```dart
/// final (total, peak) = tee(readings,
///     (seed: 0, step: (int a, int r) => a + r),
///     (seed: 0, step: (int a, int r) => r > a ? r : a));
/// ```
@pragma('vm:align-loops')
(R1, R2) tee<A, R1, R2>(
    Iterable<A> iterable, Fold<A, R1> first, Fold<A, R2> second) {
  final f1 = first.step;
  final f2 = second.step;
  var a1 = first.seed;
  var a2 = second.seed;
  for (final a in iterable) {
    a1 = f1(a1, a);
    a2 = f2(a2, a);
  }
  return (a1, a2);
}

/// Three-fold [tee].
@pragma('vm:align-loops')
(R1, R2, R3) tee3<A, R1, R2, R3>(Iterable<A> iterable, Fold<A, R1> first,
    Fold<A, R2> second, Fold<A, R3> third) {
  final f1 = first.step;
  final f2 = second.step;
  final f3 = third.step;
  var a1 = first.seed;
  var a2 = second.seed;
  var a3 = third.seed;
  for (final a in iterable) {
    a1 = f1(a1, a);
    a2 = f2(a2, a);
    a3 = f3(a3, a);
  }
  return (a1, a2, a3);
}

/// Async counterpart of [tee]. Steps may return a [Future]; each element is
/// applied to both accumulators before the next is pulled.
Future<(R1, R2)> teeAsync<A, R1, R2>(FxAsyncIterable<A> iterable,
    AsyncFold<A, R1> first, AsyncFold<A, R2> second) async {
  final f1 = first.step;
  final f2 = second.step;
  var a1 = await first.seed;
  var a2 = await second.seed;
  await eachAsync((A a) {
    final r1 = f1(a1, a);
    if (r1 is Future<R1>) {
      return r1.then((v1) {
        a1 = v1;
        final r2 = f2(a2, a);
        if (r2 is Future<R2>) return r2.then((v2) => a2 = v2);
        a2 = r2;
      });
    }
    a1 = r1;
    final r2 = f2(a2, a);
    if (r2 is Future<R2>) return r2.then((v2) => a2 = v2);
    a2 = r2;
  }, iterable);
  return (a1, a2);
}

/// The [teeAsync] counterpart of [Fold].
typedef AsyncFold<A, R> = ({
  FutureOr<R> seed,
  FutureOr<R> Function(R acc, A a) step
});
