import 'dart:async';
import 'dart:collection';

import 'config.dart';

/// The concurrency signal that lazy operators thread *backwards* through the
/// iterator protocol's `next(concurrent)` argument.
///
/// A [Concurrent] instance turns on concurrent evaluation for the upstream
/// chain; `null` means sequential.
///
/// Port of FxTS `Concurrent` (`Lazy/concurrent.ts`).
class Concurrent {
  /// How many upstream items to evaluate at once.
  final int length;

  /// Creates a marker requesting [length]-way concurrent evaluation.
  const Concurrent(this.length);

  /// Alias for the default constructor, mirroring FxTS's `Concurrent.of`.
  static Concurrent of(int length) => Concurrent(length);
}

/// The result of one pull from an [FxAsyncIterator] — a port of the JS
/// `IteratorResult` (`{done, value}`).
class IterResult<T> {
  /// Whether the iterator is exhausted. When true, [value] is absent.
  final bool done;
  final T? _value;

  /// A terminal result — the iterator has no more values.
  const IterResult.done() : done = true, _value = null;

  /// A result carrying the next [value].
  const IterResult.value(T value) : done = false, _value = value;

  /// The yielded value. Only valid when [done] is false.
  T get value => _value as T;

  @override
  String toString() => done ? 'IterResult.done()' : 'IterResult($_value)';
}

/// Pull-based async iterator with a concurrency back-channel.
///
/// Dart's `Stream` is push-based and cannot express FxTS's `concurrent(n)`
/// protocol, where a downstream operator asks the upstream chain to evaluate
/// `n` items at once by passing a [Concurrent] marker through `next()`.
/// This protocol is a faithful port of the JS `AsyncIterator` as FxTS uses it.
abstract interface class FxAsyncIterator<T> {
  /// Pulls the next result. Passing a [Concurrent] marker asks the upstream
  /// chain to evaluate that many items at once, in order.
  Future<IterResult<T>> next([Concurrent? concurrent]);
}

/// Pull-based async iterable — the async counterpart of [Iterable].
///
/// Obtain one from [toAsync], [fromStream], or any `*Async` operator.
/// Consume it with `toListAsync`, `eachAsync`, `reduceAsync`, the
/// [FxAsync] chain, or convert it to a [Stream] with [toStream].
abstract interface class FxAsyncIterable<T> {
  /// A fresh [FxAsyncIterator] positioned at the start of this iterable.
  FxAsyncIterator<T> get iterator;
}

/// Builds an [FxAsyncIterable] from a factory of iterators.
class DelegateAsyncIterable<T> implements FxAsyncIterable<T> {
  final FxAsyncIterator<T> Function() _make;

  /// Wraps a factory invoked once per [iterator] access.
  const DelegateAsyncIterable(this._make);

  @override
  FxAsyncIterator<T> get iterator => _make();
}

/// Builds an [FxAsyncIterator] from a `next` closure.
class DelegateAsyncIterator<T> implements FxAsyncIterator<T>, StreamPullCancel {
  final Future<IterResult<T>> Function(Concurrent? concurrent) _next;
  final Future<void> Function()? _cancel;

  /// Wraps a `next` closure as an [FxAsyncIterator].
  const DelegateAsyncIterator(this._next, {Future<void> Function()? cancel})
    : _cancel = cancel;

  @override
  Future<IterResult<T>> next([Concurrent? concurrent]) => _next(concurrent);

  @override
  Future<void> cancel() => _cancel?.call() ?? Future<void>.value();
}

/// Serializes overlapping `next()` calls, mimicking the implicit request
/// queueing of JS async generators. Wrap hand-written sequential state
/// machines with this so that a concurrent consumer cannot interleave pulls.
class SerialAsyncIterator<T> implements FxAsyncIterator<T>, StreamPullCancel {
  final Future<IterResult<T>> Function(Concurrent? concurrent) _inner;
  final Future<void> Function()? _cancel;
  // The gate of the pull currently in flight, or null when idle. Null lets
  // the common serial consumer (one pull awaited at a time) call [_inner]
  // directly — chaining off an already-completed future would cost a
  // microtask hop per element.
  Future<void>? _inFlight;

  /// Wraps [_inner], chaining each pull after the previous one settles.
  SerialAsyncIterator(this._inner, {Future<void> Function()? cancel})
    : _cancel = cancel;

  @override
  Future<IterResult<T>> next([Concurrent? concurrent]) {
    final prev = _inFlight;
    final result = prev == null
        ? _inner(concurrent)
        : prev.then((_) => _inner(concurrent));
    late final Future<void> gate;
    void clear() {
      if (identical(_inFlight, gate)) _inFlight = null;
    }

    // Registered before the caller can await [result], so the gate clears
    // ahead of the consumer's continuation and back-to-back serial pulls
    // stay on the direct path. Errors are the caller's to observe on
    // [result]; the gate only sequences.
    gate = result.then((_) => clear(), onError: (Object _) => clear());
    _inFlight = gate;
    return result;
  }

  @override
  Future<void> cancel() => _cancel?.call() ?? Future<void>.value();
}

/// An empty async iterable.
@pragma('vm:prefer-inline')
FxAsyncIterable<T> asyncEmpty<T>() => DelegateAsyncIterable(
  () => DelegateAsyncIterator((_) async => IterResult<T>.done()),
);

// --- why the operator factories are `vm:prefer-inline` --------------------
//
// Every `*Async` factory below (and every one-line chain method on `FxAsync`)
// carries `@pragma('vm:prefer-inline')`. The point is not the wrapper
// allocation — it is that AOT specializes an operator's *type checks* only
// when the type arguments are statically known at the site that allocates the
// iterator. Built through a chain of un-inlined generic factories, the type
// arguments are runtime values, and every `x is Future<B>` / `x as B` in the
// operator's hot loop becomes a real subtype test. That is cheap for ordinary
// classes and very expensive for **record** types — which fxdart hands out
// everywhere (`zip`, `attach`, `pairwise`, `zipWithIndex`, a tuple `scan`
// accumulator). Inlining the factories back into the user's statically-typed
// call site measured 2.3–2.5× on record-carrying async pipelines. The chain
// is only as good as its weakest link: one un-inlined generic hop between the
// call site and the allocation loses the specialization for the whole
// operator, which is why the pragma is applied across the surface rather than
// case by case.

// --- internal fast-pull protocol ------------------------------------------
//
// The public protocol answers every pull with a Future — that is the price
// of `concurrent(n)` and cannot change without breaking implementers. But a
// *serial* consumer that owns its iterator (every terminal in this library)
// doesn't need the Future when the element is already available. Iterators
// that can answer synchronously implement [FxFastIterator]; terminals check
// for it and loop on [FxFastIterator.nextOr], so a chain of synchronous
// stages over a synchronous source runs with no futures at all — the same
// cost structure as a push Stream's event dispatch. NOT exported: this is
// library machinery, not API.

/// Internal fast-pull extension of the iterator protocol. [nextOr] is
/// serial-only: callers must await (or otherwise settle) one pull before
/// issuing the next, and must not interleave [nextOr] with [next].
abstract interface class FxFastIterator<T> implements FxAsyncIterator<T> {
  /// Pulls the next result, answering synchronously when it can.
  FutureOr<IterResult<T>> nextOr();
}

/// Shared overlap gate for public `next()` on fast iterators: serializes
/// overlapping calls (the JS async-generator queueing [SerialAsyncIterator]
/// also provides) around a [FutureOr]-returning state machine.
mixin FxFastNextGate<T> implements FxFastIterator<T> {
  Future<void>? _fxGate;

  @override
  Future<IterResult<T>> next([Concurrent? concurrent]) {
    final prev = _fxGate;
    Future<IterResult<T>> run() {
      final FutureOr<IterResult<T>> r;
      try {
        r = nextOr();
      } catch (e, st) {
        return Future.error(e, st);
      }
      return r is Future<IterResult<T>> ? r : Future.value(r);
    }

    final result = prev == null ? run() : prev.then((_) => run());
    late final Future<void> gate;
    void clear() {
      if (identical(_fxGate, gate)) _fxGate = null;
    }

    gate = result.then((_) => clear(), onError: (Object _) => clear());
    _fxGate = gate;
    return result;
  }
}

