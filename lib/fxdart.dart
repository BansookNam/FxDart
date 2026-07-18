/// A functional programming library for Dart, ported from
/// [FxTS](https://fxts.dev).
///
/// - **Sync** operators work on plain [Iterable]s and stay lazy.
/// - **Async** operators work on [FxAsyncIterable] — a pull-based async
///   protocol with a concurrency back-channel (`concurrentAsync`), which
///   Dart Streams cannot express. Bridge with `toAsync`, `fromStream`,
///   and `toStream()`.
/// - **Pipelines**: use the typed `fx()` chain; the dynamic `pipe` exists
///   for FxTS parity but loses static types (Dart has no variadic
///   generics/overloads).
library;

export 'src/async_iterable.dart'
    show
        Concurrent,
        IterResult,
        FxAsyncIterable,
        FxAsyncIterator,
        FxAsyncIterableToStream,
        asyncEmpty,
        toAsync,
        fromStream,
        concurrentAsync,
        concurrentPoolAsync;
export 'src/fx.dart' show fx, fxAsync, fxStream, Fx, FxAsync, FxNum, FxAsyncNum;
export 'src/lazy/combine.dart';
export 'src/lazy/filter.dart';
export 'src/lazy/map.dart';
export 'src/lazy/take_drop.dart';
export 'src/lazy/zip.dart';
export 'src/pipe.dart';
export 'src/strict/access.dart';
export 'src/strict/aggregate.dart';
export 'src/strict/func.dart';
export 'src/strict/object.dart';
export 'src/strict/predicates.dart';
export 'src/util/shuffle.dart';
export 'src/util/timing.dart';
