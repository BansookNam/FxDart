import 'dart:async';

import 'events.dart';

/// Chain-completeness operators on [FxEvents].
///
/// Each operator is an extension method (never a [Stream] extension) so it
/// cannot collide with rxdart. Implementations listen through the public
/// [FxEvents.stream] getter; the result is a new [FxEvents] over a derived
/// stream. Controller-based operators are single-subscription even when the
/// source is broadcast, matching the rest of the events layer.
extension FxEventsChain<T> on FxEvents<T> {
  // --- effects --------------------------------------------------------------

  /// Runs side effects on each notification and passes the stream through
  /// unchanged.
  ///
  /// A throwing callback becomes an error event and the chain continues;
  /// the event whose peek failed is not re-emitted. fxdart events layer,
  /// after Rx's `tap` / `doOn*`.
  FxEvents<T> peek(
    void Function(T)? onData, {
    void Function(Object, StackTrace)? onError,
    void Function()? onDone,
  }) {
    final out = StreamController<T>();
    out.onListen = () {
      final sub = stream.listen(
        (v) {
          if (onData != null) {
            try {
              onData(v);
            } catch (e, st) {
              out.addError(e, st);
              return;
            }
          }
          out.add(v);
        },
        onError: (Object e, StackTrace st) {
          if (onError != null) {
            try {
              onError(e, st);
            } catch (e2, st2) {
              out.addError(e2, st2);
              return;
            }
          }
          out.addError(e, st);
        },
        onDone: () {
          if (onDone != null) {
            try {
              onDone();
            } catch (e, st) {
              out.addError(e, st);
            }
          }
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

  // --- filtering & slicing --------------------------------------------------

  /// Mirrors events while [test] is true, then cancels the source and
  /// closes — the failing event is not emitted.
  ///
  /// fxdart events layer, after Rx's `takeWhile`.
  FxEvents<T> takeWhile(bool Function(T) test) =>
      FxEvents(stream.takeWhile(test));

  /// Drops events while [test] is true, then mirrors the rest.
  ///
  /// fxdart events layer, after Rx's `skipWhile`. The name is [dropWhile]
  /// because pull-layer names win; [skipWhile] is kept as an alias because
  /// the pull layer has that spelling too.
  FxEvents<T> dropWhile(bool Function(T) test) =>
      FxEvents(stream.skipWhile(test));

  /// Dart-idiomatic alias of [dropWhile].
  FxEvents<T> skipWhile(bool Function(T) test) => dropWhile(test);

  /// Mirrors events until [test] is true, emits the matching event, then
  /// cancels the source and closes.
  ///
  /// A throwing [test] becomes an error event and the chain continues.
  /// fxdart events layer, after Rx's `takeWhile` with `{inclusive: true}`.
  FxEvents<T> takeUntilInclusive(bool Function(T) test) {
    final out = StreamController<T>();
    out.onListen = () {
      final sub = stream.listen(
        null,
        onError: out.addError,
        onDone: () {
          if (!out.isClosed) out.close();
        },
      );
      sub.onData((v) {
        if (out.isClosed) return;
        final bool stop;
        try {
          stop = test(v);
        } catch (e, st) {
          out.addError(e, st);
          return;
        }
        out.add(v);
        if (stop) {
          sub.cancel();
          out.close();
        }
      });
      out
        ..onPause = sub.pause
        ..onResume = sub.resume
        ..onCancel = sub.cancel;
    };
    return FxEvents(out.stream);
  }

  /// The last [count] events, emitted when the source closes.
  ///
  /// Nothing is forwarded until close — a live source is fully buffered
  /// (capped at [count]). A [count] below 1 yields an empty stream without
  /// subscribing. fxdart events layer, after Rx's `takeLast`; named
  /// [takeRight] for the pull layer.
  FxEvents<T> takeRight(int count) {
    if (count < 1) {
      return FxEvents(Stream<T>.empty(broadcast: false));
    }
    final out = StreamController<T>();
    out.onListen = () {
      final buffer = <T>[];
      var head = 0;
      final sub = stream.listen(
        (v) {
          buffer.add(v);
          if (buffer.length - head > count) head++;
          // Amortised O(1): shift only once the dead prefix is as long as
          // the window, so the buffer never holds more than 2x [count].
          if (head >= buffer.length - head) {
            buffer.removeRange(0, head);
            head = 0;
          }
        },
        onError: out.addError,
        onDone: () {
          for (var i = head; i < buffer.length; i++) {
            out.add(buffer[i]);
          }
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

  /// Skips the last [count] events; each event is delayed until [count]
  /// more have arrived, so the tail is never emitted.
  ///
  /// A [count] below 1 is a no-op. fxdart events layer, after Rx's
  /// `skipLast`; named [dropRight] for the pull layer.
  FxEvents<T> dropRight(int count) {
    if (count < 1) return FxEvents(stream);
    final out = StreamController<T>();
    out.onListen = () {
      final buffer = <T>[];
      var head = 0;
      final sub = stream.listen(
        (v) {
          buffer.add(v);
          if (buffer.length - head > count) out.add(buffer[head++]);
          if (head >= buffer.length - head) {
            buffer.removeRange(0, head);
            head = 0;
          }
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

  /// Keeps the events that are an instance of [S].
  ///
  /// fxdart events layer, after Rx's `whereType`.
  FxEvents<S> whereType<S>() => FxEvents(stream.where((e) => e is S).cast<S>());

  /// Re-types each event as [R]; a value that is not an [R] becomes an
  /// error when it is delivered.
  ///
  /// fxdart events layer, after [Stream.cast].
  FxEvents<R> cast<R>() => FxEvents(stream.cast<R>());

  /// Maps each event to an [Iterable] and emits the elements in order —
  /// iterable flatten, not recursive stream expand.
  ///
  /// fxdart events layer, after [Stream.expand] / Rx's `mergeMap` over
  /// an iterable. Recursive stream expand is a later `expandEach`.
  FxEvents<R> expand<R>(Iterable<R> Function(T) f) =>
      FxEvents(stream.expand(f));

  // --- errors & time --------------------------------------------------------

  /// Intercepts source errors matching [test] (every error when [test] is
  /// omitted), runs [onError], and continues.
  ///
  /// This is the per-error-and-continue form; [FxEvents.onErrorResume] is
  /// the abandon-and-switch form. fxdart events layer, after
  /// [Stream.handleError] / Rx's `catchError` in its non-switching shape.
  FxEvents<T> handleError(Function onError, {bool Function(Object)? test}) =>
      FxEvents(
        stream.handleError(
          onError,
          test: test == null ? null : (e) => test(e as Object),
        ),
      );

  /// Errors if [limit] passes with no event — from listen, then from each
  /// subsequent event — wrapping [Stream.timeout].
  ///
  /// When [orElse] is omitted a [TimeoutException] is forwarded as an
  /// error and the source is kept. When [orElse] is provided, the first
  /// [TimeoutException] cancels the source and the chain switches to that
  /// fallback. fxdart events layer, after Rx's `timeout`.
  FxEvents<T> timeout(Duration limit, {Stream<T> Function()? orElse}) {
    if (orElse == null) return FxEvents(stream.timeout(limit));
    final out = StreamController<T>();
    out.onListen = () {
      StreamSubscription<T>? sub;
      var switched = false;

      void listenTo(Stream<T> source, {required bool timed}) {
        sub = (timed ? source.timeout(limit) : source).listen(
          out.add,
          onError: (Object e, StackTrace st) {
            if (!switched && e is TimeoutException) {
              switched = true;
              sub!.cancel();
              final Stream<T> fallback;
              try {
                fallback = orElse();
              } catch (e2, st2) {
                out
                  ..addError(e2, st2)
                  ..close();
                return;
              }
              listenTo(fallback, timed: false);
              return;
            }
            out.addError(e, st);
          },
          onDone: out.close,
        );
      }

      listenTo(stream, timed: true);
      out.onPause = () {
        sub?.pause();
      };
      out.onResume = () {
        sub?.resume();
      };
      out.onCancel = () => sub?.cancel();
    };
    return FxEvents(out.stream);
  }

  // --- edges ----------------------------------------------------------------

  /// Emits every value in [values], then the source's events.
  ///
  /// fxdart events layer, after Rx's `startWithMany`.
  FxEvents<T> startWithAll(Iterable<T> values) {
    final out = StreamController<T>();
    out.onListen = () {
      for (final v in values) {
        out.add(v);
      }
      final sub = stream.listen(
        out.add,
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

  /// Emits the source's events, then [value] when the source closes.
  ///
  /// fxdart events layer, after Rx's `endWith`.
  FxEvents<T> endWith(T value) => endWithAll([value]);

  /// Emits the source's events, then every value in [values] when the
  /// source closes.
  ///
  /// A cancel before close drops the suffix. fxdart events layer, after
  /// Rx's `endWithMany`.
  FxEvents<T> endWithAll(Iterable<T> values) {
    final out = StreamController<T>();
    out.onListen = () {
      final tail = List<T>.of(values);
      final sub = stream.listen(
        out.add,
        onError: out.addError,
        onDone: () {
          for (final v in tail) {
            out.add(v);
          }
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

  /// If the source closes without emitting, emits [fallback] then closes;
  /// otherwise mirrors the source.
  ///
  /// [fallback] is called only in the empty case. A throwing [fallback]
  /// becomes an error event. fxdart events layer, after Rx's
  /// `defaultIfEmpty` / pull `ifEmpty`.
  FxEvents<T> ifEmpty(T Function() fallback) {
    final out = StreamController<T>();
    out.onListen = () {
      var empty = true;
      final sub = stream.listen(
        (v) {
          empty = false;
          out.add(v);
        },
        onError: out.addError,
        onDone: () {
          if (empty) {
            try {
              out.add(fallback());
            } catch (e, st) {
              out.addError(e, st);
            }
          }
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

  /// If the source closes without emitting, emits [value] then closes;
  /// otherwise mirrors the source.
  ///
  /// fxdart events layer, after Rx's `defaultIfEmpty`.
  FxEvents<T> defaultIfEmpty(T value) => ifEmpty(() => value);

  /// If the source closes without emitting, emits an error and closes.
  ///
  /// The error is [errorFactory]'s result, or a [StateError] when the
  /// factory is omitted. A throwing factory becomes that error. fxdart
  /// events layer, after Rx's `throwIfEmpty`.
  FxEvents<T> throwIfEmpty([Object Function()? errorFactory]) {
    final out = StreamController<T>();
    out.onListen = () {
      var empty = true;
      final sub = stream.listen(
        (v) {
          empty = false;
          out.add(v);
        },
        onError: out.addError,
        onDone: () {
          if (empty) {
            Object error;
            try {
              error =
                  errorFactory?.call() ??
                  StateError('throwIfEmpty: source closed without emitting');
            } catch (e, st) {
              out
                ..addError(e, st)
                ..close();
              return;
            }
            out.addError(error);
          }
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

  /// Drops events equal to any earlier event, keeping the first of each
  /// value — a growing seen-set.
  ///
  /// Unlike [FxEvents.uniqAdjacent], duplicates need not be neighbours, so
  /// the set of seen values grows without bound. **A long-lived feed plus
  /// unbounded [uniq] is a memory leak**; prefer [FxEvents.uniqAdjacent]
  /// when only consecutive repeats should go, or cancel the chain when the
  /// run is over.
  ///
  /// [equals] defaults to `==`. A throwing [equals] becomes an error event
  /// and the compared value is not recorded. fxdart events layer, after
  /// Rx's `distinct`.
  FxEvents<T> uniq([bool Function(T, T)? equals]) {
    final out = StreamController<T>();
    out.onListen = () {
      final seenSet = equals == null ? <T>{} : null;
      final seenEq = equals == null ? null : <T>[];
      final sub = stream.listen(
        (v) {
          if (equals == null) {
            if (!seenSet!.add(v)) return;
          } else {
            try {
              for (final s in seenEq!) {
                if (equals(s, v)) return;
              }
            } catch (e, st) {
              out.addError(e, st);
              return;
            }
            seenEq.add(v);
          }
          out.add(v);
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

  /// Listens, drops every event, and completes when the source closes.
  ///
  /// Errors from the source complete the future as errors. fxdart events
  /// layer, after Rx's `ignoreElements` consumed to completion.
  Future<void> drain() => stream.drain<void>();

  // --- terminals ------------------------------------------------------------

  /// The last event, or `null` when the stream closes without one.
  ///
  /// Named for the pull layer's terminal, not for [Stream.last]: that one
  /// answers `Future<T>` and throws on an empty stream, and it is one hop
  /// away through [stream]. On an `FxEvents<T?>` a `null` last event and
  /// an empty stream both answer `null`, as on [FxEvents.head]. fxdart
  /// events layer, after Rx's `last`.
  Future<T?> last() => stream.fold<T?>(null, (_, v) => v);

  /// The event at 0-based [index], or `null` when missing — then cancels
  /// the source.
  ///
  /// A negative [index] answers `null` without subscribing. fxdart events
  /// layer, after Rx's `elementAt` / pull `nth`.
  Future<T?> nth(int index) {
    if (index < 0) return Future<T?>.value(null);
    final completer = Completer<T?>();
    var i = 0;
    final sub = stream.listen(
      null,
      onError: (Object e, StackTrace st) {
        if (completer.isCompleted) return;
        completer.completeError(e, st);
      },
      onDone: () {
        if (completer.isCompleted) return;
        completer.complete(null);
      },
      cancelOnError: true,
    );
    sub.onData((v) {
      if (completer.isCompleted) return;
      if (i++ == index) {
        sub.cancel().whenComplete(() {
          if (!completer.isCompleted) completer.complete(v);
        });
      }
    });
    return completer.future;
  }

  /// How many events the source emits before it closes.
  Future<int> get length => stream.length;

  /// Whether the source closes without emitting.
  Future<bool> get isEmpty => stream.isEmpty;

  /// Whether any event matches [test]; `false` when the source is empty.
  Future<bool> any(bool Function(T) test) => stream.any(test);

  /// Whether every event matches [test]; `true` when the source is empty.
  Future<bool> every(bool Function(T) test) => stream.every(test);

  /// Folds [combine] over every event, starting from [initial].
  Future<R> fold<R>(R initial, R Function(R, T) combine) =>
      stream.fold(initial, combine);

  /// Reduces [combine] over every event. Throws a [StateError] on empty.
  Future<T> reduce(T Function(T, T) combine) => stream.reduce(combine);

  /// Runs [action] for every event; completes when the source closes.
  Future<void> forEach(void Function(T) action) => stream.forEach(action);
}

/// Null-dropping companion of [FxEventsChain], on nullable events only.
extension FxEventsNonNulls<T extends Object> on FxEvents<T?> {
  /// Drops null events and re-types the rest as [T].
  ///
  /// fxdart events layer, after Dart's `Iterable.nonNulls` / Rx's
  /// `whereNotNull`.
  FxEvents<T> get nonNulls =>
      FxEvents(stream.where((e) => e != null).cast<T>());
}