/// Returns an [FxAsyncIterable] of the given iterable, where any [Future]
/// element is awaited.
///
/// Port of FxTS `toAsync`. The source iterator is advanced *synchronously*,
/// so `n` overlapping `next()` calls start `n` futures at once — this is
/// what makes `concurrent(n)` physically parallel at the source.
///
/// ```dart
/// await toListAsync(mapAsync((a) => a + 10, toAsync([1, 2, 3]))); // [11, 12, 13]
/// ```
@pragma('vm:prefer-inline')
FxAsyncIterable<T> toAsync<T>(Iterable<FutureOr<T>> iterable) =>
    FxIterableSourceIterable(iterable);

/// The [toAsync] iterable. A marker class, like [FxStreamSourceIterable]: a
/// terminal driving a fused chain over a plain [Iterable] can step the source
/// with `moveNext()` directly (see [fxFusedDrive]) instead of wrapping every
/// element in an [IterResult] the drive would unwrap again.
class FxIterableSourceIterable<T> implements FxAsyncIterable<T> {
  /// Wraps [source] without iterating it; each [iterator] starts a walk.
  const FxIterableSourceIterable(this.source);

  /// The underlying synchronous source.
  final Iterable<FutureOr<T>> source;

  @override
  FxAsyncIterator<T> get iterator => _ToAsyncIterator(source.iterator);
}

/// The [toAsync] iterator. Deliberately NOT gated: overlapping `next()`
/// calls each advance the sync source immediately (see [toAsync] — that is
/// what makes `concurrent(n)` physically parallel), and the synchronous
/// advance is atomic so overlap is safe.
class _ToAsyncIterator<T> implements FxFastIterator<T> {
  _ToAsyncIterator(this._it);
  final Iterator<FutureOr<T>> _it;

  @override
  FutureOr<IterResult<T>> nextOr() {
    if (!_it.moveNext()) return IterResult<T>.done();
    final current = _it.current;
    if (current is Future<T>) return current.then(IterResult<T>.value);
    return IterResult<T>.value(current);
  }

  @override
  Future<IterResult<T>> next([Concurrent? concurrent]) {
    final r = nextOr();
    return r is Future<IterResult<T>> ? r : Future.value(r);
  }
}

// --- fused sync-stage pipeline --------------------------------------------
//
// A run of map / filter / takeWhile operators is a list of per-element
// transformations. Layering them as separate iterators costs one future and
// at least one microtask per element *per layer*; fusing them applies the
// whole run inline on each pulled element. The moment a [Concurrent] marker
// arrives on a fresh iterator, fusion is abandoned for [legacy] — the exact
// operator layering fusion replaced — so the concurrency protocol behaves
// identically to the unfused chain. Internal; not exported.

/// One fused per-element stage. Stage callbacks are wrapped `(Object?)`
/// closures created once per operator call, never per element.
sealed class FxStage {
  const FxStage();
}

/// A `mapAsync` stage.
class FxMapStage extends FxStage {
  const FxMapStage(this.f);
  final FutureOr<Object?> Function(Object? value) f;
}

/// A `filterAsync` stage.
class FxFilterStage extends FxStage {
  const FxFilterStage(this.p);
  final FutureOr<bool> Function(Object? value) p;
}

/// A `takeWhileAsync` stage — a failing predicate ends the whole pipeline.
class FxTakeWhileStage extends FxStage {
  const FxTakeWhileStage(this.p);
  final FutureOr<bool> Function(Object? value) p;
}

/// A `dropWhileAsync` stage. Stateful like [FxScanStage]: the latch ("have we
/// stopped dropping yet") lives on the iterator, so at most one may be fused
/// into a run — a second one starts a new fused iterable, exactly as a second
/// `scan` does.
class FxDropWhileStage extends FxStage {
  const FxDropWhileStage(this.p);
  final FutureOr<bool> Function(Object? value) p;
}

/// A `uniqByAsync` stage — `uniqAsync` when [f] is null (the element is its
/// own key). Stateful like [FxScanStage]: the seen-set lives on the iterator,
/// so at most one may be fused into a run; a second one starts a new run.
class FxUniqByStage extends FxStage {
  const FxUniqByStage(this.f);

  /// The key function, or null when the element is its own key.
  final FutureOr<Object?> Function(Object? value)? f;
}

/// A `takeAsync` stage. Stateful: the count lives on the iterator, so at most
/// one may be fused into a run.
///
/// The run ends the moment the [count]th element passes *through* this stage,
/// not when the next pull finds the counter spent — `take` must not pull the
/// element after its last, and the fused form keeps that exact pull count. An
/// element the stage passes can still be dropped by a later stage; ending is
/// decided here either way, so the source is never over-pulled.
class FxTakeStage extends FxStage {
  const FxTakeStage(this.count);

  /// How many elements pass before the run ends. Always >= 1: `takeAsync`
  /// keeps a non-positive count off the fused path entirely.
  final int count;
}

/// A `scanAsync` stage. Unlike the others it carries state: the running
/// accumulator lives on the iterator (one scan per fused run, so one slot),
/// and [seed] is emitted through the stages *after* this one before the
/// source is pulled at all.
class FxScanStage extends FxStage {
  const FxScanStage(this.f, this.seed);
  final FutureOr<Object?> Function(Object? acc, Object? value) f;
  final FutureOr<Object?> seed;
}

/// A stage compiled into the chain the hot loop actually walks.
///
/// The stage *list* is the build-time description; this is its executable
/// form. Walking a linked chain drops the per-stage list load, its bounds
/// check, and the index arithmetic from every element, and — the reason it
/// exists — lets an asynchronous stage resume at [next] directly instead of
/// re-deriving `i + 1` and re-entering the loop by index.
///
/// Links are immutable and built once per [FxFusedAsyncIterable], so every
/// iterator over it shares one chain; a fused scan's running accumulator
/// lives on the iterator, never here.
sealed class FxLink {
  const FxLink(this.next);

  /// The next stage, or null at the end of the run.
  final FxLink? next;
}

/// Compiled [FxMapStage].
final class FxMapLink extends FxLink {
  const FxMapLink(this.f, super.next);
  final FutureOr<Object?> Function(Object? value) f;
}

/// Compiled [FxFilterStage].
final class FxFilterLink extends FxLink {
  const FxFilterLink(this.p, super.next);
  final FutureOr<bool> Function(Object? value) p;
}

/// Compiled [FxTakeWhileStage].
final class FxTakeWhileLink extends FxLink {
  const FxTakeWhileLink(this.p, super.next);
  final FutureOr<bool> Function(Object? value) p;
}

/// Compiled [FxDropWhileStage].
final class FxDropWhileLink extends FxLink {
  const FxDropWhileLink(this.p, super.next);
  final FutureOr<bool> Function(Object? value) p;
}

/// Compiled [FxUniqByStage].
final class FxUniqByLink extends FxLink {
  const FxUniqByLink(this.f, super.next);
  final FutureOr<Object?> Function(Object? value)? f;
}

/// Compiled [FxTakeStage].
final class FxTakeLink extends FxLink {
  const FxTakeLink(this.count, super.next);
  final int count;
}

/// Compiled [FxScanStage].
final class FxScanLink extends FxLink {
  const FxScanLink(this.f, this.seed, super.next);
  final FutureOr<Object?> Function(Object? acc, Object? value) f;
  final FutureOr<Object?> seed;
}

/// A fused run of stages over one [source].
class FxFusedAsyncIterable<T> implements FxAsyncIterable<T> {
  // Everything derived from [stages] is computed on FIRST USE, not here.
  //
  // Each operator in a chain builds a *new* FxFusedAsyncIterable carrying
  // `[...stages, stage]`, so a k-operator chain allocates k of them and
  // discards the first k-1 without ever iterating them. Deriving eagerly made
  // every one of those pay four list traversals plus a link allocation per
  // stage. That is invisible when a chain is built once and drained, and
  // dominant when a chain is built *per work item* — `flaky-api-retry` builds
  // one four-operator chain per job, 100,000 times.
  FxFusedAsyncIterable(this.source, this.stages, this.legacy);

  /// The pre-stage upstream.
  final FxAsyncIterable<Object?> source;

  /// The stages, in application order.
  final List<FxStage> stages;

  /// Rebuilds the unfused operator layering (for the concurrent path).
  final FxAsyncIterable<T> Function() legacy;

  /// True when no stage can drop or end an element, so one source element
  /// always yields exactly one output. This lets the pull answer with the
  /// stage's own future instead of chaining a second one to re-check for a
  /// filtered-out element — one future and one microtask hop per element.
  late final bool oneToOne = _oneToOne(stages);

  /// Index of the run's [FxScanStage], or -1 when there is none. At most one
  /// scan fuses into a run; a second one starts a new run over this iterable.
  late final int scanIndex = _scanIndex(stages);

