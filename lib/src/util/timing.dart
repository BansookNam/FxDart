import 'dart:async';

/// A debounced function, as returned by [fxDebounce].
///
/// Port of the FxTS debounced callable (JS attaches `cancel` to the
/// function; Dart uses a callable class). [flush], [isPending] and the
/// `maxWait` bound are fxdart extensions, after lodash's `debounce`.
class Debounced<T> {
  final void Function(T arg) _func;
  final Duration _wait;
  final Duration? _maxWait;
  final bool _leading;
  Timer? _timer;
  Timer? _maxTimer;
  T? _arg;
  bool _pending = false;

  Debounced._(
    this._func,
    this._wait, {
    required bool leading,
    Duration? maxWait,
  }) : _leading = leading,
       _maxWait = maxWait {
    if (maxWait != null && maxWait < _wait) {
      throw ArgumentError.value(
        maxWait,
        'maxWait',
        'must be at least wait ($_wait)',
      );
    }
  }

  /// Registers a call with [arg], (re)starting the wait window. The wrapped
  /// function runs on the trailing edge (or immediately, once per idle
  /// window, when constructed with `leading: true`).
  ///
  /// With `maxWait`, the window cannot be stretched past `maxWait` from its
  /// first call: a stream of calls that never pauses for [_wait] still runs
  /// the function (with the newest argument) once per `maxWait`.
  void call(T arg) {
    final idle = _timer == null;
    _timer?.cancel();
    _timer = Timer(_wait, _close);
    final maxWait = _maxWait;
    if (maxWait != null && _maxTimer == null) {
      _maxTimer = Timer(maxWait, _close);
    }
    if (_leading) {
      // Leading mode never has a trailing call: the first call of an idle
      // window runs now, the rest only keep the window open.
      if (idle) _func(arg);
      return;
    }
    _arg = arg;
    _pending = true;
  }

  /// Ends the window: both timers go, and a pending trailing call runs.
  void _close() {
    _timer?.cancel();
    _timer = null;
    _maxTimer?.cancel();
    _maxTimer = null;
    if (!_pending) return;
    final arg = _arg as T;
    _arg = null;
    _pending = false;
    _func(arg);
  }

  /// Whether a trailing invocation is waiting to run.
  ///
  /// Always `false` for a `leading: true` debounce, which has no trailing
  /// call.
  bool get isPending => _pending;

  /// Runs the pending trailing invocation now, with the newest argument, and
  /// ends the window. Does nothing when nothing is pending.
  ///
  /// The call to make from `dispose` or an app-pause hook, where cancelling
  /// would drop the last value and waiting is not an option.
  void flush() {
    if (_pending) _close();
  }

  /// Cancels the pending trailing invocation, if any.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _maxTimer?.cancel();
    _maxTimer = null;
    _arg = null;
    _pending = false;
  }
}

/// Creates a debounced function that delays invoking [func] until [wait] has
/// elapsed since the last invocation. With [leading] it fires on the leading
/// edge instead.
///
/// [maxWait] caps how long calls can keep postponing [func]: once that much
/// time has passed since the first call of a window, the window closes (and
/// a trailing call runs) even if calls are still arriving. It must be at
/// least [wait]. Without it, a source that never pauses never fires.
///
/// Port of FxTS `debounce` (`Util/debounce.ts`); `maxWait`,
/// [Debounced.flush] and [Debounced.isPending] are fxdart extensions, after
/// lodash.
///
/// ```dart
/// final save = fxDebounce(prefs.save, Duration(milliseconds: 300),
///     maxWait: Duration(seconds: 2));
/// slider.onChanged = save;      // at most one write per pause (or per 2s)
/// onPause = save.flush;         // write the last value before suspending
/// ```
Debounced<T> fxDebounce<T>(
  void Function(T arg) func,
  Duration wait, {
  bool leading = false,
  Duration? maxWait,
}) => Debounced._(func, wait, leading: leading, maxWait: maxWait);

/// A throttled function, as returned by [fxThrottle].
class Throttled<T> {
  final void Function(T arg) _func;
  final Duration _wait;
  final bool _leading;
  final bool _trailing;
  Timer? _timer;
  DateTime? _lastCallTime;
  T? _lastArg;
  bool _hasPendingArg = false;

