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
        fromStreamLatest,
        fromStreamChunked,
        fromStreamNext,
        concurrentAsync,
        concurrentPoolAsync;
export 'src/config.dart' show FxDart, FxConfig;
export 'src/fx.dart'
    show
        fx,
        fxAsync,
        fxStream,
        Fx,
        FxAsync,
        FxNum,
        FxAsyncNum,
        FxEntry,
        FxAsyncEntry,
        FxStreamEntry,
        FxFutureEntry,
        FxPair,
        FxAsyncPair;
export 'src/dart_aliases.dart';
export 'src/lazy/combine.dart';
export 'src/lazy/effect.dart';
export 'src/lazy/filter.dart';
export 'src/lazy/map.dart';
export 'src/lazy/take_drop.dart';
export 'src/lazy/zip.dart';
export 'src/pipe.dart';
export 'src/strict/access.dart';
export 'src/strict/aggregate.dart';
export 'src/strict/curried.dart';
export 'src/strict/func.dart';
export 'src/strict/object.dart';
export 'src/strict/predicates.dart';
export 'src/strict/sequence_equal.dart';
export 'src/stream/events.dart'
    show FxEvents, FxEventsEntry, LiveValue, EventEmitter, fxEvents;
export 'src/stream/events_chain.dart';
export 'src/stream/events_combine.dart';
export 'src/stream/events_either.dart';
export 'src/stream/events_notify.dart';
export 'src/stream/events_pull.dart';
export 'src/stream/events_scan.dart';
export 'src/stream/events_select.dart';
export 'src/stream/events_window.dart';
export 'src/stream/connectable.dart';
export 'src/stream/values.dart';
export 'src/stream/subscriptions.dart' show FxSubscriptions;
export 'src/typed/accumulate.dart'
    show Accumulated, Accumulator, AccumulatingRaise, AccumulatingRaiseOps;
export 'src/typed/either.dart' show Either, EitherNel, Left, Right;
export 'src/typed/fx_either.dart'
    show
        FxAccumulateOps,
        FxAsyncAccumulateOps,
        FxAsyncEitherOps,
        FxEitherOps,
        flattenOrAccumulate,
        flattenOrAccumulateAsync,
        lefts,
        leftsAsync,
        mapOrAccumulate,
        mapOrAccumulateAsync,
        rights,
        rightsAsync,
        separateEither,
        separateEitherAsync,
        sequenceEither,
        sequenceEitherAsync;
export 'src/typed/non_empty_list.dart' show IterableToNel, Nel, NonEmptyList;
export 'src/typed/raise.dart'
    show
        Raise,
        RaiseLeakedError,
        RaiseOps,
        SingletonRaise,
        catching,
        catchingAsync,
        either,
        eitherAsync,
        eitherCatching,
        eitherCatchingAsync,
        foldRaise,
        foldRaiseAsync,
        nullable,
        nullableAsync;
export 'src/util/shuffle.dart';
export 'src/util/timing.dart';
