import 'dart:async';

import '../async_iterable.dart';

// The sync operators here (and in filter.dart, take_drop.dart, zip.dart,
// combine.dart, effect.dart) are hand-written Iterator classes rather than
// sync* generators: a sync* moveNext costs ~4x more than a plain class under
// AOT, and the difference compounds per chained operator. Laziness, effect
// order, and per-iteration freshness are identical to the generator form.
// Operators over a List source additionally index it directly (no snapshot
// copy, no iterator) where the output is unchanged.

/// Returns a lazy [Iterable] of values by running each element through [f].
///
/// Port of FxTS `map` (sync).
///
/// ```dart
/// map((a) => a + 10, [1, 2, 3, 4]); // (11, 12, 13, 14)
/// ```
Iterable<B> map<A, B>(B Function(A a) f, Iterable<A> iterable) =>
    _MapIterable(f, iterable);

class _MapIterable<A, B> extends Iterable<B> {
  _MapIterable(this._f, this._source);
  final B Function(A) _f;
  final Iterable<A> _source;
  @override
  Iterator<B> get iterator => _MapIterator(_f, _source.iterator);
  @override
  List<B> toList({bool growable = true}) {
    final source = _source;
    // A List source maps into a pre-sized list — the inherited toList grows
    // and recopies ~log n times. [_f] still runs exactly once per element,
    // in order.
    if (source is List<A>) {
      final length = source.length;
      if (length == 0) return growable ? <B>[] : List<B>.empty();
      final out = List<B>.filled(length, _f(source[0]), growable: growable);
      for (var i = 1; i < length; i++) {
        out[i] = _f(source[i]);
      }
      return out;
    }
    return super.toList(growable: growable);
  }
}

class _MapIterator<A, B> implements Iterator<B> {
  _MapIterator(this._f, this._it);
  final B Function(A) _f;
  final Iterator<A> _it;
  @override
  late B current;
  @override
  bool moveNext() {
    if (_it.moveNext()) {
      current = _f(_it.current);
      return true;
    }
    return false;
  }
}

/// Async counterpart of [map]. The callback may return a [Future].
///
/// ```dart
/// await toListAsync(mapAsync((a) async => a + 10, toAsync([1, 2, 3])));
/// // [11, 12, 13]
/// ```
@pragma('vm:prefer-inline')
FxAsyncIterable<B> mapAsync<A, B>(
    FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) {
  // Fused-stage form: a run of map/filter/takeWhile applies inline per
  // element (see FxFusedAsyncIterable); a Concurrent marker falls back to
  // [_mapAsyncLegacy], the parallel-safe pass-through layering.
  final stage = FxMapStage((v) => f(v as A));
  if (iterable is FxFusedAsyncIterable<A>) {
    final source = iterable.source;
    final stages = iterable.stages;
    final legacy = iterable.legacy;
    return FxFusedAsyncIterable<B>(
        source, [...stages, stage], () => _mapAsyncLegacy(f, legacy()));
  }
  return FxFusedAsyncIterable<B>(
      iterable, [stage], () => _mapAsyncLegacy(f, iterable));
}

FxAsyncIterable<B> _mapAsyncLegacy<A, B>(
    FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) {
  return DelegateAsyncIterable(() {
    final iterator = iterable.iterator;
    // Parallel-safe pass-through: overlapping next() calls must start
    // overlapping upstream pulls — that is how `concurrent` parallelizes.
    // Then-based with bare returns: a synchronous [f] result completes the
    // pull directly, where async/await would add a microtask hop and the
    // async-function wrapper per element (measured 1.4× on sync callbacks).
    return DelegateAsyncIterator(
        (concurrent) => iterator.next(concurrent).then((result) {
              if (result.done) return IterResult<B>.done();
              final value = f(result.value);
              if (value is Future<B>) return value.then(IterResult<B>.value);
              return IterResult<B>.value(value);
            }));
  });
}

/// Identical to [map], but intended for side effects by convention.
Iterable<B> mapEffect<A, B>(B Function(A a) f, Iterable<A> iterable) =>
    map(f, iterable);

