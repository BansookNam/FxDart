import 'dart:async';

import '../async_iterable.dart';
import '../fx.dart';

/// Wraps a [Stream] in a chainable [FxEvents] — fxdart's push-side chain.
///
/// fxdart events layer (inspired by Rx; not part of FxTS). The pull
/// pipelines ([Fx]/[FxAsync]) model *data over demand*; [FxEvents] models
/// *events over time* on plain Dart [Stream]s: debouncing, throttling,
/// sampling, latest-value combination, and switching. Cross back into the
/// typed pull world with [FxEvents.pull].
///
/// ```dart
/// final results = await fxEvents(keystrokes)
///     .debounce(const Duration(milliseconds: 160))
///     .switchMap((q) => search(q).asStream())
///     .toList();
/// ```
FxEvents<T> fxEvents<T>(Stream<T> stream) => FxEvents(stream);

/// `fxEvents(stream)` as a getter: `keystrokes.fxEvents.debounce(window)`.
///
/// The push-side counterpart to `Stream.fx`, which gives the *pull* chain
/// ([FxAsync]). Both spellings of both entry points exist; these pages use
/// the functions.
///
/// This is an extension where [FxEvents] itself deliberately is not — see the
/// note on the class. One entry-point name is not the same risk as forty
/// operator names: `debounce` and `switchMap` collide with rxdart's Stream
/// extensions, `fxEvents` does not.
extension FxEventsEntry<T> on Stream<T> {
  /// This stream as a chainable [FxEvents].
  @pragma('vm:prefer-inline')
  FxEvents<T> get fxEvents => FxEvents(this);

  /// This stream as a [LiveValue] — see [LiveValue.from].
  ///
  /// Hot: the subscription opens immediately, so values arriving before
  /// anyone listens still update [LiveValue.value].
  LiveValue<T> get fxLive => LiveValue<T>.from(this);

  /// This stream as a [LiveValue] already holding [seed] — see
  /// [LiveValue.seededFrom].
  LiveValue<T> fxLiveSeeded(T seed) => LiveValue<T>.seededFrom(seed, this);
}

/// Chainable event-stream operators over a plain Dart [Stream].
///
/// A thin wrapper (never an extension), so it can coexist with any other
/// stream library — including rxdart — without member conflicts. The one
/// extension in this file is [FxEventsEntry], which adds the single entry
/// name `fxEvents` and nothing rxdart claims. Every
/// operator returns a new [FxEvents] over a derived single-subscription
/// stream; unwrap with [stream], collect with [toList], or continue in the
/// pull model with [pull].
class FxEvents<T> {
  final Stream<T> _inner;

  /// Wraps [_inner] without listening to it; the chain stays cold.
  const FxEvents(this._inner);

  /// The wrapped stream, for handing to any `Stream`-based API.
  Stream<T> get stream => _inner;

  // --- constructors ---------------------------------------------------------

  /// A stream that emits [value] and then closes.
  ///
  /// Cold: the value is not produced until a listener arrives. fxdart
  /// events layer, after Rx's `of`/`just`.
  FxEvents.value(T value) : _inner = Stream<T>.value(value);

  /// A stream that closes without emitting.
  ///
  /// Wraps [Stream.empty] (broadcast, as the Dart default). fxdart
  /// events layer, after Rx's `EMPTY`.
  FxEvents.empty() : _inner = Stream<T>.empty();

  /// A stream that never emits and never closes.
  ///
  /// Listening hangs until cancelled. fxdart events layer, after Rx's
  /// `NEVER`.
  FxEvents.never() : _inner = StreamController<T>().stream;

  /// A stream that emits [error] and then closes.
  ///
  /// fxdart events layer, after Rx's `throwError`.
  FxEvents.error(Object error, [StackTrace? stackTrace])
    : _inner = Stream<T>.error(error, stackTrace);

  /// A stream that emits the result of [future] (or its error) and closes.
  ///
  /// Cold: the future is not observed until a listener arrives, matching
  /// [Stream.fromFuture]. fxdart events layer, after Rx's `from` on a
  /// Promise.
  FxEvents.fromFuture(Future<T> future) : _inner = Stream<T>.fromFuture(future);

  /// Emits a value every [period] and never completes.
  ///
  /// When [computation] is omitted the event is the 0-based tick count,
  /// so `FxEvents<int>.periodic(period)` is Rx's `interval`. fxdart
  /// events layer, after Rx's `interval`.
  FxEvents.periodic(Duration period, [T Function(int count)? computation])
    : _inner = Stream<T>.periodic(period, computation ?? (i) => i as T);

  /// Emits `0` after [delay] and closes; with [every], continues `1, 2, …`
  /// on that period.
  ///
  /// fxdart events layer, after Rx's `timer`.
  static FxEvents<int> timer(Duration delay, [Duration? every]) =>
      FxEvents(_timerStream(delay, every));

  /// Builds the inner stream on listen, so each subscriber gets a fresh
  /// source.
  ///
  /// A throw from [factory] is forwarded and the stream closes. fxdart
  /// events layer, after Rx's `defer`.
  FxEvents.defer(Stream<T> Function() factory) : _inner = _deferStream(factory);

  /// Walks `initial, iterate(initial), …` while [condition] holds.
  ///
  /// Production starts on listen. Each step is a timer tick so an
  /// infinite generator can still be cancelled. fxdart events layer,
  /// after Rx's `generate`.
  FxEvents.generate(
    T initial,
    bool Function(T) condition,
    T Function(T) iterate,
  ) : _inner = _generateStream(initial, condition, iterate);

  /// Subscribes by calling [add] with a handler and unsubscribes by
  /// calling [remove] with the same handler.
  ///
  /// The typical bridge to `on`/`off` event APIs. fxdart events layer,
  /// after Rx's `fromEventPattern`.
  FxEvents.fromPattern(
    void Function(void Function(T) handler) add,
    void Function(void Function(T) handler) remove,
  ) : _inner = _fromPatternStream(add, remove);

  /// Acquires a resource on listen, mirrors [asStream] of it, and
  /// releases the resource exactly once — on cancel, complete, error, or
  /// if [asStream] throws.
  ///
  /// A throw from [acquire] is forwarded and there is nothing to
  /// release. fxdart events layer, after Rx's `using`.
  static FxEvents<T> using<R, T>(
    R Function() acquire,
    Stream<T> Function(R resource) asStream,
    FutureOr<void> Function(R resource) release,
  ) => FxEvents(_usingStream(acquire, asStream, release));

  /// Calls [init] on listen with an [EventEmitter] the producer uses to
  /// push events, errors, and completion.
  ///
  /// Set [EventEmitter.onCancel] for teardown; a throw from [init] is
  /// forwarded and the stream closes. fxdart events layer, after Rx's
  /// `Observable` constructor / `create`.
  FxEvents.create(void Function(EventEmitter<T> emit) init)
    : _inner = _createStream(init);

