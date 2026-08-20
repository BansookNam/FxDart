import 'dart:async';

import '../async_iterable.dart';
import 'list_range.dart';

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
Iterable<B> map<A, B>(B Function(A a) f, Iterable<A> iterable) {
  // Resolved once, when the chain is built — never per element. Cast, not
  // promotion: FxMapFusable is not a subtype of Iterable, so the type test
  // alone does not promote (the shape `uniqBy` uses for FxUniqByFusable).
  if (iterable is FxMapFusable<A>) {
    return (iterable as FxMapFusable<A>).fxFuseMap<B>(f);
  }
  return _MapIterable(f, iterable);
}

/// Implemented by a lazy stage that can absorb a following `uniq` into its
/// own loop instead of being pulled through an [Iterator] by it.
///
/// The pull protocol costs two virtual calls per element per stage boundary
/// (`moveNext` + `current`), and the inner one is megamorphic — a stage holds
/// its upstream as a bare `Iterator<A>`, so the call site sees every iterator
/// in the program. On the `first-visit-merchants` benchmark
/// (`map().uniq().toList()` over 1M transactions) that boundary, not the work,
/// was most of fxdart's 1.89x against the equivalent hand-written loop:
/// fusing the two stages took it to 1.16x, and dropping the seen set's
/// per-element covariance check (see `_MapUniqIterable.toList`) to 1.11x.
/// What is left is the user's callback, the one indirect call per element that
/// no amount of fusing can remove.
///
/// The fused node has to be built *by the mapping stage*, which is why this
/// is a method on it rather than a type test at the `uniq` call site: the
/// element type of the stage's own source is not nameable from downstream,
/// and recovering it there (a generic-method handshake, or erasing to
/// `Object?` and casting per element) costs back most of what fusion wins.
abstract class FxUniqFusable<B> {
  /// This stage followed by `uniq`, as a single stage.
  ///
  /// Same elements, order, and laziness as `uniq(this)` — including a seen-set
  /// per iteration, and the transform running once per element consumed.
  Iterable<B> fxFuseUniq();
}

class _MapIterable<A, B> extends Iterable<B> implements FxUniqFusable<B> {
  _MapIterable(this._f, this._source);
  final B Function(A) _f;
  final Iterable<A> _source;
  @override
  Iterator<B> get iterator {
    final source = _source;
    if (source is List<A>) return _MapListIterator(_f, source);
    return _MapIterator(_f, source.iterator);
  }

  @override
  Iterable<B> fxFuseUniq() => _MapUniqIterable(_f, _source);

  /// Hands a `List` source to the SDK's own `map().toList()` rather than
  /// filling a pre-sized list here.
  ///
  /// Filling one from package code costs a **covariant store check per
  /// element**: `List<B>.operator[]=` takes a covariant parameter, and here `B`
  /// is a runtime type argument, so the check cannot be elided. For a record
  /// type — structural, so the test is not a class-id compare — that was
  /// catastrophic. Measured at N=1,000,000 mapping to `(Tx, double)`:
  /// pre-sized fill 394 ms, `List.generate` 219 ms, inherited `toList` 220 ms,
  /// **this 65 ms**, against 70 ms for the same `txns.map(...).toList()` in
  /// plain Dart. Producing the records is not the cost — draining the same
  /// chain with a `for-in` is 8 ms.
  ///
  /// `source.map(_f)` returns an SDK `MappedListIterable`, which the SDK knows
  /// has an efficient length, so `toList` pre-allocates and bulk-fills with
  /// internal *unchecked* stores that package code cannot reach.
  ///
  /// [_f] still runs exactly once per element, in order.
  @override
  List<B> toList({bool growable = true}) {
    final source = _source;
    if (source is List<A>) {
      return source.map(_f).toList(growable: growable);
    }
    return super.toList(growable: growable);
  }
}