/// Identical to [mapAsync], but intended for side effects by convention.
@pragma('vm:prefer-inline')
FxAsyncIterable<B> mapEffectAsync<A, B>(
        FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) =>
    mapAsync(f, iterable);

/// Maps [f] over [iterable] with up to [concurrency] elements in flight at
/// once, yielding results in source order — the pre-combined form of
/// `toAsync` → `mapAsync` → `concurrentAsync`.
///
/// Dart-native addition (FxTS pipes `concurrent` as a separate step).
///
/// ```dart
/// await toListAsync(mapConcurrent(3, fetchProfile, users));
/// ```
@pragma('vm:prefer-inline')
FxAsyncIterable<B> mapConcurrent<A, B>(
        int concurrency, FutureOr<B> Function(A a) f, Iterable<A> iterable) =>
    concurrentAsync(concurrency, mapAsync(f, toAsync(iterable)));

/// Async-source counterpart of [mapConcurrent] — the pre-combined form of
/// `mapAsync` → `concurrentAsync`.
@pragma('vm:prefer-inline')
FxAsyncIterable<B> mapConcurrentAsync<A, B>(int concurrency,
        FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) =>
    concurrentAsync(concurrency, mapAsync(f, iterable));

/// Lazily pairs each element with the value [f] derives from it — the input
/// stays beside its result, so no hand-built `(x, f(x))` records.
///
/// Dart-native addition (no FxTS counterpart).
///
/// ```dart
/// attach((w) => w.length, ['a', 'bb']); // (('a', 1), ('bb', 2))
/// ```
Iterable<(A, B)> attach<A, B>(B Function(A a) f, Iterable<A> iterable) =>
    _AttachIterable(f, iterable);

class _AttachIterable<A, B> extends Iterable<(A, B)> {
  _AttachIterable(this._f, this._source);
  final B Function(A) _f;
  final Iterable<A> _source;
  @override
  Iterator<(A, B)> get iterator => _AttachIterator(_f, _source.iterator);
}

class _AttachIterator<A, B> implements Iterator<(A, B)> {
  _AttachIterator(this._f, this._it);
  final B Function(A) _f;
  final Iterator<A> _it;
  @override
  late (A, B) current;
  @override
  bool moveNext() {
    if (_it.moveNext()) {
      final v = _it.current;
      current = (v, _f(v));
      return true;
    }
    return false;
  }
}

/// Async counterpart of [attach]. Built on [mapAsync], so overlapping
/// `next()` calls start overlapping upstream pulls — it composes with
/// `concurrentAsync` like any other async operator.
@pragma('vm:prefer-inline')
FxAsyncIterable<(A, B)> attachAsync<A, B>(
        FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) =>
    mapAsync((A a) async => (a, await f(a)), iterable);

/// Iterates over each element, applying [f] without changing the values.
///
/// Port of FxTS `peek`.
Iterable<A> peek<A>(void Function(A a) f, Iterable<A> iterable) =>
    _PeekIterable(f, iterable);

class _PeekIterable<A> extends Iterable<A> {
  _PeekIterable(this._f, this._source);
  final void Function(A) _f;
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator => _PeekIterator(_f, _source.iterator);
}

class _PeekIterator<A> implements Iterator<A> {
  _PeekIterator(this._f, this._it);
  final void Function(A) _f;
  final Iterator<A> _it;
  @override
  late A current;
  @override
  bool moveNext() {
    if (_it.moveNext()) {
      final v = _it.current;
      _f(v);
      current = v;
      return true;
    }
    return false;
  }
}

/// Async counterpart of [peek].
@pragma('vm:prefer-inline')
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
@pragma('vm:prefer-inline')
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
Iterable<dynamic> flat(Iterable<dynamic> iterable, [int depth = 1]) =>
    _FlatIterable(iterable, depth);

class _FlatIterable extends Iterable<dynamic> {
  _FlatIterable(this._source, this._depth);
  final Iterable<dynamic> _source;
  final int _depth;
  @override
  Iterator<dynamic> get iterator => _FlatIterator(_source.iterator, _depth);
}