  Throttled._(
    this._func,
    this._wait, {
    required bool leading,
    required bool trailing,
  }) : _leading = leading,
       _trailing = trailing;

  /// Registers a call with [arg]. The wrapped function runs at most once per
  /// [wait] window — on the leading edge, the trailing edge, or both, per the
  /// flags passed to [fxThrottle].
  void call(T arg) {
    final now = DateTime.now();
    final last = _lastCallTime;

    // A new window opens whenever nothing has run within the last [_wait].
    // The window start is recorded regardless of [_leading]; otherwise a
    // trailing-only throttle could never tell windows apart and would
    // degenerate into a debounce.
    if (last == null || now.difference(last) >= _wait) {
      // A pending timer can only survive here if it is due at this exact
      // instant; drop it so it cannot fire alongside the new window.
      _timer?.cancel();
      _timer = null;
      _lastCallTime = now;
      if (_leading) {
        _lastArg = null;
        _hasPendingArg = false;
        _func(arg);
        return;
      }
      // No leading edge: this call is itself the pending trailing invocation.
      _lastArg = arg;
      _hasPendingArg = _trailing;
      if (_trailing) _scheduleTrailing(_wait);
      return;
    }

    // Within the window: remember the newest argument for the trailing edge
    // without extending the deadline (this is what separates throttle from
    // debounce).
    _lastArg = arg;
    _hasPendingArg = _trailing;
    if (_trailing && _timer == null) {
      _scheduleTrailing(_wait - now.difference(last));
    }
  }

  void _scheduleTrailing(Duration remaining) {
    _timer = Timer(remaining, () {
      _timer = null;
      if (_hasPendingArg) {
        // The trailing invocation opens the next window.
        _lastCallTime = DateTime.now();
        _func(_lastArg as T);
      }
      _lastArg = null;
      _hasPendingArg = false;
    });
  }

  /// Cancels any pending trailing invocation.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _lastCallTime = null;
    _lastArg = null;
    _hasPendingArg = false;
  }
}

/// Creates a throttled function that invokes [func] at most once per [wait].
///
/// Port of FxTS `throttle` (`Util/throttle.ts`).
Throttled<T> fxThrottle<T>(
  void Function(T arg) func,
  Duration wait, {
  bool leading = true,
  bool trailing = true,
}) => Throttled._(func, wait, leading: leading, trailing: trailing);

/// Method spellings of [fxDebounce], [fxThrottle] and [fxOnChange], on the
/// callback itself.
///
/// Both carry the `fx` prefix on purpose. `saveDraft.debounce(…)` would read
/// as if Dart had always had it; `saveDraft.fxDebounce(…)` says which library
/// is wrapping the callback, and leaves the bare names free for whatever else
/// a project puts on its function types.
extension FxCallbackTiming<T> on void Function(T arg) {
  /// This callback, debounced by [wait]. See [fxDebounce].
  Debounced<T> fxDebounce(
    Duration wait, {
    bool leading = false,
    Duration? maxWait,
  }) => Debounced._(this, wait, leading: leading, maxWait: maxWait);

  /// This callback, throttled to once per [wait]. See [fxThrottle].
  Throttled<T> fxThrottle(
    Duration wait, {
    bool leading = true,
    bool trailing = true,
  }) => Throttled._(this, wait, leading: leading, trailing: trailing);

  /// This callback, called only when its argument changes. See [fxOnChange].
  OnChange<T> fxOnChange({bool Function(T previous, T next)? equals}) =>
      OnChange._(this, equals);
}

/// A change-gated function, as returned by [fxOnChange].
class OnChange<T> {
  final void Function(T arg) _func;
  final bool Function(T previous, T next)? _equals;
  T? _last;
  bool _seen = false;

  OnChange._(this._func, this._equals);

  /// Runs the wrapped function with [arg] unless [arg] equals the argument
  /// of the last call that ran it. The first call always runs.
  ///
  /// [arg] becomes the last argument only once the wrapped function returns:
  /// when it throws, the next call with the same value runs it again.
  void call(T arg) {
    if (_seen) {
      final last = _last as T;
      final equals = _equals;
      if (equals == null ? last == arg : equals(last, arg)) return;
    }
    _func(arg);
    _last = arg;
    _seen = true;
  }

