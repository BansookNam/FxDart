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
  final iterator = iterable.iterator;
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
  final iterator = iterable.iterator;
  while (true) {
    final r = await iterator.next();
    if (r.done) return;
    await f(r.value);
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

/// Async counterpart of [reduce].
Future<A> reduceAsync<A>(
    FutureOr<A> Function(A acc, A a) f, FxAsyncIterable<A> iterable) async {
  final iterator = iterable.iterator;
  final first = await iterator.next();
  if (first.done) {
    throw StateError("'reduce' of empty iterable with no initial value");
  }
  var acc = first.value;
  while (true) {
    final r = await iterator.next();
    if (r.done) return acc;
    acc = await f(acc, r.value);
  }
}

/// Async counterpart of [fold].
Future<Acc> foldAsync<A, Acc>(FutureOr<Acc> seed,
    FutureOr<Acc> Function(Acc acc, A a) f, FxAsyncIterable<A> iterable) async {
  var acc = await seed;
  final iterator = iterable.iterator;
  while (true) {
    final r = await iterator.next();
    if (r.done) return acc;
    acc = await f(acc, r.value);
  }
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
num sum(Iterable<num> iterable) {
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
num sumBy<A>(num Function(A a) f, Iterable<A> iterable) {
  // Same unboxed int-then-double accumulation as [sum].
  var iacc = 0;
  var dacc = 0.0;
  var isInt = true;
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
double average(Iterable<num> iterable) {
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
double averageBy<A>(num Function(A a) f, Iterable<A> iterable) {
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
num min(Iterable<num> iterable) => fold(double.infinity, _minOf, iterable);

/// Async counterpart of [min].
Future<num> minAsync(FxAsyncIterable<num> iterable) =>
    foldAsync(double.infinity, _minOf, iterable);

/// Returns the largest number; `-infinity` for an empty iterable, `NaN` if
/// any element is `NaN` — mirroring FxTS `max`.
num max(Iterable<num> iterable) => fold(-double.infinity, _maxOf, iterable);

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
/// Port of FxTS `size`.
int size<A>(Iterable<A> iterable) {
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
  for (final a in iterable) {
    result.putIfAbsent(f(a), () => []).add(a);
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
  for (final a in iterable) {
    result.update(f(a), (n) => n + 1, ifAbsent: () => 1);
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
List<A> sortBy<A>(Object? Function(A a) f, Iterable<A> iterable) {
  // Decorate-sort-undecorate: extract each key once, sort an index list, and
  // read the permutation back. Sorting the values directly with a
  // `_compareBy` comparator would call [f] twice per comparison —
  // 2·n·log n extractions instead of n. The permutation is identical to the
  // direct sort's: sort decisions depend only on comparator outcomes, and
  // the index comparator returns exactly what the direct comparator would.
  final items = List.of(iterable);
  final length = items.length;
  if (length < 2) return items;
  final keys = [for (final a in items) f(a)];
  final indices = [for (var i = 0; i < length; i++) i];

  // Homogeneous key types get an unboxed key array and a devirtualized
  // compareTo — the generic path pays an `is Comparable` test and a dynamic
  // compareTo on every comparison. compareTo semantics (NaN, -0.0) are the
  // same on every path. No Int64List: the playground build targets JS.
  var allDouble = true, allInt = true, allString = true;
  for (final k in keys) {
    if (k is! double) allDouble = false;
    if (k is! int) allInt = false;
    if (k is! String) allString = false;
    if (!(allDouble || allInt || allString)) break;
  }
  if (allDouble) {
    final dk = Float64List(length);
    for (var i = 0; i < length; i++) {
      dk[i] = keys[i] as double;
    }
    indices.sort((i, j) => dk[i].compareTo(dk[j]));
  } else if (allInt) {
    final ik = List<int>.filled(length, 0);
    for (var i = 0; i < length; i++) {
      ik[i] = keys[i] as int;
    }
    indices.sort((i, j) => ik[i].compareTo(ik[j]));
  } else if (allString) {
    final sk = List<String>.filled(length, '');
    for (var i = 0; i < length; i++) {
      sk[i] = keys[i] as String;
    }
    indices.sort((i, j) => sk[i].compareTo(sk[j]));
  } else {
    indices.sort((i, j) => _compareKeys(keys[i], keys[j]));
  }
  return [for (final i in indices) items[i]];
}

/// Async counterpart of [sortBy].
Future<List<A>> sortByAsync<A>(
        Object? Function(A a) f, FxAsyncIterable<A> iterable) =>
    sortAsync((a, b) => _compareBy(f, a, b), iterable);

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
