#!/usr/bin/env bash
# Generates docs/assets/fxdart_single.dart: a single-file build of fxdart for
# use in a web playground (the file is meant to be prepended to user code and
# compiled by the DartPad compile service).
#
# Rerunnable: this script always regenerates the output from scratch.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT/docs/assets"
OUT="$OUT_DIR/fxdart_single.dart"

mkdir -p "$OUT_DIR"

# Files to concatenate, in order. fx.dart is handled separately below because
# it needs a source transform.
FILES=(
  "lib/src/config.dart"
  "lib/src/async_iterable.dart"
  "lib/src/pipe.dart"
  "lib/src/lazy/list_range.dart"
  "lib/src/lazy/map.dart"
  "lib/src/lazy/filter.dart"
  "lib/src/lazy/take_drop.dart"
  "lib/src/lazy/zip.dart"
  "lib/src/lazy/combine.dart"
  "lib/src/lazy/effect.dart"
  "lib/src/lazy/parallel_stub.dart"
  "lib/src/lazy/parallel.dart"
  "lib/src/strict/aggregate.dart"
  "lib/src/strict/access.dart"
  "lib/src/strict/object.dart"
  "lib/src/strict/func.dart"
  "lib/src/strict/curried.dart"
  "lib/src/strict/predicates.dart"
  "lib/src/strict/sequence_equal.dart"
  "lib/src/dart_aliases.dart"
  "lib/src/util/timing.dart"
  "lib/src/util/shuffle.dart"
  "lib/src/typed/non_empty_list.dart"
  "lib/src/typed/raise.dart"
  "lib/src/typed/accumulate.dart"
  "lib/src/typed/fx_either.dart"
  "lib/src/stream/events.dart"
  "lib/src/stream/events_chain.dart"
  "lib/src/stream/events_combine.dart"
  "lib/src/stream/events_either.dart"
  "lib/src/stream/events_notify.dart"
  "lib/src/stream/events_pull.dart"
  "lib/src/stream/events_scan.dart"
  "lib/src/stream/events_select.dart"
  "lib/src/stream/events_window.dart"
  "lib/src/stream/connectable.dart"
  "lib/src/stream/values.dart"
  "lib/src/stream/subscriptions.dart"
)

# Strips lines that start with `import `, `export `, or the exact `library;`
# directive.
strip_directives() {
  grep -vE '^(import |export )' "$1" | grep -vE '^library;$'
}

