import 'dart:async';

import 'async_iterable.dart';
import 'async_iterable.dart' as async_;
import 'lazy/combine.dart' as l;
import 'lazy/effect.dart' as l;
import 'lazy/filter.dart' as l;
import 'lazy/map.dart' as l;
import 'lazy/take_drop.dart' as l;
import 'lazy/zip.dart' as l;
import 'strict/access.dart' as s;
import 'strict/aggregate.dart' as s;
import 'strict/sequence_equal.dart' as s;

/// Wraps an [Iterable] (or anything convertible) in a lazy, chainable [Fx].
///
/// Port of FxTS `fx`. This chain is the Dart replacement for FxTS's curried
/// `pipe` pipelines, which cannot be typed in Dart.
///
/// The chain uses lazy evaluation throughout: fully composable, minimal overhead,
/// zero allocations for non-terminal operations.
///
/// ```dart
/// fx([1, 2, 3, 4, 5])
///     .map((a) => a + 10)
///     .filter((a) => a % 2 == 0)
///     .toList(); // [12, 14]
/// ```
// prefer-inline lets AOT escape analysis erase the wrapper allocation when a
// chain like `fx(w).average()` is built and consumed inside one expression.
@pragma('vm:prefer-inline')
Fx<T> fx<T>(Iterable<T> iterable) => Fx(iterable);

/// Wraps an [FxAsyncIterable] in a chainable [FxAsync].
@pragma('vm:prefer-inline')
FxAsync<T> fxAsync<T>(FxAsyncIterable<T> iterable) => FxAsync(iterable);

/// Wraps a [Stream] in a chainable [FxAsync].
@pragma('vm:prefer-inline')
FxAsync<T> fxStream<T>(Stream<T> stream) => FxAsync(fromStream(stream));

// --- getter entry points --------------------------------------------------
//
// `xs.fx` and `fx(xs)` are the same chain: `Fx` is an extension type, so the
// wrapper erases to `xs` itself and the getter is a static call returning its
// receiver. Measured on a 1M map+filter+sum, AOT, 20 interleaved rounds, the
// getter form is 1.002x the function form — noise, against a ~5% floor.
//
// Both spellings stay: the function is the FxTS-parity name and reads better
// when the type argument is written out, the getter reads better when the
// source is itself a call. Type arguments are available on the getter through
// an extension override — `FxEntry<num>(xs).fx` — since a getter cannot take
// them postfix.

/// `fx(iterable)` as a getter: `xs.fx.map(f).toList()`.
///
/// Chains off a call site without wrapping it in parentheses. Identical to
/// [fx] in every other way.
extension FxEntry<T> on Iterable<T> {
  /// This iterable as a chainable [Fx].
  @pragma('vm:prefer-inline')
  Fx<T> get fx => Fx(this);
}

/// `fxAsync(iterable)` as a getter: `it.fx.map(f).concurrent(4)`.
extension FxAsyncEntry<T> on FxAsyncIterable<T> {
  /// This async iterable as a chainable [FxAsync].
  @pragma('vm:prefer-inline')
  FxAsync<T> get fx => FxAsync(this);
}

/// `fxStream(stream)` as a getter: `stream.fx.filter(f).toList()`.
extension FxStreamEntry<T> on Stream<T> {
  /// This stream as a chainable [FxAsync].
  @pragma('vm:prefer-inline')
  FxAsync<T> get fx => FxAsync(fromStream(this));
}

/// Awaited entry for an iterable of futures: `futures.fxAsync.sum()`.
///
/// `futures.fx` would give an `Fx<Future<T>>` — a chain over the futures
/// themselves, not their values. This getter resolves them, so `T` is the
/// awaited type, and the chain can then run them with `concurrent(n)`.
extension FxFutureEntry<T> on Iterable<FutureOr<T>> {
  /// This iterable of futures as a chainable [FxAsync] of their values.
  @pragma('vm:prefer-inline')
  FxAsync<T> get fxAsync => FxAsync(async_.toAsync(this));
}

/// Lazy chainable iterable — the sync half of FxTS's `fx` chain.
///
/// [Fx] extends [Iterable], so the whole Dart iterable API is available
/// alongside the FxTS-named operators.
extension type Fx<T>(Iterable<T> _inner) implements Iterable<T> {
  // An EXTENSION TYPE, not a class, and that is a performance decision.
  //
  // As a class, `Fx<T>` was a real object carrying T in its runtime type
  // arguments, so every operator built inside a chain method was allocated
  // with a *runtime* type argument and AOT could not specialize its type
  // checks — the same effect 0.7.6 documented for async. Measured on
  // `dropWhile().head()` over 1M readings: 11.6ms as a class, 5.3ms as an
  // extension type, against 5.0ms for the hand-written loop.
  //
  // An extension type erases to its representation, so `_inner` IS the chain
  // at runtime: T is a compile-time constant at each call site, no wrapper is
  // allocated, and operators downstream see the real iterable rather than a
  // wrapper hiding it. `implements Iterable<T>` keeps the whole Dart iterable
  // API available; members not redeclared below go straight to _inner.

  /// Applies a user-defined [converter] to the whole chain.
  R to<R>(R Function(Fx<T> iterable) converter) => converter(this);

  // --- lazy operators -----------------------------------------------------

  Fx<R> map<R>(R Function(T a) toElement) {
    final mapped = l.map(toElement, _inner);
    return Fx(mapped);
  }

  /// [map] with the element's 0-based position — `zipWithIndex().map(...)`
  /// without the intermediate record.
  Fx<R> mapWithIndex<R>(R Function(T a, int index) f) =>
      Fx(l.mapWithIndex(f, _inner));

  /// Identical to [map]; intended for side effects by convention.
  Fx<R> mapEffect<R>(R Function(T a) f) => map(f);

  /// Maps each value through [f] and keeps only the non-null results —
  /// `map(f).compact()` as a single lazy stage. See the top-level
  /// `mapNotNull`.
  Fx<R> mapNotNull<R extends Object>(R? Function(T a) f) =>
      Fx(l.mapNotNull(f, _inner));

  /// Maps each value through [f], replacing any error [f] throws with what
  /// [onError] returns for it. Stays on the sync chain — there is no delay
  /// to await, unlike [mapRetry]. A raise signal is rethrown, never
  /// recovered; see the top-level `mapCatching`.
  Fx<R> mapCatching<R>(
    R Function(T a) f,
    R Function(Object error, StackTrace stackTrace) onError,
  ) => Fx(l.mapCatching(f, onError, _inner));

  /// See top-level `flatMap`; same contract as [Iterable.expand].
  Fx<R> flatMap<R>(Iterable<R> Function(T a) f) {
    final flatMapped = l.flatMap(f, _inner);
    return Fx(flatMapped);
  }

  /// [flatMap] with the source element's 0-based position.
  Fx<R> flatMapWithIndex<R>(Iterable<R> Function(T a, int index) f) =>
      Fx(l.flatMapWithIndex(f, _inner));

  Fx<R> expand<R>(Iterable<R> Function(T element) toElements) =>
      flatMap(toElements);

