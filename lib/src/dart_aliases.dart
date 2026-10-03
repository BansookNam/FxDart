/// Dart-idiomatic aliases for the FxTS-named operators.
///
/// fxdart is a port of FxTS, so the primary names follow FxTS. Where Dart's own
/// `Iterable`/collection libraries have an established name for the same
/// operation, that name is provided here as a first-class alias — both spellings
/// are supported, and the FxDart 101 course teaches the Dart-idiomatic one.
/// Like every short top-level name, a one- or two-word alias carries the `fx`
/// prefix (`fxWhere`, `fxDistinct`); on the chain the plain Dart word is used
/// (`fx(xs).where(f)`).
///
/// (The lone exception is `toArray`, which was *removed* in favour of `toList`
/// rather than aliased — it claimed a type Dart doesn't have.)
library;

import 'dart:async';

import 'async_iterable.dart';
import 'lazy/filter.dart';
import 'lazy/map.dart';
import 'lazy/take_drop.dart';
import 'lazy/zip.dart';
import 'strict/access.dart';
import 'strict/aggregate.dart';

// --- lazy/filter.dart ---
/// Dart-idiomatic alias for [fxFilter].
Iterable<A> fxWhere<A>(bool Function(A a) f, Iterable<A> iterable) =>
    fxFilter(f, iterable);

/// Dart-idiomatic alias for [fxFilterAsync].
FxAsyncIterable<A> fxWhereAsync<A>(
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) => fxFilterAsync(f, iterable);

/// Dart-idiomatic alias for [fxReject] (keeps items where `f` is false).
Iterable<A> fxWhereNot<A>(bool Function(A a) f, Iterable<A> iterable) =>
    fxReject(f, iterable);

/// Dart-idiomatic alias for [fxRejectAsync].
FxAsyncIterable<A> fxWhereNotAsync<A>(
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) => fxRejectAsync(f, iterable);

/// Dart-idiomatic alias for [fxCompact] (drops `null`s).
Iterable<A> fxNonNulls<A>(Iterable<A?> iterable) => fxCompact(iterable);

/// Dart-idiomatic alias for [fxCompactAsync].
FxAsyncIterable<A> fxNonNullsAsync<A>(FxAsyncIterable<A?> iterable) =>
    fxCompactAsync(iterable);

/// Dart-idiomatic alias for [fxUniq].
Iterable<A> fxDistinct<A>(Iterable<A> iterable) => fxUniq(iterable);

/// Dart-idiomatic alias for [fxUniqAsync].
FxAsyncIterable<A> fxDistinctAsync<A>(FxAsyncIterable<A> iterable) =>
    fxUniqAsync(iterable);

/// Dart-idiomatic alias for [fxUniqBy].
Iterable<A> fxDistinctBy<A, B>(B Function(A a) f, Iterable<A> iterable) =>
    fxUniqBy(f, iterable);

/// Dart-idiomatic alias for [fxUniqByAsync].
FxAsyncIterable<A> fxDistinctByAsync<A, B>(
  FutureOr<B> Function(A a) f,
  FxAsyncIterable<A> iterable,
) => fxUniqByAsync(f, iterable);

// --- lazy/map.dart ---
/// Dart-idiomatic alias for [fxFlatMap] (matches `Iterable.expand`).
Iterable<B> fxExpand<A, B>(Iterable<B> Function(A a) f, Iterable<A> iterable) =>
    fxFlatMap(f, iterable);

/// Dart-idiomatic alias for [fxFlatMapAsync].
FxAsyncIterable<B> fxExpandAsync<A, B>(
  FutureOr<Iterable<B>> Function(A a) f,
  FxAsyncIterable<A> iterable,
) => fxFlatMapAsync(f, iterable);

/// Dart-idiomatic alias for [fxFlat] (flattens [depth] levels, default 1).
Iterable<dynamic> fxFlattened(Iterable<dynamic> iterable, [int depth = 1]) =>
    fxFlat(iterable, depth);

/// Dart-idiomatic alias for [fxFlatAsync].
FxAsyncIterable<dynamic> fxFlattenedAsync(
  FxAsyncIterable<dynamic> iterable, [
  int depth = 1,
]) => fxFlatAsync(iterable, depth);

// --- lazy/take_drop.dart ---
/// Dart-idiomatic alias for [fxTakeRight] (the last [length] items).
Iterable<A> fxTakeLast<A>(int length, Iterable<A> iterable) =>
    fxTakeRight(length, iterable);

/// Dart-idiomatic alias for [fxTakeRightAsync].
FxAsyncIterable<A> fxTakeLastAsync<A>(
  int length,
  FxAsyncIterable<A> iterable,
) => fxTakeRightAsync(length, iterable);

/// Dart-idiomatic alias for [fxDrop] (matches `Iterable.skip`).
Iterable<A> fxSkip<A>(int length, Iterable<A> iterable) =>
    fxDrop(length, iterable);