class _FlatIterator implements Iterator<dynamic> {
  _FlatIterator(this._root, this._depth);
  final Iterator<dynamic> _root;
  final int _depth;
  // Explicit descent stack instead of recursive generators: an element is
  // descended into while fewer than [_depth] containers are open.
  final List<Iterator<dynamic>> _stack = [];
  @override
  dynamic current;
  @override
  bool moveNext() {
    while (true) {
      while (_stack.isNotEmpty) {
        final top = _stack.last;
        if (top.moveNext()) {
          final value = top.current;
          if (_isFlatAble(value) && _stack.length < _depth) {
            _stack.add((value as Iterable).iterator);
            continue;
          }
          current = value;
          return true;
        }
        _stack.removeLast();
      }
      if (!_root.moveNext()) return false;
      final value = _root.current;
      if (_isFlatAble(value) && _depth >= 1) {
        _stack.add((value as Iterable).iterator);
        continue;
      }
      current = value;
      return true;
    }
  }
}

/// Async counterpart of [flat]. Only *sync* nested iterables are flattened,
/// mirroring FxTS behavior.
@pragma('vm:prefer-inline')
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
        Iterable<B> Function(A a) f, Iterable<A> iterable) =>
    _FlatMapIterable(f, iterable);

class _FlatMapIterable<A, B> extends Iterable<B> {
  _FlatMapIterable(this._f, this._source);
  final Iterable<B> Function(A) _f;
  final Iterable<A> _source;
  @override
  Iterator<B> get iterator => _FlatMapIterator(_f, _source.iterator);
}

class _FlatMapIterator<A, B> implements Iterator<B> {
  _FlatMapIterator(this._f, this._it);
  final Iterable<B> Function(A) _f;
  final Iterator<A> _it;
  Iterator<B>? _inner;
  @override
  late B current;
  @override
  bool moveNext() {
    while (true) {
      final inner = _inner;
      if (inner != null) {
        if (inner.moveNext()) {
          current = inner.current;
          return true;
        }
        _inner = null;
      }
      if (!_it.moveNext()) return false;
      _inner = _f(_it.current).iterator;
    }
  }
}

/// Async counterpart of [flatMap].
@pragma('vm:prefer-inline')
FxAsyncIterable<B> flatMapAsync<A, B>(
    FutureOr<Iterable<B>> Function(A a) f, FxAsyncIterable<A> iterable) {
  return DelegateAsyncIterable(() => _FlatMapAsyncIterator<A, B>(f, iterable));
}

/// The [flatMapAsync] iterator: elements of an already-open inner iterable
/// are served synchronously via the fast-pull path; a Concurrent marker on a
/// fresh iterator falls back to [_flatMapAsyncLegacy]'s dispatch layering.
class _FlatMapAsyncIterator<A, B>
    with FxFastNextGate<B>
    implements FxFastIterator<B> {
  _FlatMapAsyncIterator(this._f, this._sourceIterable);
  final FutureOr<Iterable<B>> Function(A) _f;
  final FxAsyncIterable<A> _sourceIterable;
  FxAsyncIterator<A>? _source;
  FxAsyncIterator<B>? _fallback;
  Iterator<B>? _inner;
  bool _done = false;

  @override
  Future<IterResult<B>> next([Concurrent? concurrent]) {
    if (_fallback == null &&
        concurrent is Concurrent &&
        _source == null &&
        _inner == null &&
        !_done) {
      _fallback = _flatMapAsyncLegacy(_f, _sourceIterable).iterator;
    }
    final fb = _fallback;
    if (fb != null) return fb.next(concurrent);
    return super.next(concurrent);
  }

  @override
  FutureOr<IterResult<B>> nextOr() {
    final fb = _fallback;
    if (fb != null) return fb.next();
    while (true) {
      if (_done) return IterResult<B>.done();
      final inner = _inner;
      if (inner != null) {
        if (inner.moveNext()) return IterResult.value(inner.current);
        _inner = null;
      }
      final src = _source ??= _sourceIterable.iterator;
      final FutureOr<IterResult<A>> r =
          src is FxFastIterator<A> ? src.nextOr() : src.next();
      if (r is Future<IterResult<A>>) return r.then(_afterSource);
      if (r.done) {
        _done = true;
        return IterResult<B>.done();
      }
      final it = _f(r.value);
      if (it is Future<Iterable<B>>) {
        return it.then((i) {
          _inner = i.iterator;
          return nextOr();
        });
      }
      _inner = it.iterator;
      // Loop: an empty inner iterable pulls the next source element.
    }
  }

  FutureOr<IterResult<B>> _afterSource(IterResult<A> r) {
    if (r.done) {
      _done = true;
      return IterResult<B>.done();
    }
    final it = _f(r.value);
    if (it is Future<Iterable<B>>) {
      return it.then((i) {
        _inner = i.iterator;
        return nextOr();
      });
    }
    _inner = it.iterator;
    return nextOr();
  }
}