  /// Index of the run's [FxDropWhileStage], or -1 when there is none. At most
  /// one fuses into a run, for the reason [scanIndex] gives.
  late final int dropWhileIndex = _dropWhileIndex(stages);

  /// Index of the run's [FxUniqByStage], or -1 when there is none. At most one
  /// fuses into a run — its seen-set lives on the iterator.
  late final int uniqIndex = _stageIndex(stages, (s) => s is FxUniqByStage);

  /// Index of the run's [FxTakeStage], or -1 when there is none. At most one
  /// fuses into a run — its counter lives on the iterator.
  late final int takeIndex = _stageIndex(stages, (s) => s is FxTakeStage);

  /// [stages] compiled into the chain the per-element loops walk.
  late final FxLink? links = _compile(stages);

  /// The run's scan link, or null when the run has no scan — the entry point
  /// for emitting the seed through the stages that follow it. Resolved once
  /// per iterable, never per pull: [FxFastIterator.nextOr] consults it on
  /// every element, so walking the chain here would be a per-element cost.
  late final FxScanLink? scanLink = _findScan(links);

  static FxScanLink? _findScan(FxLink? l) {
    for (; l != null; l = l.next) {
      if (l is FxScanLink) return l;
    }
    return null;
  }

  /// Links [stages] back to front, so each link holds the one after it.
  static FxLink? _compile(List<FxStage> stages) {
    FxLink? head;
    for (var i = stages.length - 1; i >= 0; i--) {
      head = switch (stages[i]) {
        FxMapStage(:final f) => FxMapLink(f, head),
        FxFilterStage(:final p) => FxFilterLink(p, head),
        FxTakeWhileStage(:final p) => FxTakeWhileLink(p, head),
        FxScanStage(:final f, :final seed) => FxScanLink(f, seed, head),
        FxDropWhileStage(:final p) => FxDropWhileLink(p, head),
        FxUniqByStage(:final f) => FxUniqByLink(f, head),
        FxTakeStage(:final count) => FxTakeLink(count, head),
      };
    }
    return head;
  }

  static bool _oneToOne(List<FxStage> stages) {
    for (final stage in stages) {
      if (stage is! FxMapStage && stage is! FxScanStage) return false;
    }
    return true;
  }

  static int _scanIndex(List<FxStage> stages) {
    for (var i = 0; i < stages.length; i++) {
      if (stages[i] is FxScanStage) return i;
    }
    return -1;
  }

  static int _stageIndex(List<FxStage> stages, bool Function(FxStage) is_) {
    for (var i = 0; i < stages.length; i++) {
      if (is_(stages[i])) return i;
    }
    return -1;
  }

  static int _dropWhileIndex(List<FxStage> stages) {
    for (var i = 0; i < stages.length; i++) {
      if (stages[i] is FxDropWhileStage) return i;
    }
    return -1;
  }

  @override
  FxAsyncIterator<T> get iterator => _FusedIterator<T>(this);
}

class _FusedIterator<T>
    with FxFastNextGate<T>
    implements FxFastIterator<T>, StreamPullCancel {
  // The iterable's derived state is lazy (see its constructor), so resolve it
  // once here rather than paying a late-initialisation check on every element.
  // Creating an iterator is the point at which the run is definitely going to
  // be walked, so nothing is computed that would otherwise have been skipped.
  _FusedIterator(this._iterable)
    : _links = _iterable.links,
      _oneToOne = _iterable.oneToOne;
  final FxFusedAsyncIterable<T> _iterable;
  final FxLink? _links;
  final bool _oneToOne;
  FxAsyncIterator<Object?>? _source;
  FxAsyncIterator<T>? _fallback;
  bool _ended = false;

  /// The running accumulator of the run's [FxScanStage] (at most one).
  Object? _acc;
  bool _seedEmitted = false;

  /// The latch of the run's [FxDropWhileStage] (at most one). Per-iterator,
  /// like [_acc]: the links are shared by every iterator over the iterable.
  bool _dropping = true;

  /// The seen-set of the run's [FxUniqByStage] (at most one). Allocated on
  /// the first element, so a run that never reaches the stage pays nothing.
  Set<Object?>? _seen;

  /// How many elements the run's [FxTakeStage] (at most one) has passed.
  int _taken = 0;

  void _stop() {
    if (_ended) return;
    _ended = true;
    fxCancel(_source);
    fxCancel(_fallback);
  }

  @override
  Future<void> cancel() {
    _stop();
    return Future<void>.value();
  }

  @override
  Future<IterResult<T>> next([Concurrent? concurrent]) {
    if (_fallback == null &&
        concurrent is Concurrent &&
        _source == null &&
        !_seedEmitted &&
        !_ended) {
      // Nothing pulled yet and the consumer wants concurrency: hand the
      // whole iteration to the unfused layering.
      _fallback = _iterable.legacy().iterator;
    }
    final fb = _fallback;
    if (fb != null) return fb.next(concurrent);
    return super.next(concurrent);
  }

  @override
  FutureOr<IterResult<T>> nextOr() {
    final fb = _fallback;
    if (fb != null) return fb.next();
    if (_ended) return IterResult<T>.done();
    _source ??= _iterable.source.iterator;
    final scan = _iterable.scanLink;
    if (scan != null && !_seedEmitted) {
      _seedEmitted = true;
      return _emitSeed(scan);
    }
    return _pull();
  }

  /// A fused [FxScanStage] emits its seed before the source is pulled — as
  /// the standalone `scanAsync` iterator does — carried through the stages
  /// that follow the scan.
  FutureOr<IterResult<T>> _emitSeed(FxScanLink scan) {
    final seed = scan.seed;
    if (seed is Future) {
      return seed.then((s) {
        _acc = s;
        return _fromSeed(s, scan.next);
      });
    }
    _acc = seed;
    return _fromSeed(seed, scan.next);
  }

  FutureOr<IterResult<T>> _fromSeed(Object? seed, FxLink? from) {
    final out = _applyFrom(seed, from);
    if (out is Future<IterResult<T>?>) {
      return out.then((o) => o ?? _pull());
    }
    return out ?? _pull();
  }

  FutureOr<IterResult<T>> _pull() {
    final src = _source!;
    if (_oneToOne) {
      if (_ended) return IterResult<T>.done();
      final FutureOr<IterResult<Object?>> r = src is FxFastIterator<Object?>
          ? src.nextOr()
          : src.next();
      if (r is Future<IterResult<Object?>>) {
        return r.then((rr) {
          if (rr.done) {
            _stop();
            return IterResult<T>.done();
          }
          return _mapFrom(rr.value, _links);
        });
      }
      if (r.done) {
        _stop();
        return IterResult<T>.done();
      }
      return _mapFrom(r.value, _links);
    }
    while (true) {
      if (_ended) return IterResult<T>.done();
      final FutureOr<IterResult<Object?>> r = src is FxFastIterator<Object?>
          ? src.nextOr()
          : src.next();
      if (r is Future<IterResult<Object?>>) {
        return r.then((rr) {
          final out = _apply(rr);
          if (out is Future<IterResult<T>?>) {
            return out.then((o) => o ?? _pull());
          }
          return out ?? _pull();
        });
      }
      final out = _apply(r);
      if (out is Future<IterResult<T>?>) {
        return out.then((o) => o ?? _pull());
      }
      if (out != null) return out;
      // Filtered out: pull the next source element.
    }
  }

  /// The [FxFusedAsyncIterable.oneToOne] counterpart of [_applyFrom]: no
  /// stage can drop an element, so the result is never "filtered out" and the
  /// return type stays non-nullable — an asynchronous stage's own future *is*
  /// the pull's answer, one hop instead of two.
  FutureOr<IterResult<T>> _mapFrom(Object? value, FxLink? from) {
    var v = value;
    var l = from;
    while (l != null) {
      final next = l.next;
      if (l is FxMapLink) {
        final w = l.f(v);
        if (w is Future) {
          return w.then<IterResult<T>>((x) => _mapFrom(x, next));
        }
        v = w;
      } else {
        final w = (l as FxScanLink).f(_acc, v);
        if (w is Future) {
          return w.then<IterResult<T>>((x) {
            _acc = x;
            return _mapFrom(x, next);
          });
        }
        _acc = w;
        v = w;
      }
      l = next;
    }
    return IterResult<T>.value(v as T);
  }

  /// Applies the stages to one source result; `null` means "filtered out".
  FutureOr<IterResult<T>?> _apply(IterResult<Object?> r) {
    if (r.done) {
      _stop();
      return IterResult<T>.done();
    }
    return _applyFrom(r.value, _links);
  }

  FutureOr<IterResult<T>?> _applyFrom(Object? value, FxLink? from) {
    var v = value;
    var l = from;
    while (l != null) {
      final next = l.next;
      if (l is FxMapLink) {
        final w = l.f(v);
        if (w is Future) {
          return w.then<IterResult<T>?>((x) => _applyFrom(x, next));
        }
        v = w;
      } else if (l is FxScanLink) {
        final w = l.f(_acc, v);
        if (w is Future) {
          return w.then<IterResult<T>?>((x) {
            _acc = x;
            return _applyFrom(x, next);
          });
        }
        _acc = w;
        v = w;
      } else if (l is FxFilterLink) {
        final k = l.p(v);
        if (k is Future<bool>) {
          final vv = v;
          return k.then<IterResult<T>?>(
            (kk) => kk ? _applyFrom(vv, next) : null,
          );
        }
        if (!k) return null;
      } else if (l is FxDropWhileLink) {
        if (_dropping) {
          final k = l.p(v);
          if (k is Future<bool>) {
            final vv = v;
            return k.then<IterResult<T>?>((kk) {
              if (kk) return null;
              _dropping = false;
              return _applyFrom(vv, next);
            });
          }
          if (k) return null;
          _dropping = false;
        }
      } else if (l is FxUniqByLink) {
        final kf = l.f;
        if (kf == null) {
          if (!(_seen ??= <Object?>{}).add(v)) return null;
        } else {
          final k = kf(v);
          if (k is Future) {
            final vv = v;
            return k.then<IterResult<T>?>(
              (kk) =>
                  (_seen ??= <Object?>{}).add(kk) ? _applyFrom(vv, next) : null,
            );
          }
          if (!(_seen ??= <Object?>{}).add(k)) return null;
        }
      } else if (l is FxTakeLink) {
        // Ends here, on the count-th element, rather than on the pull that
        // would follow it: `take` never pulls past its last element. A later
        // stage may still drop this one — `_pull`'s loop sees `_ended` and
        // answers done without pulling again.
        if (++_taken >= l.count) _stop();
      } else {
        l as FxTakeWhileLink;
        final k = l.p(v);
        if (k is Future<bool>) {
          final vv = v;
          return k.then<IterResult<T>?>((kk) {
            if (kk) return _applyFrom(vv, next);
            _stop();
            return IterResult<T>.done();
          });
        }
        if (!k) {
          _stop();
          return IterResult<T>.done();
        }
      }
      l = next;
    }
    return IterResult<T>.value(v as T);
  }
}

