import 'dart:async';

import 'async_iterable.dart';
import 'async_iterable.dart' as async_;
import 'lazy/combine.dart' as l;
import 'lazy/filter.dart' as l;
import 'lazy/map.dart' as l;
import 'lazy/take_drop.dart' as l;
import 'lazy/zip.dart' as l;
import 'strict/access.dart' as s;
import 'strict/aggregate.dart' as s;

/// Wraps an [Iterable] (or anything convertible) in a lazy, chainable [Fx].
///
/// Port of FxTS `fx`. This chain is the Dart replacement for FxTS's curried
/// `pipe` pipelines, which cannot be typed in Dart.
///
/// ```dart
/// fx([1, 2, 3, 4, 5])
///     .map((a) => a + 10)
///     .filter((a) => a % 2 == 0)
///     .toList(); // [12, 14]
/// ```
Fx<T> fx<T>(Iterable<T> iterable) => Fx(iterable);

/// Wraps an [FxAsyncIterable] in a chainable [FxAsync].
FxAsync<T> fxAsync<T>(FxAsyncIterable<T> iterable) => FxAsync(iterable);

/// Wraps a [Stream] in a chainable [FxAsync].
FxAsync<T> fxStream<T>(Stream<T> stream) => FxAsync(fromStream(stream));

/// Lazy chainable iterable — the sync half of FxTS's `fx` chain.
///
/// [Fx] extends [Iterable], so the whole Dart iterable API is available
/// alongside the FxTS-named operators.
class Fx<T> extends Iterable<T> {
  final Iterable<T> _inner;

  const Fx(this._inner);

  @override
  Iterator<T> get iterator => _inner.iterator;

  /// Applies a user-defined [converter] to the whole chain.
  R to<R>(R Function(Fx<T> iterable) converter) => converter(this);

  // --- lazy operators -----------------------------------------------------

  @override
  Fx<R> map<R>(R Function(T a) toElement) => Fx(l.map(toElement, _inner));

  /// Identical to [map]; intended for side effects by convention.
  Fx<R> mapEffect<R>(R Function(T a) f) => map(f);

  /// See top-level `flatMap`; same contract as [Iterable.expand].
  Fx<R> flatMap<R>(Iterable<R> Function(T a) f) => Fx(l.flatMap(f, _inner));

  @override
  Fx<R> expand<R>(Iterable<R> Function(T element) toElements) =>
      flatMap(toElements);

  /// Flattens nested iterables [depth] levels. Untyped — see top-level `flat`.
  Fx<dynamic> flat([int depth = 1]) => Fx(l.flat(_inner, depth));

  /// Dart-idiomatic alias of [flat].
  Fx<dynamic> flattened([int depth = 1]) => flat(depth);

  /// All elements [f] returns true for.
  Fx<T> filter(bool Function(T a) f) => Fx(l.filter(f, _inner));

  @override
  Fx<T> where(bool Function(T element) test) => filter(test);

  /// The opposite of [filter].
  Fx<T> reject(bool Function(T a) f) => Fx(l.reject(f, _inner));

  /// Dart-idiomatic alias of [reject].
  Fx<T> whereNot(bool Function(T a) f) => reject(f);

  @override
  Fx<T> take(int count) => Fx(l.take(count, _inner));

  Fx<T> takeRight(int count) => Fx(l.takeRight(count, _inner));

  /// Dart-idiomatic alias of [takeRight].
  Fx<T> takeLast(int count) => takeRight(count);

  @override
  Fx<T> takeWhile(bool Function(T value) test) => Fx(l.takeWhile(test, _inner));

  /// Yields values until [f] matches, including the matching element.
  Fx<T> takeUntilInclusive(bool Function(T a) f) =>
      Fx(l.takeUntilInclusive(f, _inner));

  @Deprecated('Use takeUntilInclusive instead')
  Fx<T> takeUntil(bool Function(T a) f) => takeUntilInclusive(f);

  /// Skips the first [count] values.
  Fx<T> drop(int count) => Fx(l.drop(count, _inner));

  @override
  Fx<T> skip(int count) => drop(count);

  Fx<T> dropRight(int count) => Fx(l.dropRight(count, _inner));

  Fx<T> dropWhile(bool Function(T a) f) => Fx(l.dropWhile(f, _inner));