  /// Flattens nested iterables [depth] levels. Untyped — see top-level `flat`.
  Fx<dynamic> flat([int depth = 1]) => Fx(l.flat(_inner, depth));

  /// Dart-idiomatic alias of [flat].
  Fx<dynamic> flattened([int depth = 1]) => flat(depth);

  /// All elements [f] returns true for.
  Fx<T> filter(bool Function(T a) f) {
    final filtered = l.filter(f, _inner);
    return Fx(filtered);
  }

  /// [filter] with the element's 0-based position in the input — dropped
  /// elements still advance the count.
  Fx<T> filterWithIndex(bool Function(T a, int index) f) =>
      Fx(l.filterWithIndex(f, _inner));

  Fx<T> where(bool Function(T element) test) => filter(test);

  /// The opposite of [filter].
  Fx<T> reject(bool Function(T a) f) => Fx(l.reject(f, _inner));

  /// Dart-idiomatic alias of [reject].
  Fx<T> whereNot(bool Function(T a) f) => reject(f);

  Fx<T> take(int count) {
    final taken = l.take(count, _inner);
    return Fx(taken);
  }

  /// The last [count] elements.
  Fx<T> takeRight(int count) => Fx(l.takeRight(count, _inner));

  /// Dart-idiomatic alias of [takeRight].
  Fx<T> takeLast(int count) => takeRight(count);

  Fx<T> takeWhile(bool Function(T value) test) => Fx(l.takeWhile(test, _inner));

  /// The longest trailing run of values [f] holds for, in source order.
  Fx<T> takeWhileRight(bool Function(T a) f) => Fx(l.takeWhileRight(f, _inner));

  /// Yields values until [f] matches, including the matching element.
  Fx<T> takeUntilInclusive(bool Function(T a) f) =>
      Fx(l.takeUntilInclusive(f, _inner));

  /// Deprecated spelling of [takeUntilInclusive].
  @Deprecated('Use takeUntilInclusive instead')
  Fx<T> takeUntil(bool Function(T a) f) => takeUntilInclusive(f);

  /// Skips the first [count] values.
  Fx<T> drop(int count) => Fx(l.drop(count, _inner));

  Fx<T> skip(int count) => drop(count);

  /// Drops the last [count] values.
  Fx<T> dropRight(int count) => Fx(l.dropRight(count, _inner));

  /// Drops leading values while [f] holds, then yields the rest.
  Fx<T> dropWhile(bool Function(T a) f) => Fx(l.dropWhile(f, _inner));

  /// Drops the longest trailing run of values [f] holds for.
  Fx<T> dropWhileRight(bool Function(T a) f) => Fx(l.dropWhileRight(f, _inner));

  Fx<T> skipWhile(bool Function(T value) test) => dropWhile(test);

  /// Skips values until [f] matches (dropping the match), yields the rest.
  Fx<T> dropUntil(bool Function(T a) f) => Fx(l.dropUntil(f, _inner));

  /// The half-open index range `[start, end)` (to the end when [end] is null).
  Fx<T> slice(int start, [int? end]) => Fx(l.slice(start, _inner, end));

  /// Groups consecutive values into lists of up to [size].
  Fx<List<T>> chunk(int size) => Fx(l.chunk(size, _inner));

  /// Sliding windows of [size] values, each starting [step] values after
  /// the previous; [partial] keeps the shorter trailing windows.
  Fx<List<T>> windowed(int size, {int step = 1, bool partial = false}) =>
      Fx(l.windowed(size, _inner, step: step, partial: partial));

  /// Pairs each value with its successor.
  Fx<(T, T)> pairwise() => Fx(l.pairwise(_inner));

  /// Applies [f] to each value without changing it.
  Fx<T> peek(void Function(T a) f) => Fx(l.peek(f, _inner));

  /// Distinct values, keeping the first occurrence of each.
  Fx<T> uniq() => Fx(l.uniq(_inner));

  /// Dart-idiomatic alias of [uniq].
  Fx<T> distinct() => uniq();

  /// Distinct by the key [f] returns, keeping the first of each key.
  Fx<T> uniqBy<B>(B Function(T a) f) => Fx(l.uniqBy(f, _inner));

  /// Dart-idiomatic alias of [uniqBy].
  Fx<T> distinctBy<B>(B Function(T a) f) => uniqBy(f);

  /// Strict [uniq]: dedups now, into a `List`, instead of lazily on iteration.
  ///
  /// The chain continues, so the result is still an [Fx] — but everything
  /// upstream has already run, and a downstream `take`/`first` can no longer
  /// cut it short. See [l.uniqStrict]; prefer plain [uniq] unless the deduped
  /// list is the goal or the chain is iterated more than once.
  Fx<T> uniqStrict() => Fx(l.uniqStrict(_inner));

  /// Strict [uniqBy] — see [uniqStrict] for the trade-off.
  Fx<T> uniqByStrict<B>(B Function(T a) f) => Fx(l.uniqByStrict(f, _inner));

  /// The first [count] elements whose [f]-key is new, as a list; a `null` key
  /// skips the element. `filter().uniqBy().take()` as one strict, inlinable
  /// call — see the top-level `takeUniqBy` for when that is worth it.
  @pragma('vm:prefer-inline')
  List<T> takeUniqBy<B extends Object>(int count, B? Function(T a) f) =>
      l.takeUniqBy(count, f, _inner);

  /// Drops values equal to their predecessor, keeping the first of each run.
  Fx<T> uniqAdjacent() => Fx(l.uniqAdjacent(_inner));

  /// Drops values whose [f]-key equals the previous value's key.
  Fx<T> uniqAdjacentBy<B>(B Function(T a) f) => Fx(l.uniqAdjacentBy(f, _inner));

  /// Switches to [fallback]'s values when this chain turns out to be empty.
  Fx<T> ifEmpty(Iterable<T> Function() fallback) =>
      Fx(l.ifEmpty(fallback, _inner));

  /// Yields the single [value] when this chain turns out to be empty.
  Fx<T> defaultIfEmpty(T value) => Fx(l.defaultIfEmpty(value, _inner));

  /// Runs two folds over a single pass of this chain — one iteration, no
  /// buffering.
  (R1, R2) tee<R1, R2>(s.Fold<T, R1> first, s.Fold<T, R2> second) =>
      s.tee(_inner, first, second);

  /// Three-fold [tee].
  (R1, R2, R3) tee3<R1, R2, R3>(
    s.Fold<T, R1> first,
    s.Fold<T, R2> second,
    s.Fold<T, R3> third,
  ) => s.tee3(_inner, first, second, third);

  /// Pairs each value with the value at the same position in [other],
  /// stopping at the shorter side.
  Fx<(T, U)> zip<U>(Iterable<U> other) => Fx(l.zip(_inner, other));

  /// Three-way [zip], stopping at the shortest side.
  ///
  /// The same shape as `zip(a).zip(b)` without the nested record — a
  /// three-element sliding window is `zip3(drop(1), drop(2))`.
  Fx<(T, U, V)> zip3<U, V>(Iterable<U> other1, Iterable<V> other2) =>
      Fx(l.zip3(_inner, other1, other2));

