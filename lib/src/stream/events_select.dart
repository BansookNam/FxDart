import 'dart:async';

import 'events.dart';

/// Selector-driven time, retry, and recovery operators on [FxEvents].
///
/// Duration forms of debounce / throttle / delay live on the class;
/// this extension is the trigger-driven (`xOn`) counterparts, plus
/// repeat and finalize. fxdart events layer, after Rx.
extension FxEventsSelect<T> on FxEvents<T> {
  // --- time -----------------------------------------------------------------

  /// Emits a source value when [selector] of it fires once, aborting the
  /// previous inner on every newer value.
  ///
  /// Inner's first next emits the pending value. Inner completion without
  /// a next **drops** it. A value still pending when the source closes is
  /// emitted before the close, matching [FxEvents.debounce]. fxdart events
  /// layer, after Rx's `debounce` (selector form).
  FxEvents<T> debounceOn(Stream<void> Function(T value) selector) {
    final out = StreamController<T>();
    out.onListen = () {
      StreamSubscription<void>? innerSub;
      late T pending;
      var hasPending = false;

      void listenInner(T v) {
        innerSub?.cancel();
        innerSub = null;
        pending = v;
        hasPending = true;
        final Stream<void> inner;
        try {
          inner = selector(v);
        } catch (e, st) {
          out.addError(e, st);
          return;
        }
        late final StreamSubscription<void> s;
        s = inner.listen(
          (_) {
            if (!identical(innerSub, s)) return;
            innerSub = null;
            s.cancel();
            if (hasPending) {
              hasPending = false;
              out.add(pending);
            }
          },
          onError: (Object e, StackTrace st) {
            if (!identical(innerSub, s)) return;
            innerSub = null;
            out.addError(e, st);
          },
          onDone: () {
            if (!identical(innerSub, s)) return;
            innerSub = null;
            // Completed without a next: drop the pending value.
            hasPending = false;
          },
        );
        innerSub = s;
      }

      final sub = stream.listen(
        listenInner,
        onError: out.addError,
        onDone: () {
          innerSub?.cancel();
          innerSub = null;
          if (hasPending) out.add(pending);
          out.close();
        },
      );
      out.onCancel = () {
        innerSub?.cancel();
        return sub.cancel();
      };
    };
    return FxEvents(out.stream);
  }

  /// Emits at most one event per inner window: [selector] of the value
  /// that opened the window, until that inner fires once.
  ///
  /// Mirrors [FxEvents.throttle]: [leading] (on by default) emits the
  /// first event of the window; [trailing] emits the newest seen during
  /// it when the inner fires, or when the source closes mid-window.
  FxEvents<T> throttleOn(
    Stream<void> Function(T value) selector, {
    bool leading = true,
    bool trailing = false,
  }) {
    final out = StreamController<T>();
    out.onListen = () {
      StreamSubscription<void>? innerSub;
      late T pending;
      var hasPending = false;
      var closed = false;
      var windowOpen = false;

      void endWindow() {
        if (!windowOpen) return;
        windowOpen = false;
        innerSub?.cancel();
        innerSub = null;
        if (trailing && hasPending) {
          hasPending = false;
          out.add(pending);
        }
        if (closed) out.close();
      }

      void openWindow(T v) {
        windowOpen = true;
        if (leading) {
          out.add(v);
        } else {
          pending = v;
          hasPending = trailing;
        }
        final Stream<void> inner;
        try {
          inner = selector(v);
        } catch (e, st) {
          out.addError(e, st);
          endWindow();
          return;
        }
        late final StreamSubscription<void> s;
        s = inner.listen(
          (_) {
            if (!identical(innerSub, s)) return;
            s.cancel();
            endWindow();
          },
          onError: (Object e, StackTrace st) {
            if (!identical(innerSub, s)) return;
            innerSub = null;
            windowOpen = false;
            hasPending = false;
            out.addError(e, st);
            if (closed) out.close();
          },
          onDone: () {
            if (!identical(innerSub, s)) return;
            endWindow();
          },
        );
        innerSub = s;
      }

      final sub = stream.listen(
        (v) {
          if (windowOpen) {
            pending = v;
            hasPending = trailing;
            return;
          }
          openWindow(v);
        },
        onError: out.addError,
        onDone: () {
          closed = true;
          if (!windowOpen || !(trailing && hasPending)) {
            innerSub?.cancel();
            innerSub = null;
            out.close();
          }
        },
      );
      out.onCancel = () {
        innerSub?.cancel();
        return sub.cancel();
      };
    };
    return FxEvents(out.stream);
  }

