import 'dart:async';

import 'events.dart';

/// A reified stream notification — a next, error, or done that can
/// travel *through* a stream as a value.
///
/// Produced by [FxEventsNotify.materialize] and consumed by
/// [FxEventsDematerialize.dematerialize]. fxdart events layer, after Rx's
/// `Notification`.
sealed class StreamEvent<T> {
  /// Shared const constructor for the three kinds.
  const StreamEvent();
}

/// A data event. fxdart events layer, after Rx's `Notification.next`.
final class Next<T> extends StreamEvent<T> {
  /// The value the source emitted.
  final T value;

  /// Wraps [value] as a data notification.
  const Next(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Next<T> && other.value == value;

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() => 'Next($value)';
}

/// An error event. fxdart events layer, after Rx's `Notification.error`.
final class Err<T> extends StreamEvent<T> {
  /// The error the source emitted.
  final Object error;

  /// The stack trace that accompanied [error], or [StackTrace.empty].
  final StackTrace stackTrace;

  /// Wraps [error] (and optional [stackTrace]) as an error notification.
  const Err(this.error, [this.stackTrace = StackTrace.empty]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Err<T> && other.error == error && other.stackTrace == stackTrace;

  @override
  int get hashCode => Object.hash(runtimeType, error, stackTrace);

  @override
  String toString() => 'Err($error)';
}

/// A completion event. fxdart events layer, after Rx's
/// `Notification.complete`.
final class Done<T> extends StreamEvent<T> {
  /// The terminal notification; it carries no value.
  const Done();

  @override
  bool operator ==(Object other) => identical(this, other) || other is Done<T>;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Done()';
}

/// Notification, time-metadata, partition, and equality operators on
/// [FxEvents].
///
/// Each operator is a thin wrapper over [FxEvents.stream]; the source
/// chain stays cold until the result is listened to. fxdart events layer.
extension FxEventsNotify<T> on FxEvents<T> {
  /// Reifies each data / error / done as a [StreamEvent], so terminals can
  /// travel as values.
  ///
  /// A data event becomes [Next]. An error becomes [Err] and then the
  /// result **completes** — it does not error. A close becomes [Done]
  /// and then the result completes.
  ///
  /// fxdart events layer, after Rx's `materialize`.
  FxEvents<StreamEvent<T>> materialize() {
    final out = StreamController<StreamEvent<T>>();
    out.onListen = () {
      final sub = stream.listen(
        (v) {
          if (out.isClosed) return;
          out.add(Next(v));
        },
        onError: (Object e, StackTrace st) {
          if (out.isClosed) return;
          out
            ..add(Err<T>(e, st))
            ..close();
        },
        onDone: () {
          if (out.isClosed) return;
          out
            ..add(Done<T>())
            ..close();
        },
      );
      out
        ..onPause = sub.pause
        ..onResume = sub.resume
        ..onCancel = sub.cancel;
    };
    return FxEvents(out.stream);
  }

  /// Pairs each event with the wall-clock time it arrived.
  ///
  /// [now] defaults to [DateTime.now]; pass a clock in tests. Errors and
  /// close pass through unchanged. fxdart events layer, after Rx's
  /// `timestamp`.
  FxEvents<(DateTime at, T value)> timestamped({DateTime Function()? now}) {
    final clock = now ?? DateTime.now;
    final out = StreamController<(DateTime, T)>();
    out.onListen = () {
      final sub = stream.listen(
        (v) => out.add((clock(), v)),
        onError: out.addError,
        onDone: out.close,
      );
      out
        ..onPause = sub.pause
        ..onResume = sub.resume
        ..onCancel = sub.cancel;
    };
    return FxEvents(out.stream);
  }

  /// Pairs each event with the time since the previous one.
  ///
  /// The first event is always [Duration.zero]; later events carry
  /// `at.difference(previousAt)`. [now] defaults to [DateTime.now]. Errors
  /// and close pass through unchanged. fxdart events layer, after Rx's
  /// `timeInterval`.
  FxEvents<(Duration dt, T value)> intervals({DateTime Function()? now}) {
    final clock = now ?? DateTime.now;
    final out = StreamController<(Duration, T)>();
    out.onListen = () {
      DateTime? prev;
      final sub = stream.listen(
        (v) {
          final at = clock();
          final dt = prev == null ? Duration.zero : at.difference(prev!);
          prev = at;
          out.add((dt, v));
        },
        onError: out.addError,
        onDone: out.close,
      );
      out
        ..onPause = sub.pause
        ..onResume = sub.resume
        ..onCancel = sub.cancel;
    };
    return FxEvents(out.stream);
  }

