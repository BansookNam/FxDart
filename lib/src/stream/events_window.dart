import 'dart:async';

import 'events.dart';

/// A live group emitted by [FxEventsWindow.groupsBy]: the [key] that opened
/// it, and the inner [events] that follow for that key.
class GroupedEvents<K, T> {
  /// The key [FxEventsWindow.groupsBy] selected for this group.
  final K key;

  /// Values that share [key], as a chainable inner stream.
  final FxEvents<T> events;

  /// Creates a group with [key] and live [events].
  const GroupedEvents(this.key, this.events);
}

/// Window, toggle and live-group operators on [FxEvents].
///
/// `window*` emits nested [FxEvents] so a subscriber can see values before
/// the window closes. `chunkToggle` is the list-family counterpart of
/// [windowToggle]. Outer cancellation completes live inners rather than
/// erroring them.
extension FxEventsWindow<T> on FxEvents<T> {
  /// Emits a live inner of events, rotating at each [boundaries] value.
  ///
  /// A window opens immediately on listen. Each boundary value completes the
  /// current inner and opens the next. Boundary completion is ignored — the
  /// current window stays open until the source completes. fxdart events
  /// layer, after Rx's `window`.
  FxEvents<FxEvents<T>> windowOn(Stream<void> boundaries) {
    final session = _Session<T>();
    session.outer.onListen = () {
      _Inner<T>? current;

      void rotate() {
        if (!session.active) return;
        final prev = current;
        current = null;
        if (prev != null) session.closeWindow(prev);
        current = session.open();
      }

      current = session.open();
      session.sourceSub = stream.listen(
        (v) => current?.add(v),
        onError: session.fail,
        onDone: session.succeed,
      );
      if (session.active) {
        session.aux.add(
          boundaries.listen((_) => rotate(), onError: session.fail),
        );
      }
      session.outer.onCancel = session.cancel;
    };
    return FxEvents(session.outer.stream);
  }

  /// Emits live inners of [size] events. [startEvery] defaults to [size]
  /// (tumbling); smaller than [size] overlaps, larger gaps.
  ///
  /// Throws an [ArgumentError] when [size] or [startEvery] is below 1.
  /// fxdart events layer, after Rx's `windowCount`.
  FxEvents<FxEvents<T>> windowCount(int size, {int? startEvery}) {
    if (size < 1) {
      throw ArgumentError.value(size, 'size', 'must be at least 1');
    }
    final every = startEvery ?? size;
    if (every < 1) {
      throw ArgumentError.value(every, 'startEvery', 'must be at least 1');
    }

    final session = _Session<T>();
    session.outer.onListen = () {
      var count = 0;
      session.open();
      session.sourceSub = stream.listen(
        (v) {
          for (final w in List<_Inner<T>>.of(session.live)) {
            w.add(v);
          }
          final closeCount = count - size + 1;
          if (closeCount >= 0 && closeCount % every == 0) {
            if (session.live.isNotEmpty) {
              session.closeWindow(session.live.first);
            }
          }
          count++;
          if (count % every == 0) session.open();
        },
        onError: session.fail,
        onDone: session.succeed,
      );
      session.outer.onCancel = session.cancel;
    };
    return FxEvents(session.outer.stream);
  }

  /// Emits live inners spanning [span]. [every] null is tumbling (the next
  /// window opens when the current closes); a value opens overlapping or
  /// gapped windows on that period. [maxSize] closes a window early by
  /// count.
  ///
  /// Throws an [ArgumentError] when [span] (or [every], if given) is not
  /// positive, or when [maxSize] is below 1. fxdart events layer, after
  /// Rx's `windowTime`.
  FxEvents<FxEvents<T>> windowEvery(
    Duration span, {
    Duration? every,
    int? maxSize,
  }) {
    if (span <= Duration.zero) {
      throw ArgumentError.value(span, 'span', 'must be positive');
    }
    if (every != null && every <= Duration.zero) {
      throw ArgumentError.value(every, 'every', 'must be positive');
    }
    if (maxSize != null && maxSize < 1) {
      throw ArgumentError.value(maxSize, 'maxSize', 'must be at least 1');
    }

    final session = _Session<T>();
    session.outer.onListen = () {
      void openTimed() {
        final w = session.open();
        if (w == null) return;
        w.timer = Timer(span, () {
          session.closeWindow(w);
          if (every == null) openTimed();
        });
      }

      openTimed();
      if (every != null) {
        session.timers.add(Timer.periodic(every, (_) => openTimed()));
      }
      session.sourceSub = stream.listen(
        (v) {
          for (final w in List<_Inner<T>>.of(session.live)) {
            w.add(v);
            if (maxSize != null && w.count >= maxSize) {
              session.closeWindow(w);
              if (every == null) openTimed();
            }
          }
        },
        onError: session.fail,
        onDone: session.succeed,
      );
      session.outer.onCancel = session.cancel;
    };
    return FxEvents(session.outer.stream);
  }