  /// Mirrors whichever candidate emits first — the whole winning stream —
  /// cancelling every other candidate the moment the winner is decided.
  ///
  /// A candidate that errors first wins with its error; candidates that
  /// close without emitting drop out, and if all do, the result closes.
  static FxEvents<T> race<T>(Iterable<Stream<T>> candidates) {
    final list = List.of(candidates);
    final out = StreamController<T>();
    final subs = <StreamSubscription<T>>[];
    var done = 0;
    var winner = -1;

    void claim(int i, void Function() deliver) {
      if (winner == -1) {
        winner = i;
        for (var j = 0; j < subs.length; j++) {
          if (j != i) subs[j].cancel();
        }
      }
      if (winner == i) deliver();
    }

    out.onListen = () {
      if (list.isEmpty) {
        out.close();
        return;
      }
      for (var i = 0; i < list.length; i++) {
        subs.add(
          list[i].listen(
            (v) => claim(i, () => out.add(v)),
            onError: (Object e, StackTrace st) =>
                claim(i, () => out.addError(e, st)),
            onDone: () {
              if (winner == i) {
                out.close();
              } else if (winner == -1 && ++done == list.length) {
                out.close();
              }
            },
          ),
        );
      }
      out.onCancel = () => Future.wait(subs.map((s) => s.cancel()));
    };
    return FxEvents(out.stream);
  }

  /// Interleaves every source in arrival order; closes when all close.
  static FxEvents<T> merge<T>(Iterable<Stream<T>> sources) {
    final list = List.of(sources);
    final out = StreamController<T>();
    final subs = <StreamSubscription<T>>[];
    var done = 0;
    out.onListen = () {
      if (list.isEmpty) {
        out.close();
        return;
      }
      for (final s in list) {
        subs.add(
          s.listen(
            out.add,
            onError: out.addError,
            onDone: () {
              if (++done == list.length) out.close();
            },
          ),
        );
      }
      out.onCancel = () => Future.wait(subs.map((s) => s.cancel()));
    };
    return FxEvents(out.stream);
  }

  /// Plays each source through to completion before starting the next.
  ///
  /// An error from any source ends the whole chain — the remaining
  /// sources are never subscribed to.
  static FxEvents<T> concat<T>(Iterable<Stream<T>> sources) =>
      FxEvents(_concat(sources));

  static Stream<T> _concat<T>(Iterable<Stream<T>> sources) async* {
    for (final source in sources) {
      yield* source;
    }
  }

  /// Pairs the sources up by index: emits [combine] of every source's
  /// 1st event, then of every source's 2nd, and so on.
  ///
  /// Faster sources are buffered until the slowest catches up. The result
  /// closes as soon as a source that has closed runs out of buffered
  /// events — no further pair can ever be formed. An empty [sources]
  /// closes immediately.
  static FxEvents<R> zip<T, R>(
    Iterable<Stream<T>> sources,
    R Function(List<T> values) combine,
  ) {
    final list = List.of(sources);
    final out = StreamController<R>();
    final subs = <StreamSubscription<T>>[];
    out.onListen = () {
      if (list.isEmpty) {
        out.close();
        return;
      }
      final buffers = [for (var i = 0; i < list.length; i++) <T>[]];
      final closed = List.filled(list.length, false);

      void pump() {
        // A late onDone can arrive after an earlier source already ended
        // the result; there is nothing left to pair.
        if (out.isClosed) return;
        while (buffers.every((b) => b.isNotEmpty)) {
          out.add(combine([for (final b in buffers) b.removeAt(0)]));
        }
        for (var i = 0; i < list.length; i++) {
          if (closed[i] && buffers[i].isEmpty) {
            out.close();
            return;
          }
        }
      }

      for (var i = 0; i < list.length; i++) {
        final index = i;
        subs.add(
          list[i].listen(
            (v) {
              buffers[index].add(v);
              pump();
            },
            onError: out.addError,
            onDone: () {
              closed[index] = true;
              pump();
            },
          ),
        );
      }
      out.onCancel = () => Future.wait(subs.map((s) => s.cancel()));
    };
    return FxEvents(out.stream);
  }

  /// On every event from any source, emits the latest value of each —
  /// once every source has produced at least one. Closes when all close.
  ///
  /// The N-ary form of [combineLatest]; values keep their source's
  /// position in the emitted list. An empty [sources] closes immediately.
  static FxEvents<List<T>> combineLatestAll<T>(Iterable<Stream<T>> sources) {
    final list = List.of(sources);
    final out = StreamController<List<T>>();
    final subs = <StreamSubscription<T>>[];
    out.onListen = () {
      if (list.isEmpty) {
        out.close();
        return;
      }
      final latest = List<T?>.filled(list.length, null);
      final has = List.filled(list.length, false);
      var seen = 0;
      var done = 0;

      for (var i = 0; i < list.length; i++) {
        final index = i;
        subs.add(
          list[i].listen(
            (v) {
              if (!has[index]) {
                has[index] = true;
                seen++;
              }
              latest[index] = v;
              if (seen == list.length) {
                out.add([for (final v in latest) v as T]);
              }
            },
            onError: out.addError,
            onDone: () {
              if (++done == list.length) out.close();
            },
          ),
        );
      }
      out.onCancel = () => Future.wait(subs.map((s) => s.cancel()));
    };
    return FxEvents(out.stream);
  }

  /// Emits one list of every source's LAST value, once all have closed —
  /// the stream counterpart of [Future.wait].
  ///
  /// A source that closes without ever emitting means no result at all:
  /// the output closes empty-handed. An empty [sources] emits `[]`.
  /// fxdart events layer, after Rx's `forkJoin`.
  static FxEvents<List<T>> waitAll<T>(Iterable<Stream<T>> sources) {
    final list = List.of(sources);
    final out = StreamController<List<T>>();
    final subs = <StreamSubscription<T>>[];
    out.onListen = () {
      if (list.isEmpty) {
        out
          ..add(<T>[])
          ..close();
        return;
      }
      final last = List<T?>.filled(list.length, null);
      final has = List.filled(list.length, false);
      var done = 0;

      for (var i = 0; i < list.length; i++) {
        final index = i;
        subs.add(
          list[i].listen(
            (v) {
              last[index] = v;
              has[index] = true;
            },
            onError: out.addError,
            onDone: () {
              if (++done == list.length) {
                if (!has.contains(false)) {
                  out.add([for (final v in last) v as T]);
                }
                out.close();
              }
            },
          ),
        );
      }
      out.onCancel = () => Future.wait(subs.map((s) => s.cancel()));
    };
    return FxEvents(out.stream);
  }

