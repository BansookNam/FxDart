import 'dart:async';

import '../async_iterable.dart';
import 'list_range.dart';
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

class _FilterIterable<A> extends Iterable<A>
    implements FxUniqFusable<A>, FxUniqByFusable<A> {
  _FilterIterable(this._f, this._source);
  final bool Function(A) _f;
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator {
    final source = _source;
    if (source is List<A>) return _FilterListIterator(_f, source);
    if (source is FxFilterFusable<A>) {
      // A `zip`/`zip3` over `List` ranges absorbs this filter into its own
      // iterator, which removes a whole stage boundary per element — see
      // [FxFilterFusable]. Null means the sides are not all indexable, and
      // the ordinary layering below stands. Resolved once per iteration,
      // never per element.
      final fused = (source as FxFilterFusable<A>).fxFusedFilterIterator(_f);
      if (fused != null) return fused;
    }
    final r = fxIntRangeOf(source);
    if (r != null) {
      // `range()` is the other source shape that is a plain counted loop.
      // `filter(p, range(0, xs.length))` — walking indices to keep positional
      // context — is common enough to be worth the counter.
      return _FilterRangeIterator(_f, r) as Iterator<A>;
    }
    return _FilterIterator(_f, source.iterator);
  }

  @override
  Iterable<A> fxFuseUniq() => _FilterUniqIterable(_f, _source);

  @override
  Iterable<A> fxFuseUniqBy<B>(B Function(A a) f) =>
      _FilterUniqByIterable<A, B>(_f, f, _source);

  /// Hands a `List` source to the SDK's `where().toList()`, for the reason
  /// given on `_MapIterable.toList`: accumulating here costs a covariant
  /// check on every `add`, and pulls each element through [_FilterIterator]
  /// as well. [_f] still runs exactly once per element, in order.
  @override
  List<A> toList({bool growable = true}) {
    final source = _source;
    if (source is List<A>) {
      return source.where(_f).toList(growable: growable);
    }
    return super.toList(growable: growable);
  }
}

/// `filter(p, source)` followed by `uniq()`, as one stage.
///
/// The saving is one stage boundary — a `moveNext` plus a `current` read per
/// source element — not the callbacks, which still run once each per element
/// consumed. Measured on the `recent-errors` shape (1M logs, ~1/3 passing the
/// predicate): the layered form is 1.58x a hand-written loop over the same
/// data, one fused loop 1.36x, and the 1.36x is the two closure calls the
/// hand-written loop inlines and a callback-taking API cannot.
class _FilterUniqIterable<A> extends Iterable<A> {
  _FilterUniqIterable(this._p, this._source);
  final bool Function(A) _p;
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator {
    final source = _source;
    if (source is List<A>) return _FilterUniqListIterator(_p, source);
    return _FilterUniqIterator(_p, source.iterator);
  }

  @override
  List<A> toList({bool growable = true}) {
    final result = <A>[];
    final seen = <Object?>{};
    final p = _p;
    final source = _source;
    if (source is List<A>) {
      final length = source.length;
      for (var i = 0; i < length; i++) {
        final a = source[i];
        if (p(a) && seen.add(a)) result.add(a);
      }
    } else {
      for (final a in source) {
        if (p(a) && seen.add(a)) result.add(a);
      }
    }
    return growable ? result : List<A>.from(result, growable: false);
  }
}

/// [_FilterUniqIterable] over a `List` — see [_FilterUniqByListIterator] for
/// why indexing beats holding the source as an `Iterator<A>` field.
class _FilterUniqListIterator<A> implements Iterator<A> {
  _FilterUniqListIterator(this._p, this._list) : _end = _list.length;
  final bool Function(A) _p;
  final List<A> _list;
  final int _end;
  final _seen = <Object?>{};
  int _i = 0;
  @override
  late A current;
  @override
  bool moveNext() {
    final list = _list;
    final end = _end;
    var i = _i;
    while (i < end) {
      final v = list[i++];
      if (_p(v) && _seen.add(v)) {
        _i = i;
        current = v;
        return true;
      }
    }
    _i = i;
    return false;
  }
}

class _FilterUniqIterator<A> implements Iterator<A> {
  _FilterUniqIterator(this._p, this._it);
  final bool Function(A) _p;
  final Iterator<A> _it;
  final _seen = <Object?>{};
  @override
  late A current;
  @override
  bool moveNext() {
    while (_it.moveNext()) {
      final v = _it.current;
      if (_p(v) && _seen.add(v)) {
        current = v;
        return true;
      }
    }
    return false;
  }
}

