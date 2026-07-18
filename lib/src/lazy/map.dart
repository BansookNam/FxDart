import 'dart:async';

import '../async_iterable.dart';

/// Returns a lazy [Iterable] of values by running each element through [f].
///
/// Port of FxTS `map` (sync).
///
/// ```dart
/// map((a) => a + 10, [1, 2, 3, 4]); // (11, 12, 13, 14)
/// ```
Iterable<B> map<A, B>(B Function(A a) f, Iterable<A> iterable) sync* {
  for (final a in iterable) {
    yield f(a);
  }
}

/// Async counterpart of [map]. The callback may return a [Future].
///
/// ```dart
/// await toArrayAsync(mapAsync((a) async => a + 10, toAsync([1, 2, 3])));
/// // [11, 12, 13]
/// ```
FxAsyncIterable<B> mapAsync<A, B>(
    FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) {
  return DelegateAsyncIterable(() {
    final iterator = iterable.iterator;
    // Parallel-safe pass-through: overlapping next() calls must start
    // overlapping upstream pulls — that is how `concurrent` parallelizes.
    return DelegateAsyncIterator((concurrent) async {
      final result = await iterator.next(concurrent);
      if (result.done) return IterResult<B>.done();
      return IterResult.value(await f(result.value));
    });
  });
}

/// Identical to [map], but intended for side effects by convention.
Iterable<B> mapEffect<A, B>(B Function(A a) f, Iterable<A> iterable) =>
    map(f, iterable);

/// Identical to [mapAsync], but intended for side effects by convention.
FxAsyncIterable<B> mapEffectAsync<A, B>(
        FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) =>
    mapAsync(f, iterable);

/// Iterates over each element, applying [f] without changing the values.
///
/// Port of FxTS `peek`.
Iterable<A> peek<A>(void Function(A a) f, Iterable<A> iterable) sync* {
  for (final a in iterable) {
    f(a);
    yield a;
  }
}

/// Async counterpart of [peek].
FxAsyncIterable<A> peekAsync<A>(
        FutureOr<void> Function(A a) f, FxAsyncIterable<A> iterable) =>
    mapAsync((A a) async {
      await f(a);
      return a;
    }, iterable);

/// Extracts the value under [key] from each map in [iterable].
///
/// Port of FxTS `pluck`.
Iterable<V?> pluck<K, V>(K key, Iterable<Map<K, V>> iterable) =>
    map((Map<K, V> a) => a[key], iterable);

/// Async counterpart of [pluck].
FxAsyncIterable<V?> pluckAsync<K, V>(
        K key, FxAsyncIterable<Map<K, V>> iterable) =>
    mapAsync((Map<K, V> a) => a[key], iterable);

bool _isFlatAble(Object? a) => a is Iterable && a is! String;

/// Returns a flattened iterable. If [depth] is given, flattens that many
/// levels of nesting; strings are not flattened.
///
/// Nested element types cannot be expressed in Dart's type system the way
/// TypeScript's `DeepFlat` does, so this returns `Iterable<dynamic>`.
/// Prefer [flatMap] when a typed result is possible.
///
/// Port of FxTS `flat`.
///
/// ```dart
/// flat([1, [2, 3], [4, [5]]]);    // (1, 2, 3, 4, [5])
/// flat([1, [2, [3]]], 2);         // (1, 2, 3)
/// ```
Iterable<dynamic> flat(Iterable<dynamic> iterable, [int depth = 1]) sync* {
  for (final value in iterable) {
    if (_isFlatAble(value) && depth >= 1) {
      yield* flat(value as Iterable, depth - 1);
    } else {
      yield value;
    }
  }
}