  @override
  Fx<T> skipWhile(bool Function(T value) test) => dropWhile(test);

  /// Skips values until [f] matches (dropping the match), yields the rest.
  Fx<T> dropUntil(bool Function(T a) f) => Fx(l.dropUntil(f, _inner));

  Fx<T> slice(int start, [int? end]) => Fx(l.slice(start, _inner, end));

  Fx<List<T>> chunk(int size) => Fx(l.chunk(size, _inner));

  /// Applies [f] to each value without changing it.
  Fx<T> peek(void Function(T a) f) => Fx(l.peek(f, _inner));

  Fx<T> uniq() => Fx(l.uniq(_inner));

  /// Dart-idiomatic alias of [uniq].
  Fx<T> distinct() => uniq();

  Fx<T> uniqBy<B>(B Function(T a) f) => Fx(l.uniqBy(f, _inner));

  /// Dart-idiomatic alias of [uniqBy].
  Fx<T> distinctBy<B>(B Function(T a) f) => uniqBy(f);

  Fx<(T, U)> zip<U>(Iterable<U> other) => Fx(l.zip(_inner, other));

  Fx<(int, T)> zipWithIndex() => Fx(l.zipWithIndex(_inner));

  Fx<T> append(T a) => Fx(l.append(a, _inner));

  Fx<T> prepend(T a) => Fx(l.prepend(a, _inner));

  Fx<T> concat(Iterable<T> other) => Fx(l.concat(_inner, other));

  Fx<B> scan<B>(B Function(B acc, T a) f, B seed) =>
      Fx(l.scan(f, seed, _inner));

  Fx<T> reverse() => Fx(l.reverse(_inner));

  Fx<T> cycle() => Fx(l.cycle(_inner));

  Fx<T> sort(int Function(T a, T b) f) => Fx(s.sort(f, _inner));

  Fx<T> sortBy(Object? Function(T a) f) => Fx(s.sortBy(f, _inner));

  // --- conversion ---------------------------------------------------------

  /// Switches to the async chain. Values stay plain; use the top-level
  /// `toAsync` for an `Iterable<Future<T>>`.
  FxAsync<T> toAsync() => FxAsync(async_.toAsync(_inner));

  // --- terminal operators -------------------------------------------------

  /// Materializes the pipeline into a [List] (Dart's `Iterable.toList`).
  @override
  List<T> toList({bool growable = true}) => _inner.toList(growable: growable);

  void each(void Function(T a) f) => s.each(f, _inner);

  /// Consumes up to [n] values (all when omitted), forcing side effects.
  void consume([int? n]) => s.consume(_inner, n);

  Map<K, List<T>> groupBy<K>(K Function(T a) f) => s.groupBy(f, _inner);

  Map<K, T> indexBy<K>(K Function(T a) f) => s.indexBy(f, _inner);

  Map<K, int> countBy<K>(K Function(T a) f) => s.countBy(f, _inner);

  bool some(bool Function(T a) f) => s.some(f, _inner);

  T? find(bool Function(T a) f) => s.find(f, _inner);

  /// Dart-idiomatic alias of [find] (cf. `package:collection`).
  T? firstWhereOrNull(bool Function(T a) f) => find(f);

  int findIndex(bool Function(T a) f) => s.findIndex(f, _inner);

  /// Dart-idiomatic alias of [findIndex] (cf. `List.indexWhere`).
  int indexWhere(bool Function(T a) f) => findIndex(f);

  T? head() => s.head(_inner);

  T? minBy(Object? Function(T a) f) => s.minBy(f, _inner);

  T? maxBy(Object? Function(T a) f) => s.maxBy(f, _inner);

  num sumBy(num Function(T a) f) => s.sumBy(f, _inner);

  double averageBy(num Function(T a) f) => s.averageBy(f, _inner);

  (List<T>, List<T>) partition(bool Function(T a) f) => s.partition(f, _inner);

  int size() => s.size(_inner);
}

/// Numeric terminals for [Fx] chains (generic covariance makes these apply
/// to `Fx<int>` and `Fx<double>` as well).
extension FxNum on Fx<num> {
  num sum() => s.sum(this);
  double average() => s.average(this);
  num min() => s.min(this);
  num max() => s.max(this);
}

