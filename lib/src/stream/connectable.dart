import 'dart:async';

import 'events.dart';
import 'values.dart';

/// A multicast wrapper that does not subscribe to its source until
/// [connect] — fxdart's counterpart of Rx's `ConnectableObservable`.
///
/// [events] is a broadcast of whatever [connect] forwards. Listeners
/// attached before [connect] wait; late listeners miss already-emitted
/// values (use [FxEventsConnectable.shareReplay] to keep history).
///
/// fxdart events layer (inspired by Rx; not part of FxTS).
///
/// ```dart
/// final published = fxEvents(source).connectable();
/// published.events.listen(print); // nothing yet
/// published.connect(); // source starts
/// ```
class ConnectableEvents<T> {
  final Stream<T> _source;
  final StreamController<T> _controller;
  StreamSubscription<void>? _connection;

  /// The multicast feed. Listening here does not start the source.
  final FxEvents<T> events;

  ConnectableEvents._(Stream<T> source)
    : this._with(source, StreamController<T>.broadcast());

  ConnectableEvents._with(this._source, this._controller)
    : events = FxEvents(_controller.stream);

  /// Starts forwarding the source into [events]. A second call while
  /// already connected is a no-op and returns the existing subscription.
  /// Cancel the subscription to stop forwarding.
  StreamSubscription<void> connect() {
    if (_connection != null) return _connection!;
    return _connection = _source.listen(
      _controller.add,
      onError: _controller.addError,
      onDone: _controller.close,
    );
  }

  /// Connects on the first listener, disconnects on the last.
  ///
  /// A later generation of listeners reconnects the source (when the
  /// source itself allows a second listen).
  FxEvents<T> refCount() {
    var refs = 0;
    return FxEvents(
      Stream<T>.multi((listener) {
        refs++;
        final sub = _controller.stream.listen(
          listener.add,
          onError: listener.addError,
          onDone: listener.close,
        );
        if (refs == 1) connect();
        listener
          ..onPause = sub.pause
          ..onResume = sub.resume
          ..onCancel = () async {
            await sub.cancel();
            refs--;
            if (refs == 0) {
              final connection = _connection;
              _connection = null;
              await connection?.cancel();
            }
          };
      }),
    );
  }
}

/// Multicasting entry points on an [FxEvents] chain.
extension FxEventsConnectable<T> on FxEvents<T> {
  /// A connectable view of this chain. The source is not subscribed
  /// until [ConnectableEvents.connect].
  ConnectableEvents<T> connectable() => ConnectableEvents._(stream);

  /// Multicasts through a [ReplayValue]. The first listener connects
  /// the source; late listeners receive the retained history, then
  /// follow.
  ///
  /// [size] keeps the last n values (`null`, the default, is unbounded).
  /// [maxAge] drops values older than that duration.
  ///
  /// [resetOnCancel] (default `true`): the last listener leaving
  /// disconnects the source and the next generation is a fresh
  /// [ReplayValue]. `false` leaves the source connected forever, so
  /// later listeners still see the same buffer.
  FxEvents<T> shareReplay({
    int? size,
    Duration? maxAge,
    bool resetOnCancel = true,
  }) {
    ReplayValue<T>? replay;
    StreamSubscription<T>? sourceSub;
    var refs = 0;
    return FxEvents(
      Stream<T>.multi((listener) {
        var current = replay;
        if (current == null) {
          current = ReplayValue<T>(size: size, maxAge: maxAge);
          replay = current;
          sourceSub = stream.listen(
            current.add,
            onError: current.addError,
            onDone: current.close,
          );
        }
        final ReplayValue<T> active = current;
        refs++;
        final sub = active.live.stream.listen(
          listener.add,
          onError: listener.addError,
          onDone: listener.close,
        );
        listener
          ..onPause = sub.pause
          ..onResume = sub.resume
          ..onCancel = () async {
            await sub.cancel();
            refs--;
            if (refs == 0 && resetOnCancel) {
              final pending = sourceSub;
              sourceSub = null;
              replay = null;
              await pending?.cancel();
              await active.close();
            }
          };
      }),
    );
  }
}
