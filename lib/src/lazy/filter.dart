import 'dart:async';

import '../async_iterable.dart';
import 'map.dart';

/// Returns a lazy [Iterable] of all elements [f] returns true for.
///
/// Port of FxTS `filter` (sync).
///
/// ```dart
/// filter((a) => a % 2 == 0, [0, 1, 2, 3, 4, 5, 6]); // (0, 2, 4, 6)
/// ```
Iterable<A> filter<A>(bool Function(A a) f, Iterable<A> iterable) =>
    _FilterIterable(f, iterable);

class _FilterIterable<A> extends Iterable<A> {
  _FilterIterable(this._f, this._source);
  final bool Function(A) _f;
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator => _FilterIterator(_f, _source.iterator);
}

class _FilterIterator<A> implements Iterator<A> {
  _FilterIterator(this._f, this._it);
  final bool Function(A) _f;
  final Iterator<A> _it;
  @override
  late A current;
  @override
  bool moveNext() {
    while (_it.moveNext()) {
      final v = _it.current;
      if (_f(v)) {
        current = v;
        return true;
      }
    }
    return false;
  }
}

/// Like [filter], but the predicate also receives the element's 0-based
/// position in the **input** — dropped elements still advance the count.
///
/// ```dart
/// filterWithIndex((a, i) => i.isEven, ['a', 'b', 'c']); // ('a', 'c')
/// ```
Iterable<A> filterWithIndex<A>(
        bool Function(A a, int index) f, Iterable<A> iterable) =>
    _FilterWithIndexIterable(f, iterable);

class _FilterWithIndexIterable<A> extends Iterable<A> {
  _FilterWithIndexIterable(this._f, this._source);
  final bool Function(A, int) _f;
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator => _FilterWithIndexIterator(_f, _source.iterator);
}

class _FilterWithIndexIterator<A> implements Iterator<A> {
  _FilterWithIndexIterator(this._f, this._it);
  final bool Function(A, int) _f;
  final Iterator<A> _it;
  var _i = 0;
  @override
  late A current;
  @override
  bool moveNext() {
    while (_it.moveNext()) {
      final v = _it.current;
      if (_f(v, _i++)) {
        current = v;
        return true;
      }
    }
    return false;
  }
}

/// Async counterpart of [filterWithIndex].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> filterWithIndexAsync<A>(
    FutureOr<bool> Function(A a, int index) f, FxAsyncIterable<A> iterable) {
  return dispatchAsync(iterable, (source) {
    var i = 0;
    return filterAsync((A a) => f(a, i++), source).iterator;
  });
}

/// The opposite of [filter]: all elements [f] returns false for.
///
/// Port of FxTS `reject`.
Iterable<A> reject<A>(bool Function(A a) f, Iterable<A> iterable) =>
    filter((A a) => !f(a), iterable);

/// Filters `null` out and narrows the element type.
///
/// Port of FxTS `compact`.
Iterable<A> compact<A>(Iterable<A?> iterable) => _CompactIterable(iterable);

class _CompactIterable<A> extends Iterable<A> {
  _CompactIterable(this._source);
  final Iterable<A?> _source;
  @override
  Iterator<A> get iterator => _CompactIterator(_source.iterator);
}

class _CompactIterator<A> implements Iterator<A> {
  _CompactIterator(this._it);
  final Iterator<A?> _it;
  @override
  late A current;
  @override
  bool moveNext() {
    while (_it.moveNext()) {
      final v = _it.current;
      if (v != null) {
        current = v;
        return true;
      }
    }
    return false;
  }
}

// --- async ---------------------------------------------------------------

/// Maps upstream values to `(passed, value)` pairs, forwarding the
/// concurrency marker. Port of `toFilterIterator` in FxTS `filter.ts`.
FxAsyncIterable<(bool, A)> _toFilterIterable<A>(
    FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) {
  return mapAsync((A a) async => (await f(a), a), iterable);
}