  /// Pairs each value with its index.
  Fx<(int, T)> zipWithIndex() => Fx(l.zipWithIndex(_inner));

  /// Yields the chain, then [a].
  Fx<T> append(T a) => Fx(l.append(a, _inner));

  /// Yields [a], then the chain.
  Fx<T> prepend(T a) => Fx(l.prepend(a, _inner));

  /// Yields this chain followed by [other].
  Fx<T> concat(Iterable<T> other) => Fx(l.concat(_inner, other));

  /// Emits [seed], then each running accumulation as [f] folds in each value.
  Fx<B> scan<B>(B Function(B acc, T a) f, B seed) =>
      Fx(l.scan(f, seed, _inner));

  /// Emits each running accumulation, n values for n values — [scan]
  /// without [seed] in the output. See the top-level `mapAccum`.
  Fx<B> mapAccum<B>(B Function(B acc, T a) f, B seed) =>
      Fx(l.mapAccum(f, seed, _inner));

  /// The values in reverse order (materializes the source).
  Fx<T> reverse() => Fx(l.reverse(_inner));

  /// Repeats the source endlessly.
  Fx<T> cycle() => Fx(l.cycle(_inner));

  /// A new chain sorted by the comparator [f].
  Fx<T> sort(int Function(T a, T b) f) => Fx(s.sort(f, _inner));

  /// A new chain sorted by the key [f] returns for each value.
  Fx<T> sortBy(Object? Function(T a) f) => Fx(s.sortBy(f, _inner));

  /// A new chain sorted by the key [f], descending — any comparable key,
  /// not just the numeric ones `sortBy((a) => -key)` can negate.
  Fx<T> sortByDesc(Object? Function(T a) f) => Fx(s.sortByDesc(f, _inner));

  /// The [k] values with the largest keys [f], largest first — one boundary
  /// pass, not a whole sort. Ties keep input order; see the top-level
  /// `topBy`.
  ///
  /// Inlined for the reason given on [minBy]: the pragma has to be on this
  /// hop *and* on the top-level function, or the caller's key extractor
  /// stops being visible inside the loop.
  @pragma('vm:prefer-inline')
  Fx<T> topBy(int k, Object? Function(T a) f) => Fx(s.topBy(k, f, _inner));

  /// The [k] values with the smallest keys [f], smallest first.
  @pragma('vm:prefer-inline')
  Fx<T> bottomBy(int k, Object? Function(T a) f) =>
      Fx(s.bottomBy(k, f, _inner));

  /// Lazily pairs each value with the result of [f] — the value stays
  /// beside what was derived from it.
  Fx<(T, R)> attach<R>(R Function(T a) f) => Fx(l.attach(f, _inner));

  /// Groups values into `(key, items)` records, in first-seen key order —
  /// the chainable view of [groupBy] (no `Map.entries` re-entry).
  @pragma('vm:prefer-inline')
  Fx<({K key, List<T> items})> groupedBy<K>(K Function(T a) f) =>
      Fx(s.groupedBy(f, _inner));

  /// Values of this chain whose [f]-keys do not occur in [other], deduped.
  Fx<T> differenceBy<B>(B Function(T a) f, Iterable<T> other) =>
      Fx(l.differenceBy(f, other, _inner));

  /// Values of this chain that do not occur in [other].
  Fx<T> difference(Iterable<T> other) => Fx(l.difference(other, _inner));

  /// Values of this chain whose [f]-keys also occur in [other], deduped.
  Fx<T> intersectionBy<B>(B Function(T a) f, Iterable<T> other) =>
      Fx(l.intersectionBy(f, other, _inner));

  /// Values of this chain that also occur in [other].
  Fx<T> intersection(Iterable<T> other) => Fx(l.intersection(other, _inner));

  // --- conversion ---------------------------------------------------------

  /// Switches to the async chain. Values stay plain; use the top-level
  /// `toAsync` for an `Iterable<Future<T>>`.
  @pragma('vm:prefer-inline')
  FxAsync<T> toAsync() => FxAsync(async_.toAsync(_inner));

  /// Switches to the async chain and maps [f] with up to [concurrency]
  /// values in flight at once, in source order — the pre-combined form of
  /// `toAsync().map(f).concurrent(concurrency)`.
  @pragma('vm:prefer-inline')
  FxAsync<R> mapConcurrent<R>(int concurrency, FutureOr<R> Function(T a) f) =>
      FxAsync(l.mapConcurrent(concurrency, f, _inner));

  /// Switches to the async chain and maps [f], retrying each call up to
  /// [attempts] times (with optional [delay] backoff) before the error
  /// propagates.
  @pragma('vm:prefer-inline')
  FxAsync<R> mapRetry<R>(
    int attempts,
    FutureOr<R> Function(T a) f, {
    Duration Function(int failed)? delay,
  }) => FxAsync(
    l.mapRetryAsync(attempts, f, async_.toAsync(_inner), delay: delay),
  );

  // --- terminal operators -------------------------------------------------

  /// Materializes the pipeline into a [List] (Dart's `Iterable.toList`).
  List<T> toList({bool growable = true}) => _inner.toList(growable: growable);

  /// Runs [f] for every value, forcing the pipeline.
  @pragma('vm:prefer-inline')
  void each(void Function(T a) f) => s.each(f, _inner);

  /// [Iterable.fold] with the element's 0-based position.
  @pragma('vm:prefer-inline')
  Acc foldWithIndex<Acc>(Acc seed, Acc Function(Acc acc, T a, int index) f) =>
      s.foldWithIndex(seed, f, _inner);

  /// Folds from the last value to the first — see top-level `foldRight`.
  Acc foldRight<Acc>(Acc seed, Acc Function(Acc acc, T a) f) =>
      s.foldRight(seed, f, _inner);

  /// [foldRight] with each value's 0-based position in the source.
  Acc foldRightWithIndex<Acc>(
    Acc seed,
    Acc Function(Acc acc, T a, int index) f,
  ) => s.foldRightWithIndex(seed, f, _inner);

  /// Consumes up to [n] values (all when omitted), forcing side effects.
  void consume([int? n]) => s.consume(_inner, n);

  /// Groups values into lists keyed by [f].
  @pragma('vm:prefer-inline')
  Map<K, List<T>> groupBy<K>(K Function(T a) f) => s.groupBy(f, _inner);

  /// Maps the key [f] returns to its value (later values win on collisions).
  @pragma('vm:prefer-inline')
  Map<K, T> indexBy<K>(K Function(T a) f) => s.indexBy(f, _inner);

  /// Counts how many values fall under each key [f] returns.
  @pragma('vm:prefer-inline')
  Map<K, int> countBy<K>(K Function(T a) f) => s.countBy(f, _inner);

  /// Folds the values under each [key] in one pass, without materializing
  /// the groups — the aggregate-only counterpart of [groupBy].
  @pragma('vm:prefer-inline')
  Map<K, Acc> foldBy<K, Acc>(
    K Function(T a) key,
    Acc seed,
    Acc Function(Acc acc, T a) f,
  ) => s.foldBy(key, seed, f, _inner);

