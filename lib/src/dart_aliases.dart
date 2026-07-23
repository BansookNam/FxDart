/// Dart-idiomatic aliases for the FxTS-named operators.
///
/// fxdart is a port of FxTS, so the primary names follow FxTS. Where Dart's own
/// `Iterable`/collection libraries have an established name for the same
/// operation, that name is provided here as a first-class alias — both spellings
/// are supported, and the FxDart 101 course teaches the Dart-idiomatic one.
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
/// Dart-idiomatic alias for [filter].
Iterable<A> where<A>(bool Function(A a) f, Iterable<A> iterable) =>
    filter(f, iterable);

/// Dart-idiomatic alias for [filterAsync].
FxAsyncIterable<A> whereAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    filterAsync(f, iterable);

/// Dart-idiomatic alias for [reject] (keeps items where `f` is false).
Iterable<A> whereNot<A>(bool Function(A a) f, Iterable<A> iterable) =>
    reject(f, iterable);

/// Dart-idiomatic alias for [rejectAsync].
FxAsyncIterable<A> whereNotAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    rejectAsync(f, iterable);

/// Dart-idiomatic alias for [compact] (drops `null`s).
Iterable<A> nonNulls<A>(Iterable<A?> iterable) => compact(iterable);

/// Dart-idiomatic alias for [compactAsync].
FxAsyncIterable<A> nonNullsAsync<A>(FxAsyncIterable<A?> iterable) =>
    compactAsync(iterable);

/// Dart-idiomatic alias for [uniq].
Iterable<A> distinct<A>(Iterable<A> iterable) => uniq(iterable);

/// Dart-idiomatic alias for [uniqAsync].
FxAsyncIterable<A> distinctAsync<A>(FxAsyncIterable<A> iterable) =>
    uniqAsync(iterable);

/// Dart-idiomatic alias for [uniqBy].
Iterable<A> distinctBy<A, B>(B Function(A a) f, Iterable<A> iterable) =>
    uniqBy(f, iterable);

/// Dart-idiomatic alias for [uniqByAsync].
FxAsyncIterable<A> distinctByAsync<A, B>(
        FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) =>
    uniqByAsync(f, iterable);

// --- lazy/map.dart ---
/// Dart-idiomatic alias for [flatMap] (matches `Iterable.expand`).
Iterable<B> expand<A, B>(Iterable<B> Function(A a) f, Iterable<A> iterable) =>
    flatMap(f, iterable);

/// Dart-idiomatic alias for [flatMapAsync].
FxAsyncIterable<B> expandAsync<A, B>(
        FutureOr<Iterable<B>> Function(A a) f, FxAsyncIterable<A> iterable) =>
    flatMapAsync(f, iterable);

/// Dart-idiomatic alias for [flat] (flattens [depth] levels, default 1).
Iterable<dynamic> flattened(Iterable<dynamic> iterable, [int depth = 1]) =>
    flat(iterable, depth);

/// Dart-idiomatic alias for [flatAsync].
FxAsyncIterable<dynamic> flattenedAsync(FxAsyncIterable<dynamic> iterable,
        [int depth = 1]) =>
    flatAsync(iterable, depth);

// --- lazy/take_drop.dart ---
/// Dart-idiomatic alias for [takeRight] (the last [length] items).
Iterable<A> takeLast<A>(int length, Iterable<A> iterable) =>
    takeRight(length, iterable);

/// Dart-idiomatic alias for [takeRightAsync].
FxAsyncIterable<A> takeLastAsync<A>(int length, FxAsyncIterable<A> iterable) =>
    takeRightAsync(length, iterable);

/// Dart-idiomatic alias for [drop] (matches `Iterable.skip`).
Iterable<A> skip<A>(int length, Iterable<A> iterable) => drop(length, iterable);

/// Dart-idiomatic alias for [dropAsync].
FxAsyncIterable<A> skipAsync<A>(int length, FxAsyncIterable<A> iterable) =>
    dropAsync(length, iterable);