/// The concurrent filter machinery: consumes an iterable of
/// `(passed, value)` pairs and yields only passing values, resolving
/// downstream pulls in order. Port of `asyncConcurrent` in FxTS `filter.ts`.
FxAsyncIterable<A> _asyncConcurrent<A>(FxAsyncIterable<(bool, A)> iterable) {
  return DelegateAsyncIterable(() {
    final iterator = iterable.iterator;
    final settlementQueue = <Completer<IterResult<A>>>[];
    final buffer = <A>[];
    var finished = false;
    var nextCallCount = 0;
    var resolvedCount = 0;
    var prevItem = Future<void>.value();

    late void Function(Concurrent? concurrent) recur;

    void fillBuffer(Concurrent? concurrent) {
      final nextItem = iterator.next(concurrent);
      prevItem = prevItem.then((_) => nextItem).then((result) {
        if (result.done) {
          while (settlementQueue.isNotEmpty) {
            settlementQueue.removeAt(0).complete(IterResult<A>.done());
          }
          finished = true;
          return;
        }
        final (cond, item) = result.value;
        if (cond) {
          buffer.add(item);
        }
        recur(concurrent);
      }).catchError((Object reason, StackTrace st) {
        finished = true;
        while (settlementQueue.isNotEmpty) {
          settlementQueue.removeAt(0).completeError(reason, st);
        }
      });
    }

    void consumeBuffer() {
      while (buffer.isNotEmpty && nextCallCount > resolvedCount) {
        final value = buffer.removeAt(0);
        settlementQueue.removeAt(0).complete(IterResult.value(value));
        resolvedCount++;
      }
    }

    recur = (Concurrent? concurrent) {
      if (finished || nextCallCount == resolvedCount) {
        return;
      } else if (buffer.isNotEmpty) {
        consumeBuffer();
      } else {
        fillBuffer(concurrent);
      }
    };

    return DelegateAsyncIterator((concurrent) {
      nextCallCount++;
      if (finished) {
        return Future.value(IterResult<A>.done());
      }
      final completer = Completer<IterResult<A>>();
      settlementQueue.add(completer);
      recur(concurrent);
      return completer.future;
    });
  });
}

/// Async counterpart of [filter]. The predicate may return a [Future].
///
/// Port of FxTS `filter` (async), including its dedicated concurrent path.
@pragma('vm:prefer-inline')
FxAsyncIterable<A> filterAsync<A>(
    FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) {
  // Fused-stage form; a Concurrent marker falls back to
  // [_filterAsyncLegacy]'s concurrent predicate machinery.
  final stage = FxFilterStage((v) => f(v as A));
  if (iterable is FxFusedAsyncIterable<A>) {
    final source = iterable.source;
    final stages = iterable.stages;
    final legacy = iterable.legacy;
    return FxFusedAsyncIterable<A>(
        source, [...stages, stage], () => _filterAsyncLegacy(f, legacy()));
  }
  return FxFusedAsyncIterable<A>(
      iterable, [stage], () => _filterAsyncLegacy(f, iterable));
}

FxAsyncIterable<A> _filterAsyncLegacy<A>(
    FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) {
  // Only reached via the fused chain's Concurrent fallback, so this is the
  // concurrent predicate machinery directly (the serial case is the fused
  // FxFilterStage). A defensive unmarked first pull degrades to width 1.
  return DelegateAsyncIterable(() {
    FxAsyncIterator<A>? inner;
    return DelegateAsyncIterator((concurrent) {
      inner ??= _asyncConcurrent(concurrentAsync(
              concurrent is Concurrent ? concurrent.length : 1,
              _toFilterIterable(f, iterable)))
          .iterator;
      return inner!.next(concurrent);
    });
  });
}

/// Async counterpart of [reject].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> rejectAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    filterAsync((A a) async => !await f(a), iterable);

/// Async counterpart of [compact].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> compactAsync<A>(FxAsyncIterable<A?> iterable) =>
    mapAsync((A? a) => a as A, filterAsync((A? a) => a != null, iterable));

// --- uniq / set operations ----------------------------------------------

/// Returns an iterable with unique values as determined by [f].
///
/// Port of FxTS `uniqBy`.
Iterable<A> uniqBy<A, B>(B Function(A a) f, Iterable<A> iterable) =>
    _UniqByIterable(f, iterable);

class _UniqByIterable<A, B> extends Iterable<A> {
  _UniqByIterable(this._f, this._source);
  final B Function(A) _f;
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator => _UniqByIterator(_f, _source.iterator);
}

class _UniqByIterator<A, B> implements Iterator<A> {
  _UniqByIterator(this._f, this._it);
  final B Function(A) _f;
  final Iterator<A> _it;
  final _seen = <B>{};
  @override
  late A current;
  @override
  bool moveNext() {
    while (_it.moveNext()) {
      final v = _it.current;
      if (_seen.add(_f(v))) {
        current = v;
        return true;
      }
    }
    return false;
  }
}