/// Converts a single-subscription or broadcast [Stream] into an
/// [FxAsyncIterable].
@pragma('vm:prefer-inline')
FxAsyncIterable<T> fromStream<T>(Stream<T> stream) =>
    FxStreamSourceIterable(stream);

/// The [fromStream] iterable. A marker class: terminals that consume a
/// fused chain over a raw stream source can execute it by subscription
/// (see [fxStreamDrive]) instead of pulling element by element.
class FxStreamSourceIterable<T> implements FxAsyncIterable<T> {
  /// Wraps [stream] without listening; each [iterator] listens once.
  const FxStreamSourceIterable(this.stream);

  /// The underlying push source.
  final Stream<T> stream;

  @override
  FxAsyncIterator<T> get iterator => _StreamBridgeIterator(stream);
}

/// Terminal subscription drive — the push execution model, used when an
/// all-consuming serial terminal ([toListAsync] and friends) sits on a
/// (possibly fused) chain whose source is a raw [Stream]. The stages run
/// inside `onData` in element order, asynchronous stage results pause the
/// subscription (the `asyncMap` discipline), a failing takeWhile cancels it,
/// and an error fails the terminal — all observably identical to the pull
/// path for a terminal that consumes everything. Returns null when the
/// chain isn't stream-sourced; [emit] may return a Future to pause on.
Future<void>? fxStreamDrive<T>(
  FxAsyncIterable<T> iterable,
  FutureOr<void> Function(T value) emit,
) {
  final Stream<Object?> stream;
  final FxLink? links;
  if (iterable is FxFusedAsyncIterable<T>) {
    final source = iterable.source;
    if (source is! FxStreamSourceIterable<Object?>) return null;
    // A fused scan emits its seed before the source produces anything, which
    // the subscription drive has no place for; the pull path handles it.
    if (iterable.scanIndex >= 0) return null;
    stream = source.stream;
    links = iterable.links;
  } else if (iterable is FxStreamSourceIterable<T>) {
    stream = iterable.stream;
    links = null;
  } else {
    return null;
  }

  final completer = Completer<void>();
  late final StreamSubscription<Object?> sub;
  var terminated = false;
  // Latch of the run's single FxDropWhileStage, if it has one.
  var dropping = true;
  // Seen-set and counter of the run's single FxUniqByStage / FxTakeStage.
  Set<Object?>? seen;
  var taken = 0;
  // Set when the run's take stage passes its last element; the caller ends
  // the drive once that element has finished flowing, dropped or emitted.
  var takeDone = false;

  void finish() {
    if (terminated) return;
    terminated = true;
    sub.cancel();
    completer.complete();
  }

  void fail(Object e, StackTrace st) {
    if (terminated) return;
    terminated = true;
    sub.cancel();
    completer.completeError(e, st);
  }

  // Applies stages [from] onward to [value]; returns a Future only when a
  // stage (or [emit]) answered asynchronously — the caller pauses on it.
  FutureOr<void> apply(Object? value, FxLink? from) {
    var v = value;
    var l = from;
    while (l != null) {
      final next = l.next;
      if (l is FxMapLink) {
        final w = l.f(v);
        if (w is Future) {
          return w.then((x) => apply(x, next));
        }
        v = w;
      } else if (l is FxFilterLink) {
        final k = l.p(v);
        if (k is Future<bool>) {
          final vv = v;
          return k.then((kk) {
            if (kk) return apply(vv, next);
          });
        }
        if (!k) return null;
      } else if (l is FxDropWhileLink) {
        if (dropping) {
          final k = l.p(v);
          if (k is Future<bool>) {
            final vv = v;
            return k.then((kk) {
              if (kk) return null;
              dropping = false;
              return apply(vv, next);
            });
          }
          if (k) return null;
          dropping = false;
        }
      } else if (l is FxUniqByLink) {
        final kf = l.f;
        if (kf == null) {
          if (!(seen ??= <Object?>{}).add(v)) return null;
        } else {
          final k = kf(v);
          if (k is Future) {
            final vv = v;
            return k.then((kk) {
              if ((seen ??= <Object?>{}).add(kk)) return apply(vv, next);
            });
          }
          if (!(seen ??= <Object?>{}).add(k)) return null;
        }
      } else if (l is FxTakeLink) {
        if (++taken >= l.count) takeDone = true;
      } else {
        l as FxTakeWhileLink;
        final k = l.p(v);
        if (k is Future<bool>) {
          final vv = v;
          return k.then((kk) {
            if (kk) return apply(vv, next);
            finish();
          });
        }
        if (!k) {
          finish();
          return null;
        }
      }
      l = next;
    }
    return emit(v as T);
  }

  sub = stream.listen(
    (value) {
      final FutureOr<void> r;
      try {
        r = apply(value, links);
      } catch (e, st) {
        fail(e, st);
        return;
      }
      if (r is Future) {
        sub.pause();
        r.then((_) {
          // The take stage's last element has finished flowing: end here
          // rather than resuming, so no further element is ever delivered.
          if (takeDone) return finish();
          if (!terminated) sub.resume();
        }, onError: fail);
        return;
      }
      if (takeDone) finish();
    },
    onError: fail,
    onDone: () {
      if (!terminated) {
        terminated = true;
        completer.complete();
      }
    },
  );
  return completer.future;
}