{
  cat <<'HEADER'
// ignore_for_file: deprecated_member_use_from_same_package, unused_element
// ignore_for_file: library_private_types_in_public_api
import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;
import 'dart:typed_data';
HEADER

  for f in "${FILES[@]}"; do
    echo ""
    echo "// ---- $f ----"
    strip_directives "$ROOT/$f"
  done

  # fx.dart is special: it calls top-level functions through import prefixes
  # (l., s., async_.) because its instance methods shadow the top-level names
  # (e.g. inside class Fx, `map` refers to the instance method). Those
  # prefixes don't exist once everything is merged into one file, so rewrite
  # every prefixed reference to a `_$NAME` wrapper defined further below.
  echo ""
  echo "// ---- lib/src/fx.dart (transformed: l./s./async_. -> _\$NAME) ----"
  strip_directives "$ROOT/lib/src/fx.dart" | perl -pe '
    s/(?<![A-Za-z0-9_])l\.([a-zA-Z0-9_]+)/_\$$1/g;
    s/(?<![A-Za-z0-9_])s\.([a-zA-Z0-9_]+)/_\$$1/g;
    s/(?<![A-Za-z0-9_])async_\.([a-zA-Z0-9_]+)/_\$$1/g;
  '

  # either.dart is also special: it imports raise.dart under the `raise_`
  # prefix because inside `class Either` the plain name `catching` would
  # resolve to the static `Either.catching` (self-reference). Types can be
  # de-prefixed directly; the two function references go through `_$typed*`
  # wrappers defined below.
  echo ""
  echo "// ---- lib/src/typed/either.dart (transformed: raise_. -> _\$typed* / plain) ----"
  strip_directives "$ROOT/lib/src/typed/either.dart" | perl -pe '
    s/(?<![A-Za-z0-9_])raise_\.Raise(?![A-Za-z0-9_])/Raise/g;
    s/(?<![A-Za-z0-9_])raise_\.fxEither(?![A-Za-z0-9_])/_\$typedEither/g;
    s/(?<![A-Za-z0-9_])raise_\.fxCatching(?![A-Za-z0-9_])/_\$typedCatching/g;
  '

  # Wrapper section: every `_$NAME` used above, defined as a small top-level
  # delegating function. At top level the plain names resolve to the
  # top-level functions from the concatenated files (not to Fx/FxAsync
  # instance methods, which only shadow them inside the class body), so these
  # wrappers are legal and just forward the call.
  #
  # This list is static. It was generated once by hand from:
  #   grep -oE '(l|s|async_)\.[a-zA-Z0-9_]+' lib/src/fx.dart | sort -u
  # (ignoring the false matches `s.dart` / `s._inner` that come from import
  # lines / `this._inner`), cross-checked against each function's signature
  # in the lib/src source files.
  cat <<'WRAPPERS'

// ---- wrappers for either.dart's raise_. prefixed calls ----

Either<E, A> _$typedEither<E, A>(A Function(Raise<E> r) block) =>
    fxEither(block);
A _$typedCatching<A>(A Function() block,
        A Function(Object error, StackTrace stackTrace) onError) =>
    fxCatching(block, onError);

// ---- wrappers for fx.dart's l./s./async_. prefixed calls ----

// async_iterable.dart
FxAsyncIterable<T> _$fxToAsync<T>(Iterable<FutureOr<T>> iterable) =>
    fxToAsync(iterable);

// lazy/map.dart
Iterable<B> _$fxMap<A, B>(B Function(A a) f, Iterable<A> iterable) =>
    fxMap(f, iterable);
FxAsyncIterable<B> _$fxMapAsync<A, B>(
        FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxMapAsync(f, iterable);
Iterable<A> _$fxPeek<A>(void Function(A a) f, Iterable<A> iterable) =>
    fxPeek(f, iterable);
FxAsyncIterable<A> _$fxPeekAsync<A>(
        FutureOr<void> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxPeekAsync(f, iterable);
Iterable<dynamic> _$fxFlat(Iterable<dynamic> iterable, [int depth = 1]) =>
    fxFlat(iterable, depth);
FxAsyncIterable<dynamic> _$fxFlatAsync(FxAsyncIterable<dynamic> iterable,
        [int depth = 1]) =>
    fxFlatAsync(iterable, depth);
Iterable<B> _$fxFlatMap<A, B>(Iterable<B> Function(A a) f, Iterable<A> iterable) =>
    fxFlatMap(f, iterable);
FxAsyncIterable<B> _$fxFlatMapAsync<A, B>(
        FutureOr<Iterable<B>> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxFlatMapAsync(f, iterable);
Iterable<B> _$mapWithIndex<A, B>(
        B Function(A a, int index) f, Iterable<A> iterable) =>
    mapWithIndex(f, iterable);
FxAsyncIterable<B> _$mapWithIndexAsync<A, B>(
        FutureOr<B> Function(A a, int index) f, FxAsyncIterable<A> iterable) =>
    mapWithIndexAsync(f, iterable);
Iterable<B> _$flatMapWithIndex<A, B>(
        Iterable<B> Function(A a, int index) f, Iterable<A> iterable) =>
    flatMapWithIndex(f, iterable);
FxAsyncIterable<B> _$flatMapWithIndexAsync<A, B>(
        FutureOr<Iterable<B>> Function(A a, int index) f,
        FxAsyncIterable<A> iterable) =>
    flatMapWithIndexAsync(f, iterable);
Iterable<B> _$fxScan<A, B>(
        B Function(B acc, A a) f, B seed, Iterable<A> iterable) =>
    fxScan(f, seed, iterable);
FxAsyncIterable<B> _$fxScanAsync<A, B>(FutureOr<B> Function(B acc, A a) f,
        FutureOr<B> seed, FxAsyncIterable<A> iterable) =>
    fxScanAsync(f, seed, iterable);
Iterable<B> _$fxMapAccum<A, B>(
        B Function(B acc, A a) f, B seed, Iterable<A> iterable) =>
    fxMapAccum(f, seed, iterable);
FxAsyncIterable<B> _$fxMapAccumAsync<A, B>(FutureOr<B> Function(B acc, A a) f,
        FutureOr<B> seed, FxAsyncIterable<A> iterable) =>
    fxMapAccumAsync(f, seed, iterable);
FxAsyncIterable<B> _$fxMapConcurrent<A, B>(
        int concurrency, FutureOr<B> Function(A a) f, Iterable<A> iterable) =>
    fxMapConcurrent(concurrency, f, iterable);
FxAsyncIterable<B> _$fxMapConcurrentAsync<A, B>(int concurrency,
        FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxMapConcurrentAsync(concurrency, f, iterable);
FxAsyncIterable<R> _$fxParallel<A, R>(int workers,
        FutureOr<R> Function(A input) worker, Iterable<A> iterable,
        {int chunk = 1, bool chunked = false}) =>
    fxParallel(workers, worker, iterable, chunk: chunk, chunked: chunked);
FxAsyncIterable<R> _$fxParallelAsync<A, R>(int workers,
        FutureOr<R> Function(A input) worker, FxAsyncIterable<A> iterable,
        {int chunk = 1, bool chunked = false}) =>
    fxParallelAsync(workers, worker, iterable, chunk: chunk, chunked: chunked);
FxAsyncIterable<R> _$fxParallelOn<A, R>(IsolatePool pool,
        FutureOr<R> Function(A input) worker, Iterable<A> iterable,
        {int chunk = 1, bool chunked = false}) =>
    fxParallelOn(pool, worker, iterable, chunk: chunk, chunked: chunked);
FxAsyncIterable<R> _$fxParallelOnAsync<A, R>(IsolatePool pool,
        FutureOr<R> Function(A input) worker, FxAsyncIterable<A> iterable,
        {int chunk = 1, bool chunked = false}) =>
    fxParallelOnAsync(pool, worker, iterable, chunk: chunk, chunked: chunked);
R Function(A a) _$fxPipe<A, R>(R Function(A a) f) => fxPipe(f);
R Function(A a) _$fxPipe2<A, M, R>(
        M Function(A a) first, R Function(M m) second) =>
    fxPipe2(first, second);
R Function(A a) _$fxPipe3<A, M1, M2, R>(
        M1 Function(A a) first, M2 Function(M1 m) second,
        R Function(M2 m) third) =>
    fxPipe3(first, second, third);
R Function(A a) _$fxPipe4<A, M1, M2, M3, R>(
        M1 Function(A a) first, M2 Function(M1 m) second,
        M3 Function(M2 m) third, R Function(M3 m) fourth) =>
    fxPipe4(first, second, third, fourth);
R Function(A a) _$fxPipe5<A, M1, M2, M3, M4, R>(
        M1 Function(A a) first, M2 Function(M1 m) second,
        M3 Function(M2 m) third, M4 Function(M3 m) fourth,
        R Function(M4 m) fifth) =>
    fxPipe5(first, second, third, fourth, fifth);
typedef _$IsolatePool = IsolatePool;
Iterable<(A, B)> _$fxAttach<A, B>(B Function(A a) f, Iterable<A> iterable) =>
    fxAttach(f, iterable);
FxAsyncIterable<(A, B)> _$fxAttachAsync<A, B>(
        FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxAttachAsync(f, iterable);

// lazy/filter.dart
Iterable<A> _$fxFilter<A>(bool Function(A a) f, Iterable<A> iterable) =>
    fxFilter(f, iterable);
FxAsyncIterable<A> _$fxFilterAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxFilterAsync(f, iterable);
Iterable<A> _$filterWithIndex<A>(
        bool Function(A a, int index) f, Iterable<A> iterable) =>
    filterWithIndex(f, iterable);
FxAsyncIterable<A> _$filterWithIndexAsync<A>(
        FutureOr<bool> Function(A a, int index) f,
        FxAsyncIterable<A> iterable) =>
    filterWithIndexAsync(f, iterable);
Iterable<A> _$fxReject<A>(bool Function(A a) f, Iterable<A> iterable) =>
    fxReject(f, iterable);
FxAsyncIterable<A> _$fxRejectAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxRejectAsync(f, iterable);
Iterable<A> _$fxUniq<A>(Iterable<A> iterable) => fxUniq(iterable);
FxAsyncIterable<A> _$fxUniqAsync<A>(FxAsyncIterable<A> iterable) =>
    fxUniqAsync(iterable);
Iterable<A> _$fxUniqBy<A, B>(B Function(A a) f, Iterable<A> iterable) =>
    fxUniqBy(f, iterable);
FxAsyncIterable<A> _$fxUniqByAsync<A, B>(
        FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxUniqByAsync(f, iterable);
List<A> _$fxUniqStrict<A>(Iterable<A> iterable) => fxUniqStrict(iterable);
List<A> _$uniqByStrict<A, B>(B Function(A a) f, Iterable<A> iterable) =>
    uniqByStrict(f, iterable);
Map<K, Acc> _$foldByOrSkip<A, K extends Object, Acc>(
        K? Function(A a) key,
        Acc seed,
        Acc Function(Acc acc, A a) f,
        Iterable<A> iterable) =>
    foldByOrSkip(key, seed, f, iterable);
List<A> _$takeUniqBy<A, B extends Object>(
        int count, B? Function(A a) f, Iterable<A> iterable) =>
    takeUniqBy(count, f, iterable);
Iterable<B> _$mapNotNull<A, B extends Object>(
        B? Function(A a) f, Iterable<A> iterable) =>
    mapNotNull(f, iterable);
FxAsyncIterable<B> _$mapNotNullAsync<A, B extends Object>(
        FutureOr<B?> Function(A a) f, FxAsyncIterable<A> iterable) =>
    mapNotNullAsync(f, iterable);
Iterable<A> _$fxDifferenceBy<A, B>(
        B Function(A a) f, Iterable<A> iterable1, Iterable<A> iterable2) =>
    fxDifferenceBy(f, iterable1, iterable2);
FxAsyncIterable<A> _$fxDifferenceByAsync<A, B>(FutureOr<B> Function(A a) f,
        FxAsyncIterable<A> iterable1, FxAsyncIterable<A> iterable2) =>
    fxDifferenceByAsync(f, iterable1, iterable2);
Iterable<A> _$fxDifference<A>(Iterable<A> iterable1, Iterable<A> iterable2) =>
    fxDifference(iterable1, iterable2);
FxAsyncIterable<A> _$fxDifferenceAsync<A>(
        FxAsyncIterable<A> iterable1, FxAsyncIterable<A> iterable2) =>
    fxDifferenceAsync(iterable1, iterable2);
Iterable<A> _$fxIntersectionBy<A, B>(
        B Function(A a) f, Iterable<A> iterable1, Iterable<A> iterable2) =>
    fxIntersectionBy(f, iterable1, iterable2);
FxAsyncIterable<A> _$fxIntersectionByAsync<A, B>(FutureOr<B> Function(A a) f,
        FxAsyncIterable<A> iterable1, FxAsyncIterable<A> iterable2) =>
    fxIntersectionByAsync(f, iterable1, iterable2);
Iterable<A> _$fxIntersection<A>(Iterable<A> iterable1, Iterable<A> iterable2) =>
    fxIntersection(iterable1, iterable2);
FxAsyncIterable<A> _$fxIntersectionAsync<A>(
        FxAsyncIterable<A> iterable1, FxAsyncIterable<A> iterable2) =>
    fxIntersectionAsync(iterable1, iterable2);

// lazy/take_drop.dart
Iterable<A> _$fxTake<A>(int length, Iterable<A> iterable) =>
    fxTake(length, iterable);
FxAsyncIterable<A> _$fxTakeAsync<A>(int length, FxAsyncIterable<A> iterable) =>
    fxTakeAsync(length, iterable);
Iterable<A> _$fxTakeRight<A>(int length, Iterable<A> iterable) =>
    fxTakeRight(length, iterable);
FxAsyncIterable<A> _$fxTakeRightAsync<A>(
        int length, FxAsyncIterable<A> iterable) =>
    fxTakeRightAsync(length, iterable);
Iterable<A> _$fxTakeWhile<A>(bool Function(A a) f, Iterable<A> iterable) =>
    fxTakeWhile(f, iterable);
FxAsyncIterable<A> _$fxTakeWhileAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxTakeWhileAsync(f, iterable);
Iterable<A> _$takeWhileRight<A>(bool Function(A a) f, Iterable<A> iterable) =>
    takeWhileRight(f, iterable);
FxAsyncIterable<A> _$takeWhileRightAsync<A>(
        bool Function(A a) f, FxAsyncIterable<A> iterable) =>
    takeWhileRightAsync(f, iterable);
Iterable<A> _$dropWhileRight<A>(bool Function(A a) f, Iterable<A> iterable) =>
    dropWhileRight(f, iterable);
FxAsyncIterable<A> _$dropWhileRightAsync<A>(
        bool Function(A a) f, FxAsyncIterable<A> iterable) =>
    dropWhileRightAsync(f, iterable);
Iterable<A> _$takeUntilInclusive<A>(
        bool Function(A a) f, Iterable<A> iterable) =>
    takeUntilInclusive(f, iterable);
FxAsyncIterable<A> _$takeUntilInclusiveAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    takeUntilInclusiveAsync(f, iterable);
Iterable<A> _$fxDrop<A>(int length, Iterable<A> iterable) =>
    fxDrop(length, iterable);
FxAsyncIterable<A> _$fxDropAsync<A>(int length, FxAsyncIterable<A> iterable) =>
    fxDropAsync(length, iterable);
Iterable<A> _$fxDropRight<A>(int length, Iterable<A> iterable) =>
    fxDropRight(length, iterable);
FxAsyncIterable<A> _$fxDropRightAsync<A>(
        int length, FxAsyncIterable<A> iterable) =>
    fxDropRightAsync(length, iterable);
Iterable<A> _$fxDropWhile<A>(bool Function(A a) f, Iterable<A> iterable) =>
    fxDropWhile(f, iterable);
FxAsyncIterable<A> _$fxDropWhileAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxDropWhileAsync(f, iterable);
Iterable<A> _$fxDropUntil<A>(bool Function(A a) f, Iterable<A> iterable) =>
    fxDropUntil(f, iterable);
FxAsyncIterable<A> _$fxDropUntilAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxDropUntilAsync(f, iterable);
Iterable<A> _$fxSlice<A>(int start, Iterable<A> iterable, [int? end]) =>
    fxSlice(start, iterable, end);
FxAsyncIterable<A> _$fxSliceAsync<A>(int start, FxAsyncIterable<A> iterable,
        [int? end]) =>
    fxSliceAsync(start, iterable, end);
Iterable<List<A>> _$fxChunk<A>(int size, Iterable<A> iterable) =>
    fxChunk(size, iterable);
FxAsyncIterable<List<A>> _$fxChunkAsync<A>(
        int size, FxAsyncIterable<A> iterable) =>
    fxChunkAsync(size, iterable);

// lazy/zip.dart
Iterable<(A, B)> _$fxZip<A, B>(Iterable<A> iterable1, Iterable<B> iterable2) =>
    fxZip(iterable1, iterable2);
FxAsyncIterable<(A, B)> _$fxZipAsync<A, B>(
        FxAsyncIterable<A> iterable1, FxAsyncIterable<B> iterable2) =>
    fxZipAsync(iterable1, iterable2);
Iterable<(A, B, C)> _$fxZip3<A, B, C>(Iterable<A> iterable1,
        Iterable<B> iterable2, Iterable<C> iterable3) =>
    fxZip3(iterable1, iterable2, iterable3);
FxAsyncIterable<(A, B, C)> _$fxZip3Async<A, B, C>(FxAsyncIterable<A> iterable1,
        FxAsyncIterable<B> iterable2, FxAsyncIterable<C> iterable3) =>
    fxZip3Async(iterable1, iterable2, iterable3);
Iterable<(int, A)> _$zipWithIndex<A>(Iterable<A> iterable) =>
    zipWithIndex(iterable);
FxAsyncIterable<(int, A)> _$zipWithIndexAsync<A>(
        FxAsyncIterable<A> iterable) =>
    zipWithIndexAsync(iterable);
(List<A>, List<B>) _$fxUnzip<A, B>(Iterable<(A, B)> iterable) =>
    fxUnzip(iterable);
Future<(List<A>, List<B>)> _$fxUnzipAsync<A, B>(
        FxAsyncIterable<(A, B)> iterable) =>
    fxUnzipAsync(iterable);

// lazy/combine.dart
Iterable<A> _$fxAppend<A>(A a, Iterable<A> iterable) => fxAppend(a, iterable);
FxAsyncIterable<A> _$fxAppendAsync<A>(
        FutureOr<A> a, FxAsyncIterable<A> iterable) =>
    fxAppendAsync(a, iterable);
Iterable<A> _$fxPrepend<A>(A a, Iterable<A> iterable) => fxPrepend(a, iterable);
FxAsyncIterable<A> _$fxPrependAsync<A>(
        FutureOr<A> a, FxAsyncIterable<A> iterable) =>
    fxPrependAsync(a, iterable);
Iterable<A> _$fxConcat<A>(Iterable<A> iterable1, Iterable<A> iterable2) =>
    fxConcat(iterable1, iterable2);
FxAsyncIterable<A> _$fxConcatAsync<A>(
        FxAsyncIterable<A> iterable1, FxAsyncIterable<A> iterable2) =>
    fxConcatAsync(iterable1, iterable2);
Iterable<A> _$fxReverse<A>(Iterable<A> iterable) => fxReverse(iterable);
FxAsyncIterable<A> _$fxReverseAsync<A>(FxAsyncIterable<A> iterable) =>
    fxReverseAsync(iterable);
Iterable<T> _$fxCycle<T>(Iterable<T> iterable) => fxCycle(iterable);
FxAsyncIterable<T> _$fxCycleAsync<T>(FxAsyncIterable<T> iterable) =>
    fxCycleAsync(iterable);

// lazy/take_drop.dart + lazy/filter.dart + lazy/combine.dart (0.7.2)
Iterable<List<A>> _$fxWindowed<A>(int size, Iterable<A> iterable,
        {int step = 1, bool partial = false}) =>
    fxWindowed(size, iterable, step: step, partial: partial);
FxAsyncIterable<List<A>> _$fxWindowedAsync<A>(
        int size, FxAsyncIterable<A> iterable,
        {int step = 1, bool partial = false}) =>
    fxWindowedAsync(size, iterable, step: step, partial: partial);
Iterable<(A, A)> _$fxPairwise<A>(Iterable<A> iterable) => fxPairwise(iterable);
FxAsyncIterable<(A, A)> _$fxPairwiseAsync<A>(FxAsyncIterable<A> iterable) =>
    fxPairwiseAsync(iterable);
Iterable<A> _$fxUniqAdjacent<A>(Iterable<A> iterable) => fxUniqAdjacent(iterable);
FxAsyncIterable<A> _$fxUniqAdjacentAsync<A>(FxAsyncIterable<A> iterable) =>
    fxUniqAdjacentAsync(iterable);
Iterable<A> _$uniqAdjacentBy<A, B>(B Function(A a) f, Iterable<A> iterable) =>
    uniqAdjacentBy(f, iterable);
FxAsyncIterable<A> _$uniqAdjacentByAsync<A, B>(
        FutureOr<B> Function(A a) f, FxAsyncIterable<A> iterable) =>
    uniqAdjacentByAsync(f, iterable);
Iterable<A> _$fxIfEmpty<A>(
        Iterable<A> Function() fallback, Iterable<A> iterable) =>
    fxIfEmpty(fallback, iterable);
FxAsyncIterable<A> _$fxIfEmptyAsync<A>(FxAsyncIterable<A> Function() fallback,
        FxAsyncIterable<A> iterable) =>
    fxIfEmptyAsync(fallback, iterable);
Iterable<A> _$defaultIfEmpty<A>(A value, Iterable<A> iterable) =>
    defaultIfEmpty(value, iterable);
FxAsyncIterable<A> _$defaultIfEmptyAsync<A>(
        FutureOr<A> value, FxAsyncIterable<A> iterable) =>
    defaultIfEmptyAsync(value, iterable);

// lazy/effect.dart (0.7.2)
FxAsyncIterable<R> _$fxMapRetryAsync<A, R>(
        int attempts, FutureOr<R> Function(A a) f, FxAsyncIterable<A> iterable,
        {Duration Function(int failed)? delay}) =>
    fxMapRetryAsync(attempts, f, iterable, delay: delay);
Iterable<R> _$fxMapCatching<A, R>(R Function(A a) f,
        R Function(Object error, StackTrace stackTrace) onError,
        Iterable<A> iterable) =>
    fxMapCatching(f, onError, iterable);
FxAsyncIterable<R> _$fxMapCatchingAsync<A, R>(FutureOr<R> Function(A a) f,
        FutureOr<R> Function(Object error, StackTrace stackTrace) onError,
        FxAsyncIterable<A> iterable) =>
    fxMapCatchingAsync(f, onError, iterable);
FxAsyncIterable<A> _$fxTimeoutAsync<A>(
        Duration limit, FxAsyncIterable<A> iterable) =>
    fxTimeoutAsync(limit, iterable);

// strict/aggregate.dart
List<A> _$fxToList<A>(Iterable<A> iterable) => fxToList(iterable);
Future<List<A>> _$fxToListAsync<A>(FxAsyncIterable<A> iterable) =>
    fxToListAsync(iterable);
A _$fxReduce<A>(A Function(A acc, A a) f, Iterable<A> iterable) =>
    fxReduce(f, iterable);
Acc _$fxFold<A, Acc>(
        Acc seed, Acc Function(Acc acc, A a) f, Iterable<A> iterable) =>
    fxFold(seed, f, iterable);
void _$fxEach<A>(void Function(A a) f, Iterable<A> iterable) => fxEach(f, iterable);
Future<void> _$fxEachAsync<A>(
        FutureOr<void> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxEachAsync(f, iterable);
void _$fxConsume<A>(Iterable<A> iterable, [int? n]) => fxConsume(iterable, n);
Future<void> _$fxConsumeAsync<A>(FxAsyncIterable<A> iterable, [int? n]) =>
    fxConsumeAsync(iterable, n);
Future<A> _$fxReduceAsync<A>(
        FutureOr<A> Function(A acc, A a) f, FxAsyncIterable<A> iterable) =>
    fxReduceAsync(f, iterable);
Future<Acc> _$fxFoldAsync<A, Acc>(FutureOr<Acc> seed,
        FutureOr<Acc> Function(Acc acc, A a) f, FxAsyncIterable<A> iterable) =>
    fxFoldAsync(seed, f, iterable);
Acc _$foldWithIndex<A, Acc>(Acc seed,
        Acc Function(Acc acc, A a, int index) f, Iterable<A> iterable) =>
    foldWithIndex(seed, f, iterable);
Future<Acc> _$foldWithIndexAsync<A, Acc>(
        FutureOr<Acc> seed,
        FutureOr<Acc> Function(Acc acc, A a, int index) f,
        FxAsyncIterable<A> iterable) =>
    foldWithIndexAsync(seed, f, iterable);
Acc _$fxFoldRight<A, Acc>(
        Acc seed, Acc Function(Acc acc, A a) f, Iterable<A> iterable) =>
    fxFoldRight(seed, f, iterable);
Acc _$foldRightWithIndex<A, Acc>(Acc seed,
        Acc Function(Acc acc, A a, int index) f, Iterable<A> iterable) =>
    foldRightWithIndex(seed, f, iterable);
Future<Acc> _$fxFoldRightAsync<A, Acc>(FutureOr<Acc> seed,
        FutureOr<Acc> Function(Acc acc, A a) f, FxAsyncIterable<A> iterable) =>
    fxFoldRightAsync(seed, f, iterable);
Future<Acc> _$foldRightWithIndexAsync<A, Acc>(
        FutureOr<Acc> seed,
        FutureOr<Acc> Function(Acc acc, A a, int index) f,
        FxAsyncIterable<A> iterable) =>
    foldRightWithIndexAsync(seed, f, iterable);
num _$fxSum(Iterable<num> iterable) => fxSum(iterable);
Future<num> _$fxSumAsync(FxAsyncIterable<num> iterable) => fxSumAsync(iterable);
num _$fxProduct(Iterable<num> iterable) => fxProduct(iterable);
Future<num> _$fxProductAsync(FxAsyncIterable<num> iterable) =>
    fxProductAsync(iterable);
double _$fxAverage(Iterable<num> iterable) => fxAverage(iterable);
Future<double> _$fxAverageAsync(FxAsyncIterable<num> iterable) =>
    fxAverageAsync(iterable);
num _$fxMin(Iterable<num> iterable) => fxMin(iterable);
Future<num> _$fxMinAsync(FxAsyncIterable<num> iterable) => fxMinAsync(iterable);
num _$fxMax(Iterable<num> iterable) => fxMax(iterable);
Future<num> _$fxMaxAsync(FxAsyncIterable<num> iterable) => fxMaxAsync(iterable);
A? _$fxMinBy<A>(Object? Function(A a) f, Iterable<A> iterable) =>
    fxMinBy(f, iterable);
Future<A?> _$fxMinByAsync<A>(
        Object? Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxMinByAsync(f, iterable);
A? _$fxMaxBy<A>(Object? Function(A a) f, Iterable<A> iterable) =>
    fxMaxBy(f, iterable);
Future<A?> _$fxMaxByAsync<A>(
        Object? Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxMaxByAsync(f, iterable);
num _$fxSumBy<A>(num Function(A a) f, Iterable<A> iterable) =>
    fxSumBy(f, iterable);
Future<num> _$fxSumByAsync<A>(
        FutureOr<num> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxSumByAsync(f, iterable);
num _$fxProductBy<A>(num Function(A a) f, Iterable<A> iterable) =>
    fxProductBy(f, iterable);
Future<num> _$fxProductByAsync<A>(
        FutureOr<num> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxProductByAsync(f, iterable);
double _$fxAverageBy<A>(num Function(A a) f, Iterable<A> iterable) =>
    fxAverageBy(f, iterable);
Future<double> _$fxAverageByAsync<A>(
        FutureOr<num> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxAverageByAsync(f, iterable);
int _$fxSize<A>(Iterable<A> iterable) => fxSize(iterable);
Future<int> _$fxSizeAsync<A>(FxAsyncIterable<A> iterable) => fxSizeAsync(iterable);
Future<String> _$fxJoinAsync<A>(String sep, FxAsyncIterable<A> iterable) =>
    fxJoinAsync(sep, iterable);
Map<K, List<A>> _$fxGroupBy<A, K>(K Function(A a) f, Iterable<A> iterable) =>
    fxGroupBy(f, iterable);
Future<Map<K, List<A>>> _$fxGroupByAsync<A, K>(
        FutureOr<K> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxGroupByAsync(f, iterable);
Map<K, A> _$fxIndexBy<A, K>(K Function(A a) f, Iterable<A> iterable) =>
    fxIndexBy(f, iterable);
Future<Map<K, A>> _$fxIndexByAsync<A, K>(
        FutureOr<K> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxIndexByAsync(f, iterable);
Map<K, int> _$fxCountBy<A, K>(K Function(A a) f, Iterable<A> iterable) =>
    fxCountBy(f, iterable);
Map<K, Acc> _$fxFoldBy<A, K, Acc>(K Function(A a) key, Acc seed,
        Acc Function(Acc acc, A a) f, Iterable<A> iterable) =>
    fxFoldBy(key, seed, f, iterable);
Future<Map<K, Acc>> _$fxFoldByAsync<A, K, Acc>(
        FutureOr<K> Function(A a) key,
        FutureOr<Acc> seed,
        FutureOr<Acc> Function(Acc acc, A a) f,
        FxAsyncIterable<A> iterable) =>
    fxFoldByAsync(key, seed, f, iterable);
Future<Map<K, int>> _$fxCountByAsync<A, K>(
        FutureOr<K> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxCountByAsync(f, iterable);
List<A> _$fxSort<A>(int Function(A a, A b) f, Iterable<A> iterable) =>
    fxSort(f, iterable);
Future<List<A>> _$fxSortAsync<A>(
        int Function(A a, A b) f, FxAsyncIterable<A> iterable) =>
    fxSortAsync(f, iterable);
List<A> _$fxSortBy<A>(Object? Function(A a) f, Iterable<A> iterable) =>
    fxSortBy(f, iterable);
Future<List<A>> _$fxSortByAsync<A>(
        Object? Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxSortByAsync(f, iterable);
List<A> _$sortByDesc<A>(Object? Function(A a) f, Iterable<A> iterable) =>
    sortByDesc(f, iterable);
Future<List<A>> _$sortByDescAsync<A>(
        Object? Function(A a) f, FxAsyncIterable<A> iterable) =>
    sortByDescAsync(f, iterable);
List<A> _$fxTopBy<A>(
        int k, Object? Function(A a) f, Iterable<A> iterable) =>
    fxTopBy(k, f, iterable);
List<A> _$fxBottomBy<A>(
        int k, Object? Function(A a) f, Iterable<A> iterable) =>
    fxBottomBy(k, f, iterable);
Future<List<A>> _$fxTopByAsync<A>(
        int k, Object? Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxTopByAsync(k, f, iterable);
Future<List<A>> _$fxBottomByAsync<A>(
        int k, Object? Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxBottomByAsync(k, f, iterable);
List<({K key, List<A> items})> _$fxGroupedBy<A, K>(
        K Function(A a) f, Iterable<A> iterable) =>
    fxGroupedBy(f, iterable);
Future<List<({K key, List<A> items})>> _$fxGroupedByAsync<A, K>(
        FutureOr<K> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxGroupedByAsync(f, iterable);
int _$fxCountWhere<A>(bool Function(A a) f, Iterable<A> iterable) =>
    fxCountWhere(f, iterable);
Future<int> _$fxCountWhereAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxCountWhereAsync(f, iterable);
(List<A>, List<A>) _$fxPartition<A>(bool Function(A a) f, Iterable<A> iterable) =>
    fxPartition(f, iterable);
Future<(List<A>, List<A>)> _$fxPartitionAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxPartitionAsync(f, iterable);
// tee's fold records reach fx.dart as `s.Fold` / `s.AsyncFold`, so the
// prefix rewrite needs these two names to exist as types, not functions.
typedef _$Fold<A, R> = Fold<A, R>;
typedef _$AsyncFold<A, R> = AsyncFold<A, R>;
(R1, R2) _$fxTee<A, R1, R2>(
        Iterable<A> iterable, Fold<A, R1> first, Fold<A, R2> second) =>
    fxTee(iterable, first, second);
(R1, R2, R3) _$fxTee3<A, R1, R2, R3>(Iterable<A> iterable, Fold<A, R1> first,
        Fold<A, R2> second, Fold<A, R3> third) =>
    fxTee3(iterable, first, second, third);
Future<(R1, R2)> _$fxTeeAsync<A, R1, R2>(FxAsyncIterable<A> iterable,
        AsyncFold<A, R1> first, AsyncFold<A, R2> second) =>
    fxTeeAsync(iterable, first, second);

// strict/access.dart
A? _$fxHead<A>(Iterable<A> iterable) => fxHead(iterable);
Future<A?> _$fxHeadAsync<A>(FxAsyncIterable<A> iterable) => fxHeadAsync(iterable);
A? _$fxLast<A>(Iterable<A> iterable) => fxLast(iterable);
Future<A?> _$fxLastAsync<A>(FxAsyncIterable<A> iterable) => fxLastAsync(iterable);
A? _$fxFind<A>(bool Function(A a) f, Iterable<A> iterable) => fxFind(f, iterable);
Future<A?> _$fxFindAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxFindAsync(f, iterable);
int _$fxFindIndex<A>(bool Function(A a) f, Iterable<A> iterable) =>
    fxFindIndex(f, iterable);
Future<int> _$fxFindIndexAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxFindIndexAsync(f, iterable);
bool _$fxSome<A>(bool Function(A a) f, Iterable<A> iterable) => fxSome(f, iterable);
Future<bool> _$fxSomeAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxSomeAsync(f, iterable);
bool _$fxEvery<A>(bool Function(A a) f, Iterable<A> iterable) =>
    fxEvery(f, iterable);
Future<bool> _$fxEveryAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxEveryAsync(f, iterable);
bool _$fxNone<A>(bool Function(A a) f, Iterable<A> iterable) =>
    fxNone(f, iterable);
Future<bool> _$fxNoneAsync<A>(
        FutureOr<bool> Function(A a) f, FxAsyncIterable<A> iterable) =>
    fxNoneAsync(f, iterable);
bool _$fxSequenceEqual<A>(
        Iterable<A> a, Iterable<A> b, [bool Function(A, A)? eq]) =>
    fxSequenceEqual(a, b, eq);
Future<bool> _$fxSequenceEqualAsync<A>(
        FxAsyncIterable<A> a, FxAsyncIterable<A> b, [bool Function(A, A)? eq]) =>
    fxSequenceEqualAsync(a, b, eq);
B? _$firstNotNullOf<A, B extends Object>(
        B? Function(A a) f, Iterable<A> iterable) =>
    firstNotNullOf(f, iterable);
Future<B?> _$firstNotNullOfAsync<A, B extends Object>(
        FutureOr<B?> Function(A a) f, FxAsyncIterable<A> iterable) =>
    firstNotNullOfAsync(f, iterable);
WRAPPERS

} | dart run "$ROOT/tool/strip_dart_comments.dart" > "$OUT.tmp"

# The banner is added after stripping so it survives it. Everything else in
# the file is comment-free: this file's bytes decide every playground
# artifact id (a snippet's id hashes bundle + snippet), so leaving lib/'s
# dartdoc in here meant a comment-only edit rotated all ~450 ids and rewrote
# the data-pg attribute on ~1,900 generated pages. Analyzer `ignore`
# directives are kept — CI runs `dart analyze` on this file.
{
  cat <<'BANNER'
// GENERATED by tools/build_single_file.sh — single-file build of fxdart for the web playground. Do not edit.
// Comments are stripped (tool/strip_dart_comments.dart) so that a dartdoc-only
// change to lib/ leaves this file byte-identical and churns no artifact ids.
BANNER
  cat "$OUT.tmp"
} > "$OUT"
rm -f "$OUT.tmp"

echo "Generated $OUT"
wc -l "$OUT"

echo "Running dart analyze..."
dart analyze "$OUT"