/// Returns an iterable with duplicate values removed.
///
/// Port of FxTS `uniq`. Dedicated iterator (not `uniqBy(identity)`) — the
/// identity-key closure would cost an indirect call per element.
Iterable<A> uniq<A>(Iterable<A> iterable) => _UniqIterable(iterable);

class _UniqIterable<A> extends Iterable<A> {
  _UniqIterable(this._source);
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator => _UniqIterator(_source.iterator);
}

class _UniqIterator<A> implements Iterator<A> {
  _UniqIterator(this._it);
  final Iterator<A> _it;
  final Set<A> _seen = {};
  @override
  late A current;
  @override
  bool moveNext() {
    while (_it.moveNext()) {
      final v = _it.current;
      if (_seen.add(v)) {
        current = v;
        return true;
      }
    }
    return false;
  }
}

/// Async counterpart of [uniqBy]. Uses then/bare pattern for sync keys.
@pragma('vm:prefer-inline')
FxAsyncIterable<A> uniqByAsync<A, B>(
    FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) {
  return DelegateAsyncIterable(() {
    final seen = <B>{};
    return filterAsync((A a) {
      final key = f(a);
      if (key is Future<B>) {
        return key.then((k) => seen.add(k));
      }
      return seen.add(key as B);
    }, iterable).iterator;
  });
}

/// Async counterpart of [uniq].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> uniqAsync<A>(FxAsyncIterable<A> iterable) =>
    uniqByAsync((A a) => a, iterable);

/// Drops elements whose [f]-key equals the previous element's key, keeping
/// the first of each run. Unlike [uniqBy], only *adjacent* duplicates are
/// removed, so no seen-set builds up.
///
/// fxdart extension (not part of FxTS), after Rx's `distinctUntilChanged`
/// and Dart `Stream.distinct`.
///
/// ```dart
/// uniqAdjacentBy((a) => a % 10, [1, 11, 21, 2, 1]); // (1, 2, 1)
/// ```
Iterable<A> uniqAdjacentBy<A, B>(B Function(A a) f, Iterable<A> iterable) =>
    _UniqAdjacentByIterable(f, iterable);

class _UniqAdjacentByIterable<A, B> extends Iterable<A> {
  _UniqAdjacentByIterable(this._f, this._source);
  final B Function(A) _f;
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator => _UniqAdjacentByIterator(_f, _source.iterator);
}

class _UniqAdjacentByIterator<A, B> implements Iterator<A> {
  _UniqAdjacentByIterator(this._f, this._it);
  final B Function(A) _f;
  final Iterator<A> _it;
  bool _hasPrev = false;
  late B _prevKey;
  @override
  late A current;
  @override
  bool moveNext() {
    while (_it.moveNext()) {
      final a = _it.current;
      final key = _f(a);
      final keep = !_hasPrev || key != _prevKey;
      _prevKey = key;
      _hasPrev = true;
      if (keep) {
        current = a;
        return true;
      }
    }
    return false;
  }
}

/// Drops elements equal to their predecessor, keeping the first of each run.
///
/// fxdart extension (not part of FxTS) — see [uniqAdjacentBy].
///
/// ```dart
/// uniqAdjacent([1, 1, 2, 2, 2, 1]); // (1, 2, 1)
/// ```
Iterable<A> uniqAdjacent<A>(Iterable<A> iterable) =>
    uniqAdjacentBy((A a) => a, iterable);

/// Async counterpart of [uniqAdjacentBy]. The key comparison is inherently
/// ordered, so keys are computed one at a time; combine with `concurrent`
/// to still evaluate the upstream in parallel.
@pragma('vm:prefer-inline')
FxAsyncIterable<A> uniqAdjacentByAsync<A, B>(
    FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    var hasPrev = false;
    late B prevKey;
    return SerialAsyncIterator((concurrent) async {
      while (true) {
        final result = await iterator.next(concurrent);
        if (result.done) return IterResult<A>.done();
        final key = await f(result.value);
        final isNew = !hasPrev || key != prevKey;
        prevKey = key;
        hasPrev = true;
        if (isNew) return IterResult.value(result.value);
      }
    });
  });
}

/// Async counterpart of [uniqAdjacent].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> uniqAdjacentAsync<A>(FxAsyncIterable<A> iterable) =>
    uniqAdjacentByAsync((A a) => a, iterable);

/// Returns the elements of [iterable2] whose [f]-keys do not occur in
/// [iterable1], with duplicates removed.
///
/// Port of FxTS `differenceBy`.
Iterable<A> differenceBy<A, B>(
        B Function(A a) f, Iterable<A> iterable1, Iterable<A> iterable2) =>
    _SetOpIterable(f, iterable1, iterable2, false);