/// Dart-idiomatic alias for [dropWhile] (matches `Iterable.skipWhile`).
Iterable<A> skipWhile<A>(bool Function(A a) f, Iterable<A> iterable) =>
    dropWhile(f, iterable);

/// Dart-idiomatic alias for [dropWhileAsync].
FxAsyncIterable<A> skipWhileAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    dropWhileAsync(f, iterable);

// --- lazy/zip.dart ---
/// Dart-idiomatic alias for [zipWithIndex] (each item paired with its index).
Iterable<(int, A)> indexed<A>(Iterable<A> iterable) => zipWithIndex(iterable);

/// Dart-idiomatic alias for [zipWithIndexAsync].
FxAsyncIterable<(int, A)> indexedAsync<A>(FxAsyncIterable<A> iterable) =>
    zipWithIndexAsync(iterable);

// --- strict/access.dart ---
/// Dart-idiomatic alias for [head] (first item, or `null` if empty).
A? firstOrNull<A>(Iterable<A> iterable) => head(iterable);

/// Dart-idiomatic alias for [headAsync].
Future<A?> firstOrNullAsync<A>(FxAsyncIterable<A> iterable) =>
    headAsync(iterable);

/// Dart-idiomatic alias for [last] (last item, or `null` if empty).
A? lastOrNull<A>(Iterable<A> iterable) => last(iterable);

/// Dart-idiomatic alias for [lastAsync].
Future<A?> lastOrNullAsync<A>(FxAsyncIterable<A> iterable) => lastAsync(iterable);

/// Dart-idiomatic alias for [nth] (item at [index], or `null`).
A? elementAtOrNull<A>(int index, Iterable<A> iterable) => nth(index, iterable);

/// Dart-idiomatic alias for [nthAsync].
Future<A?> elementAtOrNullAsync<A>(int index, FxAsyncIterable<A> iterable) =>
    nthAsync(index, iterable);

/// Dart-idiomatic alias for [find] (first match, or `null`).
A? firstWhereOrNull<A>(bool Function(A a) f, Iterable<A> iterable) =>
    find(f, iterable);

/// Dart-idiomatic alias for [findAsync].
Future<A?> firstWhereOrNullAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    findAsync(f, iterable);

/// Dart-idiomatic alias for [findIndex] (index of first match, or -1).
int indexWhere<A>(bool Function(A a) f, Iterable<A> iterable) =>
    findIndex(f, iterable);

/// Dart-idiomatic alias for [findIndexAsync].
Future<int> indexWhereAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    findIndexAsync(f, iterable);

// Note: no top-level `contains` alias — it collides with `package:test`'s
// matcher, and Dart's idiom is the inherited `.contains()` on the chain anyway.
// The FxTS-named top-level `includes` remains.

/// Dart-idiomatic alias for [some] (true if any item matches).
bool any<A>(bool Function(A a) f, Iterable<A> iterable) => some(f, iterable);

/// Dart-idiomatic alias for [someAsync].
Future<bool> anyAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    someAsync(f, iterable);

// --- strict/aggregate.dart ---
/// Dart-idiomatic alias for [each] (matches `Iterable.forEach`).
void forEach<A>(void Function(A a) f, Iterable<A> iterable) =>
    each(f, iterable);

/// Dart-idiomatic alias for [eachAsync].
Future<void> forEachAsync<A>(
        FutureOr<void> Function(A a) f, FxAsyncIterable<A> iterable) =>
    eachAsync(f, iterable);

/// Dart-idiomatic alias for [size] (element count).
int count<A>(Iterable<A> iterable) => size(iterable);

/// Dart-idiomatic alias for [sizeAsync].
Future<int> countAsync<A>(FxAsyncIterable<A> iterable) => sizeAsync(iterable);

/// Dart-idiomatic alias for [toSorted] (a new sorted [List]).
List<A> sorted<A>(int Function(A a, A b) f, Iterable<A> iterable) =>
    toSorted(f, iterable);