  /// Subscribes to `factory()`, and on error throws the attempt away and
  /// subscribes to a fresh one — up to [count] retries, or forever when
  /// [count] is null.
  ///
  /// The retry budget counts *re*-subscriptions, so `count: 2` means at
  /// most three attempts. When it runs out, the last error is forwarded
  /// and the stream closes. Events already emitted by a failed attempt
  /// are not taken back.
  static FxEvents<T> retry<T>(Stream<T> Function() factory, [int? count]) {
    final out = StreamController<T>();
    out.onListen = () {
      var retries = 0;
      StreamSubscription<T>? sub;

      void attempt() {
        final Stream<T> source;
        try {
          source = factory();
        } catch (e, st) {
          out
            ..addError(e, st)
            ..close();
          return;
        }
        sub = source.listen(
          out.add,
          onError: (Object e, StackTrace st) {
            sub!.cancel();
            sub = null;
            if (count != null && retries >= count) {
              out
                ..addError(e, st)
                ..close();
              return;
            }
            retries++;
            attempt();
          },
          onDone: out.close,
        );
      }

      attempt();
      out.onCancel = () => sub?.cancel();
    };
    return FxEvents(out.stream);
  }

  // --- gating ---------------------------------------------------------------

  /// Mirrors the source until [trigger] fires once, then closes and
  /// cancels both subscriptions — the chain's off switch.
  ///
  /// Nothing [trigger] carries is read, only that it fired; a
  /// `Stream<void>` accepts any stream. The source closing first ends the
  /// chain the ordinary way. fxdart events layer, after Rx's `takeUntil`
  /// — the name is `stopOn` because [Fx.takeUntil] already means the
  /// predicate-driven `takeUntilInclusive` in the pull layer.
  FxEvents<T> stopOn(Stream<void> trigger) {
    final out = StreamController<T>();
    out.onListen = () {
      late final StreamSubscription<T> sourceSub;
      late final StreamSubscription<void> triggerSub;
      sourceSub = _inner.listen(
        out.add,
        onError: out.addError,
        onDone: () {
          triggerSub.cancel();
          out.close();
        },
      );
      triggerSub = trigger.listen((_) {
        sourceSub.cancel();
        triggerSub.cancel();
        out.close();
      }, onError: out.addError);
      out.onCancel = () =>
          Future.wait([sourceSub.cancel(), triggerSub.cancel()]);
    };
    return FxEvents(out.stream);
  }

  /// Drops source events until [trigger] fires once, then mirrors the
  /// source for good — the chain's on switch.
  ///
  /// The counterpart of [stopOn]; note it is unrelated to [startWith],
  /// which prepends a value rather than gating the start. fxdart events
  /// layer, after Rx's `skipUntil`.
  FxEvents<T> startOn(Stream<void> trigger) {
    final out = StreamController<T>();
    out.onListen = () {
      var open = false;
      late final StreamSubscription<T> sourceSub;
      late final StreamSubscription<void> triggerSub;
      sourceSub = _inner.listen(
        (v) {
          if (open) out.add(v);
        },
        onError: out.addError,
        onDone: () {
          triggerSub.cancel();
          out.close();
        },
      );
      triggerSub = trigger.listen((_) {
        open = true;
        triggerSub.cancel();
      }, onError: out.addError);
      out.onCancel = () =>
          Future.wait([sourceSub.cancel(), triggerSub.cancel()]);
    };
    return FxEvents(out.stream);
  }

  // --- time -----------------------------------------------------------------

  /// Emits an event only once [window] has passed without a newer one —
  /// the trailing value of each burst. A value still pending when the
  /// source closes is emitted before the close.
  FxEvents<T> debounce(Duration window) {
    final out = StreamController<T>();
    out.onListen = () {
      Timer? timer;
      late T pending;
      var hasPending = false;
      final sub = _inner.listen(
        (v) {
          pending = v;
          hasPending = true;
          timer?.cancel();
          timer = Timer(window, () {
            hasPending = false;
            out.add(pending);
          });
        },
        onError: out.addError,
        onDone: () {
          timer?.cancel();
          if (hasPending) out.add(pending);
          out.close();
        },
      );
      out
        ..onPause = sub.pause
        ..onResume = sub.resume
        ..onCancel = () {
          timer?.cancel();
          return sub.cancel();
        };
    };
    return FxEvents(out.stream);
  }

  /// Emits at most one event per [window]: the first one opens the window
  /// ([leading], on by default), and with [trailing] the newest event seen
  /// during the window is emitted when it ends (or when the source closes
  /// mid-window).
  FxEvents<T> throttle(
    Duration window, {
    bool leading = true,
    bool trailing = false,
  }) {
    final out = StreamController<T>();
    out.onListen = () {
      Timer? timer;
      late T pending;
      var hasPending = false;
      var closed = false;

      void endWindow() {
        timer = null;
        if (trailing && hasPending) {
          hasPending = false;
          out.add(pending);
        }
        if (closed) out.close();
      }

      final sub = _inner.listen(
        (v) {
          if (timer == null) {
            timer = Timer(window, endWindow);
            if (leading) {
              out.add(v);
              return;
            }
          }
          pending = v;
          hasPending = trailing;
        },
        onError: out.addError,
        onDone: () {
          closed = true;
          // A trailing value still waiting on its window is delivered before
          // the close; without one, close immediately.
          if (timer == null || !(trailing && hasPending)) {
            timer?.cancel();
            out.close();
          }
        },
      );
      out
        ..onPause = sub.pause
        ..onResume = sub.resume
        ..onCancel = () {
          timer?.cancel();
          return sub.cancel();
        };
    };
    return FxEvents(out.stream);
  }

  /// Emits the newest source value each time [trigger] fires — and only
  /// when a value newer than the last emission exists. Closes when the
  /// source closes; unsampled values are dropped.
  FxEvents<T> sampleOn(Stream<void> trigger) {
    final out = StreamController<T>();
    out.onListen = () {
      late T latest;
      var hasNew = false;
      late final StreamSubscription<T> sourceSub;
      late final StreamSubscription<void> triggerSub;
      sourceSub = _inner.listen(
        (v) {
          latest = v;
          hasNew = true;
        },
        onError: out.addError,
        onDone: () {
          triggerSub.cancel();
          out.close();
        },
      );
      triggerSub = trigger.listen((_) {
        if (hasNew) {
          hasNew = false;
          out.add(latest);
        }
      }, onError: out.addError);
      out.onCancel = () =>
          Future.wait([sourceSub.cancel(), triggerSub.cancel()]);
    };
    return FxEvents(out.stream);
  }

  /// Emits the newest source value every [period] — and only when a value
  /// newer than the last emission exists.
  ///
  /// The clock-driven companion of [sampleOn]: same lossy, newest-wins
  /// behaviour, with an internal tick instead of a supplied trigger.
  /// fxdart events layer, after Rx's `sampleTime`.
  FxEvents<T> sample(Duration period) =>
      sampleOn(Stream<int>.periodic(period, (i) => i));

