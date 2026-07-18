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
Iterable<A> filter<A>(bool Function(A a) f, Iterable<A> iterable) sync* {
  for (final a in iterable) {
    if (f(a)) yield a;
  }
}

/// The opposite of [filter]: all elements [f] returns false for.
///
/// Port of FxTS `reject`.
Iterable<A> reject<A>(bool Function(A a) f, Iterable<A> iterable) =>
    filter((A a) => !f(a), iterable);

/// Filters `null` out and narrows the element type.
///
/// Port of FxTS `compact`.
Iterable<A> compact<A>(Iterable<A?> iterable) sync* {
  for (final a in iterable) {
    if (a != null) yield a;
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
FxAsyncIterable<A> filterAsync<A>(
    FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) {
  return DelegateAsyncIterable(() {
    FxAsyncIterator<A>? inner;
    return DelegateAsyncIterator((concurrent) {
      if (inner == null) {
        if (concurrent is Concurrent) {
          inner = _asyncConcurrent(concurrentAsync(
                  concurrent.length, _toFilterIterable(f, iterable)))
              .iterator;
        } else {
          final iterator = iterable.iterator;
          inner = SerialAsyncIterator((c) async {
            while (true) {
              final result = await iterator.next(c);
              if (result.done) return IterResult<A>.done();
              if (await f(result.value)) {
                return IterResult.value(result.value);
              }
            }
          });
        }
      }
      return inner!.next(concurrent);
    });
  });
}

/// Async counterpart of [reject].
FxAsyncIterable<A> rejectAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    filterAsync((A a) async => !await f(a), iterable);

/// Async counterpart of [compact].
FxAsyncIterable<A> compactAsync<A>(FxAsyncIterable<A?> iterable) =>
    mapAsync((A? a) => a as A, filterAsync((A? a) => a != null, iterable));

// --- uniq / set operations ----------------------------------------------

/// Returns an iterable with unique values as determined by [f].
///
/// Port of FxTS `uniqBy`.
Iterable<A> uniqBy<A, B>(B Function(A a) f, Iterable<A> iterable) sync* {
  final seen = <B>{};
  for (final a in iterable) {
    if (seen.add(f(a))) yield a;
  }
}

/// Returns an iterable with duplicate values removed.
///
/// Port of FxTS `uniq`.
Iterable<A> uniq<A>(Iterable<A> iterable) => uniqBy((A a) => a, iterable);

/// Async counterpart of [uniqBy].
FxAsyncIterable<A> uniqByAsync<A, B>(
    FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) {
  return DelegateAsyncIterable(() {
    final seen = <B>{};
    return filterAsync((A a) async => seen.add(await f(a)), iterable).iterator;
  });
}

/// Async counterpart of [uniq].
FxAsyncIterable<A> uniqAsync<A>(FxAsyncIterable<A> iterable) =>
    uniqByAsync((A a) => a, iterable);

/// Returns the elements of [iterable2] whose [f]-keys do not occur in
/// [iterable1], with duplicates removed.
///
/// Port of FxTS `differenceBy`.
Iterable<A> differenceBy<A, B>(
    B Function(A a) f, Iterable<A> iterable1, Iterable<A> iterable2) sync* {
  final set = map(f, iterable1).toSet();
  yield* uniq(reject((A a) => set.contains(f(a)), iterable2));
}

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
    B Function(A a) f, Iterable<A> iterable1, Iterable<A> iterable2) sync* {
  final set = map(f, iterable1).toSet();
  yield* uniq(filter((A a) => set.contains(f(a)), iterable2));
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
FxAsyncIterable<A> differenceByAsync<A, B>(FutureOr<B> Function(A a) f,
        FxAsyncIterable<A> iterable1, FxAsyncIterable<A> iterable2) =>
    _setOpAsync(f, iterable1, iterable2, false);

/// Async counterpart of [difference].
FxAsyncIterable<A> differenceAsync<A>(
        FxAsyncIterable<A> iterable1, FxAsyncIterable<A> iterable2) =>
    differenceByAsync((A a) => a, iterable1, iterable2);

/// Async counterpart of [intersectionBy].
FxAsyncIterable<A> intersectionByAsync<A, B>(FutureOr<B> Function(A a) f,
        FxAsyncIterable<A> iterable1, FxAsyncIterable<A> iterable2) =>
    _setOpAsync(f, iterable1, iterable2, true);

/// Async counterpart of [intersection].
FxAsyncIterable<A> intersectionAsync<A>(
        FxAsyncIterable<A> iterable1, FxAsyncIterable<A> iterable2) =>
    intersectionByAsync((A a) => a, iterable1, iterable2);