  /// Forgets the last argument, so the next call runs whatever it carries.
  void reset() {
    _last = null;
    _seen = false;
  }
}

/// Wraps [func] so it runs only when its argument differs from the last one
/// it ran with — `uniqAdjacent` for a callback. Arguments are compared with
/// `==`, or with [equals] when given. The first call always runs.
///
/// For a value polled on a timer or recomputed every frame (an elapsed
/// second, a coin count, a progress fraction) that should cost a rebuild
/// only when it actually moves.
///
/// fxdart extension (not part of FxTS); the callback twin of
/// `uniqAdjacent`, alongside [fxDebounce] and [fxThrottle].
///
/// ```dart
/// final show = fxOnChange<int>((s) => setState(() => _seconds = s));
/// Timer.periodic(Duration(milliseconds: 250), (_) => show(elapsed()));
/// // setState runs once a second, not four times
/// ```
OnChange<T> fxOnChange<T>(
  void Function(T arg) func, {
  bool Function(T previous, T next)? equals,
}) => OnChange._(func, equals);

/// A conflating async runner, as returned by [fxConflate].
class Conflated<T> {
  final FutureOr<void> Function(T value) _run;
  final void Function(Object error, StackTrace stackTrace)? _onError;
  bool _running = false;
  bool _hasNext = false;
  T? _next;
  Completer<void>? _idle;

  Conflated._(this._run, this._onError);

  /// Starts a run with [value], or — when a run is already in flight —
  /// keeps [value] as the next one, replacing any value kept before it.
  void call(T value) {
    if (_running) {
      _next = value;
      _hasNext = true;
      return;
    }
    _start(value);
  }

  void _start(T value) {
    _running = true;
    Future<void>.sync(() => _run(value)).then(
      (_) => _done(),
      onError: (Object e, StackTrace st) {
        // `finally`: an `onError` that throws must not leave the runner
        // stuck in `_running` (its error still reaches the zone).
        try {
          final onError = _onError;
          if (onError != null) {
            onError(e, st);
          } else {
            Zone.current.handleUncaughtError(e, st);
          }
        } finally {
          _done();
        }
      },
    );
  }

  void _done() {
    if (_hasNext) {
      final next = _next as T;
      _next = null;
      _hasNext = false;
      _start(next);
      return;
    }
    _running = false;
    final idle = _idle;
    _idle = null;
    idle?.complete();
  }

  /// Whether a run is in flight.
  bool get isRunning => _running;

  /// Whether a value is waiting for the in-flight run to finish.
  bool get isPending => _hasNext;

  /// Completes once no run is in flight and no value is waiting.
  Future<void> get idle {
    if (!_running) return Future<void>.value();
    return (_idle ??= Completer<void>()).future;
  }

  /// Drops the waiting value, if any. A run already in flight is not
  /// interrupted — a `Future` cannot be.
  void cancel() {
    _next = null;
    _hasNext = false;
  }
}

/// Wraps the async [run] so that at most one run is in flight: a call that
/// arrives while one is running is held, and only the **newest** held value
/// runs when it finishes. Values in between are dropped.
///
/// The shape of a video scrubber's `seekTo`, a "sync to the server" button
/// pressed while a sync is still going, or a preview rendered from a slider:
/// every call matters only as "the latest state", and starting runs in
/// parallel would let an old one finish last. Unlike [fxDebounce] it never
/// waits — the first call starts at once — and unlike
/// `FxEvents.exhaustLatest`/`switchLatest` it needs no stream and never
/// abandons the run in flight.
///
/// An error thrown by [run] goes to [onError], or to the current zone when
/// there is none; it does not stop later runs.
///
/// fxdart extension (not part of FxTS), after Kotlin Flow's `conflate`.
///
/// ```dart
/// final seek = fxConflate<Duration>((at) => player.seekTo(at));
/// slider.onChanged = (v) => seek(total * v);
/// // seeks one after another, each to wherever the thumb is now
/// ```
Conflated<T> fxConflate<T>(
  FutureOr<void> Function(T value) run, {
  void Function(Object error, StackTrace stackTrace)? onError,
}) => Conflated._(run, onError);