  /// [foldBy] where a `null` key skips the element — `filter().foldBy()` as
  /// one strict, inlinable call. See the top-level `foldByOrSkip` for when
  /// that is worth reaching for.
  @pragma('vm:prefer-inline')
  Map<K, Acc> foldByOrSkip<K extends Object, Acc>(
    K? Function(T a) key,
    Acc seed,
    Acc Function(Acc acc, T a) f,
  ) => s.foldByOrSkip(key, seed, f, _inner);

  /// Counts the values [f] holds for — `filter` + `size` in one walk.
  @pragma('vm:prefer-inline')
  int countWhere(bool Function(T a) f) => s.countWhere(f, _inner);

  /// Whether [f] holds for at least one value.
  @pragma('vm:prefer-inline')
  bool some(bool Function(T a) f) => s.some(f, _inner);

  /// Whether [f] holds for no value — a universal, rather than the negated
  /// existential `!some(f)`.
  @pragma('vm:prefer-inline')
  bool none(bool Function(T a) f) => s.none(f, _inner);

  /// The first value [f] matches, or `null`.
  T? find(bool Function(T a) f) => s.find(f, _inner);

  /// Dart-idiomatic alias of [find] (cf. `package:collection`).
  T? firstWhereOrNull(bool Function(T a) f) => find(f);

  /// The first non-null result of [f], or `null` when [f] returns `null` for
  /// every value — the projection [find] cannot hand back.
  @pragma('vm:prefer-inline')
  R? firstNotNullOf<R extends Object>(R? Function(T a) f) =>
      s.firstNotNullOf(f, _inner);

  /// The index of the first value [f] matches, or -1.
  int findIndex(bool Function(T a) f) => s.findIndex(f, _inner);

  /// Dart-idiomatic alias of [findIndex] (cf. `List.indexWhere`).
  int indexWhere(bool Function(T a) f) => findIndex(f);

  /// The first value, or `null` if empty.
  T? head() => s.head(_inner);

  /// The value with the smallest key [f], or `null` if empty.
  ///
  /// Inlined so the chain method does not sit between the caller's closure
  /// and the loop that runs it — see the note on the top-level `minBy`.
  @pragma('vm:prefer-inline')
  T? minBy(Object? Function(T a) f) => s.minBy(f, _inner);

  /// The value with the largest key [f], or `null` if empty.
  @pragma('vm:prefer-inline')
  T? maxBy(Object? Function(T a) f) => s.maxBy(f, _inner);

  /// The sum of [f] over every value.
  num sumBy(num Function(T a) f) => s.sumBy(f, _inner);

  /// The product of [f] over every value; `1` when empty.
  num productBy(num Function(T a) f) => s.productBy(f, _inner);

  /// The mean of [f] over every value.
  double averageBy(num Function(T a) f) => s.averageBy(f, _inner);

  /// Splits into `(matches, non-matches)` by [f].
  @pragma('vm:prefer-inline')
  (List<T>, List<T>) partition(bool Function(T a) f) => s.partition(f, _inner);

  /// The number of values.
  int size() => s.size(_inner);

  // --- Phase 1: Access Operators ---

  /// The first element, or null if empty.
  T? get first => s.head(_inner);

  /// The last element, or null if empty.
  T? get last => s.last(_inner);

  /// The number of elements.
  ///
  /// O(1) for a `List` or `Set` source, O(n) for anything else: a general
  /// [Iterable] exposes no cheaper count, so this walks the chain. Unlike
  /// [isEmpty] it therefore does not terminate on an unbounded chain — that
  /// is inherent to counting, not a defect to fix.
  int get length => s.size(_inner);

  /// True if there are no elements.
  ///
  /// O(1): asks the source for its first element and stops. Through 0.8.5
  /// this was `size() == 0`, which walked the whole chain and so never
  /// returned for an unbounded one — `fx(cycle([1, 2])).isEmpty` hung.
  bool get isEmpty => _inner.isEmpty;

  /// True if there is at least one element. O(1), like [isEmpty].
  bool get isNotEmpty => _inner.isNotEmpty;

  /// True when this chain and [other] hold the same values in the same
  /// order. Optional [eq] replaces `==`. After Rx's `sequenceEqual`.
  bool sequenceEqual(Iterable<T> other, [bool Function(T, T)? eq]) =>
      s.sequenceEqual(_inner, other, eq);

  // --- Phase 1: Aggregation Operators ---

  /// The element at [index], or null if out of bounds.
  T? elementAt(int index) {
    try {
      return _inner.elementAt(index);
    } catch (_) {
      return null;
    }
  }

  /// Folds every value with [combine], starting from [initial].
  @pragma('vm:prefer-inline')
  R fold<R>(R initial, R Function(R acc, T a) combine) =>
      s.fold(initial, combine, _inner);

  /// Folds every value with [combine], starting from the first element.
  /// Throws if empty.
  @pragma('vm:prefer-inline')
  T reduce(T Function(T acc, T a) combine) => s.reduce(combine, _inner);

  /// The first element matching [test], or call [orElse] if none match.
  T? firstWhere(bool Function(T) test, {T? Function()? orElse}) {
    final found = s.find(test, _inner);
    return found ?? (orElse != null ? orElse() : null);
  }

  /// The last element matching [test], or call [orElse] if none match.
  T? lastWhere(bool Function(T) test, {T? Function()? orElse}) {
    T? result;
    for (final item in _inner) {
      if (test(item)) result = item;
    }
    return result ?? (orElse != null ? orElse() : null);
  }

  // --- Phase 1: Predicates & String ---

  /// True if [test] holds for at least one element.
  /// Stops at first true (early exit).
  @pragma('vm:prefer-inline')
  bool any(bool Function(T) test) => s.some(test, _inner);

  /// True if [test] holds for every element.
  /// Stops at first false (early exit).
  @pragma('vm:prefer-inline')
  bool all(bool Function(T) test) => s.every(test, _inner);

  /// Joins all elements into a string separated by [separator].
  ///
  /// [separator] is optional, matching `Iterable.join`. It has to be spelled
  /// out here: redeclaring a member on an extension type *replaces* the one
  /// from the implemented interface rather than overriding it, so a required
  /// parameter would make `fx(xs).join()` stop compiling.
  String join([String separator = '']) => _inner.join(separator);

  /// The maximum element using [compare] function.
  /// If [compare] is not provided, assumes T is `Comparable<T>`.
  /// Throws if empty or elements are not comparable.
  ///
  /// The chain spellings throw a [StateError] on empty input; the top-level
  /// `max(xs)` returns `double.negativeInfinity` there (`min(xs)` returns
  /// `double.infinity`). That difference is deliberate and it is not going
  /// away: the top-level pair is a `num` fold whose identity element *is* the
  /// infinity, and it is what FxTS's `max` returns, while a chain terminal
  /// over an arbitrary `T` has no identity to return and can only throw. So
  /// there are three spellings and two contracts:
  ///
  /// ```dart
  /// max(<num>[]);              // -Infinity
  /// fx(<num>[]).max();         // StateError  (this member)
  /// FxNum(fx(<num>[])).max();  // StateError  (see [FxNum.max])
  /// ```
  T max([int Function(T a, T b)? compare]) {
    final compareFn =
        compare ?? (a, b) => (a as dynamic).compareTo(b as dynamic) as int;
    // `reduce`, not `first` + `skip(1)`: the latter iterates the chain twice,
    // which on a `sync*` source with a side effect runs it twice and on an
    // expensive one pays for it twice — n + 1 pulls where n do. `reduce`
    // throws the same [StateError] on empty that `first` did.
    return _inner.reduce(
      (result, item) => compareFn(item, result) > 0 ? item : result,
    );
  }