/// Terminal fused drive — the push execution model applied to a *pull*-
/// sourced fused chain, the third member of the [fxStreamDrive] /
/// [fxPoolDrive] family. On the pull path each element crosses two futures:
/// the stage's own, and the one the pull answers with, which the terminal
/// then awaits — two microtask hops and an [IterResult] per element. Here the
/// stages run inside the stage future's own callback and hand the value
/// straight to [emit], so an element crosses one future and allocates no
/// result wrapper.
///
/// Semantics are the pull path's, for a terminal that consumes everything
/// serially: stages apply in order, a failing filter skips to the next source
/// element, a failing takeWhile ends the drive, a fused scan emits its seed
/// first, an [emit] returning a Future holds the pipeline until it settles,
/// and any error fails the terminal. Returns null when [iterable] is not a
/// fused run. The [Concurrent] back-channel is never involved: the terminals
/// that use this pull serially and never pass a marker.
Future<void>? fxFusedDrive<T>(
  FxAsyncIterable<T> iterable,
  FutureOr<void> Function(T value) emit,
) {
  if (iterable is! FxFusedAsyncIterable<T>) return null;
  final links = iterable.links;
  final upstream = iterable.source;
  // A plain-Iterable source steps with `moveNext()`: no IterResult per
  // element, and no iterator layer to dispatch through.
  final raw = upstream is FxIterableSourceIterable<Object?>
      ? upstream.source.iterator
      : null;
  final source = raw == null ? upstream.iterator : null;
  final fast = source is FxFastIterator<Object?> ? source : null;
  final completer = Completer<void>();
  var terminated = false;
  Object? acc;
  Set<Object?>? seen;
  var taken = 0;
  // Set when the run's take stage passes its last element; the loop ends once
  // that element has finished flowing, dropped or emitted.
  var takeDone = false;
  // Latch of the run's single FxDropWhileStage, if it has one.
  var dropping = true;

  void fail(Object e, StackTrace st) {
    if (terminated) return;
    terminated = true;
    fxCancel(source);
    completer.completeError(e, st);
  }

  void finish() {
    if (terminated) return;
    terminated = true;
    fxCancel(source);
    completer.complete();
  }

  late void Function() pump;

  /// Re-enters [step] from inside an asynchronous stage's continuation, then
  /// resumes the loop if the element finished there. The try/catch is not
  /// optional: a later stage that throws *synchronously* would otherwise
  /// escape into the discarded future [Future.then] returns, leaving the
  /// terminal hung on an error nobody observes. Declared as a variable rather
  /// than a local function only because it and [step] call each other.
  late void Function(Object?, FxLink?) resume;

  /// Applies stages [from] onward to [value] and emits the survivor. Returns
  /// null when the element finished synchronously (dropped, ended, or
  /// emitted) and the caller should pull the next one; otherwise a future
  /// whose own continuation resumes the loop.
  Future<void>? step(Object? value, FxLink? from) {
    var v = value;
    var l = from;
    while (l != null) {
      final next = l.next;
      if (l is FxMapLink) {
        final w = l.f(v);
        if (w is Future) return w.then((x) => resume(x, next), onError: fail);
        v = w;
      } else if (l is FxScanLink) {
        final w = l.f(acc, v);
        if (w is Future) {
          return w.then((x) {
            acc = x;
            resume(x, next);
          }, onError: fail);
        }
        acc = w;
        v = w;
      } else if (l is FxFilterLink) {
        final k = l.p(v);
        if (k is Future<bool>) {
          final vv = v;
          return k.then((kk) {
            if (terminated) return;
            if (!kk) return pump();
            resume(vv, next);
          }, onError: fail);
        }
        if (!k) return null;
      } else if (l is FxDropWhileLink) {
        if (dropping) {
          final k = l.p(v);
          if (k is Future<bool>) {
            final vv = v;
            return k.then((kk) {
              if (terminated) return;
              if (kk) return pump();
              dropping = false;
              resume(vv, next);
            }, onError: fail);
          }
          if (k) return null;
          dropping = false;
        }
      } else if (l is FxUniqByLink) {
        final kf = l.f;
        if (kf == null) {
          if (!(seen ??= <Object?>{}).add(v)) return null;
        } else {
          final k = kf(v);
          if (k is Future) {
            final vv = v;
            return k.then((kk) {
              if (terminated) return;
              if ((seen ??= <Object?>{}).add(kk)) return resume(vv, next);
              if (takeDone) return finish();
              pump();
            }, onError: fail);
          }
          if (!(seen ??= <Object?>{}).add(k)) return null;
        }
      } else if (l is FxTakeLink) {
        // See [FxTakeStage]: the run ends on the count-th element, not on the
        // pull that would follow it.
        if (++taken >= l.count) takeDone = true;
      } else {
        l as FxTakeWhileLink;
        final k = l.p(v);
        if (k is Future<bool>) {
          final vv = v;
          return k.then((kk) {
            if (terminated) return;
            if (!kk) return finish();
            resume(vv, next);
          }, onError: fail);
        }
        if (!k) {
          finish();
          return null;
        }
      }
      l = next;
    }
    final r = emit(v as T);
    if (r is Future) {
      return r.then((_) {
        if (terminated) return;
        if (takeDone) return finish();
        pump();
      }, onError: fail);
    }
    return null;
  }

  resume = (Object? value, FxLink? from) {
    if (terminated) return;
    final Future<void>? held;
    try {
      held = step(value, from);
    } catch (e, st) {
      return fail(e, st);
    }
    if (held == null && !terminated) {
      if (takeDone) return finish();
      pump();
    }
  };

  pump = () {
    while (!terminated) {
      if (raw != null) {
        final Object? cur;
        try {
          if (!raw.moveNext()) return finish();
          cur = raw.current;
        } catch (e, st) {
          return fail(e, st);
        }
        if (cur is Future) {
          cur.then((v) => resume(v, links), onError: fail);
          return;
        }
        final Future<void>? held;
        try {
          held = step(cur, links);
        } catch (e, st) {
          return fail(e, st);
        }
        if (held != null) return;
        if (takeDone) return finish();
        continue;
      }
      final FutureOr<IterResult<Object?>> r;
      try {
        r = fast != null ? fast.nextOr() : source!.next();
      } catch (e, st) {
        return fail(e, st);
      }
      if (r is Future<IterResult<Object?>>) {
        r.then((rr) {
          if (terminated) return;
          if (rr.done) return finish();
          resume(rr.value, links);
        }, onError: fail);
        return;
      }
      if (r.done) return finish();
      final Future<void>? held;
      try {
        held = step(r.value, links);
      } catch (e, st) {
        return fail(e, st);
      }
      if (held != null) return;
      if (takeDone) return finish();
    }
  };

  final scan = iterable.scanLink;
  if (scan != null) {
    final seed = scan.seed;
    if (seed is Future) {
      seed.then((s) {
        acc = s;
        resume(s, scan.next);
      }, onError: fail);
      return completer.future;
    }
    acc = seed;
    final Future<void>? held;
    try {
      held = step(seed, scan.next);
    } catch (e, st) {
      fail(e, st);
      return completer.future;
    }
    if (held != null || terminated) return completer.future;
  }
  pump();
  return completer.future;
}

/// Direct subscription bridge behind [fromStream]. Same contract as the
/// `StreamIterator` it replaces — lazy subscribe on the first pull, paused
/// whenever no pull is waiting, an error answers the pull that met it and
/// ends the iteration — but without the `StreamIterator` + serializer +
/// async-closure stack, which cost several microtask hops per element.
class _StreamBridgeIterator<T> implements FxFastIterator<T> {
  _StreamBridgeIterator(this._stream);

  @override
  FutureOr<IterResult<T>> nextOr() {
    if (_buffered.isNotEmpty) return IterResult.value(_buffered.removeAt(0));
    if (_done) return IterResult<T>.done();
    return next();
  }

  final Stream<T> _stream;
  StreamSubscription<T>? _sub;
  final List<Completer<IterResult<T>>> _waiters = [];
  // Values that arrived with no pull waiting (a sync controller can deliver
  // between our pause taking effect) — served before touching the stream.
  final List<T> _buffered = [];
  bool _done = false;

  @override
  Future<IterResult<T>> next([Concurrent? concurrent]) {
    if (_buffered.isNotEmpty) {
      return Future.value(IterResult.value(_buffered.removeAt(0)));
    }
    if (_done) return Future.value(IterResult<T>.done());
    final completer = Completer<IterResult<T>>();
    _waiters.add(completer);
    final sub = _sub;
    if (sub == null) {
      _sub = _stream.listen(
        (value) {
          if (_waiters.isEmpty) {
            _buffered.add(value);
            if (!_sub!.isPaused) _sub!.pause();
            return;
          }
          _waiters.removeAt(0).complete(IterResult.value(value));
          if (_waiters.isEmpty && !_sub!.isPaused) _sub!.pause();
        },
        onError: (Object e, StackTrace st) {
          // Mirror StreamIterator: the pull that meets the error gets it, and
          // the iteration is over.
          _done = true;
          _sub!.cancel();
          if (_waiters.isNotEmpty) {
            _waiters.removeAt(0).completeError(e, st);
          }
          while (_waiters.isNotEmpty) {
            _waiters.removeAt(0).complete(IterResult<T>.done());
          }
        },
        onDone: () {
          _done = true;
          while (_waiters.isNotEmpty) {
            _waiters.removeAt(0).complete(IterResult<T>.done());
          }
        },
      );
    } else if (_waiters.length == 1 && sub.isPaused) {
      sub.resume();
    }
    return completer.future;
  }
}

