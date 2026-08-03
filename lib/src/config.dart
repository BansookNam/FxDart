/// Process-wide configuration switches, reached through [FxDart.config].
///
/// Every setting is read when a pipeline **starts iterating**, not when it is
/// built, so flipping one affects pipelines started afterwards and leaves any
/// already-running iteration on the behavior it began with.
class FxConfig {
  FxConfig._();

  /// Keeps `concurrentPoolAsync`'s two internal buffers — settled results
  /// waiting for a consumer, and consumer pulls waiting for a result — in
  /// plain growable `List`s — the original implementation — instead of the
  /// `Queue`s used by default.
  ///
  /// The `List` form dequeues with `removeAt(0)`, which is O(length). That is
  /// free while the buffers stay short — they do whenever the source is
  /// genuinely slower than the consumer, which is the normal shape of a
  /// concurrency pool. But `concurrentPoolAsync` refills its pool on every
  /// completion without waiting for a pull, so a source that resolves faster
  /// than the consumer drains (cached lookups, `Future.value`, futures that
  /// are already complete) lets the ready buffer run ahead to O(n) and turns
  /// the whole pipeline quadratic: with 16,000 instantly-resolving elements
  /// the `List` form took 350 ms against the `Queue` form's 15 ms.
  ///
  /// Defaults to `false` — `Queue`s, linear at every source speed. Set it to
  /// `true` only to restore the old behavior, either to reproduce a result
  /// measured against an earlier version or to trade that worst case for the
  /// `List`'s slightly tighter allocation (a `Queue` keeps a power-of-two
  /// backing store, so it can hold up to ~2× the elements' worth of slots).
  /// The difference is small: on the `completion-order-pool` benchmark the two
  /// forms measured the same peak RSS to within 0.1 MB.
  bool optimizeMemoryForConcurrentPool = false;
}

/// Namespace for fxdart's global configuration.
///
/// ```dart
/// FxDart.config.optimizeMemoryForConcurrentPool = true;
/// ```
abstract final class FxDart {
  /// The process-wide settings. See [FxConfig].
  static final FxConfig config = FxConfig._();
}
