import 'dart:async';

import '../async_iterable.dart';
import 'map.dart';

/// Merges two iterables into a lazy iterable of record pairs, ending when
/// either input ends.
///
/// Port of FxTS `zip` (TS tuples become Dart records).
///
/// ```dart
/// zip(['a', 'b'], [1, 2]); // (('a', 1), ('b', 2))
/// ```
Iterable<(A, B)> zip<A, B>(Iterable<A> iterable1, Iterable<B> iterable2) sync* {
  final it1 = iterable1.iterator;
  final it2 = iterable2.iterator;
  while (it1.moveNext() && it2.moveNext()) {
    yield (it1.current, it2.current);
  }
}

/// Three-iterable variant of [zip]. (Dart has no variadic generics, so each
/// arity is a separate function.)
Iterable<(A, B, C)> zip3<A, B, C>(
    Iterable<A> iterable1, Iterable<B> iterable2, Iterable<C> iterable3) sync* {
  final it1 = iterable1.iterator;
  final it2 = iterable2.iterator;
  final it3 = iterable3.iterator;
  while (it1.moveNext() && it2.moveNext() && it3.moveNext()) {
    yield (it1.current, it2.current, it3.current);
  }
}

/// Async counterpart of [zip]: pulls both sources in parallel per pair.
FxAsyncIterable<(A, B)> zipAsync<A, B>(
    FxAsyncIterable<A> iterable1, FxAsyncIterable<B> iterable2) {
  return DelegateAsyncIterable(() {
    final it1 = iterable1.iterator;
    final it2 = iterable2.iterator;
    // Pass-through: sub-iterator pulls are issued synchronously before any
    // await, so overlapping next() calls keep pairing by call order while
    // `concurrent` propagates into both sources.
    return DelegateAsyncIterator((concurrent) async {
      final f1 = it1.next(concurrent);
      final f2 = it2.next(concurrent);
      final r1 = await f1;
      final r2 = await f2;
      if (r1.done || r2.done) return IterResult<(A, B)>.done();
      return IterResult.value((r1.value, r2.value));
    });
  });
}

/// Async counterpart of [zip3].
FxAsyncIterable<(A, B, C)> zip3Async<A, B, C>(FxAsyncIterable<A> iterable1,
    FxAsyncIterable<B> iterable2, FxAsyncIterable<C> iterable3) {
  return DelegateAsyncIterable(() {
    final it1 = iterable1.iterator;
    final it2 = iterable2.iterator;
    final it3 = iterable3.iterator;
    return DelegateAsyncIterator((concurrent) async {
      final f1 = it1.next(concurrent);
      final f2 = it2.next(concurrent);
      final f3 = it3.next(concurrent);
      final r1 = await f1;
      final r2 = await f2;
      final r3 = await f3;
      if (r1.done || r2.done || r3.done) {
        return IterResult<(A, B, C)>.done();
      }
      return IterResult.value((r1.value, r2.value, r3.value));
    });
  });
}

/// Zips two iterables through the combining function [f].
///
/// Port of FxTS `zipWith`.
Iterable<C> zipWith<A, B, C>(
        C Function(A a, B b) f, Iterable<A> iterable1, Iterable<B> iterable2) =>
    map((r) => f(r.$1, r.$2), zip(iterable1, iterable2));

/// Async counterpart of [zipWith].
FxAsyncIterable<C> zipWithAsync<A, B, C>(FutureOr<C> Function(A a, B b) f,
        FxAsyncIterable<A> iterable1, FxAsyncIterable<B> iterable2) =>
    mapAsync((r) => f(r.$1, r.$2), zipAsync(iterable1, iterable2));

/// Pairs each element with its index: `(index, value)`.
///
/// Port of FxTS `zipWithIndex`.
Iterable<(int, A)> zipWithIndex<A>(Iterable<A> iterable) sync* {
  var i = 0;
  for (final a in iterable) {
    yield (i++, a);
  }
}

/// Async counterpart of [zipWithIndex].
FxAsyncIterable<(int, A)> zipWithIndexAsync<A>(FxAsyncIterable<A> iterable) {
  return dispatchAsync(iterable, (source) {
    var i = 0;
    return mapAsync((A a) => (i++, a), source).iterator;
  });
}

/// Returns the transposition of the given rows: the n-th output list holds
/// the n-th element of every input row that has one.
///
/// Port of FxTS `transpose` (single-arity: pass the rows as one iterable).
Iterable<List<A>> transpose<A>(Iterable<Iterable<A>> rows) sync* {
  final iterators = rows.map((r) => r.iterator).toList(growable: false);
  if (iterators.isEmpty) return;
  while (true) {
    final current = <A>[];
    for (final it in iterators) {
      if (it.moveNext()) current.add(it.current);
    }
    if (current.isEmpty) return;
    yield current;
  }
}

/// Async counterpart of [transpose].
FxAsyncIterable<List<A>> transposeAsync<A>(Iterable<FxAsyncIterable<A>> rows) {
  return DelegateAsyncIterable(() {
    final iterators = rows.map((r) => r.iterator).toList(growable: false);
    return DelegateAsyncIterator((concurrent) async {
      if (iterators.isEmpty) return IterResult<List<A>>.done();
      final results =
          await Future.wait(iterators.map((it) => it.next(concurrent)));
      final current = [
        for (final r in results)
          if (!r.done) r.value
      ];
      if (current.isEmpty) return IterResult<List<A>>.done();
      return IterResult.value(current);
    });
  });
}