  /// Splits this chain into `(matches, rest)` by [test], sharing **one**
  /// run of the source.
  ///
  /// The record is returned eagerly. Listening to either side starts the
  /// source; cancelling both (or the only listener) cancels it. Values
  /// that belong to a side nobody is listening to are dropped, not
  /// buffered. fxdart events layer, after Rx's `partition`.
  (FxEvents<T> matches, FxEvents<T> rest) partition(bool Function(T) test) {
    final matchCtrl = StreamController<T>();
    final restCtrl = StreamController<T>();
    StreamSubscription<T>? sub;
    var started = false;
    var stopped = false;

    void deliverError(Object e, StackTrace st) {
      if (matchCtrl.hasListener) matchCtrl.addError(e, st);
      if (restCtrl.hasListener) restCtrl.addError(e, st);
    }

    void ensureSource() {
      if (started) return;
      started = true;
      sub = stream.listen(
        (v) {
          final bool pass;
          try {
            pass = test(v);
          } catch (e, st) {
            deliverError(e, st);
            return;
          }
          final side = pass ? matchCtrl : restCtrl;
          if (side.hasListener) side.add(v);
        },
        onError: deliverError,
        onDone: () {
          stopped = true;
          sub = null;
          if (!matchCtrl.isClosed) matchCtrl.close();
          if (!restCtrl.isClosed) restCtrl.close();
        },
      );
    }

    Future<void>? maybeStop() {
      if (matchCtrl.hasListener || restCtrl.hasListener) return null;
      stopped = true;
      final s = sub;
      sub = null;
      return s?.cancel();
    }

    void listenSide(StreamController<T> side) {
      if (stopped) {
        side.close();
        return;
      }
      ensureSource();
    }

    matchCtrl.onListen = () => listenSide(matchCtrl);
    matchCtrl.onCancel = maybeStop;
    restCtrl.onListen = () => listenSide(restCtrl);
    restCtrl.onCancel = maybeStop;

    return (FxEvents(matchCtrl.stream), FxEvents(restCtrl.stream));
  }

  /// True when this chain and [other] emit the same values (by [eq], or
  /// `==`) in the same order and complete together.
  ///
  /// False on the first value or length mismatch. An error from either
  /// side fails the future. fxdart events layer, after Rx's
  /// `sequenceEqual`.
  Future<bool> sequenceEqual(
    Stream<T> other, {
    bool Function(T a, T b)? eq,
  }) async {
    final equal = eq ?? (T a, T b) => a == b;
    final a = StreamIterator(stream);
    final b = StreamIterator(other);
    try {
      while (true) {
        final hasA = await a.moveNext();
        final hasB = await b.moveNext();
        if (!hasA && !hasB) return true;
        if (!hasA || !hasB) return false;
        if (!equal(a.current, b.current)) return false;
      }
    } finally {
      await a.cancel();
      await b.cancel();
    }
  }
}

/// Inverse of [FxEventsNotify.materialize].
extension FxEventsDematerialize<T> on FxEvents<StreamEvent<T>> {
  /// Unwraps [StreamEvent]s back into data / error / done.
  ///
  /// [Next] becomes a value, [Err] becomes [Stream.addError], [Done]
  /// closes the result. Anything after [Done] is ignored. A source error
  /// (not an [Err] notification) is forwarded and the result closes.
  ///
  /// fxdart events layer, after Rx's `dematerialize`.
  FxEvents<T> dematerialize() {
    final out = StreamController<T>();
    out.onListen = () {
      var finished = false;
      final sub = stream.listen(
        (event) {
          if (finished) return;
          switch (event) {
            case Next(:final value):
              out.add(value);
            case Err(:final error, :final stackTrace):
              out.addError(error, stackTrace);
            case Done():
              finished = true;
              out.close();
          }
        },
        onError: (Object e, StackTrace st) {
          if (finished) return;
          finished = true;
          out
            ..addError(e, st)
            ..close();
        },
        onDone: () {
          if (finished) return;
          finished = true;
          out.close();
        },
      );
      out
        ..onPause = sub.pause
        ..onResume = sub.resume
        ..onCancel = sub.cancel;
    };
    return FxEvents(out.stream);
  }
}
