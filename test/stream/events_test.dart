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

void main() {
  group('fxEvents', () {
    test('stream unwraps and toList collects', () async {
      expect(await fxEvents(Stream.fromIterable([1, 2, 3])).toList(),
          equals([1, 2, 3]));
      expect(fxEvents(Stream.fromIterable([1])).stream, isA<Stream<int>>());
    });

    group('debounce', () {
      test('emits the trailing value of each burst', () async {
        final out = await fxEvents(
                timed([(0, 'a'), (40, 'b'), (80, 'c'), (400, 'd')], 800))
            .debounce(const Duration(milliseconds: 150))
            .toList();
        expect(out, equals(['c', 'd']));
      });

      test('flushes a pending value on close', () async {
        final out = await fxEvents(timed([(0, 1)], 30))
            .debounce(const Duration(milliseconds: 200))
            .toList();
        expect(out, equals([1]));
      });

      test('forwards errors and supports cancel', () async {
        final c = StreamController<int>();
        final events = <Object>[];
        final sub = fxEvents(c.stream)
            .debounce(const Duration(milliseconds: 50))
            .listen(events.add, onError: events.add);
        c.addError(StateError('boom'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        c.add(1);
        await sub.cancel();
        await Future<void>.delayed(const Duration(milliseconds: 80));
        expect(events.single, isA<StateError>());
        await c.close();
      });
    });

    group('throttle', () {
      test('leading only (default): first event per window', () async {
        final out = await fxEvents(timed(
                [(0, 1), (40, 2), (80, 3), (400, 4), (440, 5), (800, 6)], 1100))
            .throttle(const Duration(milliseconds: 200))
            .toList();
        expect(out, equals([1, 4, 6]));
      });

      test('trailing only: newest value when each window ends', () async {
        final out = await fxEvents(timed([(0, 1), (40, 2), (400, 3)], 800))
            .throttle(const Duration(milliseconds: 200),
                leading: false, trailing: true)
            .toList();
        expect(out, equals([2, 3]));
      });

      test('leading + trailing', () async {
        final out = await fxEvents(timed([(0, 1), (40, 2), (80, 3)], 500))
            .throttle(const Duration(milliseconds: 200), trailing: true)
            .toList();
        expect(out, equals([1, 3]));
      });

      test('close mid-window still delivers the pending trailing value',
          () async {
        final out = await fxEvents(timed([(0, 1), (40, 2)], 100))
            .throttle(const Duration(milliseconds: 300), trailing: true)
            .toList();
        expect(out, equals([1, 2]));
      });

      test('close mid-window without trailing closes immediately', () async {
        final sw = Stopwatch()..start();
        final out = await fxEvents(timed([(0, 1)], 60))
            .throttle(const Duration(milliseconds: 500))
            .toList();
        expect(out, equals([1]));
        expect(sw.elapsedMilliseconds, lessThan(400));
      });
    });

    group('sampleOn', () {
      test('emits the newest unseen value per trigger', () async {
        final source =
            timed([(0, 1), (50, 2), (100, 3), (150, 4), (200, 5)], 600);
        final trigger = timed([(75, null), (125, null), (300, null), (450, null)], 620);
        final out = await fxEvents(source)
            .sampleOn(trigger)
            .toList();
        // 75ms→2, 125ms→3, 300ms→5; 450ms trigger has nothing new.
        expect(out, equals([2, 3, 5]));
      });

      test('closes with the source and forwards its errors', () async {
        final c = StreamController<int>();
        final trigger = StreamController<void>();
        final events = <Object>[];
        var done = false;
        fxEvents(c.stream).sampleOn(trigger.stream).listen(events.add,
            onError: events.add, onDone: () => done = true);
        c.addError(StateError('boom'));
        await c.close();
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(events.single, isA<StateError>());
        expect(done, isTrue);
        await trigger.close();
      });
    });

    group('combineLatest', () {
      test('emits pairs of latest values once both sides have spoken',
          () async {
        final a = timed([(0, 'a1'), (100, 'a2')], 400);
        final b = timed([(50, 'b1'), (150, 'b2')], 450);
        final out = await fxEvents(a)
            .combineLatest(b, (x, y) => '$x$y')
            .toList();
        expect(out, equals(['a1b1', 'a2b1', 'a2b2']));
      });

      test('closes only when both sides have closed', () async {
        final a = timed([(0, 1)], 50);
        final b = timed([(20, 2), (100, 3)], 200);
        final out =
            await fxEvents(a).combineLatest(b, (x, y) => x + y).toList();
        expect(out, equals([3, 4]));
      });
    });

    group('withLatestFrom', () {
      test('stamps source events with the latest of other', () async {
        final source = timed([(0, 'r1'), (100, 'r2'), (200, 'r3')], 400);
        final config = timed([(50, 'v1'), (150, 'v2')], 450);
        final out = await fxEvents(source)
            .withLatestFrom(config, (r, v) => '$r@$v')
            .toList();
        // r1 arrives before any config and is dropped.
        expect(out, equals(['r2@v1', 'r3@v2']));
      });

      test('closes with the source even while other stays open', () async {
        final other = StreamController<int>();
        other.add(7);
        final out = await fxEvents(timed([(30, 1)], 80))
            .withLatestFrom(other.stream, (a, b) => a + b)
            .toList();
        expect(out, equals([8]));
        await other.close();
      });
    });

    group('switchMap', () {
      test('a newer event cancels the previous inner stream', () async {
        final queries = timed([(0, 'q1'), (60, 'q2')], 500);
        final started = <String>[];
        final out = await fxEvents(queries).switchMap((q) {
          started.add(q);
          return timed([(150, 'result-$q')], 200);
        }).toList();
        expect(started, equals(['q1', 'q2']));
        expect(out, equals(['result-q2']));
      });

      test('closes after outer done and last inner completes', () async {
        final out = await fxEvents(timed([(0, 1)], 30))
            .switchMap((v) => timed([(60, v * 10), (90, v * 100)], 120))
            .toList();
        expect(out, equals([10, 100]));
      });

      test('a throwing mapper becomes an error event, source continues',
          () async {
        final events = <Object>[];
        final done = Completer<void>();
        fxEvents(Stream.fromIterable([1, 2, 3]))
            .switchMap<int>((v) => v == 2
                ? throw StateError('bad')
                : Stream.value(v * 10))
            .listen(events.add,
                onError: events.add, onDone: done.complete);
        await done.future;
        expect(events.whereType<StateError>().length, equals(1));
        expect(events.whereType<int>().last, equals(30));
      });
    });

    group('race', () {
      test(
          'the first stream to emit wins, is mirrored in full, and losers '
          'are cancelled', () async {
        var loserEvents = 0;
        final fast = timed([(40, 'fast-1'), (90, 'fast-2')], 130);
        final slow = timed([(200, 'slow')], 240)
            .map((v) {
          loserEvents++;
          return v;
        });
        final out = await FxEvents.race([slow, fast]).toList();
        expect(out, equals(['fast-1', 'fast-2']));
        await Future<void>.delayed(const Duration(milliseconds: 250));
        expect(loserEvents, equals(0));
      });

      test('an error can win the race', () async {
        final failing = timed([(30, 'x')], 60)
            .asyncMap((_) => Future<String>.error(StateError('lost mirror')));
        final slow = timed([(200, 'slow')], 240);
        await expectLater(
            FxEvents.race([failing, slow]).toList(), throwsStateError);
      });

      test('all candidates closing empty closes the result', () async {
        expect(await FxEvents.race<int>([timed([], 30), timed([], 50)]).toList(),
            equals([]));
        expect(await FxEvents.race<int>(const []).toList(), equals([]));
      });
    });

    group('merge', () {
      test('interleaves and closes when all close', () async {
        final out = await FxEvents.merge([
          timed([(0, 'a'), (100, 'c')], 200),
          timed([(50, 'b'), (150, 'd')], 220),
        ]).toList();
        expect(out, equals(['a', 'b', 'c', 'd']));
      });

      test('empty source list closes immediately', () async {
        expect(await FxEvents.merge<int>(const []).toList(), equals([]));
      });
    });

    test('startWith, map, where, asyncMap compose', () async {
      final out = await fxEvents(Stream.fromIterable([1, 2, 3, 4]))
          .startWith(0)
          .where((v) => v.isEven)
          .map((v) => v * 10)
          .asyncMap((v) async => 'v$v')
          .toList();
      expect(out, equals(['v0', 'v20', 'v40']));
    });

    test('pull crosses into the FxAsync chain', () async {
      final out = await fxEvents(Stream.fromIterable([1, 2, 3, 4, 5]))
          .pull()
          .filter((v) => v.isOdd)
          .map((v) => v * 2)
          .toList();
      expect(out, equals([2, 6, 10]));
    });
  });

  group('LiveValue', () {
    test('seeded value is replayed to a late subscriber before updates',
        () async {
      final live = LiveValue.seeded(21.0);
      final seen = <double>[];
      live.stream.listen(seen.add);
      live.add(21.5);
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([21.0, 21.5]));
    });

    test('a subscriber arriving after updates gets the latest then the rest',
        () async {
      final live = LiveValue<int>();
      live.add(1);
      live.add(2);
      final seen = <int>[];
      live.stream.listen(seen.add);
      live.add(3);
      await live.close();
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([2, 3]));
    });

    test('value and hasValue report the current state', () {
      final live = LiveValue<int>();
      expect(live.hasValue, isFalse);
      expect(() => live.value, throwsStateError);
      live.add(7);
      expect(live.hasValue, isTrue);
      expect(live.value, equals(7));
    });

    test('add after close throws; late subscriber still gets the replay',
        () async {
      final live = LiveValue.seeded('last');
      await live.close();
      expect(live.isClosed, isTrue);
      expect(() => live.add('more'), throwsStateError);
      expect(await live.stream.toList(), equals(['last']));
    });

    test('a paused live subscriber buffers updates until resume', () async {
      final live = LiveValue.seeded(1);
      final seen = <int>[];
      final sub = live.stream.listen(seen.add);
      await Future<void>.delayed(Duration.zero);
      sub.pause();
      live.add(2);
      live.add(3);
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1]));
      sub.resume();
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1, 2, 3]));
      await sub.cancel();
      await live.close();
    });

    test('live chains into FxEvents operators', () async {
      final live = LiveValue.seeded(1);
      final firstTwo = live.live.map((v) => v * 10).stream.take(2).toList();
      live.add(2);
      live.add(3);
      expect(await firstTwo, equals([10, 20]));
      await live.close();
    });
  });
}