/// Async chainable iterable — the async half of FxTS's `fx` chain.
class FxAsync<T> implements FxAsyncIterable<T> {
  final FxAsyncIterable<T> _inner;

  const FxAsync(this._inner);

  @override
  FxAsyncIterator<T> get iterator => _inner.iterator;

  /// Applies a user-defined [converter] to the whole chain.
  R to<R>(R Function(FxAsync<T> iterable) converter) => converter(this);

  // --- lazy operators -----------------------------------------------------

  FxAsync<R> map<R>(FutureOr<R> Function(T a) f) =>
      FxAsync(l.mapAsync(f, _inner));

  FxAsync<R> mapEffect<R>(FutureOr<R> Function(T a) f) => map(f);

  FxAsync<R> flatMap<R>(FutureOr<Iterable<R>> Function(T a) f) =>
      FxAsync(l.flatMapAsync(f, _inner));

  FxAsync<dynamic> flat([int depth = 1]) => FxAsync(l.flatAsync(_inner, depth));

  FxAsync<T> filter(FutureOr<bool> Function(T a) f) =>
      FxAsync(l.filterAsync(f, _inner));

  FxAsync<T> reject(FutureOr<bool> Function(T a) f) =>
      FxAsync(l.rejectAsync(f, _inner));

  FxAsync<T> take(int count) => FxAsync(l.takeAsync(count, _inner));

  FxAsync<T> takeRight(int count) => FxAsync(l.takeRightAsync(count, _inner));

  FxAsync<T> takeWhile(FutureOr<bool> Function(T a) f) =>
      FxAsync(l.takeWhileAsync(f, _inner));

  FxAsync<T> takeUntilInclusive(FutureOr<bool> Function(T a) f) =>
      FxAsync(l.takeUntilInclusiveAsync(f, _inner));

  @Deprecated('Use takeUntilInclusive instead')
  FxAsync<T> takeUntil(FutureOr<bool> Function(T a) f) => takeUntilInclusive(f);

  FxAsync<T> drop(int count) => FxAsync(l.dropAsync(count, _inner));

  FxAsync<T> dropRight(int count) => FxAsync(l.dropRightAsync(count, _inner));

  FxAsync<T> dropWhile(FutureOr<bool> Function(T a) f) =>
      FxAsync(l.dropWhileAsync(f, _inner));

  FxAsync<T> dropUntil(FutureOr<bool> Function(T a) f) =>
      FxAsync(l.dropUntilAsync(f, _inner));

  FxAsync<T> slice(int start, [int? end]) =>
      FxAsync(l.sliceAsync(start, _inner, end));

  FxAsync<List<T>> chunk(int size) => FxAsync(l.chunkAsync(size, _inner));

  FxAsync<T> peek(FutureOr<void> Function(T a) f) =>
      FxAsync(l.peekAsync(f, _inner));

  FxAsync<T> uniq() => FxAsync(l.uniqAsync(_inner));

  FxAsync<T> uniqBy<B>(FutureOr<B> Function(T a) f) =>
      FxAsync(l.uniqByAsync(f, _inner));

  FxAsync<(T, U)> zip<U>(FxAsyncIterable<U> other) =>
      FxAsync(l.zipAsync(_inner, other));

  FxAsync<(int, T)> zipWithIndex() => FxAsync(l.zipWithIndexAsync(_inner));

  FxAsync<T> append(FutureOr<T> a) => FxAsync(l.appendAsync(a, _inner));

  FxAsync<T> prepend(FutureOr<T> a) => FxAsync(l.prependAsync(a, _inner));

  FxAsync<T> concat(FxAsyncIterable<T> other) =>
      FxAsync(l.concatAsync(_inner, other));

  FxAsync<B> scan<B>(FutureOr<B> Function(B acc, T a) f, FutureOr<B> seed) =>
      FxAsync(l.scanAsync(f, seed, _inner));

  FxAsync<T> reverse() => FxAsync(l.reverseAsync(_inner));

  FxAsync<T> cycle() => FxAsync(l.cycleAsync(_inner));

  /// Evaluates the upstream chain up to [length] items at a time.
  ///
  /// Port of FxTS `concurrent`.
  FxAsync<T> concurrent(int length) => FxAsync(concurrentAsync(length, _inner));

  /// Like [concurrent] but yields in completion order.
  FxAsync<T> concurrentPool(int length) =>
      FxAsync(concurrentPoolAsync(length, _inner));

