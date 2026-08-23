import '../async_iterable.dart';
import '../fx.dart';
import 'events.dart';

/// Crosses an [FxEvents] chain into the pull model under an explicit
/// drop/batch policy. Existing [FxEvents.pull] stays the lossless default.
extension FxEventsPull<T> on FxEvents<T> {
  /// Latest-wins: each arrival while the consumer is busy replaces the
  /// unread slot.
  FxAsync<T> pullLatest() => fxAsync(fromStreamLatest(stream));

  /// Batched: values that arrive between pulls are yielded as a list.
  FxAsync<List<T>> pullChunked() => fxAsync(fromStreamChunked(stream));

  /// Demand-gated: values that arrive while the consumer is busy are
  /// dropped.
  FxAsync<T> pullNext() => fxAsync(fromStreamNext(stream));
}