/// `filter(p, source)` followed by `uniqBy(f)`, as one stage — see
/// [_FilterUniqIterable].
class _FilterUniqByIterable<A, B> extends Iterable<A> {
  _FilterUniqByIterable(this._p, this._f, this._source);
  final bool Function(A) _p;
  final B Function(A) _f;
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator {
    final source = _source;
    if (source is List<A>) {
      return _FilterUniqByListIterator(_p, _f, source);
    }
    return _FilterUniqByIterator(_p, _f, source.iterator);
  }

  @override
  List<A> toList({bool growable = true}) {
    final result = <A>[];
    final seen = <Object?>{};
    final p = _p;
    final f = _f;
    final source = _source;
    if (source is List<A>) {
      final length = source.length;
      for (var i = 0; i < length; i++) {
        final a = source[i];
        if (p(a) && seen.add(f(a))) result.add(a);
      }
    } else {
      for (final a in source) {
        if (p(a) && seen.add(f(a))) result.add(a);
      }
    }
    return growable ? result : List<A>.from(result, growable: false);
  }
}

/// [_FilterUniqByIterable] over a `List`, walked by index.
///
/// Holding the source as an `Iterator<A>` field is what costs here: a
/// `for-in` over a statically-known `List` is inlined by AOT into an indexed
/// walk, but once the same iterator is stored in a field typed
/// `Iterator<A>` every `moveNext`/`current` becomes a megamorphic virtual
/// call — the site sees every iterator in the program.
///
/// The bounds are fixed when iteration starts, so a source mutated mid-pass
/// is not reported as a `ConcurrentModificationError` — the trade-off
/// `takeRight`/`dropRight`/[FxListRange] and `_MapUniqIterable.toList`
/// already make.
class _FilterUniqByListIterator<A, B> implements Iterator<A> {
  _FilterUniqByListIterator(this._p, this._f, this._list) : _end = _list.length;
  final bool Function(A) _p;
  final B Function(A) _f;
  final List<A> _list;
  final int _end;
  final _seen = <Object?>{};
  int _i = 0;
  @override
  late A current;
  @override
  bool moveNext() {
    final list = _list;
    final end = _end;
    var i = _i;
    while (i < end) {
      final v = list[i++];
      if (_p(v) && _seen.add(_f(v))) {
        _i = i;
        current = v;
        return true;
      }
    }
    _i = i;
    return false;
  }
}

class _FilterUniqByIterator<A, B> implements Iterator<A> {
  _FilterUniqByIterator(this._p, this._f, this._it);
  final bool Function(A) _p;
  final B Function(A) _f;
  final Iterator<A> _it;
  final _seen = <Object?>{};
  @override
  late A current;
  @override
  bool moveNext() {
    while (_it.moveNext()) {
      final v = _it.current;
      if (_p(v) && _seen.add(_f(v))) {
        current = v;
        return true;
      }
    }
    return false;
  }
}

/// [filter] over a `List`, walked by index — see [_FilterUniqByListIterator]
/// for why the `Iterator<A>` field is what costs.
class _FilterListIterator<A> implements Iterator<A> {
  _FilterListIterator(this._f, this._list) : _end = _list.length;
  final bool Function(A) _f;
  final List<A> _list;
  final int _end;
  int _i = 0;
  @override
  late A current;
  @override
  bool moveNext() {
    final list = _list;
    final end = _end;
    final f = _f;
    var i = _i;
    while (i < end) {
      final v = list[i++];
      if (f(v)) {
        _i = i;
        current = v;
        return true;
      }
    }
    _i = i;
    return false;
  }
}