  /// Delays every event by [duration], preserving order and spacing.
  ///
  /// The whole stream is shifted, not thinned: nothing is dropped, and
  /// the close waits for the last delayed event to land. Errors are
  /// forwarded immediately — only data is held.
  FxEvents<T> delay(Duration duration) {
    final out = StreamController<T>();
    out.onListen = () {
      final timers = <Timer>{};
      var closed = false;
      void settle() {
        if (closed && timers.isEmpty) out.close();
      }

      final sub = _inner.listen(
        (v) {
          late final Timer timer;
          timer = Timer(duration, () {
            timers.remove(timer);
            out.add(v);
            settle();
          });
          timers.add(timer);
        },
        onError: out.addError,
        onDone: () {
          closed = true;
          settle();
        },
      );
      out.onCancel = () {
        for (final t in timers) {
          t.cancel();
        }
        timers.clear();
        return sub.cancel();
      };
    };
    return FxEvents(out.stream);
  }

  /// Forces at least [gap] between emissions, queueing rather than
  /// dropping — a burst comes out evenly spaced.
  ///
  /// This is the lossless counterpart of [throttle]: where throttle keeps
  /// one event per window and discards the rest, `spaceBy` keeps them all
  /// and stretches the stream out. An unbounded burst therefore grows an
  /// unbounded queue. fxdart events layer, after Rx's `interval`.
  FxEvents<T> spaceBy(Duration gap) {
    final out = StreamController<T>();
    out.onListen = () {
      final queue = <T>[];
      Timer? timer;
      var closed = false;
      void settle() {
        if (closed && queue.isEmpty && timer == null) out.close();
      }

      void pump() {
        timer = Timer(gap, () {
          timer = null;
          if (queue.isNotEmpty) {
            out.add(queue.removeAt(0));
            if (queue.isNotEmpty) pump();
          }
          settle();
        });
      }

      final sub = _inner.listen(
        (v) {
          queue.add(v);
          if (timer == null) pump();
        },
        onError: out.addError,
        onDone: () {
          closed = true;
          settle();
        },
      );
      out.onCancel = () {
        timer?.cancel();
        return sub.cancel();
      };
    };
    return FxEvents(out.stream);
  }

  // --- batching -------------------------------------------------------------