/// [map] over a `List`, walked by index.
///
/// Rejected in 0.8.0 on the strength of a before/after `results.json` diff
/// that showed a −3.8% median; that comparison was later shown to be unable
/// to resolve anything under ~5% (the `native` side, whose binary does not
/// even change, moved −27% to +4% across runs). Re-measured with the paired
/// interleaved A/B in `tool/ab_bench.dart` — see the CHANGELOG for the
/// per-case numbers.
class _MapListIterator<A, B> implements Iterator<B> {
  _MapListIterator(this._f, this._list) : _end = _list.length;
  final B Function(A) _f;
  final List<A> _list;
  final int _end;
  int _i = 0;
  @override
  late B current;
  @override
  bool moveNext() {
    final i = _i;
    if (i >= _end) return false;
    _i = i + 1;
    current = _f(_list[i]);
    return true;
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

/// `map(f, source)` followed by `uniq()`, as one stage — see [FxUniqFusable].
///
/// Lazily equivalent to both halves it replaces: [_f] runs once per element
/// consumed, the seen set is per-iteration, and a downstream `take` still cuts
/// the source short.
class _MapUniqIterable<A, B> extends Iterable<B> {
  _MapUniqIterable(this._f, this._source);
  final B Function(A) _f;
  final Iterable<A> _source;

  @override
  Iterator<B> get iterator => _MapUniqIterator(_f, _source.iterator);

  /// The point of the fusion: mapping, dedup, and accumulation in one loop.
  /// A `toList` consumes everything anyway, so indexing a `List` source costs
  /// nothing in laziness and skips the iterator entirely — leaving [_f] as the
  /// only call the compiler cannot inline.
  ///
  /// [_f] and the length are copied into locals first, so neither is reloaded
  /// through the receiver on every iteration. Fixing the length is the same
  /// trade-off `takeRight`/`dropRight` and [FxListRange] already make — a
  /// source mutated by [_f] mid-pass is not reported as a
  /// `ConcurrentModificationError`.
  @override
  List<B> toList({bool growable = true}) {
    final result = <B>[];
    // `Set<Object?>`, not `Set<B>`: B is a runtime type argument here, so
    // every `add` on a `Set<B>` pays a covariant parameter check — once per
    // source element, against once per *distinct* element for `result.add`.
    // Membership is `hashCode`/`==` either way, so the dedup is unchanged.
    final seen = <Object?>{};
    final f = _f;
    final source = _source;
    if (source is List<A>) {
      final length = source.length;
      for (var i = 0; i < length; i++) {
        final v = f(source[i]);
        if (seen.add(v)) result.add(v);
      }
    } else {
      for (final a in source) {
        final v = f(a);
        if (seen.add(v)) result.add(v);
      }
    }
    return growable ? result : List<B>.from(result, growable: false);
  }
}

class _MapUniqIterator<A, B> implements Iterator<B> {
  _MapUniqIterator(this._f, this._it);
  final B Function(A) _f;
  final Iterator<A> _it;
  final _seen = <Object?>{};
  @override
  late B current;
  @override
  bool moveNext() {
    while (_it.moveNext()) {
      final v = _f(_it.current);
      if (_seen.add(v)) {
        current = v;
        return true;
      }
    }
    return false;
  }
}

/// Like [map], but the callback also receives the element's 0-based
/// position.
///
/// Not an FxTS port. `zipWithIndex` + `map` over the pair already expressed
/// this, at the cost of a record per element and a `p.$1`/`p.$2` callback
/// body; taking the index as a second argument keeps the chain readable and
/// allocates nothing.
///
/// ```dart
/// mapWithIndex((a, i) => '$i:$a', ['a', 'b']); // ('0:a', '1:b')
/// ```
Iterable<B> mapWithIndex<A, B>(
  B Function(A a, int index) f,
  Iterable<A> iterable,
) => _MapWithIndexIterable(f, iterable);

class _MapWithIndexIterable<A, B> extends Iterable<B> {
  _MapWithIndexIterable(this._f, this._source);
  final B Function(A, int) _f;
  final Iterable<A> _source;
  @override
  Iterator<B> get iterator => _MapWithIndexIterator(_f, _source.iterator);
  @override
  List<B> toList({bool growable = true}) {
    final source = _source;
    // Same SDK hand-off as [_MapIterable.toList], and for the same reason —
    // a pre-sized fill here pays a covariant store check per element. There is
    // no SDK `mapWithIndex`, so the index rides along in the closure; `toList`
    // makes exactly one in-order pass, so the counter stays in step.
    if (source is List<A>) {
      final f = _f;
      var i = 0;
      return source.map((a) => f(a, i++)).toList(growable: growable);
    }
    return super.toList(growable: growable);
  }
}

class _MapWithIndexIterator<A, B> implements Iterator<B> {
  _MapWithIndexIterator(this._f, this._it);
  final B Function(A, int) _f;
  final Iterator<A> _it;
  var _i = 0;
  @override
  late B current;
  @override
  bool moveNext() {
    if (_it.moveNext()) {
      current = _f(_it.current, _i++);
      return true;
    }
    return false;
  }
}

/// Async counterpart of [mapWithIndex].
///
/// The index counts elements of *this* stage's input, in source order —
/// `concurrent` overlaps the upstream pulls but still resolves them in
/// order, so the numbering is the same either way.
@pragma('vm:prefer-inline')
FxAsyncIterable<B> mapWithIndexAsync<A, B>(
  FutureOr<B> Function(A a, int index) f,
  FxAsyncIterable<A> iterable,
) {
  // dispatchAsync so the counter is per-iteration, not per-iterable — the
  // same shape as [zipWithIndexAsync].
  return dispatchAsync(iterable, (source) {
    var i = 0;
    return mapAsync((A a) => f(a, i++), source).iterator;
  });
}

/// Async counterpart of [map]. The callback may return a [Future].
///
/// ```dart
/// await toListAsync(mapAsync((a) async => a + 10, toAsync([1, 2, 3])));
/// // [11, 12, 13]
/// ```
@pragma('vm:prefer-inline')
FxAsyncIterable<B> mapAsync<A, B>(
  FutureOr<B> Function(A a) f,
  FxAsyncIterable<A> iterable,
) {
  // Fused-stage form: a run of map/filter/takeWhile applies inline per
  // element (see FxFusedAsyncIterable); a Concurrent marker falls back to
  // [_mapAsyncLegacy], the parallel-safe pass-through layering.
  final stage = FxMapStage((v) => f(v as A));
  if (iterable is FxFusedAsyncIterable<A>) {
    final source = iterable.source;
    final stages = iterable.stages;
    final legacy = iterable.legacy;
    return FxFusedAsyncIterable<B>(source, [
      ...stages,
      stage,
    ], () => _mapAsyncLegacy(f, legacy()));
  }
  return FxFusedAsyncIterable<B>(iterable, [
    stage,
  ], () => _mapAsyncLegacy(f, iterable));
}

FxAsyncIterable<B> _mapAsyncLegacy<A, B>(
  FutureOr<B> Function(A a) f,
  FxAsyncIterable<A> iterable,
) {
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
      }),
    );
  });
}