  /// Opens a window on each [openings] value; the first event from
  /// [closeOf] of that opening completes it. Windows overlap.
  ///
  /// Completion of an opening's closer without a value leaves that window
  /// open until the source completes. fxdart events layer, after Rx's
  /// `windowToggle`.
  FxEvents<FxEvents<T>> windowToggle<O>(
    Stream<O> openings,
    Stream<void> Function(O opening) closeOf,
  ) => _toggle<O, FxEvents<T>>(
    openings,
    closeOf,
    asWindow: true,
    emitOpen: (slot, emit) => emit(slot.inner!.events),
    emitClose: (slot, emit) => slot.inner!.complete(),
  );

  /// Consecutive windows: open one, subscribe [closeOf], and on its first
  /// event (or completion) complete the window and immediately open the
  /// next. fxdart events layer, after Rx's `windowWhen`.
  FxEvents<FxEvents<T>> windowWhen(Stream<void> Function() closeOf) {
    final session = _Session<T>();
    session.outer.onListen = () {
      var pending = false;
      var draining = false;
      StreamSubscription<void>? currentCloser;

      void stopCloser() {
        currentCloser?.cancel();
        currentCloser = null;
      }

      void requestRotate() {
        pending = true;
        if (draining) return;
        draining = true;
        try {
          while (pending && session.active) {
            pending = false;
            stopCloser();
            if (session.live.isNotEmpty) {
              session.closeWindow(session.live.last);
            }
            if (!session.active) break;
            session.open();
            final Stream<void> closer;
            try {
              closer = closeOf();
            } catch (e, st) {
              session.fail(e, st);
              break;
            }
            var signaled = false;
            void signal() {
              if (signaled || session.terminated) return;
              signaled = true;
              requestRotate();
            }

            currentCloser = closer.listen(
              (_) => signal(),
              onError: (Object e, StackTrace st) {
                stopCloser();
                session.fail(e, st);
              },
              onDone: signal,
            );
          }
        } finally {
          draining = false;
        }
      }

      requestRotate();
      if (session.active) {
        session.sourceSub = stream.listen(
          (v) {
            if (session.live.isNotEmpty) session.live.last.add(v);
          },
          onError: (Object e, StackTrace st) {
            stopCloser();
            session.fail(e, st);
          },
          onDone: () {
            stopCloser();
            session.succeed();
          },
        );
      }
      session.outer.onCancel = () {
        stopCloser();
        return session.cancel();
      };
    };
    return FxEvents(session.outer.stream);
  }

  /// Overlapping list-buffers: each [openings] value starts a buffer,
  /// closed (and emitted) on the first event from [closeOf] of that
  /// opening. Empty buffers are skipped, matching [FxEvents.chunkOn].
  ///
  /// fxdart events layer, after Rx's `bufferToggle`.
  FxEvents<List<T>> chunkToggle<O>(
    Stream<O> openings,
    Stream<void> Function(O opening) closeOf,
  ) => _toggle<O, List<T>>(
    openings,
    closeOf,
    asWindow: false,
    emitOpen: (slot, emit) {},
    emitClose: (slot, emit) {
      if (slot.buffer.isNotEmpty) emit(slot.buffer);
    },
  );

