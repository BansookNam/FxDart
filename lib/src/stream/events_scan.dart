import 'dart:async';

import 'events.dart';

/// Scan-flatten and recursive expand on [FxEvents].
///
/// fxdart events layer, after Rx's `mergeScan`, `switchScan`, and `expand`.
/// The seed of [mergeScan] / [switchScan] is **not** emitted — unlike
/// [FxEvents.scan], which emits the seed before any event arrives.
extension FxEventsScan<T> on FxEvents<T> {
  /// Folds each event into shared state by opening `accumulator(state, value)`
  /// as an inner stream. Every inner emission becomes the new state and is
  /// forwarded; the [seed] itself is never emitted.
  ///
  /// That last point is the difference from [FxEvents.scan], which yields the
  /// seed first (the pull-layer convention). This matches Rx's `mergeScan`.
  ///
  /// With [concurrent] set, at most that many inner streams run at a time
  /// and later source events wait their turn in a queue. Concurrent inners
  /// share one state variable — the latest inner emission wins. Null
  /// [concurrent] is unlimited. Closes when the source has closed and every
  /// inner stream has finished. An inner error is forwarded.
  ///
  /// Throws an [ArgumentError] when [concurrent] is below 1.
  FxEvents<R> mergeScan<R>(
    R seed,
    Stream<R> Function(R acc, T value) accumulator, {
    int? concurrent,
  }) {
    if (concurrent != null && concurrent < 1) {
      throw ArgumentError.value(concurrent, 'concurrent', 'must be at least 1');
    }
    final out = StreamController<R>();
    out.onListen = () {
      var state = seed;
      final inners = <StreamSubscription<R>>[];
      final waiting = <T>[];
      var outerDone = false;
      void settle() {
        if (outerDone && inners.isEmpty && waiting.isEmpty && !out.isClosed) {
          out.close();
        }
      }

      void start(T v) {
        final Stream<R> inner;
        try {
          inner = accumulator(state, v);
        } catch (e, st) {
          out.addError(e, st);
          if (waiting.isNotEmpty) start(waiting.removeAt(0));
          settle();
          return;
        }
        late final StreamSubscription<R> s;
        s = inner.listen(
          (r) {
            state = r;
            out.add(r);
          },
          onError: out.addError,
          onDone: () {
            inners.remove(s);
            if (waiting.isNotEmpty) start(waiting.removeAt(0));
            settle();
          },
        );
        inners.add(s);
      }

      final sub = stream.listen(
        (v) {
          if (concurrent != null && inners.length >= concurrent) {
            waiting.add(v);
          } else {
            start(v);
          }
        },
        onError: out.addError,
        onDone: () {
          outerDone = true;
          settle();
        },
      );
      out.onCancel = () =>
          Future.wait([sub.cancel(), for (final s in inners) s.cancel()]);
    };
    return FxEvents(out.stream);
  }

  /// Like [mergeScan], but each new source value **cancels** the previous
  /// inner stream mid-flight. The latest inner emission (if any) is the
  /// state handed to the next [accumulator] call.
  ///
  /// The [seed] is not emitted — unlike [FxEvents.scan]. After the source
  /// closes, the current inner is allowed to finish before the result
  /// closes. An inner error is forwarded.
  FxEvents<R> switchScan<R>(
    R seed,
    Stream<R> Function(R acc, T value) accumulator,
  ) {
    final out = StreamController<R>();
    out.onListen = () {
      var state = seed;
      StreamSubscription<R>? innerSub;
      var outerDone = false;
      final sub = stream.listen(
        (v) {
          innerSub?.cancel();
          innerSub = null;
          final Stream<R> inner;
          try {
            inner = accumulator(state, v);
          } catch (e, st) {
            out.addError(e, st);
            return;
          }
          late final StreamSubscription<R> s;
          s = inner.listen(
            (r) {
              state = r;
              out.add(r);
            },
            onError: out.addError,
            onDone: () {
              if (identical(innerSub, s)) {
                innerSub = null;
                if (outerDone && !out.isClosed) out.close();
              }
            },
          );
          innerSub = s;
        },
        onError: out.addError,
        onDone: () {
          outerDone = true;
          if (innerSub == null && !out.isClosed) out.close();
        },
      );
      out.onCancel = () =>
          Future.wait([sub.cancel(), if (innerSub != null) innerSub!.cancel()]);
    };
    return FxEvents(out.stream);
  }

  /// Emits every source value, then recursively flattens [project] of that
  /// value — and of every value [project] itself emits — breadth-first.
  ///
  /// This is Rx's `expand`. It is not named `expand` because the pull
  /// layer already uses that word for iterable flatMap. A [project] that
  /// never returns an empty stream will not terminate.
  ///
  /// With [concurrent] set, at most that many [project] streams run at a
  /// time; further values (source or projected) wait in a queue. Null
  /// [concurrent] is unlimited. Closes when the source has closed, the
  /// queue is empty, and every in-flight [project] has finished.
  ///
  /// Throws an [ArgumentError] when [concurrent] is below 1.
  FxEvents<T> expandEach(
    Stream<T> Function(T value) project, {
    int? concurrent,
  }) {
    if (concurrent != null && concurrent < 1) {
      throw ArgumentError.value(concurrent, 'concurrent', 'must be at least 1');
    }
    final out = StreamController<T>();
    out.onListen = () {
      final queue = <T>[];
      final inners = <StreamSubscription<T>>[];
      var outerDone = false;
      var draining = false;
      void settle() {
        if (outerDone &&
            inners.isEmpty &&
            queue.isEmpty &&
            !draining &&
            !out.isClosed) {
          out.close();
        }
      }

      void drain() {
        if (draining) return;
        draining = true;
        try {
          while (queue.isNotEmpty &&
              (concurrent == null || inners.length < concurrent)) {
            final v = queue.removeAt(0);
            out.add(v);
            final Stream<T> inner;
            try {
              inner = project(v);
            } catch (e, st) {
              out.addError(e, st);
              continue;
            }
            late final StreamSubscription<T> s;
            s = inner.listen(
              (child) {
                queue.add(child);
                drain();
              },
              onError: out.addError,
              onDone: () {
                inners.remove(s);
                drain();
              },
            );
            inners.add(s);
          }
        } finally {
          draining = false;
        }
        settle();
      }

      final sub = stream.listen(
        (v) {
          queue.add(v);
          drain();
        },
        onError: out.addError,
        onDone: () {
          outerDone = true;
          drain();
        },
      );
      out.onCancel = () =>
          Future.wait([sub.cancel(), for (final s in inners) s.cancel()]);
    };
    return FxEvents(out.stream);
  }
}
