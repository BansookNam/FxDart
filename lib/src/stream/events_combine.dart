import 'dart:async';

import 'events.dart';

/// One input to [combine]: a [source] plus whether it triggers an emit
/// and whether it must have spoken before any emit.
///
/// Search term: `FxEvents.combine`.
///
/// * [causesEmit] `true` (default) — an event from this source may
///   produce an output, once every [requireFirst] spec has a value.
///   All-true specs are [FxEvents.combineLatestAll].
/// * [causesEmit] `false` — this source is context only, like
///   [FxEvents.withLatestFrom]: it updates the slot but never fires
///   an emit on its own.
/// * [requireFirst] `true` (default) — no emit until this source has
///   produced at least one value.
/// * [requireFirst] `false` — the slot may be `null` until it speaks;
///   use a nullable [T].
class CombineSpec<T> {
  /// The stream whose latest value occupies this spec's slot.
  final Stream<T> source;

  /// Whether an event from [source] triggers an output (when ready).
  final bool causesEmit;

  /// Whether [source] must have produced a value before any emit.
  final bool requireFirst;

  /// Creates a spec over [source].
  const CombineSpec(
    this.source, {
    this.causesEmit = true,
    this.requireFirst = true,
  });
}

/// Latest values of every [CombineSpec], emitted as a [List].
///
/// Emits only once every spec with [CombineSpec.requireFirst] has
/// spoken, and only when a spec with [CombineSpec.causesEmit] fires.
/// Closes when every source has closed. An empty [specs] closes
/// immediately with no event.
///
/// Search term: `FxEvents.combine` — a top-level function because Dart
/// cannot add statics to [FxEvents] from this file.
FxEvents<List<T>> combine<T>(Iterable<CombineSpec<T>> specs) {
  final list = List<CombineSpec<T>>.of(specs);
  final out = StreamController<List<T>>();
  final subs = <StreamSubscription<T>>[];
  out.onListen = () {
    if (list.isEmpty) {
      out.close();
      return;
    }
    final latest = List<T?>.filled(list.length, null);
    final has = List<bool>.filled(list.length, false);
    var requiredCount = 0;
    for (final spec in list) {
      if (spec.requireFirst) requiredCount++;
    }
    var requiredSeen = 0;
    var done = 0;

    for (var i = 0; i < list.length; i++) {
      final index = i;
      final spec = list[i];
      subs.add(
        spec.source.listen(
          (v) {
            if (!has[index]) {
              has[index] = true;
              if (spec.requireFirst) requiredSeen++;
            }
            latest[index] = v;
            if (spec.causesEmit && requiredSeen == requiredCount) {
              out.add([for (final value in latest) value as T]);
            }
          },
          onError: out.addError,
          onDone: () {
            if (++done == list.length) out.close();
          },
        ),
      );
    }
    out.onCancel = () => Future.wait(subs.map((s) => s.cancel()));
  };
  return FxEvents(out.stream);
}

/// Subscribes to every source immediately and plays them in source
/// order: all of the first, then the second, and so on. Later sources
/// are buffered until their turn.
///
/// Contrast [FxEvents.concat], which waits to subscribe to the next
/// source until the current one completes. An empty [sources] closes
/// immediately. fxdart events layer, after Rx's `concatEager`.
FxEvents<T> concatEager<T>(Iterable<Stream<T>> sources) {
  final list = List<Stream<T>>.of(sources);
  final out = StreamController<T>();
  out.onListen = () {
    if (list.isEmpty) {
      out.close();
      return;
    }
    final buffers = [for (var i = 0; i < list.length; i++) <T>[]];
    final closed = List<bool>.filled(list.length, false);
    var active = 0;
    final subs = <StreamSubscription<T>>[];

    void drain() {
      while (active < list.length) {
        final buf = buffers[active];
        while (buf.isNotEmpty) {
          out.add(buf.removeAt(0));
        }
        if (closed[active]) {
          active++;
          continue;
        }
        return;
      }
      out.close();
    }

    for (var i = 0; i < list.length; i++) {
      final index = i;
      subs.add(
        list[i].listen(
          (v) {
            if (index == active) {
              out.add(v);
            } else {
              buffers[index].add(v);
            }
          },
          onError: out.addError,
          onDone: () {
            closed[index] = true;
            if (index == active) drain();
          },
        ),
      );
    }
    out.onCancel = () => Future.wait(subs.map((s) => s.cancel()));
  };
  return FxEvents(out.stream);
}

/// Higher-order flattening over a stream of streams: switch, merge,
/// concat, exhaust, and zip-after-outer-complete.
extension FxEventsSwitchLatest<T> on FxEvents<Stream<T>> {
  /// Mirrors only the newest inner stream: a fresh one cancels the
  /// previous mid-flight. Identity [FxEvents.switchMap].
  ///
  /// An [FxEvents] of [FxEvents] flattens as
  /// `.map((e) => e.stream).switchLatest()`.
  FxEvents<T> switchLatest() => switchMap((s) => s);

