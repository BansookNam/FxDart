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
Iterable<(A, B)> zip<A, B>(Iterable<A> iterable1, Iterable<B> iterable2) =>
    _ZipIterable(iterable1, iterable2);

class _ZipIterable<A, B> extends Iterable<(A, B)> {
  _ZipIterable(this._source1, this._source2);
  final Iterable<A> _source1;
  final Iterable<B> _source2;
  @override
  Iterator<(A, B)> get iterator =>
      _ZipIterator(_source1.iterator, _source2.iterator);
}

class _ZipIterator<A, B> implements Iterator<(A, B)> {
  _ZipIterator(this._it1, this._it2);
  final Iterator<A> _it1;
  final Iterator<B> _it2;
  @override
  late (A, B) current;
  @override
  bool moveNext() {
    if (_it1.moveNext() && _it2.moveNext()) {
      current = (_it1.current, _it2.current);
      return true;
    }
    return false;
  }
}

/// Three-iterable variant of [zip]. (Dart has no variadic generics, so each
/// arity is a separate function.)
Iterable<(A, B, C)> zip3<A, B, C>(Iterable<A> iterable1, Iterable<B> iterable2,
        Iterable<C> iterable3) =>
    _Zip3Iterable(iterable1, iterable2, iterable3);

class _Zip3Iterable<A, B, C> extends Iterable<(A, B, C)> {
  _Zip3Iterable(this._source1, this._source2, this._source3);
  final Iterable<A> _source1;
  final Iterable<B> _source2;
  final Iterable<C> _source3;
  @override
  Iterator<(A, B, C)> get iterator =>
      _Zip3Iterator(_source1.iterator, _source2.iterator, _source3.iterator);
}

class _Zip3Iterator<A, B, C> implements Iterator<(A, B, C)> {
  _Zip3Iterator(this._it1, this._it2, this._it3);
  final Iterator<A> _it1;
  final Iterator<B> _it2;
  final Iterator<C> _it3;
  @override
  late (A, B, C) current;
  @override
  bool moveNext() {
    if (_it1.moveNext() && _it2.moveNext() && _it3.moveNext()) {
      current = (_it1.current, _it2.current, _it3.current);
      return true;
    }
    return false;
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
Iterable<(int, A)> zipWithIndex<A>(Iterable<A> iterable) =>
    _ZipWithIndexIterable(iterable);

class _ZipWithIndexIterable<A> extends Iterable<(int, A)> {
  _ZipWithIndexIterable(this._source);
  final Iterable<A> _source;
  @override
  Iterator<(int, A)> get iterator => _ZipWithIndexIterator(_source.iterator);
}

class _ZipWithIndexIterator<A> implements Iterator<(int, A)> {
  _ZipWithIndexIterator(this._it);
  final Iterator<A> _it;
  var _i = 0;
  @override
  late (int, A) current;
  @override
  bool moveNext() {
    if (_it.moveNext()) {
      current = (_i++, _it.current);
      return true;
    }
    return false;
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
