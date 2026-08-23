import 'dart:async';

import 'events.dart';

/// A bounded replay buffer with subscribers — fxdart's counterpart of Rx's
/// `ReplaySubject`. A late subscriber immediately receives the retained
/// values (those still inside [size] and [maxAge]), then the live updates.
///
/// fxdart events layer (inspired by Rx; not part of FxTS).
///
/// ```dart
/// final recent = ReplayValue<int>(size: 3);
/// recent.add(1);
/// recent.add(2);
/// recent.add(3);
/// recent.add(4);
/// recent.stream.listen(print); // prints 2, 3, 4, then updates
/// ```
class ReplayValue<T> {
  final int? _size;
  final Duration? _maxAge;
  final _controller = StreamController<T>.broadcast();
  final _buffer = <({DateTime at, T value})>[];
  var _closed = false;

  /// A replay buffer.
  ///
  /// [size] keeps the last n values (default 1). Pass `null`, or a value
  /// less than 1, for an unbounded buffer.
  ///
  /// [maxAge] drops buffered values older than that duration, both when
  /// a new value is added and when a subscriber listens.
  ReplayValue({int? size = 1, Duration? maxAge})
    : _size = size,
      _maxAge = maxAge;

  /// Whether [close] has been called.
  bool get isClosed => _closed;

  /// Stores [value] at the end of the buffer, trims to [size] / [maxAge],
  /// and delivers it to current subscribers.
  void add(T value) {
    if (_closed) throw StateError('ReplayValue is closed');
    _buffer.add((at: DateTime.now(), value: value));
    _trim();
    _controller.add(value);
  }

  /// Delivers [error] to current subscribers. Errors are not retained —
  /// a late listener does not see past errors. Same contract as
  /// [LiveValue]: errors go to subscribers, not into the value buffer.
  void addError(Object error, [StackTrace? stackTrace]) {
    if (_closed) throw StateError('ReplayValue is closed');
    _controller.addError(error, stackTrace);
  }

  /// The value feed: each new listener first receives the retained
  /// buffer (values that still pass [maxAge]), then every subsequent
  /// [add], as an [FxEvents] chain (unwrap with `.stream` for a plain
  /// [Stream]).
  ///
  /// After [close], a late listener still gets the buffer, then done.
  FxEvents<T> get live {
    late StreamController<T> c;
    StreamSubscription<T>? sub;
    c = StreamController<T>(
      onListen: () {
        // Synchronous replay-then-subscribe: no update can slip between
        // the replayed values and the live feed.
        _trim();
        for (final entry in List.of(_buffer)) {
          c.add(entry.value);
        }
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

  /// Closes the feed. Late listeners still receive the retained buffer,
  /// then done — like Rx's `ReplaySubject`.
  Future<void> close() {
    if (_closed) return _controller.done;
    _closed = true;
    return _controller.close();
  }

  void _trim() {
    if (_maxAge != null) {
      final cutoff = DateTime.now().subtract(_maxAge);
      while (_buffer.isNotEmpty && _buffer.first.at.isBefore(cutoff)) {
        _buffer.removeAt(0);
      }
    }
    final size = _size;
    if (size != null && size >= 1) {
      while (_buffer.length > size) {
        _buffer.removeAt(0);
      }
    }
  }
}

/// Remembers the last value and emits it only on [close] — fxdart's
/// counterpart of Rx's `AsyncSubject`. Subscribers while open receive
/// nothing; on close they get the last value (if any) then done.
///
/// fxdart events layer (inspired by Rx; not part of FxTS).
///
/// ```dart
/// final last = CompletionValue<int>();
/// last.add(1);
/// last.add(2);
/// last.stream.listen(print); // prints nothing yet
/// await last.close(); // prints 2, then done
/// ```
class CompletionValue<T> {
  final _controller = StreamController<T>.broadcast();
  T? _value;
  var _hasValue = false;
  var _closed = false;
  var _hasError = false;
  Object? _error;
  StackTrace? _stackTrace;

  /// An empty [CompletionValue]; nothing is emitted until [close].
  CompletionValue();

  /// Whether a value has been [add]ed (readable even before [close]).
  bool get hasValue => _hasValue;

  /// The remembered value. Throws a [StateError] when none has been
  /// set — check [hasValue]. After [close] with a value, this is still
  /// readable.
  T get value {
    if (!_hasValue) {
      throw StateError('CompletionValue has no value yet — check hasValue');
    }
    return _value as T;
  }

  /// Whether [close] or [addError] has been called.
  bool get isClosed => _closed;

  /// Remembers [value] as the last value. Not emitted until [close].
  void add(T value) {
    if (_closed) throw StateError('CompletionValue is closed');
    _value = value;
    _hasValue = true;
  }

  /// Delivers [error] to current subscribers and closes. Late listeners
  /// receive the error (not a remembered value). Rx `AsyncSubject`
  /// contract: an error completes the subject immediately.
  void addError(Object error, [StackTrace? stackTrace]) {
    if (_closed) throw StateError('CompletionValue is closed');
    _closed = true;
    _hasError = true;
    _error = error;
    _stackTrace = stackTrace;
    _controller.addError(error, stackTrace);
    _controller.close();
  }

  /// The value feed. Listeners while open wait for [close]; listeners
  /// after [close] get the last value (if any) then done, immediately.
  FxEvents<T> get live {
    late StreamController<T> c;
    StreamSubscription<T>? sub;
    c = StreamController<T>(
      onListen: () {
        if (_hasError) {
          c.addError(_error!, _stackTrace);
          c.close();
          return;
        }
        if (_closed) {
          if (_hasValue) c.add(_value as T);
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

  /// Emits the last value (if any) then done. A late listener after
  /// this still gets that value then done. Closing with no value
  /// produces just done.
  Future<void> close() {
    if (_closed) return _controller.done;
    _closed = true;
    if (_hasValue) _controller.add(_value as T);
    return _controller.close();
  }
}