/// Async counterpart of [flat]. Only *sync* nested iterables are flattened,
/// mirroring FxTS behavior.
FxAsyncIterable<dynamic> flatAsync(FxAsyncIterable<dynamic> iterable,
    [int depth = 1]) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    final stack = <Iterator<dynamic>>[];
    return SerialAsyncIterator((concurrent) async {
      while (true) {
        while (stack.isNotEmpty) {
          final top = stack.last;
          if (top.moveNext()) {
            final value = top.current;
            if (_isFlatAble(value) && stack.length < depth) {
              stack.add((value as Iterable).iterator);
              continue;
            }
            return IterResult.value(value);
          }
          stack.removeLast();
        }
        final result = await iterator.next(concurrent);
        if (result.done) return const IterResult<dynamic>.done();
        final value = result.value;
        if (_isFlatAble(value) && depth >= 1) {
          stack.add((value as Iterable).iterator);
          continue;
        }
        return IterResult.value(value);
      }
    });
  });
}

/// Returns a flattened iterable of values by running each element through
/// [f], which must return an iterable.
///
/// Unlike FxTS `flatMap` (which flattens any mix of values one level), the
/// Dart port requires the callback to return an `Iterable<B>` so the result
/// can stay typed — same contract as `Iterable.expand`.
Iterable<B> flatMap<A, B>(
    Iterable<B> Function(A a) f, Iterable<A> iterable) sync* {
  for (final a in iterable) {
    yield* f(a);
  }
}

/// Async counterpart of [flatMap].
FxAsyncIterable<B> flatMapAsync<A, B>(
    FutureOr<Iterable<B>> Function(A a) f, FxAsyncIterable<A> iterable) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    Iterator<B>? current;
    return SerialAsyncIterator((concurrent) async {
      while (true) {
        if (current != null) {
          if (current!.moveNext()) return IterResult.value(current!.current);
          current = null;
        }
        final result = await iterator.next(concurrent);
        if (result.done) return IterResult<B>.done();
        current = (await f(result.value)).iterator;
      }
    });
  });
}

/// Returns an iterable of successively reduced values, starting with [seed].
///
/// Port of FxTS `scan` (seeded form).
///
/// ```dart
/// scan((acc, a) => acc + a, 10, [1, 2, 3]); // (10, 11, 13, 16)
/// ```
Iterable<B> scan<A, B>(
    B Function(B acc, A a) f, B seed, Iterable<A> iterable) sync* {
  var acc = seed;
  yield acc;
  for (final a in iterable) {
    yield acc = f(acc, a);
  }
}

/// [scan] without a seed: the first element is used as the seed.
/// Returns an empty iterable when [iterable] is empty.
///
/// Port of FxTS `scan(f, iterable)`.
Iterable<A> scan1<A>(A Function(A acc, A a) f, Iterable<A> iterable) sync* {
  final iterator = iterable.iterator;
  if (!iterator.moveNext()) return;
  var acc = iterator.current;
  yield acc;
  while (iterator.moveNext()) {
    yield acc = f(acc, iterator.current);
  }
}

/// Async counterpart of [scan].
FxAsyncIterable<B> scanAsync<A, B>(FutureOr<B> Function(B acc, A a) f,
    FutureOr<B> seed, FxAsyncIterable<A> iterable) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    B? acc;
    var emittedSeed = false;
    return SerialAsyncIterator((concurrent) async {
      if (!emittedSeed) {
        emittedSeed = true;
        acc = await seed;
        return IterResult.value(acc as B);
      }
      final result = await iterator.next(concurrent);
      if (result.done) return IterResult<B>.done();
      acc = await f(acc as B, result.value);
      return IterResult.value(acc as B);
    });
  });
}

/// Async counterpart of [scan1].
FxAsyncIterable<A> scan1Async<A>(
    FutureOr<A> Function(A acc, A a) f, FxAsyncIterable<A> iterable) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    A? acc;
    var emittedSeed = false;
    return SerialAsyncIterator((concurrent) async {
      if (!emittedSeed) {
        final result = await iterator.next(concurrent);
        if (result.done) return IterResult<A>.done();
        emittedSeed = true;
        acc = result.value;
        return IterResult.value(acc as A);
      }
      final result = await iterator.next(concurrent);
      if (result.done) return IterResult<A>.done();
      acc = await f(acc as A, result.value);
      return IterResult.value(acc as A);
    });
  });
}