  /// Holds each value until [selector] of it fires once; inner completion
  /// without a next **drops** that value.
  ///
  /// Inners run independently, so values may reorder if their inners fire
  /// out of order — matching Rx's `delayWhen`. The close waits for
  /// outstanding inners. Errors are forwarded immediately; only data is
  /// held.
  FxEvents<T> delayOn(Stream<void> Function(T value) selector) {
    final out = StreamController<T>();
    out.onListen = () {
      final inners = <StreamSubscription<void>>[];
      var closed = false;
      void settle() {
        if (closed && inners.isEmpty) out.close();
      }

      final sub = stream.listen(
        (v) {
          final Stream<void> inner;
          try {
            inner = selector(v);
          } catch (e, st) {
            out.addError(e, st);
            return;
          }
          var got = false;
          late final StreamSubscription<void> s;
          s = inner.listen(
            (_) {
              if (got) return;
              got = true;
              inners.remove(s);
              s.cancel();
              out.add(v);
              settle();
            },
            onError: (Object e, StackTrace st) {
              inners.remove(s);
              out.addError(e, st);
              settle();
            },
            onDone: () {
              inners.remove(s);
              // Completed without a next: drop this value.
              settle();
            },
          );
          inners.add(s);
        },
        onError: out.addError,
        onDone: () {
          closed = true;
          settle();
        },
      );
      out.onCancel = () {
        for (final s in inners) {
          s.cancel();
        }
        inners.clear();
        return sub.cancel();
      };
    };
    return FxEvents(out.stream);
  }

  // --- retry / repeat -------------------------------------------------------

  /// On source error, does not forward it: pushes the error into [notifier]
  /// and resubscribes when the notifier emits. Notifier complete completes
  /// the result; notifier error is forwarded.
  ///
  /// [notifier] is subscribed once, with a hot-enough errors stream that
  /// it can listen immediately. Re-listens [stream] — a spent
  /// single-subscription source will error on the second listen; use a
  /// re-listenable source (`Stream.multi`, broadcast). fxdart events
  /// layer, after Rx's `retryWhen`.
  FxEvents<T> retryOn(Stream<void> Function(FxEvents<Object> errors) notifier) {
    final out = StreamController<T>();
    out.onListen = () {
      final errors = StreamController<Object>();
      StreamSubscription<T>? sourceSub;
      StreamSubscription<void>? notifierSub;

      void subscribeSource() {
        if (out.isClosed) return;
        try {
          sourceSub = stream.listen(
            (v) {
              if (!out.isClosed) out.add(v);
            },
            onError: (Object e, StackTrace _) {
              sourceSub?.cancel();
              sourceSub = null;
              if (!errors.isClosed) errors.add(e);
            },
            onDone: () {
              sourceSub = null;
              if (!out.isClosed) out.close();
            },
          );
        } catch (e, st) {
          out
            ..addError(e, st)
            ..close();
        }
      }

      final Stream<void> notifierStream;
      try {
        notifierStream = notifier(FxEvents(errors.stream));
      } catch (e, st) {
        errors.close();
        out
          ..addError(e, st)
          ..close();
        return;
      }
      // Output done waits for onCancel. Never await errors.close() — a
      // controller with no listener never completes that future.
      out.onCancel = () =>
          Future.wait([
            if (sourceSub != null) sourceSub!.cancel(),
            if (notifierSub != null) notifierSub.cancel(),
          ]).whenComplete(() {
            if (!errors.isClosed) errors.close();
          });
      notifierSub = notifierStream.listen(
        (_) {
          if (sourceSub == null && !out.isClosed) subscribeSource();
        },
        onError: (Object e, StackTrace st) {
          if (!out.isClosed) {
            out
              ..addError(e, st)
              ..close();
          }
        },
        onDone: () {
          if (!out.isClosed) out.close();
        },
      );
      subscribeSource();
    };
    return FxEvents(out.stream);
  }

  /// Resubscribes [stream] on error — up to [count] retries, or forever
  /// when [count] is null. [delay] if set is consulted before each retry
  /// with the 1-based attempt number.
  ///
  /// Re-listens [stream]. A spent single-subscription source will error
  /// on the second listen; use [FxEvents.retry] with a factory for
  /// one-shot controllers, and this form for re-listenable sources
  /// (broadcast, `Stream.multi`).
  FxEvents<T> retryOnError({
    int? count,
    Duration Function(int attempt)? delay,
  }) {
    final out = StreamController<T>();
    out.onListen = () {
      var retries = 0;
      StreamSubscription<T>? sub;
      Timer? timer;

      void attempt() {
        if (out.isClosed) return;
        try {
          sub = stream.listen(
            out.add,
            onError: (Object e, StackTrace st) {
              sub?.cancel();
              sub = null;
              if (count != null && retries >= count) {
                out
                  ..addError(e, st)
                  ..close();
                return;
              }
              retries++;
              if (delay == null) {
                attempt();
                return;
              }
              final Duration wait;
              try {
                wait = delay(retries);
              } catch (e2, st2) {
                out
                  ..addError(e2, st2)
                  ..close();
                return;
              }
              timer = Timer(wait, attempt);
            },
            onDone: out.close,
          );
        } catch (e, st) {
          out
            ..addError(e, st)
            ..close();
        }
      }

      attempt();
      out.onCancel = () {
        timer?.cancel();
        return sub?.cancel();
      };
    };
    return FxEvents(out.stream);
  }

