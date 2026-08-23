import 'dart:async';

import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

/// Emits each (offsetMs, value) pair at its offset, closing at [closeMs].
Stream<T> timed<T>(List<(int, T)> events, int closeMs) {
  final c = StreamController<T>();
  for (final (ms, v) in events) {
    Timer(Duration(milliseconds: ms), () => c.add(v));
  }
  Timer(Duration(milliseconds: closeMs), c.close);
  return c.stream;
}

Stream<void> after(int ms) =>
    Stream<void>.fromFuture(Future<void>.delayed(Duration(milliseconds: ms)));

/// A re-listenable source: [onListen] runs fresh for every subscription.
Stream<T> multi<T>(void Function(MultiStreamController<T> c) onListen) =>
    Stream<T>.multi(onListen);

void main() {
  group('debounceOn', () {
    test('emits the trailing value of each burst', () async {
      final out = await fxEvents(
        timed([(0, 'a'), (40, 'b'), (80, 'c'), (400, 'd')], 800),
      ).debounceOn((_) => after(150)).toList();
      expect(out, equals(['c', 'd']));
    });

    test('flushes a pending value on close', () async {
      final out = await fxEvents(
        timed([(0, 1)], 30),
      ).debounceOn((_) => after(200)).toList();
      expect(out, equals([1]));
    });

    test('inner completion without a next drops the pending value', () async {
      final c = StreamController<int>();
      final out = fxEvents(
        c.stream,
      ).debounceOn((_) => const Stream<void>.empty()).toList();
      c.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      c.add(2);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await c.close();
      expect(await out, hasLength(0));
    });

    test('inner first next emits the pending value', () async {
      final out = await fxEvents(
        Stream.fromIterable([1, 2, 3]),
      ).debounceOn((_) => Stream<void>.value(null)).toList();
      expect(out, equals([1, 2, 3]));
    });

    test('a throwing selector becomes an error event', () async {
      final seen = <Object>[];
      final done = Completer<void>();
      fxEvents(Stream.fromIterable([1, 2]))
          .debounceOn(
            (v) => v == 1 ? throw StateError('bad') : Stream<void>.value(null),
          )
          .listen(seen.add, onError: seen.add, onDone: done.complete);
      await done.future;
      expect(seen.whereType<StateError>(), hasLength(1));
      expect(seen.whereType<int>().last, 2);
    });

    test('forwards inner errors, source errors, and supports cancel', () async {
      final c = StreamController<int>();
      final inner = StreamController<void>();
      final seen = <Object>[];
      final sub = fxEvents(
        c.stream,
      ).debounceOn((_) => inner.stream).listen(seen.add, onError: seen.add);
      c.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      inner.addError(StateError('inner'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      c.addError(StateError('source'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(seen.whereType<StateError>(), hasLength(2));
      c.add(2);
      await sub.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(seen.whereType<int>(), hasLength(0));
      await c.close();
      await inner.close();
    });

    test('empty source closes empty', () async {
      expect(
        await fxEvents(
          const Stream<int>.empty(),
        ).debounceOn((_) => after(20)).toList(),
        hasLength(0),
      );
    });

    test('cancel aborts an in-flight inner', () async {
      final c = StreamController<int>();
      final seen = <int>[];
      final sub = fxEvents(
        c.stream,
      ).debounceOn((_) => after(200)).listen(seen.add);
      c.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await sub.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(seen, hasLength(0));
      await c.close();
    });
  });

  group('throttleOn', () {
    test('leading only (default): first event per window', () async {
      final out = await fxEvents(
        timed([(0, 1), (40, 2), (80, 3), (400, 4), (440, 5), (800, 6)], 1100),
      ).throttleOn((_) => after(200)).toList();
      expect(out, equals([1, 4, 6]));
    });

    test('trailing only: newest value when each window ends', () async {
      final out = await fxEvents(
        timed([(0, 1), (40, 2), (400, 3)], 800),
      ).throttleOn((_) => after(200), leading: false, trailing: true).toList();
      expect(out, equals([2, 3]));
    });

    test('leading + trailing', () async {
      final out = await fxEvents(
        timed([(0, 1), (40, 2), (80, 3)], 500),
      ).throttleOn((_) => after(200), trailing: true).toList();
      expect(out, equals([1, 3]));
    });

    test(
      'close mid-window still delivers the pending trailing value',
      () async {
        final out = await fxEvents(
          timed([(0, 1), (40, 2)], 100),
        ).throttleOn((_) => after(300), trailing: true).toList();
        expect(out, equals([1, 2]));
      },
    );

    test('close mid-window without trailing closes immediately', () async {
      final sw = Stopwatch()..start();
      final out = await fxEvents(
        timed([(0, 1)], 60),
      ).throttleOn((_) => after(500)).toList();
      expect(out, equals([1]));
      expect(sw.elapsedMilliseconds, lessThan(400));
    });

    test('inner completion without a next ends the window', () async {
      final out = await fxEvents(
        Stream.fromIterable([1, 2, 3]),
      ).throttleOn((_) => const Stream<void>.empty(), trailing: true).toList();
      expect(out, contains(1));
    });

    test('leading false trailing false emits nothing', () async {
      final out = await fxEvents(
        timed([(0, 1), (20, 2)], 80),
      ).throttleOn((_) => after(40), leading: false).toList();
      expect(out, hasLength(0));
    });

    test('a throwing selector becomes an error and ends the window', () async {
      final seen = <Object>[];
      final done = Completer<void>();
      fxEvents(Stream.fromIterable([1, 2]))
          .throttleOn(
            (v) => v == 1 ? throw StateError('bad') : Stream<void>.value(null),
          )
          .listen(seen.add, onError: seen.add, onDone: done.complete);
      await done.future;
      expect(seen.whereType<StateError>(), hasLength(1));
      expect(seen.whereType<int>(), containsAll([1, 2]));
    });

    test('forwards inner errors, source errors, and supports cancel', () async {
      final c = StreamController<int>();
      final inner = StreamController<void>();
      final seen = <Object>[];
      final sub = fxEvents(c.stream)
          .throttleOn((_) => inner.stream, trailing: true)
          .listen(seen.add, onError: seen.add);
      c.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      c.add(2);
      inner.addError(StateError('inner'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      c.addError(StateError('source'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(seen.whereType<int>(), equals([1]));
      expect(seen.whereType<StateError>(), hasLength(2));
      c.add(3);
      await sub.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(seen.whereType<int>(), equals([1]));
      await c.close();
      await inner.close();
    });

    test('inner error while source already closed still closes', () async {
      final c = StreamController<int>();
      final inner = StreamController<void>();
      final seen = <Object>[];
      final done = Completer<void>();
      fxEvents(c.stream)
          .throttleOn((_) => inner.stream, trailing: true)
          .listen(seen.add, onError: seen.add, onDone: done.complete);
      c.add(1);
      c.add(2);
      await c.close();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      inner.addError(StateError('late'));
      await done.future;
      expect(seen.whereType<StateError>().single, isA<StateError>());
      await inner.close();
    });

    test('empty source closes empty', () async {
      expect(
        await fxEvents(
          const Stream<int>.empty(),
        ).throttleOn((_) => after(20)).toList(),
        hasLength(0),
      );
    });

    test('cancel aborts an in-flight window', () async {
      final c = StreamController<int>();
      final seen = <int>[];
      final sub = fxEvents(
        c.stream,
      ).throttleOn((_) => after(200), trailing: true).listen(seen.add);
      c.add(1);
      c.add(2);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await sub.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(seen, equals([1]));
      await c.close();
    });
  });

  group('delayOn', () {
    test('holds each value until its inner fires', () async {
      final out = await fxEvents(
        Stream.fromIterable([1, 2, 3]),
      ).delayOn((_) => after(40)).toList();
      expect(out, equals([1, 2, 3]));
    });

    test('allows reorder when inners fire out of order', () async {
      final out = await fxEvents(Stream.fromIterable([1, 2])).delayOn((v) {
        return after(v == 1 ? 80 : 20);
      }).toList();
      expect(out, equals([2, 1]));
    });

    test('inner completion without a next drops that value', () async {
      final out = await fxEvents(Stream.fromIterable([1, 2, 3])).delayOn((v) {
        return v == 2 ? const Stream<void>.empty() : Stream<void>.value(null);
      }).toList();
      expect(out, equals([1, 3]));
    });

    test('waits for outstanding inners after the source closes', () async {
      final sw = Stopwatch()..start();
      final out = await fxEvents(
        timed([(0, 1)], 20),
      ).delayOn((_) => after(80)).toList();
      expect(out, equals([1]));
      expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(70));
    });

    test(
      'a throwing selector becomes an error event, source continues',
      () async {
        final seen = <Object>[];
        final done = Completer<void>();
        fxEvents(Stream.fromIterable([1, 2]))
            .delayOn(
              (v) =>
                  v == 1 ? throw StateError('bad') : Stream<void>.value(null),
            )
            .listen(seen.add, onError: seen.add, onDone: done.complete);
        await done.future;
        expect(seen.whereType<StateError>(), hasLength(1));
        expect(seen.whereType<int>().last, 2);
      },
    );

    test('forwards inner errors, source errors, and supports cancel', () async {
      final c = StreamController<int>();
      final inner = StreamController<void>();
      final seen = <Object>[];
      final sub = fxEvents(
        c.stream,
      ).delayOn((_) => inner.stream).listen(seen.add, onError: seen.add);
      c.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      inner.addError(StateError('inner'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      c.addError(StateError('source'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(seen.whereType<StateError>(), hasLength(2));
      c.add(2);
      await sub.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(seen.whereType<int>(), hasLength(0));
      await c.close();
      await inner.close();
    });

    test('drops a value whose inner emits more than once', () async {
      // First next releases; further inner events are ignored.
      final out = await fxEvents(Stream.fromIterable([7])).delayOn((_) {
        return Stream<void>.fromIterable([null, null, null]);
      }).toList();
      expect(out, equals([7]));
    });

    test('empty source closes empty', () async {
      expect(
        await fxEvents(
          const Stream<int>.empty(),
        ).delayOn((_) => after(20)).toList(),
        hasLength(0),
      );
    });

    test('cancel aborts outstanding inners', () async {
      final c = StreamController<int>();
      final seen = <int>[];
      final sub = fxEvents(
        c.stream,
      ).delayOn((_) => after(200)).listen(seen.add);
      c.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await sub.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(seen, hasLength(0));
      await c.close();
    });
  });

  group('retryOn', () {
    test('resubscribes when the notifier emits', () async {
      var attempts = 0;
      final source = multi<int>((c) {
        attempts++;
        if (attempts < 3) {
          c.addError(StateError('attempt $attempts'));
          c.close();
        } else {
          c
            ..add(1)
            ..add(2)
            ..close();
        }
      });
      final out = await fxEvents(
        source,
      ).retryOn((errors) => errors.stream).toList();
      expect(out, equals([1, 2]));
      expect(attempts, 3);
    });

    test('notifier complete completes the result without forwarding', () async {
      var attempts = 0;
      final source = multi<int>((c) {
        attempts++;
        c.addError(StateError('x'));
        c.close();
      });
      final out = await fxEvents(source).retryOn((errors) {
        final c = StreamController<void>();
        errors.listen((_) => c.close());
        return c.stream;
      }).toList();
      expect(out, hasLength(0));
      expect(attempts, 1);
    });

    test('notifier error is forwarded', () async {
      final source = multi<int>((c) {
        c.addError(StateError('src'));
        c.close();
      });
      expect(
        fxEvents(source)
            .retryOn(
              (errors) => errors.stream.map((_) => throw ArgumentError('n')),
            )
            .toList(),
        throwsArgumentError,
      );
    });

    test('a throwing notifier becomes an error', () async {
      expect(
        fxEvents(
          Stream.fromIterable([1]),
        ).retryOn((_) => throw StateError('n')).toList(),
        throwsStateError,
      );
    });

    test(
      'notifier next while the source is still running is ignored',
      () async {
        final trigger = StreamController<void>.broadcast();
        final c = StreamController<int>();
        final seen = <int>[];
        final done = Completer<void>();
        fxEvents(c.stream)
            .retryOn((_) => trigger.stream)
            .listen(seen.add, onDone: done.complete);
        c.add(1);
        trigger.add(null);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(seen, equals([1]));
        await c.close();
        await done.future;
        await trigger.close();
      },
    );

    test(
      'notifier complete while waiting after an error closes empty-handed',
      () async {
        final trigger = StreamController<void>();
        final source = multi<int>((c) {
          c.addError(StateError('x'));
          c.close();
        });
        final seen = <Object>[];
        final done = Completer<void>();
        fxEvents(source)
            .retryOn((_) => trigger.stream)
            .listen(seen.add, onError: seen.add, onDone: done.complete);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await trigger.close();
        await done.future;
        expect(seen, hasLength(0));
      },
    );

    test('re-listen of a spent single-subscription source errors', () async {
      final c = StreamController<int>();
      final seen = <Object>[];
      final done = Completer<void>();
      fxEvents(c.stream)
          .retryOn((errors) => errors.stream)
          .listen(seen.add, onError: seen.add, onDone: done.complete);
      c.addError(StateError('first'));
      await done.future.timeout(const Duration(milliseconds: 200));
      expect(seen, isNotEmpty);
      await c.close();
    });

    test('supports cancel mid-attempt', () async {
      final c = StreamController<int>();
      final seen = <int>[];
      final sub = fxEvents(
        c.stream,
      ).retryOn((errors) => errors.stream).listen(seen.add);
      c.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await sub.cancel();
      expect(seen, equals([1]));
      await c.close();
    });

    test('an already-complete notifier completes an empty source', () async {
      expect(
        await fxEvents(
          const Stream<int>.empty(),
        ).retryOn((_) => const Stream<void>.empty()).toList(),
        hasLength(0),
      );
    });
  });

  group('retryOnError', () {
    test('resubscribes until the source succeeds', () async {
      var attempts = 0;
      final source = multi<int>((c) {
        attempts++;
        if (attempts < 3) {
          c.addError(StateError('attempt $attempts'));
          c.close();
        } else {
          c
            ..add(1)
            ..add(2)
            ..close();
        }
      });
      final out = await fxEvents(source).retryOnError().toList();
      expect(out, equals([1, 2]));
      expect(attempts, 3);
    });

    test('gives up after count retries and forwards the last error', () async {
      var attempts = 0;
      final source = multi<int>((c) {
        attempts++;
        c.addError(StateError('attempt $attempts'));
        c.close();
      });
      final seen = <Object>[];
      final done = Completer<void>();
      fxEvents(source)
          .retryOnError(count: 2)
          .listen(seen.add, onError: seen.add, onDone: done.complete);
      await done.future;
      expect(attempts, 3, reason: 'one attempt plus two retries');
      expect(seen.single, isA<StateError>());
    });

    test('count 0 forwards the first error', () async {
      var attempts = 0;
      final source = multi<int>((c) {
        attempts++;
        c.addError(StateError('x'));
        c.close();
      });
      final seen = <Object>[];
      final done = Completer<void>();
      fxEvents(source)
          .retryOnError(count: 0)
          .listen(seen.add, onError: seen.add, onDone: done.complete);
      await done.future;
      expect(attempts, 1);
      expect(seen.single, isA<StateError>());
    });

    test('delay waits the Duration of the 1-based attempt', () async {
      var attempts = 0;
      final source = multi<int>((c) {
        attempts++;
        if (attempts < 2) {
          c.addError(StateError('x'));
          c.close();
        } else {
          c
            ..add(9)
            ..close();
        }
      });
      final sw = Stopwatch()..start();
      final out = await fxEvents(
        source,
      ).retryOnError(delay: (n) => Duration(milliseconds: 40 * n)).toList();
      expect(out, equals([9]));
      expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(35));
    });

    test('a throwing delay becomes an error', () async {
      final source = multi<int>((c) {
        c.addError(StateError('x'));
        c.close();
      });
      expect(
        fxEvents(
          source,
        ).retryOnError(delay: (_) => throw ArgumentError('d')).toList(),
        throwsArgumentError,
      );
    });

    test('re-listen of a spent single-subscription source errors', () async {
      final c = StreamController<int>();
      final seen = <Object>[];
      final done = Completer<void>();
      fxEvents(c.stream)
          .retryOnError(count: 2)
          .listen(seen.add, onError: seen.add, onDone: done.complete);
      c.addError(StateError('first'));
      await done.future.timeout(const Duration(milliseconds: 200));
      expect(seen, isNotEmpty);
      await c.close();
    });

    test('supports cancel mid-attempt and cancels a pending delay', () async {
      var attempts = 0;
      final source = multi<int>((c) {
        attempts++;
        c.addError(StateError('x'));
        c.close();
      });
      final seen = <Object>[];
      final sub = fxEvents(source)
          .retryOnError(delay: (_) => const Duration(milliseconds: 300))
          .listen(seen.add, onError: seen.add);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await sub.cancel();
      final atCancel = attempts;
      await Future<void>.delayed(const Duration(milliseconds: 350));
      expect(attempts, atCancel, reason: 'pending delay was cancelled');
    });
  });

  group('repeat', () {
    test('count is the number of repeats', () async {
      var runs = 0;
      final source = multi<int>((c) {
        runs++;
        c
          ..add(runs)
          ..close();
      });
      final out = await fxEvents(source).repeat(count: 2).toList();
      expect(out, equals([1, 2, 3]));
      expect(runs, 3);
    });

    test('count 0 runs once', () async {
      var runs = 0;
      final source = multi<int>((c) {
        runs++;
        c
          ..add(1)
          ..close();
      });
      expect(await fxEvents(source).repeat(count: 0).toList(), equals([1]));
      expect(runs, 1);
    });

    test('delay waits between runs', () async {
      var runs = 0;
      final source = multi<int>((c) {
        runs++;
        c
          ..add(runs)
          ..close();
      });
      final sw = Stopwatch()..start();
      final out = await fxEvents(
        source,
      ).repeat(count: 1, delay: (n) => Duration(milliseconds: 40 * n)).toList();
      expect(out, equals([1, 2]));
      expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(35));
    });

    test('errors forward and stop', () async {
      var runs = 0;
      final source = multi<int>((c) {
        runs++;
        c.addError(StateError('x'));
        c.close();
      });
      final seen = <Object>[];
      final done = Completer<void>();
      fxEvents(source)
          .repeat(count: 5)
          .listen(seen.add, onError: seen.add, onDone: done.complete);
      await done.future;
      expect(runs, 1);
      expect(seen.single, isA<StateError>());
    });

    test('a throwing delay becomes an error', () async {
      final source = multi<int>((c) {
        c.close();
      });
      expect(
        fxEvents(
          source,
        ).repeat(count: 1, delay: (_) => throw ArgumentError('d')).toList(),
        throwsArgumentError,
      );
    });

    test('re-listen of a spent single-subscription source errors', () async {
      final c = StreamController<int>();
      final seen = <Object>[];
      final done = Completer<void>();
      fxEvents(c.stream)
          .repeat(count: 1)
          .listen(seen.add, onError: seen.add, onDone: done.complete);
      c.add(1);
      await c.close();
      await done.future.timeout(const Duration(milliseconds: 200));
      expect(seen.whereType<int>(), equals([1]));
      expect(seen.whereType<StateError>(), isNotEmpty);
    });

    test('cancel mid-run cancels the active subscription', () async {
      final c = StreamController<int>();
      final seen = <int>[];
      final sub = fxEvents(c.stream).repeat(count: 5).listen(seen.add);
      c.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await sub.cancel();
      expect(seen, equals([1]));
      expect(c.hasListener, isFalse);
      await c.close();
    });

    test('supports cancel mid-run and cancels a pending delay', () async {
      var runs = 0;
      final source = multi<int>((c) {
        runs++;
        c
          ..add(runs)
          ..close();
      });
      final seen = <int>[];
      final sub = fxEvents(source)
          .repeat(delay: (_) => const Duration(milliseconds: 300))
          .listen(seen.add);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await sub.cancel();
      final atCancel = runs;
      await Future<void>.delayed(const Duration(milliseconds: 350));
      expect(runs, atCancel);
    });
  });

  group('repeatOn', () {
    test('resubscribes when the notifier emits', () async {
      var runs = 0;
      final source = multi<int>((c) {
        runs++;
        c
          ..add(runs)
          ..close();
      });
      final trigger = StreamController<void>();
      final seen = <int>[];
      final done = Completer<void>();
      fxEvents(
        source,
      ).repeatOn((_) => trigger.stream).listen(seen.add, onDone: done.complete);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      trigger.add(null);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      trigger.add(null);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(seen, equals([1, 2, 3]));
      await trigger.close();
      await done.future;
      expect(runs, 3);
    });

    test('notifier complete completes the result', () async {
      var runs = 0;
      final source = multi<int>((c) {
        runs++;
        c
          ..add(1)
          ..close();
      });
      final trigger = StreamController<void>();
      final seen = <int>[];
      final done = Completer<void>();
      fxEvents(
        source,
      ).repeatOn((_) => trigger.stream).listen(seen.add, onDone: done.complete);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(seen, equals([1]));
      trigger.add(null);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(seen, equals([1, 1]));
      await trigger.close();
      await done.future;
      expect(runs, 2);
    });

    test('notifier error is forwarded', () async {
      final source = multi<int>((c) {
        c.close();
      });
      expect(
        fxEvents(source)
            .repeatOn(
              (completions) =>
                  completions.stream.map((_) => throw ArgumentError('n')),
            )
            .toList(),
        throwsArgumentError,
      );
    });

    test('a throwing notifier becomes an error', () async {
      expect(
        fxEvents(
          Stream.fromIterable([1]),
        ).repeatOn((_) => throw StateError('n')).toList(),
        throwsStateError,
      );
    });

    test('source errors forward and stop', () async {
      var runs = 0;
      final source = multi<int>((c) {
        runs++;
        c.addError(StateError('x'));
        c.close();
      });
      final seen = <Object>[];
      final done = Completer<void>();
      fxEvents(source)
          .repeatOn((completions) => completions.stream)
          .listen(seen.add, onError: seen.add, onDone: done.complete);
      await done.future;
      expect(runs, 1);
      expect(seen.single, isA<StateError>());
    });

    test('re-listen of a spent single-subscription source errors', () async {
      final c = StreamController<int>();
      final seen = <Object>[];
      final done = Completer<void>();
      fxEvents(c.stream)
          .repeatOn((completions) => completions.stream)
          .listen(seen.add, onError: seen.add, onDone: done.complete);
      c.add(1);
      await c.close();
      await done.future.timeout(const Duration(milliseconds: 200));
      expect(seen.whereType<int>(), equals([1]));
      expect(seen.whereType<StateError>(), isNotEmpty);
    });

    test('supports cancel', () async {
      final c = StreamController<int>();
      final seen = <int>[];
      final sub = fxEvents(
        c.stream,
      ).repeatOn((completions) => completions.stream).listen(seen.add);
      c.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await sub.cancel();
      expect(seen, equals([1]));
      await c.close();
    });

    test('an already-complete notifier completes an empty source', () async {
      expect(
        await fxEvents(
          const Stream<int>.empty(),
        ).repeatOn((_) => const Stream<void>.empty()).toList(),
        hasLength(0),
      );
    });
  });

  group('whenComplete', () {
    test('runs once on done', () async {
      var n = 0;
      final out = await fxEvents(
        Stream.fromIterable([1, 2]),
      ).whenComplete(() => n++).toList();
      expect(out, equals([1, 2]));
      expect(n, 1);
    });

    test('runs once on error, not again on done', () async {
      var n = 0;
      final c = StreamController<int>();
      final seen = <Object>[];
      final done = Completer<void>();
      fxEvents(c.stream)
          .whenComplete(() => n++)
          .listen(seen.add, onError: seen.add, onDone: done.complete);
      c
        ..add(1)
        ..addError(StateError('boom'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(n, 1);
      await c.close();
      await done.future;
      expect(n, 1);
      expect(seen.whereType<int>(), equals([1]));
      expect(seen.whereType<StateError>(), hasLength(1));
    });

    test('runs once on cancel', () async {
      var n = 0;
      final c = StreamController<int>();
      final sub = fxEvents(c.stream).whenComplete(() => n++).listen((_) {});
      await sub.cancel();
      expect(n, 1);
      await c.close();
      expect(n, 1);
    });

    test(
      'callback throw on done is forwarded and the chain still closes',
      () async {
        final seen = <Object>[];
        final done = Completer<void>();
        fxEvents(Stream.fromIterable([1]))
            .whenComplete(() => throw StateError('cb'))
            .listen(seen.add, onError: seen.add, onDone: done.complete);
        await done.future;
        expect(seen.whereType<int>(), equals([1]));
        expect(seen.whereType<StateError>(), hasLength(1));
      },
    );

    test('callback throw on error still forwards the original error', () async {
      final seen = <Object>[];
      final done = Completer<void>();
      fxEvents(Stream<int>.error(StateError('src')))
          .whenComplete(() => throw ArgumentError('cb'))
          .listen(seen.add, onError: seen.add, onDone: done.complete);
      await done.future.timeout(const Duration(milliseconds: 200));
      expect(seen.whereType<ArgumentError>(), hasLength(1));
      expect(seen.whereType<StateError>(), hasLength(1));
    });

    test('callback throw on cancel still cancels the source', () async {
      var n = 0;
      final c = StreamController<int>();
      final sub = fxEvents(c.stream)
          .whenComplete(() {
            n++;
            throw StateError('cb');
          })
          .listen((_) {});
      await sub.cancel();
      expect(n, 1);
      expect(c.hasListener, isFalse);
      await c.close();
    });

    test('empty source still runs the callback', () async {
      var n = 0;
      expect(
        await fxEvents(
          const Stream<int>.empty(),
        ).whenComplete(() => n++).toList(),
        hasLength(0),
      );
      expect(n, 1);
    });
  });
}
