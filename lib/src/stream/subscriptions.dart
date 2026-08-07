import 'dart:async';

/// A bag of [StreamSubscription]s cancelled together.
///
/// fxdart events layer (inspired by Rx; not part of FxTS), after Rx's
/// `CompositeSubscription`. A long-lived object that listens to several
/// streams has to hold every subscription just to cancel them again; this
/// collects them behind one [cancelAll].
///
/// ```dart
/// final subs = FxSubscriptions();
///
/// void init() {
///   subs
///     ..add(fxEvents(ticks).throttle(_second).listen(_onTick))
///     ..add(fxEvents(clicks).debounce(_short).listen(_onClick));
/// }
///
/// Future<void> dispose() => subs.cancelAll();
/// ```
///
/// After [cancelAll] the bag is empty and reusable — a later [add] starts a
/// fresh generation.
class FxSubscriptions {
  final _subs = <StreamSubscription<void>>[];

  /// How many subscriptions are held.
  int get length => _subs.length;

  /// Whether the bag holds nothing.
  bool get isEmpty => _subs.isEmpty;

  /// Whether the bag holds at least one subscription.
  bool get isNotEmpty => _subs.isNotEmpty;

  /// Adds [subscription] to the bag and returns it, so the call can be
  /// used as an expression.
  StreamSubscription<T> add<T>(StreamSubscription<T> subscription) {
    _subs.add(subscription);
    return subscription;
  }

  /// Adds every subscription in [subscriptions].
  void addAll(Iterable<StreamSubscription<void>> subscriptions) =>
      _subs.addAll(subscriptions);

  /// Cancels every held subscription and empties the bag.
  ///
  /// The bag is cleared before the cancellations are awaited, so a
  /// second [cancelAll] during the wait cancels nothing twice.
  Future<void> cancelAll() {
    final pending = List.of(_subs);
    _subs.clear();
    return Future.wait(pending.map((s) => s.cancel()));
  }

  /// Pauses every held subscription.
  void pauseAll() {
    for (final s in _subs) {
      s.pause();
    }
  }

  /// Resumes every held subscription.
  void resumeAll() {
    for (final s in _subs) {
      s.resume();
    }
  }
}