  /// The minimum element using [compare] function.
  /// If [compare] is not provided, assumes T is `Comparable<T>`.
  /// Throws if empty or elements are not comparable.
  ///
  /// On empty input this throws while the top-level `min(xs)` returns
  /// `double.infinity` — see [max] for why the two contracts differ.
  T min([int Function(T a, T b)? compare]) {
    final compareFn =
        compare ?? (a, b) => (a as dynamic).compareTo(b as dynamic) as int;
    // Single pass — see [max].
    return _inner.reduce(
      (result, item) => compareFn(item, result) < 0 ? item : result,
    );
  }
}

/// Numeric terminals for [Fx] chains (generic covariance makes these apply
/// to `Fx<int>` and `Fx<double>` as well).
///
/// [min] and [max] are reachable only through explicit extension
/// application — `FxNum(fx(xs)).min()`. On a plain `fx(xs).min()` receiver
/// the [Fx.min] *member* wins: a member redeclared on an extension type
/// shadows every extension on that type. Both chain spellings are supported,
/// and they now agree on empty input — with each other, but deliberately not
/// with the top-level `min`/`max`, which return an infinity there. [Fx.max]
/// spells the three-way comparison out.
extension FxNum on Fx<num> {
  /// The sum of every value.
  @pragma('vm:prefer-inline')
  num sum() => s.sum(_inner);

  /// The arithmetic mean of every value.
  @pragma('vm:prefer-inline')
  double average() => s.average(_inner);

  /// The product of every value; `1` when empty.
  @pragma('vm:prefer-inline')
  num product() => s.product(_inner);

  /// The smallest value under `num.compareTo` ordering.
  ///
  /// Throws a [StateError] on an empty chain, matching the [Fx.min] member
  /// this extension sits behind. Through 0.8.5 it returned `double.infinity`
  /// there instead, so the two spellings disagreed.
  @pragma('vm:prefer-inline')
  num min() => _inner.reduce(
    (result, item) => item.compareTo(result) < 0 ? item : result,
  );

  /// The largest value under `num.compareTo` ordering.
  ///
  /// Throws a [StateError] on an empty chain, matching the [Fx.max] member —
  /// see [min].
  @pragma('vm:prefer-inline')
  num max() => _inner.reduce(
    (result, item) => item.compareTo(result) > 0 ? item : result,
  );
}

/// Pair terminals for [Fx] chains over two-element records — the shape
/// `zip`, `attach` and `pairwise` produce.
extension FxPair<A, B> on Fx<(A, B)> {
  /// Splits the pairs into `(lefts, rights)` in one pass — the inverse of
  /// `zip`. See the top-level `unzip`.
  (List<A>, List<B>) unzip() => l.unzip(_inner);
}

/// Async chainable iterable — the async half of FxTS's `fx` chain.
class FxAsync<T> implements FxAsyncIterable<T> {
  final FxAsyncIterable<T> _inner;

  /// Wraps [_inner] without consuming it; the chain stays lazy.
  const FxAsync(this._inner);

  @override
  FxAsyncIterator<T> get iterator => _inner.iterator;

  /// Applies a user-defined [converter] to the whole chain.
  R to<R>(R Function(FxAsync<T> iterable) converter) => converter(this);

  // --- lazy operators -----------------------------------------------------

  /// Lazily transforms each value with [f] (which may be async).
  @pragma('vm:prefer-inline')
  FxAsync<R> map<R>(FutureOr<R> Function(T a) f) =>
      FxAsync(l.mapAsync(f, _inner));

  /// [map] with the value's 0-based position in source order.
  @pragma('vm:prefer-inline')
  FxAsync<R> mapWithIndex<R>(FutureOr<R> Function(T a, int index) f) =>
      FxAsync(l.mapWithIndexAsync(f, _inner));

  /// Identical to [map]; intended for side effects by convention.
  @pragma('vm:prefer-inline')
  FxAsync<R> mapEffect<R>(FutureOr<R> Function(T a) f) => map(f);

  /// Maps each value through [f] and keeps only the non-null results. See
  /// the top-level `mapNotNullAsync`.
  @pragma('vm:prefer-inline')
  FxAsync<R> mapNotNull<R extends Object>(FutureOr<R?> Function(T a) f) =>
      FxAsync(l.mapNotNullAsync(f, _inner));

  /// Maps each value through [f], replacing any error [f] throws with what
  /// [onError] returns for it. A raise signal is rethrown, never recovered;
  /// see the top-level `mapCatchingAsync`.
  @pragma('vm:prefer-inline')
  FxAsync<R> mapCatching<R>(
    FutureOr<R> Function(T a) f,
    FutureOr<R> Function(Object error, StackTrace stackTrace) onError,
  ) => FxAsync(l.mapCatchingAsync(f, onError, _inner));

  /// Maps each value to an iterable via [f] and flattens the results.
  @pragma('vm:prefer-inline')
  FxAsync<R> flatMap<R>(FutureOr<Iterable<R>> Function(T a) f) =>
      FxAsync(l.flatMapAsync(f, _inner));

  /// [flatMap] with the source value's 0-based position.
  @pragma('vm:prefer-inline')
  FxAsync<R> flatMapWithIndex<R>(
    FutureOr<Iterable<R>> Function(T a, int index) f,
  ) => FxAsync(l.flatMapWithIndexAsync(f, _inner));

  /// Flattens nested iterables [depth] levels.
  @pragma('vm:prefer-inline')
  FxAsync<dynamic> flat([int depth = 1]) => FxAsync(l.flatAsync(_inner, depth));

  /// All values [f] returns true for ([f] may be async).
  @pragma('vm:prefer-inline')
  FxAsync<T> filter(FutureOr<bool> Function(T a) f) =>
      FxAsync(l.filterAsync(f, _inner));

  /// [filter] with the value's 0-based position in the input — dropped
  /// values still advance the count.
  @pragma('vm:prefer-inline')
  FxAsync<T> filterWithIndex(FutureOr<bool> Function(T a, int index) f) =>
      FxAsync(l.filterWithIndexAsync(f, _inner));

  /// The opposite of [filter].
  @pragma('vm:prefer-inline')
  FxAsync<T> reject(FutureOr<bool> Function(T a) f) =>
      FxAsync(l.rejectAsync(f, _inner));

  /// The first [count] values.
  @pragma('vm:prefer-inline')
  FxAsync<T> take(int count) => FxAsync(l.takeAsync(count, _inner));