  /// Live groups: the first value of each key emits a [GroupedEvents]
  /// whose [GroupedEvents.events] then receives every later value with
  /// that key.
  ///
  /// If [lastFor] is set, the first event (or completion) of `lastFor(key)`
  /// completes that group; a later value with the same key opens a new
  /// one. fxdart events layer, after Rx's `groupBy`.
  FxEvents<GroupedEvents<K, T>> groupsBy<K>(
    K Function(T value) keyOf, {
    Stream<void> Function(K key)? lastFor,
  }) {
    final out = StreamController<GroupedEvents<K, T>>();
    out.onListen = () {
      final groups = <K, _Group<K, T>>{};
      var terminated = false;
      StreamSubscription<T>? sourceSub;

      void haltGroups({Object? error, StackTrace? stackTrace}) {
        final gs = groups.values.toList();
        groups.clear();
        for (final g in gs) {
          g.lastSub?.cancel();
          if (error != null) {
            g.inner.error(error, stackTrace ?? StackTrace.current);
          } else {
            g.inner.complete();
          }
        }
      }

      void succeed() {
        if (terminated) return;
        terminated = true;
        haltGroups();
        if (!out.isClosed) out.close();
      }

      void fail(Object error, StackTrace stackTrace) {
        if (terminated) return;
        terminated = true;
        haltGroups(error: error, stackTrace: stackTrace);
        sourceSub?.cancel();
        if (!out.isClosed) {
          out
            ..addError(error, stackTrace)
            ..close();
        }
      }

      void drop(_Group<K, T> g, {Object? error, StackTrace? stackTrace}) {
        if (groups[g.key] != g) return;
        groups.remove(g.key);
        g.lastSub?.cancel();
        g.lastSub = null;
        if (error != null) {
          g.inner.error(error, stackTrace ?? StackTrace.current);
        } else {
          g.inner.complete();
        }
      }

      void startLast(_Group<K, T> g) {
        if (lastFor == null) return;
        final Stream<void> sig;
        try {
          sig = lastFor(g.key);
        } catch (e, st) {
          fail(e, st);
          return;
        }
        var signaled = false;
        g.lastSub = sig.listen(
          (_) {
            if (signaled) return;
            signaled = true;
            drop(g);
          },
          onError: (Object e, StackTrace st) {
            if (signaled) return;
            signaled = true;
            drop(g, error: e, stackTrace: st);
          },
          onDone: () {
            if (signaled) return;
            signaled = true;
            drop(g);
          },
        );
      }

      sourceSub = stream.listen(
        (v) {
          if (terminated) return;
          final K key;
          try {
            key = keyOf(v);
          } catch (e, st) {
            fail(e, st);
            return;
          }
          var g = groups[key];
          if (g == null) {
            g = _Group<K, T>(key);
            groups[key] = g;
            out.add(GroupedEvents(key, g.inner.events));
            g.inner.add(v);
            startLast(g);
            return;
          }
          g.inner.add(v);
        },
        onError: fail,
        onDone: succeed,
      );

      out.onCancel = () {
        if (!terminated) {
          terminated = true;
          haltGroups();
          if (!out.isClosed) out.close();
        }
        return sourceSub?.cancel();
      };
    };
    return FxEvents(out.stream);
  }

  FxEvents<R> _toggle<O, R>(
    Stream<O> openings,
    Stream<void> Function(O opening) closeOf, {
    required bool asWindow,
    required void Function(_Slot<T> slot, void Function(R value) emit) emitOpen,
    required void Function(_Slot<T> slot, void Function(R value) emit)
    emitClose,
  }) {
    final out = StreamController<R>();
    out.onListen = () {
      final live = <_Slot<T>>[];
      final aux = <StreamSubscription<void>>[];
      var terminated = false;
      StreamSubscription<T>? sourceSub;

      void emit(R value) {
        if (!out.isClosed) out.add(value);
      }

      void cancelAux() {
        for (final s in aux) {
          s.cancel();
        }
        aux.clear();
      }

      List<_Slot<T>> takeLive() {
        final slots = List<_Slot<T>>.of(live);
        live.clear();
        for (final slot in slots) {
          slot.closer?.cancel();
          slot.closer = null;
        }
        return slots;
      }

      void succeed() {
        if (terminated) return;
        terminated = true;
        cancelAux();
        for (final slot in takeLive()) {
          emitClose(slot, emit);
        }
        if (!out.isClosed) out.close();
      }

      void fail(Object error, StackTrace stackTrace) {
        if (terminated) return;
        terminated = true;
        cancelAux();
        for (final slot in takeLive()) {
          slot.inner?.error(error, stackTrace);
        }
        sourceSub?.cancel();
        if (!out.isClosed) {
          out
            ..addError(error, stackTrace)
            ..close();
        }
      }

      void closeSlot(_Slot<T> slot) {
        if (!live.remove(slot)) return;
        slot.closer?.cancel();
        slot.closer = null;
        emitClose(slot, emit);
      }

      void openSlot(O opening) {
        if (terminated) return;
        final slot = _Slot<T>(asWindow: asWindow);
        live.add(slot);
        emitOpen(slot, emit);
        if (terminated || !live.contains(slot)) return;
        final Stream<void> closer;
        try {
          closer = closeOf(opening);
        } catch (e, st) {
          fail(e, st);
          return;
        }
        var signaled = false;
        final sub = closer.listen((_) {
          if (signaled) return;
          signaled = true;
          closeSlot(slot);
        }, onError: fail);
        slot.closer = sub;
      }

      aux.add(openings.listen(openSlot, onError: fail));
      sourceSub = stream.listen(
        (v) {
          for (final slot in List<_Slot<T>>.of(live)) {
            slot.receive(v);
          }
        },
        onError: fail,
        onDone: succeed,
      );

      out.onCancel = () async {
        if (!terminated) {
          terminated = true;
          cancelAux();
          for (final slot in takeLive()) {
            slot.inner?.complete();
          }
          if (!out.isClosed) out.close();
        }
        await sourceSub?.cancel();
      };
    };
    return FxEvents(out.stream);
  }
}