  /// Mirrors every inner stream at once, interleaved in arrival order.
  ///
  /// [concurrent] caps how many run together; later inners wait their
  /// turn. Identity [FxEvents.mergeMap]. Throws [ArgumentError] when
  /// [concurrent] is below 1.
  FxEvents<T> flattenMerge({int? concurrent}) =>
      mergeMap((s) => s, concurrent: concurrent);

  /// Plays each inner stream to completion before the next begins.
  /// Identity [FxEvents.concatMap].
  FxEvents<T> flattenConcat() => concatMap((s) => s);

  /// Ignores inner streams that arrive while one is still running.
  /// Identity [FxEvents.exhaustMap].
  FxEvents<T> exhaustLatest() => exhaustMap((s) => s);

  /// Collects every inner stream until this (the outer) completes, then
  /// zips them by index. Faster inners are buffered until the slowest
  /// catches up; the result closes with the shortest.
  ///
  /// Omitting [project] emits each aligned tuple as `List<T>` — write
  /// `zipAll<List<int>>()`. An empty outer closes with no event. Inner
  /// streams are not subscribed until the outer completes.
  FxEvents<R> zipAll<R>([R Function(List<T> values)? project]) {
    final mapValues = project ?? ((List<T> values) => values as R);
    final out = StreamController<R>();
    out.onListen = () {
      final inners = <Stream<T>>[];
      StreamSubscription<R>? zipSub;
      late final StreamSubscription<Stream<T>> outerSub;
      outerSub = stream.listen(
        inners.add,
        onError: out.addError,
        onDone: () {
          if (inners.isEmpty) {
            out.close();
            return;
          }
          zipSub = FxEvents.zip<T, R>(
            inners,
            mapValues,
          ).listen(out.add, onError: out.addError, onDone: out.close);
        },
      );
      out.onCancel = () => Future.wait([
        outerSub.cancel(),
        if (zipSub != null) zipSub!.cancel(),
      ]);
    };
    return FxEvents(out.stream);
  }
}

/// Source-driven combination with many others, and a share-for-selector.
extension FxEventsConnect<T> on FxEvents<T> {
  /// On every source event, emits [combine] of it and the latest value
  /// of every stream in [others] — source events before every other has
  /// spoken are dropped. Closes when the source closes; the others'
  /// closes are ignored.
  ///
  /// The N-ary form of [FxEvents.withLatestFrom]. An empty [others]
  /// stamps every source event with `[]`.
  FxEvents<R> withLatestFromAll<R>(
    Iterable<Stream<Object?>> others,
    R Function(T value, List<Object?> latest) combine,
  ) {
    final list = List<Stream<Object?>>.of(others);
    final out = StreamController<R>();
    out.onListen = () {
      final latest = List<Object?>.filled(list.length, null);
      final has = List<bool>.filled(list.length, false);
      var seen = 0;
      final otherSubs = <StreamSubscription<Object?>>[];
      for (var i = 0; i < list.length; i++) {
        final index = i;
        otherSubs.add(
          list[i].listen((v) {
            if (!has[index]) {
              has[index] = true;
              seen++;
            }
            latest[index] = v;
          }, onError: out.addError),
        );
      }
      late final StreamSubscription<T> sourceSub;
      sourceSub = stream.listen(
        (v) {
          if (seen == list.length) {
            out.add(combine(v, List<Object?>.of(latest)));
          }
        },
        onError: out.addError,
        onDone: () {
          for (final s in otherSubs) {
            s.cancel();
          }
          out.close();
        },
      );
      out.onCancel = () => Future.wait([
        sourceSub.cancel(),
        for (final s in otherSubs) s.cancel(),
      ]);
    };
    return FxEvents(out.stream);
  }

  /// Shares one run of this source with [selector] for the lifetime of
  /// the result. The source is listened to once; [selector] receives a
  /// multicast [FxEvents] of that run, so it may subscribe more than
  /// once. Cancelling the result cancels the source.
  ///
  /// fxdart events layer, after Rx's `connect`.
  FxEvents<R> connect<R>(FxEvents<R> Function(FxEvents<T> shared) selector) {
    final out = StreamController<R>();
    out.onListen = () {
      final shared = StreamController<T>.broadcast();
      StreamSubscription<T>? sourceSub;
      var resultDone = false;

      final FxEvents<R> result;
      try {
        result = selector(FxEvents(shared.stream));
      } catch (e, st) {
        shared.close();
        out
          ..addError(e, st)
          ..close();
        return;
      }

      late final StreamSubscription<R> resultSub;
      resultSub = result.stream.listen(
        out.add,
        onError: out.addError,
        onDone: () {
          resultDone = true;
          sourceSub?.cancel();
          if (!shared.isClosed) shared.close();
          out.close();
        },
      );

      if (resultDone) return;

      sourceSub = stream.listen(
        shared.add,
        onError: shared.addError,
        onDone: shared.close,
      );
      out.onCancel = () => Future.wait([
        resultSub.cancel(),
        sourceSub!.cancel(),
        shared.close(),
      ]);
    };
    return FxEvents(out.stream);
  }
}