  /// The last [count] values.
  @pragma('vm:prefer-inline')
  FxAsync<T> takeRight(int count) => FxAsync(l.takeRightAsync(count, _inner));

  /// Leading values while [f] holds.
  @pragma('vm:prefer-inline')
  FxAsync<T> takeWhile(FutureOr<bool> Function(T a) f) =>
      FxAsync(l.takeWhileAsync(f, _inner));

  /// The longest trailing run of values [f] holds for, in source order.
  /// [f] is sync here — a suffix is only known once the source has ended.
  @pragma('vm:prefer-inline')
  FxAsync<T> takeWhileRight(bool Function(T a) f) =>
      FxAsync(l.takeWhileRightAsync(f, _inner));

  /// Yields values until [f] matches, including the matching value.
  @pragma('vm:prefer-inline')
  FxAsync<T> takeUntilInclusive(FutureOr<bool> Function(T a) f) =>
      FxAsync(l.takeUntilInclusiveAsync(f, _inner));

  /// Deprecated spelling of [takeUntilInclusive].
  @Deprecated('Use takeUntilInclusive instead')
  @pragma('vm:prefer-inline')
  FxAsync<T> takeUntil(FutureOr<bool> Function(T a) f) => takeUntilInclusive(f);

  /// Skips the first [count] values.
  @pragma('vm:prefer-inline')
  FxAsync<T> drop(int count) => FxAsync(l.dropAsync(count, _inner));

  /// Drops the last [count] values.
  @pragma('vm:prefer-inline')
  FxAsync<T> dropRight(int count) => FxAsync(l.dropRightAsync(count, _inner));

  /// Drops leading values while [f] holds, then yields the rest.
  @pragma('vm:prefer-inline')
  FxAsync<T> dropWhile(FutureOr<bool> Function(T a) f) =>
      FxAsync(l.dropWhileAsync(f, _inner));

  /// Drops the longest trailing run of values [f] holds for. [f] is sync
  /// here — a suffix is only known once the source has ended.
  @pragma('vm:prefer-inline')
  FxAsync<T> dropWhileRight(bool Function(T a) f) =>
      FxAsync(l.dropWhileRightAsync(f, _inner));

  /// Skips values until [f] matches (dropping the match), yields the rest.
  @pragma('vm:prefer-inline')
  FxAsync<T> dropUntil(FutureOr<bool> Function(T a) f) =>
      FxAsync(l.dropUntilAsync(f, _inner));

  /// The half-open index range `[start, end)` (to the end when [end] is null).
  @pragma('vm:prefer-inline')
  FxAsync<T> slice(int start, [int? end]) =>
      FxAsync(l.sliceAsync(start, _inner, end));

  /// Groups consecutive values into lists of up to [size].
  @pragma('vm:prefer-inline')
  FxAsync<List<T>> chunk(int size) => FxAsync(l.chunkAsync(size, _inner));

  /// Sliding windows of [size] values, each starting [step] values after
  /// the previous; [partial] keeps the shorter trailing windows.
  @pragma('vm:prefer-inline')
  FxAsync<List<T>> windowed(int size, {int step = 1, bool partial = false}) =>
      FxAsync(l.windowedAsync(size, _inner, step: step, partial: partial));

  /// Pairs each value with its successor.
  @pragma('vm:prefer-inline')
  FxAsync<(T, T)> pairwise() => FxAsync(l.pairwiseAsync(_inner));

  /// Applies [f] to each value without changing it.
  @pragma('vm:prefer-inline')
  FxAsync<T> peek(FutureOr<void> Function(T a) f) =>
      FxAsync(l.peekAsync(f, _inner));

  /// Distinct values, keeping the first occurrence of each.
  @pragma('vm:prefer-inline')
  FxAsync<T> uniq() => FxAsync(l.uniqAsync(_inner));

  /// Distinct by the key [f] returns, keeping the first of each key.
  @pragma('vm:prefer-inline')
  FxAsync<T> uniqBy<B>(FutureOr<B> Function(T a) f) =>
      FxAsync(l.uniqByAsync(f, _inner));

  /// Drops values equal to their predecessor, keeping the first of each run.
  @pragma('vm:prefer-inline')
  FxAsync<T> uniqAdjacent() => FxAsync(l.uniqAdjacentAsync(_inner));

  /// Drops values whose [f]-key equals the previous value's key.
  @pragma('vm:prefer-inline')
  FxAsync<T> uniqAdjacentBy<B>(FutureOr<B> Function(T a) f) =>
      FxAsync(l.uniqAdjacentByAsync(f, _inner));

  /// Switches to [fallback]'s values when this chain turns out to be empty.
  @pragma('vm:prefer-inline')
  FxAsync<T> ifEmpty(FxAsyncIterable<T> Function() fallback) =>
      FxAsync(l.ifEmptyAsync(fallback, _inner));

  /// Yields the single [value] when this chain turns out to be empty.
  @pragma('vm:prefer-inline')
  FxAsync<T> defaultIfEmpty(FutureOr<T> value) =>
      FxAsync(l.defaultIfEmptyAsync(value, _inner));

  /// Runs two folds over a single pass of this chain — one iteration, no
  /// buffering.
  @pragma('vm:prefer-inline')
  Future<(R1, R2)> tee<R1, R2>(
    s.AsyncFold<T, R1> first,
    s.AsyncFold<T, R2> second,
  ) => s.teeAsync(_inner, first, second);

  /// Maps [f], retrying each call up to [attempts] times (with optional
  /// [delay] backoff) before the error propagates. Retries compose with
  /// [concurrent]: each in-flight value retries independently.
  @pragma('vm:prefer-inline')
  FxAsync<R> mapRetry<R>(
    int attempts,
    FutureOr<R> Function(T a) f, {
    Duration Function(int failed)? delay,
  }) => FxAsync(l.mapRetryAsync(attempts, f, _inner, delay: delay));

  /// Fails a pull with a [TimeoutException] when the upstream takes longer
  /// than [limit] to produce it (per pull, not whole-pipeline).
  @pragma('vm:prefer-inline')
  FxAsync<T> timeout(Duration limit) => FxAsync(l.timeoutAsync(limit, _inner));

  /// Pairs each value with the value at the same position in [other],
  /// stopping at the shorter side.
  @pragma('vm:prefer-inline')
  FxAsync<(T, U)> zip<U>(FxAsyncIterable<U> other) =>
      FxAsync(l.zipAsync(_inner, other));

  /// Three-way [zip], stopping at the shortest side.
  @pragma('vm:prefer-inline')
  FxAsync<(T, U, V)> zip3<U, V>(
    FxAsyncIterable<U> other1,
    FxAsyncIterable<V> other2,
  ) => FxAsync(l.zip3Async(_inner, other1, other2));

  /// Pairs each value with its index.
  @pragma('vm:prefer-inline')
  FxAsync<(int, T)> zipWithIndex() => FxAsync(l.zipWithIndexAsync(_inner));

  /// Yields the chain, then [a].
  @pragma('vm:prefer-inline')
  FxAsync<T> append(FutureOr<T> a) => FxAsync(l.appendAsync(a, _inner));