final class _Inner<T> {
  _Inner() : controller = StreamController<T>(sync: true);

  final StreamController<T> controller;
  var count = 0;
  Timer? timer;

  FxEvents<T> get events => FxEvents(controller.stream);

  void add(T value) {
    if (controller.isClosed) return;
    controller.add(value);
    count++;
  }

  void complete() {
    timer?.cancel();
    timer = null;
    if (!controller.isClosed) controller.close();
  }

  void error(Object error, StackTrace stackTrace) {
    timer?.cancel();
    timer = null;
    if (controller.isClosed) return;
    controller
      ..addError(error, stackTrace)
      ..close();
  }
}

final class _Session<T> {
  final outer = StreamController<FxEvents<T>>();
  final live = <_Inner<T>>[];
  final aux = <StreamSubscription<void>>[];
  final timers = <Timer>[];
  StreamSubscription<T>? sourceSub;
  var terminated = false;

  bool get active => !terminated && !outer.isClosed;

  _Inner<T>? open() {
    if (!active) return null;
    final w = _Inner<T>();
    live.add(w);
    outer.add(w.events);
    return w;
  }

  void closeWindow(_Inner<T> w) {
    live.remove(w);
    w.complete();
  }

  List<_Inner<T>> _halt() {
    terminated = true;
    for (final t in timers) {
      t.cancel();
    }
    timers.clear();
    for (final s in aux) {
      s.cancel();
    }
    final ws = List<_Inner<T>>.of(live);
    live.clear();
    return ws;
  }

  void succeed() {
    if (terminated) return;
    final ws = _halt();
    for (final w in ws) {
      w.complete();
    }
    if (!outer.isClosed) outer.close();
  }

  void fail(Object error, StackTrace stackTrace) {
    if (terminated) return;
    final ws = _halt();
    for (final w in ws) {
      w.error(error, stackTrace);
    }
    sourceSub?.cancel();
    if (!outer.isClosed) {
      outer
        ..addError(error, stackTrace)
        ..close();
    }
  }

  Future<void> cancel() async {
    if (!terminated) {
      final ws = _halt();
      for (final w in ws) {
        w.complete();
      }
      if (!outer.isClosed) outer.close();
    }
    await sourceSub?.cancel();
    for (final s in aux) {
      await s.cancel();
    }
  }
}

final class _Slot<T> {
  _Slot({required bool asWindow}) : inner = asWindow ? _Inner<T>() : null;

  final _Inner<T>? inner;
  final buffer = <T>[];
  StreamSubscription<void>? closer;

  void receive(T value) {
    if (inner != null) {
      inner!.add(value);
    } else {
      buffer.add(value);
    }
  }
}

final class _Group<K, T> {
  _Group(this.key) : inner = _Inner<T>();

  final K key;
  final _Inner<T> inner;
  StreamSubscription<void>? lastSub;
}