/// Returns the elements of [iterable2] that do not occur in [iterable1].
///
/// Port of FxTS `difference`.
Iterable<A> difference<A>(Iterable<A> iterable1, Iterable<A> iterable2) =>
    differenceBy((A a) => a, iterable1, iterable2);

/// Returns the elements of [iterable2] whose [f]-keys also occur in
/// [iterable1], with duplicates removed.
///
/// Port of FxTS `intersectionBy`.
Iterable<A> intersectionBy<A, B>(
        B Function(A a) f, Iterable<A> iterable1, Iterable<A> iterable2) =>
    _SetOpIterable(f, iterable1, iterable2, true);

/// Shared machinery of [differenceBy] / [intersectionBy]: one pass over
/// [_source2], filtering on [_source1]'s key set and deduping by element —
/// the fused form of `uniq(filter/reject(set.contains ∘ f, iterable2))`.
class _SetOpIterable<A, B> extends Iterable<A> {
  _SetOpIterable(this._f, this._source1, this._source2, this._keep);
  final B Function(A) _f;
  final Iterable<A> _source1;
  final Iterable<A> _source2;
  final bool _keep;
  @override
  Iterator<A> get iterator => _SetOpIterator(_f, _source1, _source2, _keep);
}

class _SetOpIterator<A, B> implements Iterator<A> {
  _SetOpIterator(this._f, this._source1, this._source2, this._keep);
  final B Function(A) _f;
  final Iterable<A> _source1;
  final Iterable<A> _source2;
  final bool _keep;
  Set<B>? _set; // iterable1's keys, materialized on the first pull
  Iterator<A>? _it;
  final Set<A> _seen = {};
  @override
  late A current;
  @override
  bool moveNext() {
    var it = _it;
    if (it == null) {
      _set = {for (final a in _source1) _f(a)};
      it = _it = _source2.iterator;
    }
    final set = _set!;
    while (it.moveNext()) {
      final a = it.current;
      if (set.contains(_f(a)) == _keep && _seen.add(a)) {
        current = a;
        return true;
      }
    }
    return false;
  }
}

/// Returns the elements of [iterable2] that also occur in [iterable1].
///
/// Port of FxTS `intersection`.
Iterable<A> intersection<A>(Iterable<A> iterable1, Iterable<A> iterable2) =>
    intersectionBy((A a) => a, iterable1, iterable2);

FxAsyncIterable<A> _setOpAsync<A, B>(
  FutureOr<B> Function(A a) f,
  FxAsyncIterable<A> iterable1,
  FxAsyncIterable<A> iterable2,
  bool keepWhenInSet,
) {
  // The concurrency marker applies to iterable2, as in FxTS.
  return dispatchAsync(iterable2, (source) {
    Set<B>? set;
    FxAsyncIterator<A>? inner;
    return SerialAsyncIterator((concurrent) async {
      if (set == null) {
        final keys = <B>[];
        final it1 = iterable1.iterator;
        while (true) {
          final r = await it1.next();
          if (r.done) break;
          keys.add(await f(r.value));
        }
        set = keys.toSet();
        inner = uniqAsync(filterAsync(
                (A a) async => set!.contains(await f(a)) == keepWhenInSet,
                source))
            .iterator;
      }
      return inner!.next(concurrent);
    });
  });
}

/// Async counterpart of [differenceBy].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> differenceByAsync<A, B>(FutureOr<B> Function(A a) f,
        FxAsyncIterable<A> iterable1, FxAsyncIterable<A> iterable2) =>
    _setOpAsync(f, iterable1, iterable2, false);

/// Async counterpart of [difference].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> differenceAsync<A>(
        FxAsyncIterable<A> iterable1, FxAsyncIterable<A> iterable2) =>
    differenceByAsync((A a) => a, iterable1, iterable2);

/// Async counterpart of [intersectionBy].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> intersectionByAsync<A, B>(FutureOr<B> Function(A a) f,
        FxAsyncIterable<A> iterable1, FxAsyncIterable<A> iterable2) =>
    _setOpAsync(f, iterable1, iterable2, true);

/// Async counterpart of [intersection].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> intersectionAsync<A>(
        FxAsyncIterable<A> iterable1, FxAsyncIterable<A> iterable2) =>
    intersectionByAsync((A a) => a, iterable1, iterable2);