FxAsyncIterable<B> _flatMapAsyncLegacy<A, B>(
    FutureOr<Iterable<B>> Function(A a) f, FxAsyncIterable<A> iterable) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    Iterator<B>? current;
    return SerialAsyncIterator((concurrent) {
      // Then-based: elements of an already-open inner iterable are served
      // with a value future only — no async-closure or await hops.
      Future<IterResult<B>> loop() {
        final cur = current;
        if (cur != null) {
          if (cur.moveNext()) {
            return Future.value(IterResult.value(cur.current));
          }
          current = null;
        }
        return iterator.next(concurrent).then((result) {
          if (result.done) return IterResult<B>.done();
          final inner = f(result.value);
          if (inner is Future<Iterable<B>>) {
            return inner.then((it) {
              current = it.iterator;
              return loop();
            });
          }
          current = inner.iterator;
          return loop();
        });
      }

      return loop();
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
Iterable<B> scan<A, B>(B Function(B acc, A a) f, B seed, Iterable<A> iterable) =>
    _ScanIterable(f, seed, iterable);

class _ScanIterable<A, B> extends Iterable<B> {
  _ScanIterable(this._f, this._seed, this._source);
  final B Function(B, A) _f;
  final B _seed;
  final Iterable<A> _source;
  @override
  Iterator<B> get iterator => _ScanIterator(_f, _seed, _source.iterator);
  @override
  List<B> toList({bool growable = true}) {
    final source = _source;
    // A List source scans into a pre-sized list (output length is exactly
    // n+1) — as in [_MapIterable.toList], the inherited toList would grow
    // and recopy ~log n times. [_f] still runs exactly once per element,
    // in order.
    if (source is List<A>) {
      final length = source.length;
      final out = List<B>.filled(length + 1, _seed, growable: growable);
      var acc = _seed;
      for (var i = 0; i < length; i++) {
        acc = _f(acc, source[i]);
        out[i + 1] = acc;
      }
      return out;
    }
    return super.toList(growable: growable);
  }
}

class _ScanIterator<A, B> implements Iterator<B> {
  _ScanIterator(this._f, this._seed, this._it);
  final B Function(B, A) _f;
  final B _seed;
  final Iterator<A> _it;
  var _emittedSeed = false;
  @override
  late B current;
  @override
  bool moveNext() {
    if (!_emittedSeed) {
      _emittedSeed = true;
      current = _seed;
      return true;
    }
    if (_it.moveNext()) {
      current = _f(current, _it.current);
      return true;
    }
    return false;
  }
}

/// [scan] without a seed: the first element is used as the seed.
/// Returns an empty iterable when [iterable] is empty.
///
/// Port of FxTS `scan(f, iterable)`.
Iterable<A> scan1<A>(A Function(A acc, A a) f, Iterable<A> iterable) =>
    _Scan1Iterable(f, iterable);

class _Scan1Iterable<A> extends Iterable<A> {
  _Scan1Iterable(this._f, this._source);
  final A Function(A, A) _f;
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator => _Scan1Iterator(_f, _source.iterator);
  @override
  List<A> toList({bool growable = true}) {
    final source = _source;
    // A List source scans into a pre-sized list (output length is exactly
    // n) — see [_ScanIterable.toList]. [_f] still runs exactly once per
    // element after the first, in order.
    if (source is List<A>) {
      final length = source.length;
      if (length == 0) return growable ? <A>[] : List<A>.empty();
      var acc = source[0];
      final out = List<A>.filled(length, acc, growable: growable);
      for (var i = 1; i < length; i++) {
        acc = _f(acc, source[i]);
        out[i] = acc;
      }
      return out;
    }
    return super.toList(growable: growable);
  }
}

class _Scan1Iterator<A> implements Iterator<A> {
  _Scan1Iterator(this._f, this._it);
  final A Function(A, A) _f;
  final Iterator<A> _it;
  var _started = false;
  @override
  late A current;
  @override
  bool moveNext() {
    if (!_it.moveNext()) return false;
    current = _started ? _f(current, _it.current) : _it.current;
    _started = true;
    return true;
  }
}

/// Async counterpart of [scan].
@pragma('vm:prefer-inline')
FxAsyncIterable<B> scanAsync<A, B>(FutureOr<B> Function(B acc, A a) f,
    FutureOr<B> seed, FxAsyncIterable<A> iterable) {
  // Fused-stage form: scan is one-in-one-out like map, only stateful, so it
  // joins a map/filter/takeWhile run instead of layering a pull on top of it
  // (a whole future and microtask hop per element). At most one scan per run
  // — the accumulator has one slot on the iterator — so a second scan starts
  // a new run over this one. A Concurrent marker falls back to
  // [_scanAsyncLegacy]'s dispatch layering, as the other stages do.
  final stage = FxScanStage((acc, v) => f(acc as B, v as A), seed);
  if (iterable is FxFusedAsyncIterable<A> && iterable.scanIndex < 0) {
    final source = iterable.source;
    final stages = iterable.stages;
    final legacy = iterable.legacy;
    return FxFusedAsyncIterable<B>(source, [...stages, stage],
        () => _scanAsyncLegacy(f, seed, legacy()));
  }
  return FxFusedAsyncIterable<B>(
      iterable, [stage], () => _scanAsyncLegacy(f, seed, iterable));
}

FxAsyncIterable<B> _scanAsyncLegacy<A, B>(FutureOr<B> Function(B acc, A a) f,
    FutureOr<B> seed, FxAsyncIterable<A> iterable) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    B? acc;
    var emittedSeed = false;
    return SerialAsyncIterator((concurrent) {
      if (!emittedSeed) {
        emittedSeed = true;
        final s = seed;
        if (s is Future<B>) {
          return s.then((v) {
            acc = v;
            return IterResult.value(v);
          });
        }
        acc = s;
        return Future.value(IterResult.value(s));
      }
      return iterator.next(concurrent).then((result) {
        if (result.done) return IterResult<B>.done();
        final v = f(acc as B, result.value);
        if (v is Future<B>) {
          return v.then((b) {
            acc = b;
            return IterResult.value(b);
          });
        }
        acc = v;
        return IterResult.value(v);
      });
    });
  });
}

/// Async counterpart of [scan1].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> scan1Async<A>(
    FutureOr<A> Function(A acc, A a) f, FxAsyncIterable<A> iterable) {
  return dispatchAsync(iterable, (source) {
    final iterator = source.iterator;
    A? acc;
    var emittedSeed = false;
    return SerialAsyncIterator((concurrent) {
      return iterator.next(concurrent).then((result) {
        if (result.done) return IterResult<A>.done();
        if (!emittedSeed) {
          emittedSeed = true;
          acc = result.value;
          return result;
        }
        final v = f(acc as A, result.value);
        if (v is Future<A>) {
          return v.then((b) {
            acc = b;
            return IterResult.value(b);
          });
        }
        acc = v;
        return IterResult.value(v);
      });
    });
  });
}