/// Tears down resources owned by an iterator: a `fromStream*` subscription,
/// or a `parallel` isolate pool. [fromStream] itself has no cancel — it
/// pauses instead. Early-stop operators (`take`, `head`, `find`) call
/// [fxCancel] so a [ReceivePort] cannot keep the isolate alive after the
/// consumer has stopped pulling.
abstract interface class StreamPullCancel {
  /// Releases held resources. Idempotent.
  Future<void> cancel();
}

/// No-op when [it] is not a [StreamPullCancel].
void fxCancel(Object? it) {
  if (it is StreamPullCancel) {
    it.cancel();
  }
}

/// Latest-wins pull over a [Stream]. While the consumer is between pulls,
/// each arrival replaces the single unread slot; a same-turn burst therefore
/// yields only its last value. On completion the accepted latest is yielded
/// then done; on error it is yielded then the error is thrown.
@pragma('vm:prefer-inline')
FxAsyncIterable<T> fromStreamLatest<T>(Stream<T> stream) =>
    DelegateAsyncIterable(() => _StreamLatestIterator(stream));

class _StreamLatestIterator<T>
    with FxFastNextGate<T>
    implements FxFastIterator<T>, StreamPullCancel {
  _StreamLatestIterator(this._stream);

  final Stream<T> _stream;
  StreamSubscription<T>? _sub;
  Completer<IterResult<T>>? _waiter;
  T? _latest;
  var _hasLatest = false;
  var _scheduled = false;
  var _done = false;
  Object? _error;
  StackTrace? _errorStack;

  void _onData(T value) {
    _hasLatest = true;
    _latest = value;
    if (_waiter != null && !_scheduled) {
      _scheduled = true;
      scheduleMicrotask(_deliver);
    }
  }

  void _deliver() {
    _scheduled = false;
    final waiter = _waiter;
    if (waiter == null) return;
    _hasLatest = false;
    final v = _latest as T;
    _latest = null;
    _waiter = null;
    waiter.complete(IterResult.value(v));
  }

  void _onError(Object e, StackTrace st) {
    _done = true;
    // `listen` may deliver a sync error before it has returned, so [_sub]
    // is still null.
    _sub?.cancel();
    if (_scheduled) {
      _error = e;
      _errorStack = st;
      return;
    }
    final waiter = _waiter;
    if (waiter != null) {
      _waiter = null;
      waiter.completeError(e, st);
      return;
    }
    _error = e;
    _errorStack = st;
  }

  void _onDone() {
    _done = true;
    if (_scheduled) return;
    final waiter = _waiter;
    if (waiter == null) return;
    _waiter = null;
    waiter.complete(IterResult<T>.done());
  }

  @override
  FutureOr<IterResult<T>> nextOr() {
    if (_hasLatest) {
      _hasLatest = false;
      final v = _latest as T;
      _latest = null;
      return IterResult.value(v);
    }
    if (_error != null) {
      final e = _error!;
      final st = _errorStack!;
      _error = null;
      return Future<IterResult<T>>.error(e, st);
    }
    if (_done) return IterResult<T>.done();
    if (_sub == null) {
      _sub = _stream.listen(_onData, onError: _onError, onDone: _onDone);
      return nextOr();
    }
    final waiter = Completer<IterResult<T>>();
    _waiter = waiter;
    return waiter.future;
  }

  @override
  Future<void> cancel() {
    _done = true;
    _hasLatest = false;
    _latest = null;
    final waiter = _waiter;
    _waiter = null;
    waiter?.complete(IterResult<T>.done());
    final sub = _sub;
    _sub = null;
    return sub?.cancel() ?? Future<void>.value();
  }
}

/// Batched pull over a [Stream]. Values that arrive while the consumer is
/// between pulls are yielded together as a list. Empty lists are never
/// yielded. On completion a remaining non-empty buffer is flushed then done.
@pragma('vm:prefer-inline')
FxAsyncIterable<List<T>> fromStreamChunked<T>(Stream<T> stream) =>
    DelegateAsyncIterable(() => _StreamChunkedIterator(stream));

class _StreamChunkedIterator<T>
    with FxFastNextGate<List<T>>
    implements FxFastIterator<List<T>>, StreamPullCancel {
  _StreamChunkedIterator(this._stream);

  final Stream<T> _stream;
  StreamSubscription<T>? _sub;
  Completer<IterResult<List<T>>>? _waiter;
  var _buffer = <T>[];
  var _scheduled = false;
  var _done = false;
  Object? _error;
  StackTrace? _errorStack;

  void _onData(T value) {
    _buffer.add(value);
    if (_waiter != null && !_scheduled) {
      _scheduled = true;
      scheduleMicrotask(_deliver);
    }
  }

  void _deliver() {
    _scheduled = false;
    final waiter = _waiter;
    if (waiter == null) return;
    final snapshot = _buffer;
    _buffer = <T>[];
    _waiter = null;
    waiter.complete(IterResult.value(snapshot));
  }

  void _onError(Object e, StackTrace st) {
    _done = true;
    _sub?.cancel();
    if (_scheduled) {
      _error = e;
      _errorStack = st;
      return;
    }
    final waiter = _waiter;
    if (waiter != null) {
      _waiter = null;
      waiter.completeError(e, st);
      return;
    }
    _error = e;
    _errorStack = st;
  }

  void _onDone() {
    _done = true;
    if (_scheduled) return;
    final waiter = _waiter;
    if (waiter == null) return;
    _waiter = null;
    waiter.complete(IterResult<List<T>>.done());
  }

  @override
  FutureOr<IterResult<List<T>>> nextOr() {
    if (_buffer.isNotEmpty) {
      final snapshot = _buffer;
      _buffer = <T>[];
      return IterResult.value(snapshot);
    }
    if (_error != null) {
      final e = _error!;
      final st = _errorStack!;
      _error = null;
      return Future<IterResult<List<T>>>.error(e, st);
    }
    if (_done) return IterResult<List<T>>.done();
    if (_sub == null) {
      _sub = _stream.listen(_onData, onError: _onError, onDone: _onDone);
      return nextOr();
    }
    final waiter = Completer<IterResult<List<T>>>();
    _waiter = waiter;
    return waiter.future;
  }

  @override
  Future<void> cancel() {
    _done = true;
    _buffer = <T>[];
    final waiter = _waiter;
    _waiter = null;
    waiter?.complete(IterResult<List<T>>.done());
    final sub = _sub;
    _sub = null;
    return sub?.cancel() ?? Future<void>.value();
  }
}

/// Demand-gated pull over a [Stream]. Only values that arrive while a pull
/// is waiting are yielded; arrivals while the consumer is busy are dropped.
/// A synchronously completing source can finish before the first demand slot
/// is installed and yield nothing.
@pragma('vm:prefer-inline')
FxAsyncIterable<T> fromStreamNext<T>(Stream<T> stream) =>
    DelegateAsyncIterable(() => _StreamNextIterator(stream));

class _StreamNextIterator<T>
    with FxFastNextGate<T>
    implements FxFastIterator<T>, StreamPullCancel {
  _StreamNextIterator(this._stream);

  final Stream<T> _stream;
  StreamSubscription<T>? _sub;
  Completer<IterResult<T>>? _waiter;
  var _done = false;
  Object? _error;
  StackTrace? _errorStack;

  void _onData(T value) {
    final waiter = _waiter;
    if (waiter == null) return;
    _waiter = null;
    waiter.complete(IterResult.value(value));
  }

  void _onError(Object e, StackTrace st) {
    _done = true;
    _sub?.cancel();
    final waiter = _waiter;
    if (waiter != null) {
      _waiter = null;
      waiter.completeError(e, st);
      return;
    }
    _error = e;
    _errorStack = st;
  }

  void _onDone() {
    _done = true;
    final waiter = _waiter;
    if (waiter == null) return;
    _waiter = null;
    waiter.complete(IterResult<T>.done());
  }

  @override
  FutureOr<IterResult<T>> nextOr() {
    if (_error != null) {
      final e = _error!;
      final st = _errorStack!;
      _error = null;
      return Future<IterResult<T>>.error(e, st);
    }
    if (_done) return IterResult<T>.done();
    if (_sub == null) {
      _sub = _stream.listen(_onData, onError: _onError, onDone: _onDone);
      return nextOr();
    }
    final waiter = Completer<IterResult<T>>();
    _waiter = waiter;
    return waiter.future;
  }

  @override
  Future<void> cancel() {
    _done = true;
    final waiter = _waiter;
    _waiter = null;
    waiter?.complete(IterResult<T>.done());
    final sub = _sub;
    _sub = null;
    return sub?.cancel() ?? Future<void>.value();
  }
}

