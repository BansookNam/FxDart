import 'dart:async';

import '../typed/either.dart';
import '../typed/raise.dart';
import 'events.dart';
import 'events_notify.dart';

/// Moves a failure between the two channels a Dart [Stream] has: the error
/// channel every `listen(onError:)` sees, and the value channel carrying
/// [Either].
///
/// The events layer's own error tools (`onErrorReturn`, `onErrorResume`,
/// `retryOn`, `retryOnError`) all speak untyped `Object`, because that is what
/// the error channel carries. These operators are the bridge to the typed
/// half of the library: once a failure is a [Left], the compiler knows its
/// type and a `switch` over the event cannot forget to handle it.
///
/// Convert at the source boundary and stay on the value channel afterwards.
/// [attempt] AFTER `retryOn` / `retryOnError`, never before — those operators
/// watch the error channel, and there is nothing left there to retry once the
/// error has become a value.
extension FxEventsTypedErrors<T> on FxEvents<T> {
  /// Turns each error event into a [Left] built by [onThrow], and each data
  /// event into a [Right] — so the chain keeps running past a failure the
  /// error channel would otherwise hand to a `StreamBuilder` as an error
  /// state.
  ///
  /// A Dart error is not terminal, so the source keeps its subscription and
  /// later events still arrive. A throwing [onThrow] becomes an error event
  /// and the chain continues, as with a throwing `peek` callback — the failure
  /// it was called about is replaced, not chained, and the error channel is
  /// open again below, so a `separated()` downstream fans that one error out
  /// to both halves.
  ///
  /// This is not a raise-signal boundary: whatever is on the error channel
  /// becomes a [Left] — including the raise signal that `catching` and
  /// `foldRaise` always rethrow, and the [RaiseLeakedError] the raise layer
  /// means to be loud about. Keep raise scopes inside [mapEither], where they
  /// belong.
  FxEvents<Either<E, T>> attempt<E>(
    E Function(Object error, StackTrace stackTrace) onThrow,
  ) {
    final out = StreamController<Either<E, T>>();
    out.onListen = () {
      final sub = stream.listen(
        (v) => out.add(Right(v)),
        onError: (Object e, StackTrace st) {
          final E failure;
          try {
            failure = onThrow(e, st);
          } catch (e2, st2) {
            out.addError(e2, st2);
            return;
          }
          out.add(Left(failure));
        },
        onDone: out.close,
      );
      out
        ..onPause = sub.pause
        ..onResume = sub.resume
        ..onCancel = sub.cancel;
    };
    return FxEvents(out.stream);
  }

  /// Runs [f] for each event in its own raise scope: `r.raise` (and
  /// `r.ensure` / `r.bind`) becomes a [Left], a normal return a [Right].
  ///
  /// A *thrown* exception stays on the error channel — that is the [either]
  /// builder's contract, and it keeps [attempt] the single place where a
  /// throw turns into a value. Chaining `attempt` after this one does catch
  /// the throw, at the cost of a nested `Either<E, Either<E, R>>` this layer
  /// has no flatten step for; when a callback both raises and throws, prefer
  /// [eitherCatching] inside [mapEither] so one [Either] comes out.
  FxEvents<Either<E, R>> mapEither<E, R>(R Function(Raise<E> r, T value) f) =>
      FxEvents(stream.map((v) => either<E, R>((r) => f(r, v))));

  /// Async twin of [mapEither]; one event at a time, like `asyncMap`.
  ///
  /// [eitherAsync]'s rule carries over: a raise must happen inside the awaited
  /// chain. A raise from an unawaited future outlives the scope and surfaces
  /// as an unhandled zone error instead of a [Left].
  FxEvents<Either<E, R>> mapEitherAsync<E, R>(
    FutureOr<R> Function(Raise<E> r, T value) f,
  ) => FxEvents(stream.asyncMap((v) => eitherAsync<E, R>((r) => f(r, v))));
}

/// Either-aware operators on an event chain of [Either] values — the push-side
/// counterparts of `FxEitherOps` (sync) and `FxAsyncEitherOps` (pull).
///
/// No terminals live here: `pull()` hands the chain to `FxAsync`, where
/// `sequence()` and `flattenOrAccumulate()` already exist.
extension FxEventsEitherOps<L, R> on FxEvents<Either<L, R>> {
  /// Only the success values, unwrapped.
  FxEvents<R> rights() => FxEvents(
    stream.where((e) => e is Right<L, R>).map((e) => (e as Right<L, R>).value),
  );

  /// Only the failure values, unwrapped.
  FxEvents<L> lefts() => FxEvents(
    stream.where((e) => e is Left<L, R>).map((e) => (e as Left<L, R>).value),
  );

  /// Splits into `(failures, successes)` — the [Either] shape of `partition`,
  /// and the events-layer twin of `FxEitherOps.separated`.
  ///
  /// Inherits `partition`'s lifetime rules: the record is returned eagerly,
  /// listening to either side starts the source, cancelling both cancels it,
  /// and a value belonging to a side nobody listens to is dropped rather
  /// than buffered.
  ///
  /// It inherits `partition`'s error fan-out too: an error *event* is not an
  /// [Either], so it goes to every side currently listening — one upstream
  /// failure surfaces on both halves. Call
  /// [FxEventsTypedErrors.attempt] upstream when a failure should be counted
  /// once, as a [Left] on the `failures` half.
  ///
  /// One inherited rule is not a drop: `partition` does not forward pause and
  /// resume to the source, so a half whose listener pauses keeps accumulating
  /// events in its own controller instead of applying backpressure upstream.
  (FxEvents<L> failures, FxEvents<R> successes) separated() {
    // The extension is applied explicitly because the playground bundle merges
    // every file into one library, where the top-level `partition(f, iterable)`
    // would win this unqualified call over the implicit-`this` extension member.
    final (failures, successes) = FxEventsNotify(
      this,
    ).partition((e) => e is Left<L, R>);
    return (failures.lefts(), successes.rights());
  }
}

/// Puts a typed failure back on the error channel — the direction opposite to
/// [FxEventsTypedErrors.attempt], on non-nullable failures only, because Dart
/// cannot `throw` null.
extension FxEventsRaiseLefts<L extends Object, R> on FxEvents<Either<L, R>> {
  /// Unwraps each [Right] and puts each [Left] back on the error channel, for
  /// a boundary that hands the stream to `Stream`-based code expecting Dart
  /// errors.
  ///
  /// One error event per [Left], carrying a fresh [StackTrace] — the trace
  /// [FxEventsTypedErrors.attempt] captured is not part of the [Left], so an
  /// `attempt` / `raiseLefts` round trip preserves the failure value and not
  /// its origin. The chain continues under the default `cancelOnError: false`,
  /// so a later [Right] still arrives; a listener passing `cancelOnError: true`
  /// stops at the first [Left].
  FxEvents<R> raiseLefts() => FxEvents(
    stream.map(
      (e) => switch (e) {
        Right(:final value) => value,
        Left(:final value) => throw value,
      },
    ),
  );
}
