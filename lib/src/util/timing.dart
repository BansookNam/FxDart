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

  void call(T arg) {
    final now = DateTime.now();
    if (_lastCallTime == null) {
      var leadingFired = false;
      if (_leading) {
        _func(arg);
        _lastCallTime = now;
        leadingFired = true;
      }
      _lastArg = arg;
      _hasPendingArg = !leadingFired;
      if (_trailing) {
        _timer = Timer(_wait, () {
          if (_hasPendingArg) {
            _func(_lastArg as T);
          }
          _lastCallTime = null;
          _lastArg = null;
          _hasPendingArg = false;
          _timer = null;
        });
      } else if (!_trailing && !_leading) {
        _lastCallTime = null;
      }
      return;
    }
    // Subsequent calls: remember the latest argument, keep the timer.
    _lastArg = arg;
    _hasPendingArg = true;
    if (_trailing && _timer == null) {
      final remaining = _wait - now.difference(_lastCallTime!);
      _timer = Timer(remaining.isNegative ? Duration.zero : remaining, () {
        if (_hasPendingArg) {
          _func(_lastArg as T);
          _lastCallTime = DateTime.now();
        }
        _lastArg = null;
        _hasPendingArg = false;
        _timer = null;
      });
    }
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