/// Bridges the pull-based async protocol back to a push-based [Stream].
extension FxAsyncIterableToStream<T> on FxAsyncIterable<T> {
  /// Drives this async iterable sequentially and emits its values as a
  /// [Stream]. The [Concurrent] back-channel is not used; apply
  /// `concurrentAsync` before converting if you need parallel evaluation.
  Stream<T> toStream() {
    // Hand-written controller rather than `async*`: every `yield` in an
    // async generator crosses `_AsyncStarStreamController`, which cost ~2.5
    // microtask hops per element on top of the pull itself. The controller
    // is `sync` so a settled pull hands its value straight to the listener,
    // exactly as the generator's `yield` did — and every `add` here happens
    // inside a future continuation or a controller callback, which is the
    // context a sync controller requires.
    //
    // The generator's lock-step is preserved: one element is produced per
    // element the listener takes, a paused subscription stops production,
    // and cancelling (a `break` in `await for`) stops it for good.
    late final StreamController<T> controller;
    FxAsyncIterator<T>? iterator;
    var pulling = false;
    var stopped = false;

    void close() {
      stopped = true;
      fxCancel(iterator);
      controller.close();
    }

    void failWith(Object e, StackTrace st) {
      if (stopped) return;
      stopped = true;
      fxCancel(iterator);
      controller.addError(e, st);
      controller.close();
    }

    void pump() {
      if (stopped || pulling) return;
      final it = iterator ??= this.iterator;
      while (!stopped && !controller.isPaused && controller.hasListener) {
        final FutureOr<IterResult<T>> ro;
        try {
          ro = it is FxFastIterator<T> ? it.nextOr() : it.next();
        } catch (e, st) {
          failWith(e, st);
          return;
        }
        if (ro is Future<IterResult<T>>) {
          pulling = true;
          ro.then((result) {
            pulling = false;
            if (stopped) return;
            if (result.done) return close();
            controller.add(result.value);
            pump();
          }, onError: failWith);
          return;
        }
        if (ro.done) return close();
        controller.add(ro.value);
      }
    }

    controller = StreamController<T>(
      sync: true,
      // Deferred: `listen()` has not returned yet inside onListen, so a
      // synchronous first event would reach a listener whose own
      // subscription variable is still unassigned.
      onListen: () => scheduleMicrotask(pump),
      onResume: pump,
      onCancel: () {
        stopped = true;
        fxCancel(iterator);
      },
    );
    return controller.stream;
  }
}

/// The settled outcome of a [Future] — port of JS `Promise.allSettled`
/// entries, needed so one rejected pull doesn't fail the whole batch.
sealed class Settled<T> {
  const Settled();
}

/// A [Future] that completed with a [value].
class Fulfilled<T> extends Settled<T> {
  /// The value the future completed with.
  final T value;

  /// Wraps a successful [value].
  const Fulfilled(this.value);
}

/// A [Future] that completed with an [error].
class Rejected<T> extends Settled<T> {
  /// The error the future completed with.
  final Object error;

  /// The stack trace captured when the future failed.
  final StackTrace stackTrace;

  /// Wraps a failure ([error] plus its [stackTrace]).
  const Rejected(this.error, this.stackTrace);
}

/// Balances the load of multiple asynchronous requests: pulls up to [length]
/// items from [iterable] at once, preserving order.
///
/// Port of FxTS `concurrent` (`Lazy/concurrent.ts`).
///
/// ```dart
/// await eachAsync(
///   print,
///   concurrentAsync(
///     3,
///     mapAsync((a) => delay(Duration(seconds: 1), a), toAsync([1, 2, 3, 4, 5, 6])),
///   ),
/// ); // finishes in ~2 seconds instead of ~6
/// ```
@pragma('vm:prefer-inline')
FxAsyncIterable<A> concurrentAsync<A>(int length, FxAsyncIterable<A> iterable) {
  if (length < 1) {
    throw RangeError("'length' must be positive integer");
  }
  if (length == 1) {
    // A concurrency of one is a serial pull, so none of the machinery below
    // buys anything: the ordered batch, the `prev` future chain, the
    // per-batch List.generate/List.filled and the settlement queue all exist
    // to reorder overlapping pulls, and with one in flight there is nothing
    // to reorder. Forwarding keeps the `Concurrent.of(1)` marker travelling
    // upstream, so any stage that adapts to a concurrent consumer still sees
    // the same signal it did before.
    return DelegateAsyncIterable(() {
      final iterator = iterable.iterator;
      return DelegateAsyncIterator(
        (concurrent) => iterator.next(concurrent ?? Concurrent.of(1)),
        cancel: () {
          fxCancel(iterator);
          return Future<void>.value();
        },
      );
    });
  }
  return DelegateAsyncIterable(() {
    final iterator = iterable.iterator;
    final buffer = <Settled<IterResult<A>>>[];
    var prev = Future<void>.value();
    var nextCallCount = 0;
    var resolvedItemCount = 0;
    var finished = false;
    var pending = false;
    final settlementQueue = <Completer<IterResult<A>>>[];

    void consumeBuffer() {
      while (buffer.isNotEmpty && nextCallCount > resolvedItemCount) {
        final p = buffer.removeAt(0);
        final completer = settlementQueue.removeAt(0);
        switch (p) {
          case Fulfilled(value: final value):
            resolvedItemCount++;
            completer.complete(value);
            if (value.done) {
              finished = true;
            }
          case Rejected(error: final error, stackTrace: final stackTrace):
            completer.completeError(error, stackTrace);
            finished = true;
            return;
        }
      }
    }

    late void Function() recur;

    void fillBuffer() {
      if (pending) {
        prev = prev.then((_) {
          if (!finished && nextCallCount > resolvedItemCount) {
            fillBuffer();
          }
        });
      } else {
        // One direct then per pull settling into an ordered slot — the
        // settleAll form cost two extra future wrappers per element plus
        // the Future.wait bookkeeping. The pulls are issued in one
        // List.generate first so a synchronous throw from a pull
        // propagates synchronously, exactly as it did through settleAll.
        final pulls = List.generate(
          length,
          (_) => iterator.next(Concurrent.of(length)),
          growable: false,
        );
        pending = true;
        final batch = List<Settled<IterResult<A>>?>.filled(length, null);
        var remaining = length;
        final batchDone = Completer<void>();
        void settle(int slot, Settled<IterResult<A>> outcome) {
          batch[slot] = outcome;
          if (--remaining == 0) batchDone.complete();
        }

        for (var i = 0; i < length; i++) {
          final slot = i;
          pulls[i].then(
            (v) => settle(slot, Fulfilled(v)),
            onError: (Object e, StackTrace st) =>
                settle(slot, Rejected<IterResult<A>>(e, st)),
          );
        }
        prev = prev.then((_) => batchDone.future).then((_) {
          for (final item in batch) {
            buffer.add(item!);
          }
          pending = false;
          recur();
        });
      }
    }

    recur = () {
      if (finished || nextCallCount == resolvedItemCount) {
        return;
      } else if (buffer.isNotEmpty) {
        consumeBuffer();
      } else {
        fillBuffer();
      }
    };

    return DelegateAsyncIterator(
      (_) {
        nextCallCount++;
        if (finished) {
          return Future.value(IterResult<A>.done());
        }
        final completer = Completer<IterResult<A>>();
        settlementQueue.add(completer);
        recur();
        return completer.future;
      },
      cancel: () {
        finished = true;
        fxCancel(iterator);
        return Future<void>.value();
      },
    );
  });
}

/// The FIFO behind [concurrentPoolAsync]'s two buffers. Which implementation
/// an iterator gets is decided once, when it starts, by
/// [FxConfig.optimizeMemoryForConcurrentPool].
abstract interface class _PoolFifo<E> {
  void add(E value);
  E removeFirst();
  bool get isEmpty;
  bool get isNotEmpty;
}

/// The default: O(1) at both ends, so the pipeline stays linear even when the
/// buffer runs far ahead of the consumer.
final class _QueueFifo<E> implements _PoolFifo<E> {
  final Queue<E> _queue = Queue<E>();