/// Identical to [map], but intended for side effects by convention.
Iterable<B> mapEffect<A, B>(B Function(A a) f, Iterable<A> iterable) =>
    map(f, iterable);

/// Identical to [mapAsync], but intended for side effects by convention.
@pragma('vm:prefer-inline')
FxAsyncIterable<B> mapEffectAsync<A, B>(
  FutureOr<B> Function(A a) f,
  FxAsyncIterable<A> iterable,
) => mapAsync(f, iterable);

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
  int concurrency,
  FutureOr<B> Function(A a) f,
  Iterable<A> iterable,
) => concurrentAsync(concurrency, mapAsync(f, toAsync(iterable)));

/// Async-source counterpart of [mapConcurrent] — the pre-combined form of
/// `mapAsync` → `concurrentAsync`.
@pragma('vm:prefer-inline')
FxAsyncIterable<B> mapConcurrentAsync<A, B>(
  int concurrency,
  FutureOr<B> Function(A a) f,
  FxAsyncIterable<A> iterable,
) => concurrentAsync(concurrency, mapAsync(f, iterable));

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
  FutureOr<B> Function(A a) f,
  FxAsyncIterable<A> iterable,
) => mapAsync((A a) async => (a, await f(a)), iterable);

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
  FutureOr<void> Function(A a) f,
  FxAsyncIterable<A> iterable,
) => mapAsync((A a) {
  // then/bare, not `async`+`await`: an `async` wrapper allocates a Future and
  // suspends once per element even when [f] is synchronous — which `peek`
  // usually is, since its whole job is a side effect. Same shape as
  // `uniqByAsync`; 0.7.4 measured the async-function form at 1.4x the
  // then/bare form for synchronous callbacks.
  final r = f(a);
  if (r is Future) return r.then((_) => a);
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
  K key,
  FxAsyncIterable<Map<K, V>> iterable,
) => mapAsync((Map<K, V> a) => a[key], iterable);

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
FxAsyncIterable<dynamic> flatAsync(
  FxAsyncIterable<dynamic> iterable, [
  int depth = 1,
]) {
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
Iterable<B> flatMap<A, B>(Iterable<B> Function(A a) f, Iterable<A> iterable) =>
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

/// Like [flatMap], but the callback also receives the source element's
/// 0-based position. The index counts *source* elements, not emitted ones.
///
/// ```dart
/// flatMapWithIndex((a, i) => [i, a], [10, 20]); // (0, 10, 1, 20)
/// ```
Iterable<B> flatMapWithIndex<A, B>(
  Iterable<B> Function(A a, int index) f,
  Iterable<A> iterable,
) => _FlatMapWithIndexIterable(f, iterable);

class _FlatMapWithIndexIterable<A, B> extends Iterable<B> {
  _FlatMapWithIndexIterable(this._f, this._source);
  final Iterable<B> Function(A, int) _f;
  final Iterable<A> _source;
  @override
  Iterator<B> get iterator => _FlatMapWithIndexIterator(_f, _source.iterator);
}

class _FlatMapWithIndexIterator<A, B> implements Iterator<B> {
  _FlatMapWithIndexIterator(this._f, this._it);
  final Iterable<B> Function(A, int) _f;
  final Iterator<A> _it;
  Iterator<B>? _inner;
  var _i = 0;
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
      _inner = _f(_it.current, _i++).iterator;
    }
  }
}