/// [filter] over a `range()`, walked with a counter — see
/// [_FilterUniqByListIterator] for why the `Iterator` field is what costs.
class _FilterRangeIterator implements Iterator<int> {
  _FilterRangeIterator(this._f, FxIntRange r)
    : _next = r.start,
      _end = r.end,
      _step = r.step;
  final bool Function(Never) _f;
  final int _end;
  final int _step;
  int _next;
  @override
  late int current;
  @override
  bool moveNext() {
    final end = _end;
    final step = _step;
    final f = _f as bool Function(int);
    var i = _next;
    while (step < 0 ? i > end : i < end) {
      final v = i;
      i += step;
      if (f(v)) {
        _next = i;
        current = v;
        return true;
      }
    }
    _next = i;
    return false;
  }
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
  bool Function(A a, int index) f,
  Iterable<A> iterable,
) => _FilterWithIndexIterable(f, iterable);

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
  FutureOr<bool> Function(A a, int index) f,
  FxAsyncIterable<A> iterable,
) {
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
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) {
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
      prevItem = prevItem
          .then((_) => nextItem)
          .then((result) {
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
          })
          .catchError((Object reason, StackTrace st) {
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
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) {
  // Fused-stage form; a Concurrent marker falls back to
  // [_filterAsyncLegacy]'s concurrent predicate machinery.
  final stage = FxFilterStage((v) => f(v as A));
  if (iterable is FxFusedAsyncIterable<A>) {
    final source = iterable.source;
    final stages = iterable.stages;
    final legacy = iterable.legacy;
    return FxFusedAsyncIterable<A>(source, [
      ...stages,
      stage,
    ], () => _filterAsyncLegacy(f, legacy()));
  }
  return FxFusedAsyncIterable<A>(iterable, [
    stage,
  ], () => _filterAsyncLegacy(f, iterable));
}

FxAsyncIterable<A> _filterAsyncLegacy<A>(
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) {
  // Only reached via the fused chain's Concurrent fallback, so this is the
  // concurrent predicate machinery directly (the serial case is the fused
  // FxFilterStage). A defensive unmarked first pull degrades to width 1.
  return DelegateAsyncIterable(() {
    FxAsyncIterator<A>? inner;
    return DelegateAsyncIterator((concurrent) {
      inner ??= _asyncConcurrent(
        concurrentAsync(
          concurrent is Concurrent ? concurrent.length : 1,
          _toFilterIterable(f, iterable),
        ),
      ).iterator;
      return inner!.next(concurrent);
    });
  });
}

/// Async counterpart of [reject].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> rejectAsync<A>(
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) => filterAsync((A a) async => !await f(a), iterable);

/// Async counterpart of [compact].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> compactAsync<A>(FxAsyncIterable<A?> iterable) =>
    mapAsync((A? a) => a as A, filterAsync((A? a) => a != null, iterable));

// --- uniq / set operations ----------------------------------------------

/// Returns an iterable with unique values as determined by [f].
///
/// Port of FxTS `uniqBy`.
Iterable<A> uniqBy<A, B>(B Function(A a) f, Iterable<A> iterable) {
  // Cast, not promotion — see [uniq] and `fxListRangeOf` for the shape.
  if (iterable is FxUniqByFusable<A>) {
    return (iterable as FxUniqByFusable<A>).fxFuseUniqBy<B>(f);
  }
  return _UniqByIterable(f, iterable);
}

/// Implemented by a lazy stage that can absorb a following `uniqBy` into its
/// own loop — the keyed twin of [FxUniqFusable].
///
/// Only stages whose output type equals their *input* type can offer this,
/// which is why `filter` can and `map` cannot: the fused node has to name the
/// source's element type, and for `map` that type is not reachable from the
/// `uniqBy` call site (see [FxUniqFusable] for the same argument).
abstract class FxUniqByFusable<A> {
  /// This stage followed by `uniqBy(f)`, as a single stage.
  ///
  /// Same elements, order, and laziness as `uniqBy(f, this)` — a seen-set per
  /// iteration, and both callbacks running once per element consumed.
  Iterable<A> fxFuseUniqBy<B>(B Function(A a) f);
}

class _UniqByIterable<A, B> extends Iterable<A> {
  _UniqByIterable(this._f, this._source);
  final B Function(A) _f;
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator => _UniqByIterator(_f, _source.iterator);

  /// Fuses the dedup loop with its own accumulation: one pass with `Set.add`
  /// + `List.add`, instead of a [_UniqByIterator.moveNext] per element and a
  /// separate growth pass in `super.toList`. Valid for any source — a `toList`
  /// consumes the whole iterable regardless, so nothing is evaluated that the
  /// lazy path would have skipped.
  ///
  /// The seen set is `Set<Object?>` and a `List` source is indexed rather than
  /// iterated, for the reasons given on `_MapUniqIterable.toList`.
  @override
  List<A> toList({bool growable = true}) {
    final result = <A>[];
    final seen = <Object?>{};
    final f = _f;
    final source = _source;
    if (source is List<A>) {
      final length = source.length;
      for (var i = 0; i < length; i++) {
        final a = source[i];
        if (seen.add(f(a))) result.add(a);
      }
    } else {
      for (final a in source) {
        if (seen.add(f(a))) result.add(a);
      }
    }
    return growable ? result : List<A>.from(result, growable: false);
  }
}

class _UniqByIterator<A, B> implements Iterator<A> {
  _UniqByIterator(this._f, this._it);
  final B Function(A) _f;
  final Iterator<A> _it;
  final _seen = <Object?>{};
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
///
/// A stage that can absorb this one (`map`, today) builds the fused node
/// itself; see [FxUniqFusable] for why the choice is made here and not by
/// inspecting the source in [_UniqIterable].
Iterable<A> uniq<A>(Iterable<A> iterable) {
  // Cast, not promotion: FxUniqFusable is not a subtype of Iterable, so the
  // type test alone does not promote (same shape as fxListRangeOf).
  if (iterable is FxUniqFusable<A>) {
    return (iterable as FxUniqFusable<A>).fxFuseUniq();
  }
  return _UniqIterable(iterable);
}

class _UniqIterable<A> extends Iterable<A> {
  _UniqIterable(this._source);
  final Iterable<A> _source;
  @override
  Iterator<A> get iterator => _UniqIterator(_source.iterator);

  /// Fuses the dedup loop with its own accumulation — see
  /// [_UniqByIterable.toList].
  @override
  List<A> toList({bool growable = true}) {
    final result = <A>[];
    final seen = <Object?>{};
    final source = _source;
    if (source is List<A>) {
      final length = source.length;
      for (var i = 0; i < length; i++) {
        final a = source[i];
        if (seen.add(a)) result.add(a);
      }
    } else {
      for (final a in source) {
        if (seen.add(a)) result.add(a);
      }
    }
    return growable ? result : List<A>.from(result, growable: false);
  }
}

class _UniqIterator<A> implements Iterator<A> {
  _UniqIterator(this._it);
  final Iterator<A> _it;
  final Set<Object?> _seen = {};
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

/// Strict (non-lazy) [uniq]: dedups the whole of [iterable] immediately and
/// returns the result as a `List`.
///
/// Same elements in the same order as `uniq(...).toList()`. The difference is
/// *when* and *how much* work happens:
///
/// * The upstream runs once, here, rather than on each iteration of the
///   result — so a chain that is iterated more than once pays for it once,
///   and any side effects in the upstream happen at this call.
/// * Nothing downstream can cut the work short. `uniq(xs).take(3)` stops the
///   upstream after 3 distinct values; `uniqStrict(xs).take(3)` dedups all of
///   `xs` first. Never use this ahead of a short-circuiting consumer, and
///   never on an unbounded iterable — it will not terminate.
///
/// Prefer lazy [uniq] by default; it already fuses into a single loop when
/// the chain ends in `.toList()`. Reach for this only when the deduped list
/// is itself the thing you want, or is iterated repeatedly.
List<A> uniqStrict<A>(Iterable<A> iterable) => _UniqIterable(iterable).toList();

/// Strict (non-lazy) [uniqBy] — see [uniqStrict] for the trade-off.
List<A> uniqByStrict<A, B>(B Function(A a) f, Iterable<A> iterable) =>
    _UniqByIterable(f, iterable).toList();

/// The first [count] elements of [iterable] whose [f]-key has not been seen
/// yet, as a list. A `null` key skips the element, so [f] both selects and
/// keys — the `filter_map` shape.
///
/// This is `filter(...).uniqBy(...).take(count)` written as one strict call,
/// and the *only* reason it exists is that a lazy stage cannot inline its
/// callback: the closure lives in an iterator field, which the AOT compiler
/// cannot see through. Here [f] is a parameter of a function small enough to
/// inline into the caller, so the compiler inlines the closure body with it.
/// Measured over 1,000,000 elements against the lazy spelling of the same
/// pipeline: 13.9 ms lazy, 11.2 ms here, 10.4 ms for a hand-written loop.
///
/// Prefer the lazy chain — it composes, and each step reads on its own. Reach
/// for this when the pipeline is hot and the profile says the callbacks are
/// the cost.
///
/// ```dart
/// // The three most recent errors, one per distinct message.
/// takeUniqBy(3, (l) => l.level == 'ERROR' ? l.message : null, logs);
/// ```
@pragma('vm:prefer-inline')
List<A> takeUniqBy<A, B extends Object>(
  int count,
  B? Function(A a) f,
  Iterable<A> iterable,
) {
  // The body is deliberately one loop over a `List`: a bigger one would stop
  // being inlined, and inlining is the whole point. Every other source shape
  // goes to the out-of-line walk below.
  if (count < 1 || iterable is! List<A>) {
    return _takeUniqByPulled(count, f, iterable);
  }
  final out = <A>[];
  final seen = <Object?>{};
  final end = iterable.length;
  for (var i = 0; i < end; i++) {
    final v = iterable[i];
    final k = f(v);
    if (k == null || !seen.add(k)) continue;
    out.add(v);
    if (out.length == count) break;
  }
  return out;
}

/// [takeUniqBy] over a source that is not a `List` — pulled through its
/// iterator, so the callback stays behind the same call boundary the lazy
/// chain has. Out of line to keep [takeUniqBy] itself inlinable.
List<A> _takeUniqByPulled<A, B extends Object>(
  int count,
  B? Function(A a) f,
  Iterable<A> iterable,
) {
  final out = <A>[];
  if (count < 1) return out;
  final seen = <Object?>{};
  for (final v in iterable) {
    final k = f(v);
    if (k == null || !seen.add(k)) continue;
    out.add(v);
    if (out.length == count) break;
  }
  return out;
}

/// Async counterpart of [uniqBy]. Uses then/bare pattern for sync keys.
///
/// A fused stage, so a chain that dedupes stays on the subscription drive
/// instead of dropping to the pull protocol — the seen-set lives on the
/// iterator, so only one `uniqBy` fuses into a run and a second starts a new
/// one. A [Concurrent] marker falls back to [_uniqByAsyncLegacy].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> uniqByAsync<A, B>(
  FutureOr<B> Function(A a) f,
  FxAsyncIterable<A> iterable,
) {
  final stage = FxUniqByStage((v) => f(v as A));
  if (iterable is FxFusedAsyncIterable<A> && iterable.uniqIndex < 0) {
    final source = iterable.source;
    final stages = iterable.stages;
    final legacy = iterable.legacy;
    return FxFusedAsyncIterable<A>(source, [
      ...stages,
      stage,
    ], () => _uniqByAsyncLegacy(f, legacy()));
  }
  return FxFusedAsyncIterable<A>(iterable, [
    stage,
  ], () => _uniqByAsyncLegacy(f, iterable));
}

FxAsyncIterable<A> _uniqByAsyncLegacy<A, B>(
  FutureOr<B> Function(A a) f,
  FxAsyncIterable<A> iterable,
) {
  // The pre-fusion layering, kept for the concurrent path: `filterAsync` over
  // a seen-set closure carries `uniqBy` through the concurrency machinery.
  return DelegateAsyncIterable(() {
    final seen = <B>{};
    return filterAsync((A a) {
      final key = f(a);
      if (key is Future<B>) {
        return key.then((k) => seen.add(k));
      }
      return seen.add(key);
    }, iterable).iterator;
  });
}

/// Async counterpart of [uniq].
///
/// The element is its own key, so the fused stage carries no key function at
/// all — one fewer call per element than `uniqByAsync(identity)`.
@pragma('vm:prefer-inline')
FxAsyncIterable<A> uniqAsync<A>(FxAsyncIterable<A> iterable) {
  const stage = FxUniqByStage(null);
  if (iterable is FxFusedAsyncIterable<A> && iterable.uniqIndex < 0) {
    final source = iterable.source;
    final stages = iterable.stages;
    final legacy = iterable.legacy;
    return FxFusedAsyncIterable<A>(source, [
      ...stages,
      stage,
    ], () => _uniqByAsyncLegacy((A a) => a, legacy()));
  }
  return FxFusedAsyncIterable<A>(iterable, [
    stage,
  ], () => _uniqByAsyncLegacy((A a) => a, iterable));
}

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
  FutureOr<B> Function(A a) f,
  FxAsyncIterable<A> iterable,
) {
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
  B Function(A a) f,
  Iterable<A> iterable1,
  Iterable<A> iterable2,
) => _SetOpIterable(f, iterable1, iterable2, false);

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
  B Function(A a) f,
  Iterable<A> iterable1,
  Iterable<A> iterable2,
) => _SetOpIterable(f, iterable1, iterable2, true);

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

  /// One loop: build [_source1]'s key set, then walk [_source2] by index when
  /// it is a `List`. A `toList` consumes everything anyway, so nothing is
  /// evaluated that the lazy path would have skipped, and [_f] still runs
  /// once per element of each source.
  @override
  List<A> toList({bool growable = true}) {
    final f = _f;
    final keep = _keep;
    final set = <B>{for (final a in _source1) f(a)};
    // `Set<Object?>`, not `Set<A>`: A is a runtime type argument here, so
    // every `add` on a `Set<A>` pays a covariant parameter check — once per
    // element that clears the membership test, which on an *intersection*
    // is nearly every element. Membership is `hashCode`/`==` either way, so
    // the dedup is unchanged. Same trade `_MapUniqIterable.toList` makes.
    final seen = <Object?>{};
    final result = <A>[];
    final source = _source2;
    if (source is List<A>) {
      final length = source.length;
      for (var i = 0; i < length; i++) {
        final a = source[i];
        if (set.contains(f(a)) == keep && seen.add(a)) result.add(a);
      }
    } else {
      for (final a in source) {
        if (set.contains(f(a)) == keep && seen.add(a)) result.add(a);
      }
    }
    return growable ? result : List<A>.from(result, growable: false);
  }
}