/// Dart-idiomatic alias for [fxDropAsync].
FxAsyncIterable<A> fxSkipAsync<A>(int length, FxAsyncIterable<A> iterable) =>
    fxDropAsync(length, iterable);

/// Dart-idiomatic alias for [fxDropWhile] (matches `Iterable.skipWhile`).
Iterable<A> fxSkipWhile<A>(bool Function(A a) f, Iterable<A> iterable) =>
    fxDropWhile(f, iterable);

/// Dart-idiomatic alias for [fxDropWhileAsync].
FxAsyncIterable<A> fxSkipWhileAsync<A>(
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) => fxDropWhileAsync(f, iterable);

// --- lazy/zip.dart ---
/// Dart-idiomatic alias for [zipWithIndex] (each item paired with its index).
Iterable<(int, A)> fxIndexed<A>(Iterable<A> iterable) => zipWithIndex(iterable);

/// Dart-idiomatic alias for [zipWithIndexAsync].
FxAsyncIterable<(int, A)> fxIndexedAsync<A>(FxAsyncIterable<A> iterable) =>
    zipWithIndexAsync(iterable);

// --- strict/access.dart ---
/// Dart-idiomatic alias for [fxHead] (first item, or `null` if empty).
A? firstOrNull<A>(Iterable<A> iterable) => fxHead(iterable);

/// Dart-idiomatic alias for [fxHeadAsync].
Future<A?> firstOrNullAsync<A>(FxAsyncIterable<A> iterable) =>
    fxHeadAsync(iterable);

/// Dart-idiomatic alias for [fxLast] (last item, or `null` if empty).
A? lastOrNull<A>(Iterable<A> iterable) => fxLast(iterable);

/// Dart-idiomatic alias for [fxLastAsync].
Future<A?> lastOrNullAsync<A>(FxAsyncIterable<A> iterable) =>
    fxLastAsync(iterable);

/// Dart-idiomatic alias for [fxNth] (item at [index], or `null`).
A? elementAtOrNull<A>(int index, Iterable<A> iterable) =>
    fxNth(index, iterable);

/// Dart-idiomatic alias for [fxNthAsync].
Future<A?> elementAtOrNullAsync<A>(int index, FxAsyncIterable<A> iterable) =>
    fxNthAsync(index, iterable);

/// Dart-idiomatic alias for [fxFind] (first match, or `null`).
A? firstWhereOrNull<A>(bool Function(A a) f, Iterable<A> iterable) =>
    fxFind(f, iterable);

/// Dart-idiomatic alias for [fxFindAsync].
Future<A?> firstWhereOrNullAsync<A>(
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) => fxFindAsync(f, iterable);

/// Dart-idiomatic alias for [fxFindIndex] (index of first match, or -1).
int fxIndexWhere<A>(bool Function(A a) f, Iterable<A> iterable) =>
    fxFindIndex(f, iterable);

/// Dart-idiomatic alias for [fxFindIndexAsync].
Future<int> fxIndexWhereAsync<A>(
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) => fxFindIndexAsync(f, iterable);

// Note: no top-level `contains` alias — it collides with `package:test`'s
// matcher, and Dart's idiom is the inherited `.contains()` on the chain anyway.
// The FxTS-named top-level `fxIncludes` remains.

/// Dart-idiomatic alias for [fxSome] (true if any item matches).
bool fxAny<A>(bool Function(A a) f, Iterable<A> iterable) =>
    fxSome(f, iterable);

/// Dart-idiomatic alias for [fxSomeAsync].
Future<bool> fxAnyAsync<A>(
  FutureOr<bool> Function(A a) f,
  FxAsyncIterable<A> iterable,
) => fxSomeAsync(f, iterable);

// --- strict/aggregate.dart ---
/// Dart-idiomatic alias for [fxEach] (matches `Iterable.forEach`).
void fxForEach<A>(void Function(A a) f, Iterable<A> iterable) =>
    fxEach(f, iterable);

/// Dart-idiomatic alias for [fxEachAsync].
Future<void> fxForEachAsync<A>(
  FutureOr<void> Function(A a) f,
  FxAsyncIterable<A> iterable,
) => fxEachAsync(f, iterable);

/// Dart-idiomatic alias for [fxSize] (element count).
int fxCount<A>(Iterable<A> iterable) => fxSize(iterable);

/// Dart-idiomatic alias for [fxSizeAsync].
Future<int> fxCountAsync<A>(FxAsyncIterable<A> iterable) =>
    fxSizeAsync(iterable);

/// Dart-idiomatic alias for [fxToSorted] (a new sorted [List]).
List<A> fxSorted<A>(int Function(A a, A b) f, Iterable<A> iterable) =>
    fxToSorted(f, iterable);