  /// Resubscribes [stream] on **completion** (not error) — [count]
  /// repeats, or forever when [count] is null. [delay] if set waits that
  /// long between runs, receiving the 1-based repeat count. Errors
  /// forward and stop.
  ///
  /// Re-listens [stream]; same single-subscription caveat as
  /// [retryOnError].
  FxEvents<T> repeat({int? count, Duration Function(int repeatCount)? delay}) {
    final out = StreamController<T>();
    out.onListen = () {
      var repeats = 0;
      StreamSubscription<T>? sub;
      Timer? timer;

      void attempt() {
        if (out.isClosed) return;
        try {
          sub = stream.listen(
            out.add,
            onError: (Object e, StackTrace st) {
              sub?.cancel();
              sub = null;
              out
                ..addError(e, st)
                ..close();
            },
            onDone: () {
              sub = null;
              if (count != null && repeats >= count) {
                out.close();
                return;
              }
              repeats++;
              if (delay == null) {
                attempt();
                return;
              }
              final Duration wait;
              try {
                wait = delay(repeats);
              } catch (e, st) {
                out
                  ..addError(e, st)
                  ..close();
                return;
              }
              timer = Timer(wait, attempt);
            },
          );
        } catch (e, st) {
          out
            ..addError(e, st)
            ..close();
        }
      }

      attempt();
      out.onCancel = () {
        timer?.cancel();
        return sub?.cancel();
      };
    };
    return FxEvents(out.stream);
  }

  /// On source complete, notifies [notifier] and resubscribes when it
  /// emits. Notifier complete completes the result; notifier error is
  /// forwarded. Source errors forward and stop.
  ///
  /// [notifier] is subscribed once. Re-listens [stream]; same
  /// single-subscription caveat as [retryOnError]. fxdart events layer,
  /// after Rx's `repeatWhen`.
  FxEvents<T> repeatOn(
    Stream<void> Function(FxEvents<void> completions) notifier,
  ) {
    final out = StreamController<T>();
    out.onListen = () {
      final completions = StreamController<void>();
      StreamSubscription<T>? sourceSub;
      StreamSubscription<void>? notifierSub;

      void subscribeSource() {
        if (out.isClosed) return;
        try {
          sourceSub = stream.listen(
            (v) {
              if (!out.isClosed) out.add(v);
            },
            onError: (Object e, StackTrace st) {
              sourceSub?.cancel();
              sourceSub = null;
              if (!out.isClosed) {
                out
                  ..addError(e, st)
                  ..close();
              }
            },
            onDone: () {
              sourceSub = null;
              if (!completions.isClosed) completions.add(null);
            },
          );
        } catch (e, st) {
          out
            ..addError(e, st)
            ..close();
        }
      }

      final Stream<void> notifierStream;
      try {
        notifierStream = notifier(FxEvents(completions.stream));
      } catch (e, st) {
        completions.close();
        out
          ..addError(e, st)
          ..close();
        return;
      }
      out.onCancel = () =>
          Future.wait([
            if (sourceSub != null) sourceSub!.cancel(),
            if (notifierSub != null) notifierSub.cancel(),
          ]).whenComplete(() {
            if (!completions.isClosed) completions.close();
          });
      notifierSub = notifierStream.listen(
        (_) {
          if (sourceSub == null && !out.isClosed) subscribeSource();
        },
        onError: (Object e, StackTrace st) {
          if (!out.isClosed) {
            out
              ..addError(e, st)
              ..close();
          }
        },
        onDone: () {
          if (!out.isClosed) out.close();
        },
      );
      subscribeSource();
    };
    return FxEvents(out.stream);
  }

  // --- finalize -------------------------------------------------------------

  /// Runs [callback] exactly once on done, error, or cancel — Rx
  /// `finalize`. Even if [callback] throws, the chain still tears down
  /// (the throw is forwarded when the output can still take it).
  FxEvents<T> whenComplete(void Function() callback) {
    final out = StreamController<T>();
    out.onListen = () {
      var ran = false;
      void run() {
        if (ran) return;
        ran = true;
        try {
          callback();
        } catch (e, st) {
          try {
            if (!out.isClosed) out.addError(e, st);
          } catch (_) {}
        }
      }

      final sub = stream.listen(
        out.add,
        onError: (Object e, StackTrace st) {
          run();
          out.addError(e, st);
        },
        onDone: () {
          run();
          out.close();
        },
      );
      out.onCancel = () {
        run();
        return sub.cancel();
      };
    };
    return FxEvents(out.stream);
  }
}
