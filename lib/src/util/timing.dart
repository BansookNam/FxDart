import 'dart:async';

/// A debounced function, as returned by [debounce].
///
/// Port of the FxTS debounced callable (JS attaches `cancel` to the
/// function; Dart uses a callable class).
class Debounced<T> {
  final void Function(T arg) _func;
  final Duration _wait;
  final bool _leading;
  Timer? _timer;

  Debounced._(this._func, this._wait, {required bool leading})
      : _leading = leading;

  /// Registers a call with [arg], (re)starting the wait window. The wrapped
  /// function runs on the trailing edge (or immediately, once per idle
  /// window, when constructed with `leading: true`).
  void call(T arg) {
    final callNow = _leading && _timer == null;
    _timer?.cancel();
    _timer = Timer(_wait, () {
      _timer = null;
      if (!_leading) {
        _func(arg);
      }
    });
    if (callNow) {
      _func(arg);
    }
  }

  /// Cancels the pending trailing invocation, if any.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Creates a debounced function that delays invoking [func] until [wait] has
/// elapsed since the last invocation. With [leading] it fires on the leading
/// edge instead.
///
/// Port of FxTS `debounce` (`Util/debounce.ts`).
Debounced<T> debounce<T>(void Function(T arg) func, Duration wait,
        {bool leading = false}) =>
    Debounced._(func, wait, leading: leading);

/// A throttled function, as returned by [throttle].
class Throttled<T> {
  final void Function(T arg) _func;
  final Duration _wait;
  final bool _leading;
  final bool _trailing;
  Timer? _timer;
  DateTime? _lastCallTime;
  T? _lastArg;
  bool _hasPendingArg = false;

  Throttled._(this._func, this._wait,
      {required bool leading, required bool trailing})
      : _leading = leading,
        _trailing = trailing;

  /// Registers a call with [arg]. The wrapped function runs at most once per
  /// [wait] window — on the leading edge, the trailing edge, or both, per the
  /// flags passed to [throttle].
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
Throttled<T> throttle<T>(void Function(T arg) func, Duration wait,
        {bool leading = true, bool trailing = true}) =>
    Throttled._(func, wait, leading: leading, trailing: trailing);
