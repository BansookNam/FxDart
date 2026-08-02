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

/// Chainable event-stream operators over a plain Dart [Stream].
///
/// A thin wrapper (never an extension), so it can coexist with any other
/// stream library — including rxdart — without member conflicts. Every
/// operator returns a new [FxEvents] over a derived single-subscription
/// stream; unwrap with [stream], collect with [toList], or continue in the
/// pull model with [pull].
class FxEvents<T> {
  final Stream<T> _inner;

  /// Wraps [_inner] without listening to it; the chain stays cold.
  const FxEvents(this._inner);

  /// The wrapped stream, for handing to any `Stream`-based API.
  Stream<T> get stream => _inner;

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
        subs.add(list[i].listen(
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
        ));
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
        subs.add(s.listen(out.add, onError: out.addError, onDone: () {
          if (++done == list.length) out.close();
        }));
      }
      out.onCancel = () => Future.wait(subs.map((s) => s.cancel()));
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
      final sub = _inner.listen((v) {
        pending = v;
        hasPending = true;
        timer?.cancel();
        timer = Timer(window, () {
          hasPending = false;
          out.add(pending);
        });
      }, onError: out.addError, onDone: () {
        timer?.cancel();
        if (hasPending) out.add(pending);
        out.close();
      });
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
  FxEvents<T> throttle(Duration window,
      {bool leading = true, bool trailing = false}) {
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

      final sub = _inner.listen((v) {
        if (timer == null) {
          timer = Timer(window, endWindow);
          if (leading) {
            out.add(v);
            return;
          }
        }
        pending = v;
        hasPending = trailing;
      }, onError: out.addError, onDone: () {
        closed = true;
        // A trailing value still waiting on its window is delivered before
        // the close; without one, close immediately.
        if (timer == null || !(trailing && hasPending)) {
          timer?.cancel();
          out.close();
        }
      });
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
      sourceSub = _inner.listen((v) {
        latest = v;
        hasNew = true;
      }, onError: out.addError, onDone: () {
        triggerSub.cancel();
        out.close();
      });
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

  // --- combination ----------------------------------------------------------

  /// On every event from either side, emits [combine] of the two latest
  /// values — once both sides have produced at least one. Closes when both
  /// sides have closed.
  FxEvents<R> combineLatest<U, R>(
      Stream<U> other, R Function(T a, U b) combine) {
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

      final subA = _inner.listen((v) {
        a = v;
        hasA = true;
        emit();
      }, onError: out.addError, onDone: onDone);
      final subB = other.listen((v) {
        b = v;
        hasB = true;
        emit();
      }, onError: out.addError, onDone: onDone);
      out.onCancel = () => Future.wait([subA.cancel(), subB.cancel()]);
    };
    return FxEvents(out.stream);
  }

  /// On every SOURCE event, emits [combine] of it and the latest value of
  /// [other] — source events before [other] has spoken are dropped. Closes
  /// when the source closes; [other]'s close is ignored.
  FxEvents<R> withLatestFrom<U, R>(
      Stream<U> other, R Function(T a, U b) combine) {
    final out = StreamController<R>();
    out.onListen = () {
      late U latest;
      var hasLatest = false;
      final otherSub = other.listen((v) {
        latest = v;
        hasLatest = true;
      }, onError: out.addError);
      late final StreamSubscription<T> sourceSub;
      sourceSub = _inner.listen((v) {
        if (hasLatest) out.add(combine(v, latest));
      }, onError: out.addError, onDone: () {
        otherSub.cancel();
        out.close();
      });
      out.onCancel = () =>
          Future.wait([sourceSub.cancel(), otherSub.cancel()]);
    };
    return FxEvents(out.stream);
  }

  /// Maps each event to an inner stream and mirrors only the NEWEST one:
  /// a fresh event cancels the previous inner stream mid-flight. Closes
  /// when the source has closed and the last inner stream completes.
  FxEvents<R> switchMap<R>(Stream<R> Function(T a) f) {
    final out = StreamController<R>();
    out.onListen = () {
      StreamSubscription<R>? innerSub;
      var outerDone = false;
      final sub = _inner.listen((v) {
        innerSub?.cancel();
        final Stream<R> inner;
        try {
          inner = f(v);
        } catch (e, st) {
          out.addError(e, st);
          return;
        }
        late final StreamSubscription<R> s;
        s = inner.listen(out.add, onError: out.addError, onDone: () {
          if (identical(innerSub, s)) {
            innerSub = null;
            if (outerDone) out.close();
          }
        });
        innerSub = s;
      }, onError: out.addError, onDone: () {
        outerDone = true;
        if (innerSub == null) out.close();
      });
      out.onCancel = () => Future.wait(
          [sub.cancel(), if (innerSub != null) innerSub!.cancel()]);
    };
    return FxEvents(out.stream);
  }

  // --- conveniences ---------------------------------------------------------

  /// Emits [value], then the source's events.
  FxEvents<T> startWith(T value) {
    final out = StreamController<T>();
    out.onListen = () {
      out.add(value);
      final sub =
          _inner.listen(out.add, onError: out.addError, onDone: out.close);
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

  // --- terminals & bridges --------------------------------------------------

  /// Listens to the chain (a plain [Stream.listen] passthrough).
  StreamSubscription<T> listen(void Function(T event)? onData,
          {Function? onError, void Function()? onDone, bool? cancelOnError}) =>
      _inner.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  /// Collects every event into a list (completes when the stream closes).
  Future<List<T>> toList() => _inner.toList();

  /// Crosses into the pull model: the events become an [FxAsync] chain,
  /// pulled on demand from here on.
  FxAsync<T> pull() => fxAsync(fromStream(_inner));
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

  /// An empty [LiveValue]; subscribers get nothing until the first [add].
  LiveValue();

  /// A [LiveValue] that already holds [value].
  LiveValue.seeded(T value)
      : _value = value,
        _hasValue = true;

  /// Whether a value has been set (by seed or [add]).
  bool get hasValue => _hasValue;

  /// The latest value. Throws a [StateError] when none has been set —
  /// check [hasValue], or construct with [LiveValue.seeded].
  T get value {
    if (!_hasValue) {
      throw StateError(
          'LiveValue has no value yet — check hasValue or use LiveValue.seeded');
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
    c = StreamController<T>(onListen: () {
      // Synchronous replay-then-subscribe: no update can slip between the
      // replayed value and the live feed.
      if (_hasValue) c.add(_value as T);
      if (_closed) {
        c.close();
        return;
      }
      sub = _controller.stream
          .listen(c.add, onError: c.addError, onDone: c.close);
    }, onPause: () => sub?.pause(), onResume: () => sub?.resume(),
        onCancel: () => sub?.cancel());
    return FxEvents(c.stream);
  }

  /// Plain-[Stream] view of [live].
  Stream<T> get stream => live.stream;

  /// Closes the feed; subscribers' streams close after any replayed value.
  Future<void> close() {
    _closed = true;
    return _controller.close();
  }
}