class _SetOpIterator<A, B> implements Iterator<A> {
  _SetOpIterator(this._f, this._source1, this._source2, this._keep);
  final B Function(A) _f;
  final Iterable<A> _source1;
  final Iterable<A> _source2;
  final bool _keep;
  Set<B>? _set; // iterable1's keys, materialized on the first pull
  Iterator<A>? _it;
  // A `List` [_source2] is walked by index instead, for the reason
  // [_FilterUniqByListIterator] gives: an `Iterator<A>` field turns every
  // `moveNext` into a megamorphic call. `size()` counts by pulling, so this
  // is the path a caller who only wants the size of a set operation takes.
  //
  // The names carry a `_setOp` prefix rather than the obvious `_list` / `_i` /
  // `_end` because the playground bundle concatenates every source file into
  // one library (see `list_range.dart`): a plain `_end` here makes another
  // file's nullable `_end` non-promotable, and that failure only shows up in
  // the merged build.
  List<A>? _setOpList;
  int _setOpI = 0;
  int _setOpEnd = 0;
  final Set<Object?> _seen = {}; // see _SetOpIterable.toList
  @override
  late A current;
  @override
  bool moveNext() {
    if (_set == null) {
      _set = {for (final a in _source1) _f(a)};
      final source = _source2;
      if (source is List<A>) {
        _setOpList = source;
        _setOpEnd = source.length;
      } else {
        _it = source.iterator;
      }
    }
    final set = _set!;
    final list = _setOpList;
    if (list != null) {
      var i = _setOpI;
      final end = _setOpEnd;
      while (i < end) {
        final a = list[i++];
        if (set.contains(_f(a)) == _keep && _seen.add(a)) {
          _setOpI = i;
          current = a;
          return true;
        }
      }
      _setOpI = i;
      return false;
    }
    final it = _it!;
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
        inner = uniqAsync(
          filterAsync(
            (A a) async => set!.contains(await f(a)) == keepWhenInSet,
            source,
          ),
        ).iterator;
      }
      return inner!.next(concurrent);
    });
  });
}

/// Async counterpart of [differenceBy].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> differenceByAsync<A, B>(
  FutureOr<B> Function(A a) f,
  FxAsyncIterable<A> iterable1,
  FxAsyncIterable<A> iterable2,
) => _setOpAsync(f, iterable1, iterable2, false);

/// Async counterpart of [difference].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> differenceAsync<A>(
  FxAsyncIterable<A> iterable1,
  FxAsyncIterable<A> iterable2,
) => differenceByAsync((A a) => a, iterable1, iterable2);

/// Async counterpart of [intersectionBy].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> intersectionByAsync<A, B>(
  FutureOr<B> Function(A a) f,
  FxAsyncIterable<A> iterable1,
  FxAsyncIterable<A> iterable2,
) => _setOpAsync(f, iterable1, iterable2, true);

/// Async counterpart of [intersection].
@pragma('vm:prefer-inline')
FxAsyncIterable<A> intersectionAsync<A>(
  FxAsyncIterable<A> iterable1,
  FxAsyncIterable<A> iterable2,
) => intersectionByAsync((A a) => a, iterable1, iterable2);