/// Async counterpart of [flatMapWithIndex].
@pragma('vm:prefer-inline')
FxAsyncIterable<B> flatMapWithIndexAsync<A, B>(
  FutureOr<Iterable<B>> Function(A a, int index) f,
  FxAsyncIterable<A> iterable,
) {
  return dispatchAsync(iterable, (source) {
    var i = 0;
    return flatMapAsync((A a) => f(a, i++), source).iterator;
  });
}

/// Async counterpart of [flatMap].
@pragma('vm:prefer-inline')
FxAsyncIterable<B> flatMapAsync<A, B>(
  FutureOr<Iterable<B>> Function(A a) f,
  FxAsyncIterable<A> iterable,
) {
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
      final FutureOr<IterResult<A>> r = src is FxFastIterator<A>
          ? src.nextOr()
          : src.next();
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
  FutureOr<Iterable<B>> Function(A a) f,
  FxAsyncIterable<A> iterable,
) {
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
Iterable<B> scan<A, B>(
  B Function(B acc, A a) f,
  B seed,
  Iterable<A> iterable,
) => _ScanIterable(f, seed, iterable);

class _ScanIterable<A, B> extends Iterable<B> implements FxMapFusable<B> {
  _ScanIterable(this._f, this._seed, this._source);
  final B Function(B, A) _f;
  final B _seed;
  final Iterable<A> _source;
  @override
  Iterator<B> get iterator => _ScanIterator(_f, _seed, _source.iterator);

  @override
  Iterable<C> fxFuseMap<C>(C Function(B a) g) =>
      _ScanMapIterable(_f, _seed, _source, g);

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

/// `scan(f, seed, source)` followed by `map(g)`, as one stage — see
/// [FxMapFusable].
///
/// The accumulator step and [_g] run inside a single `moveNext` (or a single
/// `toList` loop), instead of every accumulated value crossing a stage
/// boundary — a megamorphic `moveNext` plus a `current` read — to reach a
/// `map` iterator. Both callbacks land in fields of this node exactly as they
/// would in the two stages it replaces, so **neither one is devirtualized**:
/// they stay two indirect calls per element. The removed stage boundaries are
/// the whole win.
///
/// Lazily equivalent to the pair: `_g(seed)` is emitted first and then one
/// value per source element (so exactly `source.length + 1` in all), [_f] and
/// [_g] each run once per element consumed, the accumulator is fresh per
/// iteration, and a downstream `take` still cuts the source short.
class _ScanMapIterable<A, B, C> extends Iterable<C> {
  _ScanMapIterable(this._f, this._seed, this._source, this._g);
  final B Function(B, A) _f;
  final B _seed;
  final Iterable<A> _source;
  final C Function(B) _g;

  @override
  Iterator<C> get iterator => _ScanMapIterator(_f, _seed, _source.iterator, _g);

  /// The point of the fusion: accumulate, map, and collect in one loop.
  ///
  /// A `toList` consumes everything anyway, so the source shape is resolved
  /// once here rather than pulled: a [FxListRange] is walked by index and a
  /// [FxIntRange] (what `range()` produces) by counter, leaving [_f] and [_g]
  /// as the only calls per element. [_f], [_g], the accumulator and the bounds
  /// are copied into locals first, so none of them is reloaded through the
  /// receiver on every iteration (see [_MapUniqIterable.toList]).
  ///
  /// Accumulated with `add`, *not* the pre-sized fill [_ScanIterable.toList]
  /// uses: `List<C>.operator[]=` takes a covariant parameter and `C` is a
  /// runtime type argument here, so the store check per element cannot be
  /// elided — and for a record element type it is not a class-id compare. The
  /// measurement is on [_MapIterable.toList].
  @override
  List<C> toList({bool growable = true}) {
    final f = _f;
    final g = _g;
    final source = _source;
    var acc = _seed;
    final result = <C>[g(acc)];
    final r = fxListRangeOf(source);
    if (r != null) {
      final list = r.list;
      final end = r.end;
      for (var i = r.start; i < end; i++) {
        acc = f(acc, list[i]);
        result.add(g(acc));
      }
      return growable ? result : List<C>.from(result, growable: false);
    }
    final ir = fxIntRangeOf(source);
    if (ir != null) {
      // The elements are `int` while `A` is only *some* supertype of it, so
      // the callback is cast once, here — never the values, per element (the
      // shape `_FilterRangeIterator` uses).
      final fi = f as B Function(B, int);
      final end = ir.end;
      final step = ir.step;
      for (var i = ir.start; step < 0 ? i > end : i < end; i += step) {
        acc = fi(acc, i);
        result.add(g(acc));
      }
      return growable ? result : List<C>.from(result, growable: false);
    }
    for (final a in source) {
      acc = f(acc, a);
      result.add(g(acc));
    }
    return growable ? result : List<C>.from(result, growable: false);
  }
}

/// The pulled half of [_ScanMapIterable]: [_ScanIterator]'s accumulation with
/// [_g] folded into the same `moveNext`.
///
/// The accumulator needs a field of its own rather than riding in [current] as
/// [_ScanIterator] lets it — [current] is a `C` here, and what the next step
/// folds is the `B` before [_g]. The upstream is held as a bare `Iterator<A>`,
/// exactly as [_ScanIterator] holds it, so the fused chain pays one stage
/// boundary where the unfused pair pays two.
class _ScanMapIterator<A, B, C> implements Iterator<C> {
  _ScanMapIterator(this._f, this._acc, this._it, this._g);
  final B Function(B, A) _f;
  final Iterator<A> _it;
  final C Function(B) _g;
  B _acc;
  var _emittedSeed = false;
  @override
  late C current;
  @override
  bool moveNext() {
    if (!_emittedSeed) {
      _emittedSeed = true;
      current = _g(_acc);
      return true;
    }
    if (_it.moveNext()) {
      final acc = _f(_acc, _it.current);
      _acc = acc;
      current = _g(acc);
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
FxAsyncIterable<B> scanAsync<A, B>(
  FutureOr<B> Function(B acc, A a) f,
  FutureOr<B> seed,
  FxAsyncIterable<A> iterable,
) {
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
    return FxFusedAsyncIterable<B>(source, [
      ...stages,
      stage,
    ], () => _scanAsyncLegacy(f, seed, legacy()));
  }
  return FxFusedAsyncIterable<B>(iterable, [
    stage,
  ], () => _scanAsyncLegacy(f, seed, iterable));
}

FxAsyncIterable<B> _scanAsyncLegacy<A, B>(
  FutureOr<B> Function(B acc, A a) f,
  FutureOr<B> seed,
  FxAsyncIterable<A> iterable,
) {
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
  FutureOr<A> Function(A acc, A a) f,
  FxAsyncIterable<A> iterable,
) {
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