  /// Yields [a], then the chain.
  @pragma('vm:prefer-inline')
  FxAsync<T> prepend(FutureOr<T> a) => FxAsync(l.prependAsync(a, _inner));

  /// Yields this chain followed by [other].
  @pragma('vm:prefer-inline')
  FxAsync<T> concat(FxAsyncIterable<T> other) =>
      FxAsync(l.concatAsync(_inner, other));

  /// Emits [seed], then each running accumulation as [f] folds in each value.
  @pragma('vm:prefer-inline')
  FxAsync<B> scan<B>(FutureOr<B> Function(B acc, T a) f, FutureOr<B> seed) =>
      FxAsync(l.scanAsync(f, seed, _inner));

  /// Emits each running accumulation, n values for n values — [scan]
  /// without [seed] in the output. See the top-level `mapAccumAsync`.
  @pragma('vm:prefer-inline')
  FxAsync<B> mapAccum<B>(
    FutureOr<B> Function(B acc, T a) f,
    FutureOr<B> seed,
  ) => FxAsync(l.mapAccumAsync(f, seed, _inner));

  /// The values in reverse order (materializes the source).
  @pragma('vm:prefer-inline')
  FxAsync<T> reverse() => FxAsync(l.reverseAsync(_inner));

  /// Repeats the source endlessly.
  @pragma('vm:prefer-inline')
  FxAsync<T> cycle() => FxAsync(l.cycleAsync(_inner));

  /// Lazily pairs each value with the (possibly async) result of [f] —
  /// the value stays beside what was derived from it. Parallel-safe:
  /// composes with [concurrent].
  @pragma('vm:prefer-inline')
  FxAsync<(T, R)> attach<R>(FutureOr<R> Function(T a) f) =>
      FxAsync(l.attachAsync(f, _inner));

  /// Values of this chain whose [f]-keys do not occur in [other], deduped.
  @pragma('vm:prefer-inline')
  FxAsync<T> differenceBy<B>(
    FutureOr<B> Function(T a) f,
    FxAsyncIterable<T> other,
  ) => FxAsync(l.differenceByAsync(f, other, _inner));

  /// Values of this chain that do not occur in [other].
  @pragma('vm:prefer-inline')
  FxAsync<T> difference(FxAsyncIterable<T> other) =>
      FxAsync(l.differenceAsync(other, _inner));

  /// Values of this chain whose [f]-keys also occur in [other], deduped.
  @pragma('vm:prefer-inline')
  FxAsync<T> intersectionBy<B>(
    FutureOr<B> Function(T a) f,
    FxAsyncIterable<T> other,
  ) => FxAsync(l.intersectionByAsync(f, other, _inner));

  /// Values of this chain that also occur in [other].
  @pragma('vm:prefer-inline')
  FxAsync<T> intersection(FxAsyncIterable<T> other) =>
      FxAsync(l.intersectionAsync(other, _inner));

  /// Evaluates the upstream chain up to [length] items at a time.
  ///
  /// Port of FxTS `concurrent`.
  @pragma('vm:prefer-inline')
  FxAsync<T> concurrent(int length) => FxAsync(concurrentAsync(length, _inner));

  /// Maps [f] with up to [concurrency] values in flight at once, in source
  /// order — the pre-combined form of `map(f).concurrent(concurrency)`.
  @pragma('vm:prefer-inline')
  FxAsync<R> mapConcurrent<R>(int concurrency, FutureOr<R> Function(T a) f) =>
      FxAsync(l.mapConcurrentAsync(concurrency, f, _inner));

  /// Like [concurrent] but yields in completion order.
  @pragma('vm:prefer-inline')
  FxAsync<T> concurrentPool(int length) =>
      FxAsync(concurrentPoolAsync(length, _inner));

  // --- conversion ---------------------------------------------------------

  /// Converts this chain into a (sequential) [Stream].
  Stream<T> toStream() => _inner.toStream();

  // --- terminal operators -------------------------------------------------

  /// Materializes the async pipeline into a [List].
  Future<List<T>> toList() => s.toListAsync(_inner);

  /// Runs [f] for every value, forcing the pipeline.
  Future<void> each(FutureOr<void> Function(T a) f) => s.eachAsync(f, _inner);

  /// Consumes up to [n] values (all when omitted), forcing side effects.
  Future<void> consume([int? n]) => s.consumeAsync(_inner, n);

  /// Folds every value with [f], seeding from the first value.
  Future<T> reduce(FutureOr<T> Function(T acc, T a) f) =>
      s.reduceAsync(f, _inner);

  /// Folds every value with [f], starting from [seed].
  Future<Acc> fold<Acc>(
    FutureOr<Acc> seed,
    FutureOr<Acc> Function(Acc acc, T a) f,
  ) => s.foldAsync(seed, f, _inner);

  /// [fold] with the value's 0-based position.
  Future<Acc> foldWithIndex<Acc>(
    FutureOr<Acc> seed,
    FutureOr<Acc> Function(Acc acc, T a, int index) f,
  ) => s.foldWithIndexAsync(seed, f, _inner);

  /// Folds from the last value to the first, buffering the whole chain —
  /// see top-level `foldRightAsync`.
  Future<Acc> foldRight<Acc>(
    FutureOr<Acc> seed,
    FutureOr<Acc> Function(Acc acc, T a) f,
  ) => s.foldRightAsync(seed, f, _inner);

  /// [foldRight] with each value's 0-based position in the source.
  Future<Acc> foldRightWithIndex<Acc>(
    FutureOr<Acc> seed,
    FutureOr<Acc> Function(Acc acc, T a, int index) f,
  ) => s.foldRightWithIndexAsync(seed, f, _inner);

  /// Groups values into lists keyed by [f].
  Future<Map<K, List<T>>> groupBy<K>(FutureOr<K> Function(T a) f) =>
      s.groupByAsync(f, _inner);

  /// Maps the key [f] returns to its value (later values win on collisions).
  Future<Map<K, T>> indexBy<K>(FutureOr<K> Function(T a) f) =>
      s.indexByAsync(f, _inner);

  /// Counts how many values fall under each key [f] returns.
  Future<Map<K, int>> countBy<K>(FutureOr<K> Function(T a) f) =>
      s.countByAsync(f, _inner);

  /// Folds the values under each [key] in one pass, without materializing
  /// the groups — the aggregate-only counterpart of [groupBy].
  Future<Map<K, Acc>> foldBy<K, Acc>(
    FutureOr<K> Function(T a) key,
    FutureOr<Acc> seed,
    FutureOr<Acc> Function(Acc acc, T a) f,
  ) => s.foldByAsync(key, seed, f, _inner);

  /// Whether [f] holds for at least one value.
  Future<bool> some(FutureOr<bool> Function(T a) f) => s.someAsync(f, _inner);

  /// Whether [f] holds for every value.
  Future<bool> every(FutureOr<bool> Function(T a) f) => s.everyAsync(f, _inner);

  /// Whether [f] holds for no value.
  Future<bool> none(FutureOr<bool> Function(T a) f) => s.noneAsync(f, _inner);