  /// Groups events into lists of [count]; a short final batch is emitted
  /// when the source closes.
  ///
  /// The push-side counterpart of the pull layer's `chunk`. Throws an
  /// [ArgumentError] when [count] is below 1.
  FxEvents<List<T>> chunk(int count) {
    if (count < 1) {
      throw ArgumentError.value(count, 'count', 'must be at least 1');
    }
    final out = StreamController<List<T>>();
    out.onListen = () {
      var batch = <T>[];
      final sub = _inner.listen(
        (v) {
          batch.add(v);
          if (batch.length == count) {
            out.add(batch);
            batch = <T>[];
          }
        },
        onError: out.addError,
        onDone: () {
          if (batch.isNotEmpty) out.add(batch);
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

  /// Collects events until [trigger] fires, then emits them as one list.
  ///
  /// A trigger that fires over an empty buffer stays silent — you never
  /// get an empty batch just because the clock ticked. Whatever is still
  /// buffered when the source closes is emitted before the close.
  /// fxdart events layer, after Rx's `buffer`.
  FxEvents<List<T>> chunkOn(Stream<void> trigger) {
    final out = StreamController<List<T>>();
    out.onListen = () {
      var batch = <T>[];
      late final StreamSubscription<T> sourceSub;
      late final StreamSubscription<void> triggerSub;
      sourceSub = _inner.listen(
        (v) => batch.add(v),
        onError: out.addError,
        onDone: () {
          triggerSub.cancel();
          if (batch.isNotEmpty) out.add(batch);
          out.close();
        },
      );
      triggerSub = trigger.listen((_) {
        if (batch.isNotEmpty) {
          out.add(batch);
          batch = <T>[];
        }
      }, onError: out.addError);
      out.onCancel = () =>
          Future.wait([sourceSub.cancel(), triggerSub.cancel()]);
    };
    return FxEvents(out.stream);
  }

  /// Collects events for [window] at a time and emits each batch as a
  /// list — the clock-driven companion of [chunkOn].
  ///
  /// Empty windows stay silent. fxdart events layer, after Rx's
  /// `bufferTime`.
  FxEvents<List<T>> chunkEvery(Duration window) {
    final out = StreamController<List<T>>();
    out.onListen = () {
      var batch = <T>[];
      void flush() {
        if (batch.isNotEmpty) {
          out.add(batch);
          batch = <T>[];
        }
      }

      final timer = Timer.periodic(window, (_) => flush());
      final sub = _inner.listen(
        (v) => batch.add(v),
        onError: out.addError,
        onDone: () {
          timer.cancel();
          flush();
          out.close();
        },
      );
      out
        ..onPause = sub.pause
        ..onResume = sub.resume
        ..onCancel = () {
          timer.cancel();
          return sub.cancel();
        };
    };
    return FxEvents(out.stream);
  }

  // --- combination ----------------------------------------------------------

  /// On every event from either side, emits [combine] of the two latest
  /// values — once both sides have produced at least one. Closes when both
  /// sides have closed.
  FxEvents<R> combineLatest<U, R>(
    Stream<U> other,
    R Function(T a, U b) combine,
  ) {
    final out = StreamController<R>();
    out.onListen = () {
      late T a;
      late U b;
      var hasA = false, hasB = false;
      var done = 0;
      void emit() {
        if (hasA && hasB) out.add(combine(a, b));
      }

      void onDone() {
        if (++done == 2) out.close();
      }

      final subA = _inner.listen(
        (v) {
          a = v;
          hasA = true;
          emit();
        },
        onError: out.addError,
        onDone: onDone,
      );
      final subB = other.listen(
        (v) {
          b = v;
          hasB = true;
          emit();
        },
        onError: out.addError,
        onDone: onDone,
      );
      out.onCancel = () => Future.wait([subA.cancel(), subB.cancel()]);
    };
    return FxEvents(out.stream);
  }

  /// On every SOURCE event, emits [combine] of it and the latest value of
  /// [other] — source events before [other] has spoken are dropped. Closes
  /// when the source closes; [other]'s close is ignored.
  FxEvents<R> withLatestFrom<U, R>(
    Stream<U> other,
    R Function(T a, U b) combine,
  ) {
    final out = StreamController<R>();
    out.onListen = () {
      late U latest;
      var hasLatest = false;
      final otherSub = other.listen((v) {
        latest = v;
        hasLatest = true;
      }, onError: out.addError);
      late final StreamSubscription<T> sourceSub;
      sourceSub = _inner.listen(
        (v) {
          if (hasLatest) out.add(combine(v, latest));
        },
        onError: out.addError,
        onDone: () {
          otherSub.cancel();
          out.close();
        },
      );
      out.onCancel = () => Future.wait([sourceSub.cancel(), otherSub.cancel()]);
    };
    return FxEvents(out.stream);
  }

  /// Pairs this stream with [other] by index: the 1st event of each, then
  /// the 2nd of each, and so on. Whichever side runs ahead is buffered.
  ///
  /// The two-source, heterogeneously typed form of [FxEvents.zip]. Closes
  /// as soon as a closed side runs out of buffered events.
  FxEvents<R> zipWith<U, R>(Stream<U> other, R Function(T a, U b) combine) {
    final out = StreamController<R>();
    out.onListen = () {
      final bufferA = <T>[];
      final bufferB = <U>[];
      var closedA = false, closedB = false;

      void pump() {
        if (out.isClosed) return;
        while (bufferA.isNotEmpty && bufferB.isNotEmpty) {
          out.add(combine(bufferA.removeAt(0), bufferB.removeAt(0)));
        }
        if ((closedA && bufferA.isEmpty) || (closedB && bufferB.isEmpty)) {
          out.close();
        }
      }

      final subA = _inner.listen(
        (v) {
          bufferA.add(v);
          pump();
        },
        onError: out.addError,
        onDone: () {
          closedA = true;
          pump();
        },
      );
      final subB = other.listen(
        (v) {
          bufferB.add(v);
          pump();
        },
        onError: out.addError,
        onDone: () {
          closedB = true;
          pump();
        },
      );
      out.onCancel = () => Future.wait([subA.cancel(), subB.cancel()]);
    };
    return FxEvents(out.stream);
  }

  /// Interleaves this stream with [other] in arrival order; closes when
  /// both have closed. The two-source form of [FxEvents.merge].
  FxEvents<T> mergeWith(Stream<T> other) => FxEvents.merge([_inner, other]);

  /// Mirrors whichever of this stream and [other] emits first, cancelling
  /// the loser. The two-source form of [FxEvents.race].
  FxEvents<T> raceWith(Stream<T> other) => FxEvents.race([_inner, other]);

  /// Plays this stream to completion, then [next] — the two-source form
  /// of [FxEvents.concat], named after Dart's `Iterable.followedBy`.
  FxEvents<T> followedBy(Stream<T> next) => FxEvents.concat([_inner, next]);

  // --- higher-order mapping -------------------------------------------------

  /// Maps each event to an inner stream and mirrors only the NEWEST one:
  /// a fresh event cancels the previous inner stream mid-flight. Closes
  /// when the source has closed and the last inner stream completes.
  FxEvents<R> switchMap<R>(Stream<R> Function(T a) f) {
    final out = StreamController<R>();
    out.onListen = () {
      StreamSubscription<R>? innerSub;
      var outerDone = false;
      final sub = _inner.listen(
        (v) {
          innerSub?.cancel();
          final Stream<R> inner;
          try {
            inner = f(v);
          } catch (e, st) {
            out.addError(e, st);
            return;
          }
          late final StreamSubscription<R> s;
          s = inner.listen(
            out.add,
            onError: out.addError,
            onDone: () {
              if (identical(innerSub, s)) {
                innerSub = null;
                if (outerDone) out.close();
              }
            },
          );
          innerSub = s;
        },
        onError: out.addError,
        onDone: () {
          outerDone = true;
          if (innerSub == null) out.close();
        },
      );
      out.onCancel = () =>
          Future.wait([sub.cancel(), if (innerSub != null) innerSub!.cancel()]);
    };
    return FxEvents(out.stream);
  }

  /// Maps each event to an inner stream and mirrors them ALL at once,
  /// interleaved in arrival order — the fan-out of the family.
  ///
  /// With [concurrent] set, at most that many inner streams run at a
  /// time and later source events wait their turn in a queue (source
  /// order is preserved for *starting*, not for the interleaved output).
  /// Closes when the source has closed and every inner stream has
  /// finished. fxdart events layer, after Rx's `flatMap` — the name is
  /// `mergeMap` because `flatMap` already means iterable-flattening in
  /// the pull layer.
  ///
  /// Throws an [ArgumentError] when [concurrent] is below 1.
  FxEvents<R> mergeMap<R>(Stream<R> Function(T a) f, {int? concurrent}) {
    if (concurrent != null && concurrent < 1) {
      throw ArgumentError.value(concurrent, 'concurrent', 'must be at least 1');
    }
    final out = StreamController<R>();
    out.onListen = () {
      final inners = <StreamSubscription<R>>[];
      final waiting = <T>[];
      var outerDone = false;
      void settle() {
        if (outerDone && inners.isEmpty && waiting.isEmpty) out.close();
      }

      void start(T v) {
        final Stream<R> inner;
        try {
          inner = f(v);
        } catch (e, st) {
          out.addError(e, st);
          settle();
          return;
        }
        late final StreamSubscription<R> s;
        s = inner.listen(
          out.add,
          onError: out.addError,
          onDone: () {
            inners.remove(s);
            if (waiting.isNotEmpty) start(waiting.removeAt(0));
            settle();
          },
        );
        inners.add(s);
      }

      final sub = _inner.listen(
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

  /// Maps each event to an inner stream and plays them STRICTLY in
  /// order, each to completion before the next begins.
  ///
  /// Nothing is dropped and nothing overlaps, so a slow inner stream
  /// backs the whole chain up. `mergeMap(f, concurrent: 1)` differs only
  /// in that it queues source *values*; this queues the source itself.
  /// fxdart events layer, after Rx's `flatMap(maxConcurrent: 1)`.
  FxEvents<R> concatMap<R>(Stream<R> Function(T a) f) =>
      FxEvents(_inner.asyncExpand(f));

  /// Maps each event to an inner stream, and IGNORES source events that
  /// arrive while one is still running.
  ///
  /// The opposite trade to [switchMap]: first-wins instead of last-wins.
  /// This is the double-submit guard — a second tap on a button whose
  /// request is still in flight does nothing at all. fxdart events layer,
  /// after Rx's `exhaustMap`.
  FxEvents<R> exhaustMap<R>(Stream<R> Function(T a) f) {
    final out = StreamController<R>();
    out.onListen = () {
      StreamSubscription<R>? innerSub;
      var outerDone = false;
      final sub = _inner.listen(
        (v) {
          if (innerSub != null) return;
          final Stream<R> inner;
          try {
            inner = f(v);
          } catch (e, st) {
            out.addError(e, st);
            return;
          }
          innerSub = inner.listen(
            out.add,
            onError: out.addError,
            onDone: () {
              innerSub = null;
              if (outerDone) out.close();
            },
          );
        },
        onError: out.addError,
        onDone: () {
          outerDone = true;
          if (innerSub == null) out.close();
        },
      );
      out.onCancel = () =>
          Future.wait([sub.cancel(), if (innerSub != null) innerSub!.cancel()]);
    };
    return FxEvents(out.stream);
  }

  // --- errors ---------------------------------------------------------------

  /// Replaces every error with [value] and carries on.
  ///
  /// Dart stream errors do not terminate a subscription, so this is a
  /// per-error substitution, not a one-shot rescue — every error becomes
  /// one [value] event. fxdart events layer, after Rx's `onErrorReturn`.
  FxEvents<T> onErrorReturn(T value) {
    final out = StreamController<T>();
    out.onListen = () {
      final sub = _inner.listen(
        out.add,
        onError: (Object _, StackTrace __) => out.add(value),
        onDone: out.close,
      );
      out
        ..onPause = sub.pause
        ..onResume = sub.resume
        ..onCancel = sub.cancel;
    };
    return FxEvents(out.stream);
  }

  /// On the FIRST error, abandons the source and switches to the stream
  /// [f] builds from that error — a one-shot fallback.
  ///
  /// Unlike [onErrorReturn] the source is cancelled, so nothing more of
  /// it is seen; the fallback's own errors are forwarded as-is, as is an
  /// error thrown by [f] itself. fxdart events layer, after Rx's
  /// `onErrorResume`.
  FxEvents<T> onErrorResume(
    Stream<T> Function(Object error, StackTrace stackTrace) f,
  ) {
    final out = StreamController<T>();
    out.onListen = () {
      StreamSubscription<T>? sourceSub;
      StreamSubscription<T>? fallbackSub;
      sourceSub = _inner.listen(
        out.add,
        onError: (Object e, StackTrace st) {
          sourceSub!.cancel();
          sourceSub = null;
          final Stream<T> fallback;
          try {
            fallback = f(e, st);
          } catch (e2, st2) {
            out
              ..addError(e2, st2)
              ..close();
            return;
          }
          fallbackSub = fallback.listen(
            out.add,
            onError: out.addError,
            onDone: out.close,
          );
        },
        onDone: out.close,
      );
      out.onCancel = () => Future.wait([
        if (sourceSub != null) sourceSub!.cancel(),
        if (fallbackSub != null) fallbackSub!.cancel(),
      ]);
    };
    return FxEvents(out.stream);
  }

  // --- conveniences ---------------------------------------------------------

  /// Emits [value], then the source's events.
  FxEvents<T> startWith(T value) {
    final out = StreamController<T>();
    out.onListen = () {
      out.add(value);
      final sub = _inner.listen(
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

  /// Transforms each event with [f].
  FxEvents<R> map<R>(R Function(T a) f) => FxEvents(_inner.map(f));

  /// Keeps the events [f] returns true for.
  FxEvents<T> where(bool Function(T a) f) => FxEvents(_inner.where(f));

  /// Transforms each event with the async [f], one at a time.
  FxEvents<R> asyncMap<R>(FutureOr<R> Function(T a) f) =>
      FxEvents(_inner.asyncMap(f));

  // --- stateful & limiting --------------------------------------------------

  /// Emits [seed], then each running accumulation as [f] folds in an event.
  ///
  /// The push-side counterpart of the pull layer's `scan`, and seeded the
  /// same way: the seed is emitted before any event arrives. Rx's `scan`
  /// emits only the accumulations, so a port from there gains one leading
  /// value.
  ///
  /// A throwing [f] parts company with the pull spelling the same way
  /// [uniqAdjacentBy] does: there the throw ends the iteration, here it
  /// becomes one error event and the accumulator keeps its last good value,
  /// so the next event folds against a total the caller never saw. Nothing
  /// stops after the first failure, so an [f] that always throws turns a
  /// live source into an endless run of error events rather than one
  /// failure.
  ///
  /// The result is single-subscription even when the source is a broadcast
  /// stream, as with every controller-based operator here.
  FxEvents<R> scan<R>(R Function(R acc, T a) f, R seed) {
    final out = StreamController<R>();
    out.onListen = () {
      var acc = seed;
      out.add(seed);
      final sub = _inner.listen(
        (v) {
          final R next;
          try {
            next = f(acc, v);
          } catch (e, st) {
            // A throwing [f] becomes an error event rather than an uncaught
            // zone error, matching how [Stream.map] treats its transform.
            out.addError(e, st);
            return;
          }
          acc = next;
          out.add(next);
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

  /// Drops events whose [f]-key equals the previous event's key, keeping
  /// the first of each run.
  ///
  /// The push-side counterpart of the pull layer's `uniqAdjacentBy`, after
  /// Rx's `distinctUntilChanged`. Only adjacent duplicates go, so no
  /// seen-set builds up behind a long-lived source.
  ///
  /// A throwing [f] parts company with the pull spelling: there the throw
  /// leaves `moveNext()` and ends the iteration, here it becomes one error
  /// event and the chain carries on against the last key it managed to
  /// compute. A push chain has no caller to throw back to. Nothing stops
  /// after the first failure, so an [f] that always throws turns a live
  /// source into an endless run of error events.
  ///
  /// The result is single-subscription even when the source is a broadcast
  /// stream, as with every controller-based operator here.
  FxEvents<T> uniqAdjacentBy<B>(B Function(T a) f) {
    final out = StreamController<T>();
    out.onListen = () {
      var hasPrev = false;
      late B prevKey;
      final sub = _inner.listen(
        (v) {
          final B key;
          try {
            key = f(v);
          } catch (e, st) {
            out.addError(e, st);
            return;
          }
          final keep = !hasPrev || key != prevKey;
          prevKey = key;
          hasPrev = true;
          if (keep) out.add(v);
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

  /// Drops events equal to their predecessor, keeping the first of each run.
  FxEvents<T> uniqAdjacent() => uniqAdjacentBy((T a) => a);

  /// Pairs each event with its successor.
  ///
  /// Nothing is emitted until the second event arrives, so a source that
  /// closes after one event produces nothing.
  ///
  /// A source error passes through without disturbing the held predecessor,
  /// so the next event pairs with the one from before the error.
  ///
  /// The result is single-subscription even when the source is a broadcast
  /// stream, as with every controller-based operator here.
  FxEvents<(T, T)> pairwise() {
    final out = StreamController<(T, T)>();
    out.onListen = () {
      var hasPrev = false;
      late T prev;
      final sub = _inner.listen(
        (v) {
          if (hasPrev) out.add((prev, v));
          prev = v;
          hasPrev = true;
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

  /// The first [count] events, then the source is cancelled and the chain
  /// closes.
  ///
  /// [Stream.take] handles everything from 1 up, cancellation included. A
  /// count below 1 is the one case it does not: it still subscribes, where
  /// the pull layer's `take` clamps a non-positive count to empty.
  ///
  /// The empty stand-in copies the source's [Stream.isBroadcast] because
  /// `Stream.empty()` is broadcast by default while `Stream.take` forwards
  /// whatever the source is — without this, `take(0)` and `take(1)` would
  /// hand back streams that accept different numbers of listeners.
  FxEvents<T> take(int count) => count < 1
      ? FxEvents(Stream<T>.empty(broadcast: _inner.isBroadcast))
      : FxEvents(_inner.take(count));

  /// Skips the first [count] events and mirrors the rest.
  ///
  /// [Stream.skip] throws on a negative count; the pull layer's `drop` reads
  /// one as "skip nothing" and this matches it.
  FxEvents<T> drop(int count) =>
      count < 1 ? FxEvents(_inner) : FxEvents(_inner.skip(count));

  /// Dart-idiomatic alias of [drop], as on `Fx` and `FxAsync`.
  ///
  /// The name comes from Dart but the contract is [drop]'s: a negative count
  /// skips nothing, where [Stream.skip] throws.
  FxEvents<T> skip(int count) => drop(count);

  // --- multicast ------------------------------------------------------------

  /// Lets many listeners share ONE run of the chain instead of each
  /// getting a private one.
  ///
  /// Every operator above returns a single-subscription stream, so a
  /// chain that is expensive — or that has a live source behind it — can
  /// only be consumed once. `share()` connects on the first listener and
  /// broadcasts to all of them from there.
  ///
  /// [reset] (default `true`) is RxJS 7 `share` simplified to one flag.
  /// When the last listener leaves *before the source has completed*,
  /// the upstream subscription is cancelled but the broadcast stays
  /// open; the next listener starts a fresh subscribe of the source
  /// (the source must itself allow a second listen — `Stream.fromIterable`
  /// and `Stream.multi` do, a single-subscription [StreamController]
  /// does not). When the source **completes**, the broadcast closes for
  /// good: a later listener is handed a closed stream. When the source
  /// **errors**, the error is forwarded; with [reset] the broadcast stays
  /// open so a later listener may resubscribe, and with `reset: false`
  /// it closes. `reset: false` is the 0.8.7 behaviour: the last cancel
  /// closes forever.
  ///
  /// fxdart events layer, after Rx's `share`.
  FxEvents<T> share({bool reset = true}) {
    late final StreamController<T> out;
    StreamSubscription<T>? sub;
    var completed = false;
    out = StreamController<T>.broadcast(
      onListen: () {
        sub = _inner.listen(
          out.add,
          onError: (Object e, StackTrace st) {
            out.addError(e, st);
            if (reset) {
              // Drop this subscribe so a trailing onDone (Stream.error)
              // is not treated as a successful complete, and so the
              // next 0→1 listen can start a fresh one.
              sub = null;
            } else {
              completed = true;
              if (!out.isClosed) out.close();
            }
          },
          onDone: () {
            if (sub == null) return;
            completed = true;
            sub = null;
            if (!out.isClosed) out.close();
          },
        );
      },
      onCancel: () {
        // A broadcast controller's constructor types onCancel as
        // `void Function()` — there is nowhere to hand the cancel future,
        // so it is fired and forgotten.
        final current = sub;
        sub = null;
        current?.cancel();
        if (!reset || completed) {
          if (!out.isClosed) out.close();
        }
      },
    );
    return FxEvents(out.stream);
  }

  // --- terminals & bridges --------------------------------------------------

  /// Listens to the chain (a plain [Stream.listen] passthrough).
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => _inner.listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );

  /// Collects every event into a list (completes when the stream closes).
  Future<List<T>> toList() => _inner.toList();

  /// The first event, or `null` when the stream closes without one — then
  /// cancels the source.
  ///
  /// Named for the pull layer's terminal, not for [Stream.first]: that one
  /// answers `Future<T>` and throws on an empty stream, and it is one hop
  /// away through [stream].
  ///
  /// Like [Stream.first], the future waits for the source's teardown before
  /// it answers, so a caller that awaits this can rely on the subscription
  /// already being gone.
  ///
  /// On an `FxEvents<T?>` a `null` first event and an empty stream both
  /// answer `null`; the two are indistinguishable, as on `FxAsync`.
  Future<T?> head() {
    final completer = Completer<T?>();
    // [Stream.first]'s exact shape: `onError` and `onDone` go in at `listen`
    // so a source that delivers during that call is still heard, and only
    // `onData` waits for the subscription it has to cancel. `cancelOnError`
    // tears the source down on the error path for the same reason.
    final sub = _inner.listen(
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
      // `whenComplete`, not `then(onError:)`: a source that also fails to
      // tear down would otherwise replace the value with the cancel error.
      // `Stream.first` drops the teardown failure the same way — what the
      // stream delivered outranks what its disposer did.
      sub.cancel().whenComplete(() => completer.complete(v));
    });
    return completer.future;
  }

  /// Alias of [head], matching `FxAsync.firstOrNull`.
  Future<T?> firstOrNull() => head();

  /// Crosses into the pull model: the events become an [FxAsync] chain,
  /// pulled on demand from here on.
  FxAsync<T> pull() => fxAsync(fromStream(_inner));
}

/// Sink handed to [FxEvents.create] so the producer can emit, fail, or
/// complete — and register teardown.
///
/// fxdart events layer, after Rx's `Subscriber` / the `Observable`
/// constructor's observer.
class EventEmitter<T> {
  EventEmitter._(this._out);
  final StreamController<T> _out;
  var _done = false;

  /// Invoked once when the listener cancels or this emitter [close]s.
  FutureOr<void> Function()? onCancel;

  /// Pushes [value] to the current listener. No-ops after [close] or
  /// cancel.
  void add(T value) {
    if (_done || _out.isClosed) return;
    _out.add(value);
  }

  /// Pushes [error] to the current listener. No-ops after [close] or
  /// cancel.
  void addError(Object error, [StackTrace? stackTrace]) {
    if (_done || _out.isClosed) return;
    _out.addError(error, stackTrace);
  }

  /// Completes the stream. Further [add]/[addError]/[close] no-op.
  void close() {
    if (_done || _out.isClosed) return;
    _done = true;
    _out.close();
  }

  Future<void> _teardown() async {
    _done = true;
    final cb = onCancel;
    onCancel = null;
    if (cb != null) await cb();
  }
}

Stream<int> _timerStream(Duration delay, Duration? every) {
  final out = StreamController<int>();
  out.onListen = () {
    var n = 0;
    Timer? timer;
    timer = Timer(delay, () {
      out.add(n++);
      if (every == null) {
        out.close();
        return;
      }
      timer = Timer.periodic(every, (_) => out.add(n++));
    });
    out.onCancel = () => timer?.cancel();
  };
  return out.stream;
}

Stream<T> _deferStream<T>(Stream<T> Function() factory) {
  final out = StreamController<T>();
  out.onListen = () {
    final Stream<T> source;
    try {
      source = factory();
    } catch (e, st) {
      out
        ..addError(e, st)
        ..close();
      return;
    }
    final sub = source.listen(
      out.add,
      onError: out.addError,
      onDone: out.close,
    );
    out
      ..onPause = sub.pause
      ..onResume = sub.resume
      ..onCancel = sub.cancel;
  };
  return out.stream;
}

Stream<T> _generateStream<T>(
  T initial,
  bool Function(T) condition,
  T Function(T) iterate,
) {
  final out = StreamController<T>();
  out.onListen = () {
    var current = initial;
    var cancelled = false;
    Timer? pending;
    void step() {
      pending = null;
      if (cancelled || out.isClosed) return;
      final bool ok;
      try {
        ok = condition(current);
      } catch (e, st) {
        out
          ..addError(e, st)
          ..close();
        return;
      }
      if (!ok) {
        out.close();
        return;
      }
      out.add(current);
      try {
        current = iterate(current);
      } catch (e, st) {
        out
          ..addError(e, st)
          ..close();
        return;
      }
      pending = Timer(Duration.zero, step);
    }

    pending = Timer(Duration.zero, step);
    out.onCancel = () {
      cancelled = true;
      pending?.cancel();
    };
  };
  return out.stream;
}

Stream<T> _fromPatternStream<T>(
  void Function(void Function(T) handler) add,
  void Function(void Function(T) handler) remove,
) {
  final out = StreamController<T>();
  out.onListen = () {
    void handler(T value) => out.add(value);

    try {
      add(handler);
    } catch (e, st) {
      out
        ..addError(e, st)
        ..close();
      return;
    }
    out.onCancel = () => remove(handler);
  };
  return out.stream;
}

Stream<T> _usingStream<R, T>(
  R Function() acquire,
  Stream<T> Function(R resource) asStream,
  FutureOr<void> Function(R resource) release,
) {
  final out = StreamController<T>();
  out.onListen = () {
    late final R resource;
    try {
      resource = acquire();
    } catch (e, st) {
      out
        ..addError(e, st)
        ..close();
      return;
    }

    var released = false;
    Future<void> dispose() async {
      if (released) return;
      released = true;
      await release(resource);
    }

    final Stream<T> source;
    try {
      source = asStream(resource);
    } catch (e, st) {
      out
        ..addError(e, st)
        ..close();
      dispose();
      return;
    }

    late final StreamSubscription<T> sub;
    sub = source.listen(
      out.add,
      onError: (Object e, StackTrace st) {
        out.addError(e, st);
        sub.cancel();
        out.close();
        dispose();
      },
      onDone: () {
        out.close();
        dispose();
      },
    );
    out
      ..onPause = sub.pause
      ..onResume = sub.resume
      ..onCancel = () async {
        await sub.cancel();
        await dispose();
      };
  };
  return out.stream;
}

Stream<T> _createStream<T>(void Function(EventEmitter<T> emit) init) {
  final out = StreamController<T>();
  out.onListen = () {
    final emit = EventEmitter._(out);
    out.onCancel = emit._teardown;
    try {
      init(emit);
    } catch (e, st) {
      if (!out.isClosed) {
        out
          ..addError(e, st)
          ..close();
      }
    }
  };
  return out.stream;
}

/// A live "current value" with subscribers — fxdart's counterpart of Rx's
/// `BehaviorSubject`, reduced to its defining behavior: a late subscriber
/// immediately receives the latest value, then the live updates.
///
/// fxdart events layer (inspired by Rx; not part of FxTS).
///
/// ```dart
/// final temp = LiveValue.seeded(21.0);
/// temp.stream.listen(print); // prints 21.0 immediately, then updates
/// temp.add(21.5);
/// ```
class LiveValue<T> {
  final _controller = StreamController<T>.broadcast();
  T? _value;
  var _hasValue = false;
  var _closed = false;
  StreamSubscription<T>? _source;

  /// An empty [LiveValue]; subscribers get nothing until the first [add].
  LiveValue();

  /// A [LiveValue] that already holds [value].
  LiveValue.seeded(T value) : _value = value, _hasValue = true;

  /// A [LiveValue] fed by [source], starting empty.
  ///
  /// The subscription is opened immediately and is *hot*: values arriving
  /// before anyone listens still update [value]. When [source] closes,
  /// so does this. Errors reach subscribers but do not become the value.
  /// [close] cancels the subscription.
  ///
  /// Named constructors rather than an optional seed, so that a nullable
  /// `T` can still be seeded with null. fxdart events layer, after Rx's
  /// `publishValue`/`shareValue`.
  LiveValue.from(Stream<T> source) {
    _bind(source);
  }

  /// A [LiveValue] fed by [source] that already holds [seed] until the
  /// source's first value replaces it. See [LiveValue.from].
  LiveValue.seededFrom(T seed, Stream<T> source)
    : _value = seed,
      _hasValue = true {
    _bind(source);
  }

  void _bind(Stream<T> source) {
    _source = source.listen(
      (v) {
        _value = v;
        _hasValue = true;
        _controller.add(v);
      },
      onError: _controller.addError,
      onDone: close,
    );
  }

  /// Whether a value has been set (by seed or [add]).
  bool get hasValue => _hasValue;

  /// The latest value. Throws a [StateError] when none has been set —
  /// check [hasValue], or construct with [LiveValue.seeded].
  T get value {
    if (!_hasValue) {
      throw StateError(
        'LiveValue has no value yet — check hasValue or use LiveValue.seeded',
      );
    }
    return _value as T;
  }

  /// Whether [close] has been called.
  bool get isClosed => _closed;

  /// Stores [value] as the current value and delivers it to subscribers.
  void add(T value) {
    if (_closed) throw StateError('LiveValue is closed');
    _value = value;
    _hasValue = true;
    _controller.add(value);
  }

  /// The value feed: each new listener first receives the current value
  /// (when one exists), then every subsequent [add], as an [FxEvents]
  /// chain (unwrap with `.stream` for a plain [Stream]).
  FxEvents<T> get live {
    late StreamController<T> c;
    StreamSubscription<T>? sub;
    c = StreamController<T>(
      onListen: () {
        // Synchronous replay-then-subscribe: no update can slip between the
        // replayed value and the live feed.
        if (_hasValue) c.add(_value as T);
        if (_closed) {
          c.close();
          return;
        }
        sub = _controller.stream.listen(
          c.add,
          onError: c.addError,
          onDone: c.close,
        );
      },
      onPause: () => sub?.pause(),
      onResume: () => sub?.resume(),
      onCancel: () => sub?.cancel(),
    );
    return FxEvents(c.stream);
  }

  /// Plain-[Stream] view of [live].
  Stream<T> get stream => live.stream;

  /// Closes the feed; subscribers' streams close after any replayed
  /// value. A source attached by [LiveValue.from] is cancelled too.
  Future<void> close() {
    _closed = true;
    final source = _source;
    _source = null;
    return Future.wait([
      if (source != null) source.cancel(),
      _controller.close(),
    ]);
  }
}