  // --- conversion ---------------------------------------------------------

  /// Converts this chain into a (sequential) [Stream].
  Stream<T> toStream() => _inner.toStream();

  // --- terminal operators -------------------------------------------------

  /// Materializes the async pipeline into a [List].
  Future<List<T>> toList() => s.toListAsync(_inner);

  Future<void> each(FutureOr<void> Function(T a) f) => s.eachAsync(f, _inner);

  Future<void> consume([int? n]) => s.consumeAsync(_inner, n);

  Future<T> reduce(FutureOr<T> Function(T acc, T a) f) =>
      s.reduceAsync(f, _inner);

  Future<Acc> fold<Acc>(
          FutureOr<Acc> seed, FutureOr<Acc> Function(Acc acc, T a) f) =>
      s.foldAsync(seed, f, _inner);

  Future<Map<K, List<T>>> groupBy<K>(FutureOr<K> Function(T a) f) =>
      s.groupByAsync(f, _inner);

  Future<Map<K, T>> indexBy<K>(FutureOr<K> Function(T a) f) =>
      s.indexByAsync(f, _inner);

  Future<Map<K, int>> countBy<K>(FutureOr<K> Function(T a) f) =>
      s.countByAsync(f, _inner);

  Future<bool> some(FutureOr<bool> Function(T a) f) => s.someAsync(f, _inner);

  Future<bool> every(FutureOr<bool> Function(T a) f) => s.everyAsync(f, _inner);

  Future<String> join([String sep = ',']) => s.joinAsync(sep, _inner);

  Future<T?> find(FutureOr<bool> Function(T a) f) => s.findAsync(f, _inner);

  Future<int> findIndex(FutureOr<bool> Function(T a) f) =>
      s.findIndexAsync(f, _inner);

  Future<T?> head() => s.headAsync(_inner);

  Future<T?> last() => s.lastAsync(_inner);

  Future<T?> minBy(Object? Function(T a) f) => s.minByAsync(f, _inner);

  Future<T?> maxBy(Object? Function(T a) f) => s.maxByAsync(f, _inner);

  Future<num> sumBy(FutureOr<num> Function(T a) f) => s.sumByAsync(f, _inner);

  Future<double> averageBy(FutureOr<num> Function(T a) f) =>
      s.averageByAsync(f, _inner);

  Future<(List<T>, List<T>)> partition(FutureOr<bool> Function(T a) f) =>
      s.partitionAsync(f, _inner);

  Future<List<T>> sort(int Function(T a, T b) f) => s.sortAsync(f, _inner);

  Future<List<T>> sortBy(Object? Function(T a) f) => s.sortByAsync(f, _inner);

  Future<int> size() => s.sizeAsync(_inner);

  // --- Dart-idiomatic aliases -------------------------------------------
  // FxAsync does not extend Iterable, so the Dart names are provided as
  // explicit aliases here. Both spellings are supported; the 101 teaches these.

  /// Alias of [filter].
  FxAsync<T> where(FutureOr<bool> Function(T a) f) => filter(f);

  /// Alias of [reject].
  FxAsync<T> whereNot(FutureOr<bool> Function(T a) f) => reject(f);

  /// Alias of [flatMap].
  FxAsync<R> expand<R>(FutureOr<Iterable<R>> Function(T a) f) => flatMap(f);

  /// Alias of [flat].
  FxAsync<dynamic> flattened([int depth = 1]) => flat(depth);

  /// Alias of [drop].
  FxAsync<T> skip(int count) => drop(count);

  /// Alias of [dropWhile].
  FxAsync<T> skipWhile(FutureOr<bool> Function(T a) f) => dropWhile(f);

  /// Alias of [takeRight].
  FxAsync<T> takeLast(int count) => takeRight(count);

  /// Alias of [uniq].
  FxAsync<T> distinct() => uniq();

  /// Alias of [uniqBy].
  FxAsync<T> distinctBy<B>(FutureOr<B> Function(T a) f) => uniqBy(f);

  /// Alias of [zipWithIndex].
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
  Future<num> sum() => s.sumAsync(this);
  Future<double> average() => s.averageAsync(this);
  Future<num> min() => s.minAsync(this);
  Future<num> max() => s.maxAsync(this);
}