  /// True when this chain and [other] yield the same values in the same
  /// order. Optional [eq] replaces `==`. After Rx's `sequenceEqual`.
  Future<bool> sequenceEqual(
    FxAsyncIterable<T> other, [
    bool Function(T, T)? eq,
  ]) => s.sequenceEqualAsync(_inner, other, eq);

  /// Joins the values into a string separated by [sep].
  Future<String> join([String sep = ',']) => s.joinAsync(sep, _inner);

  /// The first value [f] matches, or `null`.
  Future<T?> find(FutureOr<bool> Function(T a) f) => s.findAsync(f, _inner);

  /// The first non-null result of [f], or `null` when [f] returns `null` for
  /// every value.
  Future<R?> firstNotNullOf<R extends Object>(FutureOr<R?> Function(T a) f) =>
      s.firstNotNullOfAsync(f, _inner);

  /// The index of the first value [f] matches, or -1.
  Future<int> findIndex(FutureOr<bool> Function(T a) f) =>
      s.findIndexAsync(f, _inner);

  /// The first value, or `null` if empty.
  @pragma('vm:prefer-inline')
  Future<T?> head() => s.headAsync(_inner);

  /// The last value, or `null` if empty.
  Future<T?> last() => s.lastAsync(_inner);

  /// The value with the smallest key [f], or `null` if empty.
  Future<T?> minBy(Object? Function(T a) f) => s.minByAsync(f, _inner);

  /// The value with the largest key [f], or `null` if empty.
  Future<T?> maxBy(Object? Function(T a) f) => s.maxByAsync(f, _inner);

  /// The sum of [f] over every value.
  Future<num> sumBy(FutureOr<num> Function(T a) f) => s.sumByAsync(f, _inner);

  /// The product of [f] over every value; `1` when empty.
  Future<num> productBy(FutureOr<num> Function(T a) f) =>
      s.productByAsync(f, _inner);

  /// The mean of [f] over every value.
  Future<double> averageBy(FutureOr<num> Function(T a) f) =>
      s.averageByAsync(f, _inner);

  /// Splits into `(matches, non-matches)` by [f].
  Future<(List<T>, List<T>)> partition(FutureOr<bool> Function(T a) f) =>
      s.partitionAsync(f, _inner);

  /// A new list sorted by the comparator [f].
  Future<List<T>> sort(int Function(T a, T b) f) => s.sortAsync(f, _inner);

  /// A new list sorted by the key [f] returns for each value.
  Future<List<T>> sortBy(Object? Function(T a) f) => s.sortByAsync(f, _inner);

  /// A new list sorted by the key [f], descending.
  Future<List<T>> sortByDesc(Object? Function(T a) f) =>
      s.sortByDescAsync(f, _inner);

  /// The [k] values with the largest keys [f], largest first — one boundary
  /// pass, not a whole sort. Ties keep source order.
  Future<List<T>> topBy(int k, Object? Function(T a) f) =>
      s.topByAsync(k, f, _inner);

  /// The [k] values with the smallest keys [f], smallest first.
  Future<List<T>> bottomBy(int k, Object? Function(T a) f) =>
      s.bottomByAsync(k, f, _inner);

  /// Groups values into `(key, items)` records, in first-seen key order.
  Future<List<({K key, List<T> items})>> groupedBy<K>(
    FutureOr<K> Function(T a) f,
  ) => s.groupedByAsync(f, _inner);

  /// The number of values.
  Future<int> size() => s.sizeAsync(_inner);

  /// Counts the values [f] holds for — `filter` + `size` in one walk.
  Future<int> countWhere(FutureOr<bool> Function(T a) f) =>
      s.countWhereAsync(f, _inner);

  // --- Dart-idiomatic aliases -------------------------------------------
  // FxAsync does not extend Iterable, so the Dart names are provided as
  // explicit aliases here. Both spellings are supported; the 101 teaches these.

  /// Alias of [filter].
  @pragma('vm:prefer-inline')
  FxAsync<T> where(FutureOr<bool> Function(T a) f) => filter(f);

  /// Alias of [reject].
  @pragma('vm:prefer-inline')
  FxAsync<T> whereNot(FutureOr<bool> Function(T a) f) => reject(f);

  /// Alias of [flatMap].
  @pragma('vm:prefer-inline')
  FxAsync<R> expand<R>(FutureOr<Iterable<R>> Function(T a) f) => flatMap(f);

  /// Alias of [flat].
  @pragma('vm:prefer-inline')
  FxAsync<dynamic> flattened([int depth = 1]) => flat(depth);

  /// Alias of [drop].
  @pragma('vm:prefer-inline')
  FxAsync<T> skip(int count) => drop(count);

  /// Alias of [dropWhile].
  @pragma('vm:prefer-inline')
  FxAsync<T> skipWhile(FutureOr<bool> Function(T a) f) => dropWhile(f);

  /// Alias of [takeRight].
  @pragma('vm:prefer-inline')
  FxAsync<T> takeLast(int count) => takeRight(count);

  /// Alias of [uniq].
  @pragma('vm:prefer-inline')
  FxAsync<T> distinct() => uniq();

  /// Alias of [uniqBy].
  @pragma('vm:prefer-inline')
  FxAsync<T> distinctBy<B>(FutureOr<B> Function(T a) f) => uniqBy(f);

  /// Alias of [zipWithIndex].
  @pragma('vm:prefer-inline')
  FxAsync<(int, T)> indexed() => zipWithIndex();

  /// Alias of [each].
  Future<void> forEach(FutureOr<void> Function(T a) f) => each(f);

  /// Alias of [some].
  Future<bool> any(FutureOr<bool> Function(T a) f) => some(f);

  /// Alias of [find].
  Future<T?> firstWhereOrNull(FutureOr<bool> Function(T a) f) => find(f);

  /// Alias of [findIndex].
  Future<int> indexWhere(FutureOr<bool> Function(T a) f) => findIndex(f);

  /// Alias of [head].
  Future<T?> firstOrNull() => head();

  /// Alias of [last].
  Future<T?> lastOrNull() => last();

  /// Alias of [size].
  Future<int> count() => size();
}

/// Numeric terminals for [FxAsync] chains (generic covariance makes these
/// apply to `FxAsync<int>` and `FxAsync<double>` as well).
extension FxAsyncNum on FxAsync<num> {
  /// The sum of every value.
  Future<num> sum() => s.sumAsync(this);

  /// The arithmetic mean of every value.
  Future<double> average() => s.averageAsync(this);

  /// The product of every value; `1` when empty.
  Future<num> product() => s.productAsync(this);

  /// The smallest value.
  Future<num> min() => s.minAsync(this);

  /// The largest value.
  Future<num> max() => s.maxAsync(this);
}

/// Pair terminals for [FxAsync] chains over two-element records.
extension FxAsyncPair<A, B> on FxAsync<(A, B)> {
  /// Splits the pairs into `(lefts, rights)` in one pass — the inverse of
  /// `zip`. See the top-level `unzipAsync`.
  Future<(List<A>, List<B>)> unzip() => l.unzipAsync(this);
}