  @override
  void add(E value) => _queue.addLast(value);
  @override
  E removeFirst() => _queue.removeFirst();
  @override
  bool get isEmpty => _queue.isEmpty;
  @override
  bool get isNotEmpty => _queue.isNotEmpty;
}

/// The original form: a growable `List` whose `removeAt(0)` is O(length).
final class _ListFifo<E> implements _PoolFifo<E> {
  final List<E> _list = <E>[];

  @override
  void add(E value) => _list.add(value);
  @override
  E removeFirst() => _list.removeAt(0);
  @override
  bool get isEmpty => _list.isEmpty;
  @override
  bool get isNotEmpty => _list.isNotEmpty;
}

_PoolFifo<E> _poolFifo<E>() => FxDart.config.optimizeMemoryForConcurrentPool
    ? _ListFifo<E>()
    : _QueueFifo<E>();

/// Like [concurrentAsync] but yields results in **completion order** rather
/// than source order, keeping up to [length] requests in flight.
///
/// The pool refills on every completion rather than on demand, so a source
/// faster than its consumer buffers ahead without bound; the buffers are
/// therefore `Queue`s, whose dequeue stays O(1) at any length. See
/// [FxConfig.optimizeMemoryForConcurrentPool] to get the old `List`s back.
///
/// Port of FxTS `concurrentPool`.
@pragma('vm:prefer-inline')
FxAsyncIterable<A> concurrentPoolAsync<A>(
  int length,
  FxAsyncIterable<A> iterable,
) {
  if (length < 1) {
    throw RangeError("'length' must be positive integer");
  }
  return FxConcurrentPoolIterable<A>(length, iterable);
}

/// The [concurrentPoolAsync] iterable. A marker class: an all-consuming
/// serial terminal can drain the pool by push (see [fxPoolDrive]) instead of
/// answering every element through a [Completer].
class FxConcurrentPoolIterable<T> implements FxAsyncIterable<T> {
  /// Wraps [source] without pulling from it; each [iterator] starts a pool.
  const FxConcurrentPoolIterable(this.length, this.source);

  /// How many pulls stay in flight.
  final int length;

  /// The chain the pool pulls from.
  final FxAsyncIterable<T> source;

  @override
  FxAsyncIterator<T> get iterator => _poolIterator(length, source);
}

FxAsyncIterator<A> _poolIterator<A>(int length, FxAsyncIterable<A> iterable) {
  return DelegateAsyncIterable<A>(() {
    final iterator = iterable.iterator;
    var inFlight = 0;
    var sourceDone = false;
    var failed = false;
    final ready = _poolFifo<Settled<IterResult<A>>>();
    final settlementQueue = _poolFifo<Completer<IterResult<A>>>();

    bool exhausted() => sourceDone && inFlight == 0 && ready.isEmpty;

    void drain() {
      while (ready.isNotEmpty && settlementQueue.isNotEmpty) {
        final item = ready.removeFirst();
        final completer = settlementQueue.removeFirst();
        switch (item) {
          case Fulfilled(value: final value):
            completer.complete(value);
          case Rejected(error: final error, stackTrace: final stackTrace):
            completer.completeError(error, stackTrace);
        }
      }
      if (exhausted()) {
        while (settlementQueue.isNotEmpty) {
          settlementQueue.removeFirst().complete(IterResult<A>.done());
        }
      }
    }

    late void Function() fill;
    fill = () {
      // Eagerly keep the pool full (like FxTS): up to [length] fetches stay
      // in flight regardless of how many consumers are currently waiting, so
      // even a one-pull-at-a-time terminal like toList overlaps the work.
      while (!sourceDone && !failed && inFlight < length) {
        inFlight++;
        iterator
            .next(Concurrent.of(length))
            .then(
              (result) {
                inFlight--;
                if (result.done) {
                  sourceDone = true;
                } else {
                  ready.add(Fulfilled(result));
                }
                drain();
                fill();
              },
              onError: (Object e, StackTrace st) {
                inFlight--;
                failed = true;
                sourceDone = true;
                ready.add(Rejected<IterResult<A>>(e, st));
                drain();
              },
            );
      }
    };

    return DelegateAsyncIterator((_) {
      if (exhausted()) {
        return Future.value(IterResult<A>.done());
      }
      final completer = Completer<IterResult<A>>();
      settlementQueue.add(completer);
      drain();
      fill();
      return completer.future;
    });
  }).iterator;
}

/// Terminal pool drive — the push execution model applied to
/// [concurrentPoolAsync], the counterpart of [fxStreamDrive]. On the pull
/// path every element crosses from the pull's `then` callback to the
/// suspended consumer through a [Completer], which costs a microtask hop per
/// element; here [emit] runs inside that same callback, so the element never
/// crosses a future at all.
///
/// Semantics are the pull path's: [length] pulls stay in flight, values are
/// emitted in completion order, an upstream error is delivered after the
/// values that settled before it, and an [emit] that returns a Future holds
/// the following values in order until it settles (the pull path's `ready`
/// buffer, which fills the same way while a slow consumer is away). Returns
/// null when [iterable] is not a pool.
Future<void>? fxPoolDrive<T>(
  FxAsyncIterable<T> iterable,
  FutureOr<void> Function(T value) emit,
) {
  if (iterable is! FxConcurrentPoolIterable<T>) return null;
  final length = iterable.length;
  final iterator = iterable.source.iterator;
  final completer = Completer<void>();
  // Holds settled values while an asynchronous [emit] is in flight, so they
  // reach it one at a time and in completion order.
  final pending = Queue<Settled<T>>();
  var inFlight = 0;
  var sourceDone = false;
  var terminated = false;
  var emitting = false;

  void fail(Object e, StackTrace st) {
    if (terminated) return;
    terminated = true;
    completer.completeError(e, st);
  }

  void finishIfDone() {
    if (terminated || emitting || pending.isNotEmpty) return;
    if (sourceDone && inFlight == 0) {
      terminated = true;
      completer.complete();
    }
  }

  late void Function() fill;
  late void Function() flush;

  void deliver(Settled<T> item) {
    switch (item) {
      case Rejected(error: final e, stackTrace: final st):
        fail(e, st);
      case Fulfilled(value: final v):
        final FutureOr<void> r;
        try {
          r = emit(v);
        } catch (e, st) {
          fail(e, st);
          return;
        }
        if (r is Future) {
          emitting = true;
          r.then((_) {
            emitting = false;
            if (!terminated) flush();
          }, onError: fail);
        }
    }
  }

  flush = () {
    while (!terminated && !emitting && pending.isNotEmpty) {
      deliver(pending.removeFirst());
    }
    if (terminated) return;
    fill();
    finishIfDone();
  };

  void settle(Settled<T> item) {
    if (terminated) return;
    if (emitting || pending.isNotEmpty) {
      pending.add(item);
    } else {
      deliver(item);
    }
    if (terminated) return;
    fill();
    finishIfDone();
  }

  fill = () {
    // The pull path's eager refill, unchanged: keep [length] pulls in flight
    // regardless of how fast [emit] is consuming them.
    while (!terminated && !sourceDone && inFlight < length) {
      inFlight++;
      iterator
          .next(Concurrent.of(length))
          .then(
            (result) {
              inFlight--;
              if (result.done) {
                sourceDone = true;
                if (!terminated) finishIfDone();
                return;
              }
              settle(Fulfilled(result.value));
            },
            onError: (Object e, StackTrace st) {
              inFlight--;
              sourceDone = true;
              settle(Rejected<T>(e, st));
            },
          );
    }
  };

  fill();
  return completer.future;
}

/// Shared helper implementing the FxTS "sequential wrap" dispatch pattern:
/// an operator whose sequential logic is [build]; when a [Concurrent] marker
/// arrives on the first pull, the upstream is wrapped in [concurrentAsync]
/// so items are still evaluated concurrently upstream while [build] consumes
/// them one at a time.
@pragma('vm:prefer-inline')
FxAsyncIterable<B> dispatchAsync<A, B>(
  FxAsyncIterable<A> upstream,
  FxAsyncIterator<B> Function(FxAsyncIterable<A> source) build,
) {
  return DelegateAsyncIterable(() {
    FxAsyncIterator<B>? inner;
    return DelegateAsyncIterator((concurrent) {
      inner ??= build(
        concurrent is Concurrent
            ? concurrentAsync(concurrent.length, upstream)
            : upstream,
      );
      return inner!.next(concurrent);
    });
  });
}
