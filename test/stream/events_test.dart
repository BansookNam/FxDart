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
      expect(
        await fxEvents(Stream.fromIterable([1, 2, 3])).toList(),
        equals([1, 2, 3]),
      );
      expect(fxEvents(Stream.fromIterable([1])).stream, isA<Stream<int>>());
    });

    group('debounce', () {
      test('emits the trailing value of each burst', () async {
        final out = await fxEvents(
          timed([(0, 'a'), (40, 'b'), (80, 'c'), (400, 'd')], 800),
        ).debounce(const Duration(milliseconds: 150)).toList();
        expect(out, equals(['c', 'd']));
      });

      test('flushes a pending value on close', () async {
        final out = await fxEvents(
          timed([(0, 1)], 30),
        ).debounce(const Duration(milliseconds: 200)).toList();
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
        final out = await fxEvents(
          timed([(0, 1), (40, 2), (80, 3), (400, 4), (440, 5), (800, 6)], 1100),
        ).throttle(const Duration(milliseconds: 200)).toList();
        expect(out, equals([1, 4, 6]));
      });

      test('trailing only: newest value when each window ends', () async {
        final out = await fxEvents(timed([(0, 1), (40, 2), (400, 3)], 800))
            .throttle(
              const Duration(milliseconds: 200),
              leading: false,
              trailing: true,
            )
            .toList();
        expect(out, equals([2, 3]));
      });

      test('leading + trailing', () async {
        final out = await fxEvents(
          timed([(0, 1), (40, 2), (80, 3)], 500),
        ).throttle(const Duration(milliseconds: 200), trailing: true).toList();
        expect(out, equals([1, 3]));
      });

      test(
        'close mid-window still delivers the pending trailing value',
        () async {
          final out = await fxEvents(timed([(0, 1), (40, 2)], 100))
              .throttle(const Duration(milliseconds: 300), trailing: true)
              .toList();
          expect(out, equals([1, 2]));
        },
      );

      test('close mid-window without trailing closes immediately', () async {
        final sw = Stopwatch()..start();
        final out = await fxEvents(
          timed([(0, 1)], 60),
        ).throttle(const Duration(milliseconds: 500)).toList();
        expect(out, equals([1]));
        expect(sw.elapsedMilliseconds, lessThan(400));
      });
    });

    group('sampleOn', () {
      test('emits the newest unseen value per trigger', () async {
        final source = timed([
          (0, 1),
          (50, 2),
          (100, 3),
          (150, 4),
          (200, 5),
        ], 600);
        final trigger = timed([
          (75, null),
          (125, null),
          (300, null),
          (450, null),
        ], 620);
        final out = await fxEvents(source).sampleOn(trigger).toList();
        // 75ms→2, 125ms→3, 300ms→5; 450ms trigger has nothing new.
        expect(out, equals([2, 3, 5]));
      });

      test('closes with the source and forwards its errors', () async {
        final c = StreamController<int>();
        final trigger = StreamController<void>();
        final events = <Object>[];
        var done = false;
        fxEvents(c.stream)
            .sampleOn(trigger.stream)
            .listen(events.add, onError: events.add, onDone: () => done = true);
        c.addError(StateError('boom'));
        await c.close();
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(events.single, isA<StateError>());
        expect(done, isTrue);
        await trigger.close();
      });
    });

    group('combineLatest', () {
      test(
        'emits pairs of latest values once both sides have spoken',
        () async {
          final a = timed([(0, 'a1'), (100, 'a2')], 400);
          final b = timed([(50, 'b1'), (150, 'b2')], 450);
          final out = await fxEvents(
            a,
          ).combineLatest(b, (x, y) => '$x$y').toList();
          expect(out, equals(['a1b1', 'a2b1', 'a2b2']));
        },
      );

      test('closes only when both sides have closed', () async {
        final a = timed([(0, 1)], 50);
        final b = timed([(20, 2), (100, 3)], 200);
        final out = await fxEvents(
          a,
        ).combineLatest(b, (x, y) => x + y).toList();
        expect(out, equals([3, 4]));
      });
    });

    group('withLatestFrom', () {
      test('stamps source events with the latest of other', () async {
        final source = timed([(0, 'r1'), (100, 'r2'), (200, 'r3')], 400);
        final config = timed([(50, 'v1'), (150, 'v2')], 450);
        final out = await fxEvents(
          source,
        ).withLatestFrom(config, (r, v) => '$r@$v').toList();
        // r1 arrives before any config and is dropped.
        expect(out, equals(['r2@v1', 'r3@v2']));
      });

      test('closes with the source even while other stays open', () async {
        final other = StreamController<int>();
        other.add(7);
        final out = await fxEvents(
          timed([(30, 1)], 80),
        ).withLatestFrom(other.stream, (a, b) => a + b).toList();
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
        final out = await fxEvents(
          timed([(0, 1)], 30),
        ).switchMap((v) => timed([(60, v * 10), (90, v * 100)], 120)).toList();
        expect(out, equals([10, 100]));
      });

      test(
        'a throwing mapper becomes an error event, source continues',
        () async {
          final events = <Object>[];
          final done = Completer<void>();
          fxEvents(Stream.fromIterable([1, 2, 3]))
              .switchMap<int>(
                (v) => v == 2 ? throw StateError('bad') : Stream.value(v * 10),
              )
              .listen(events.add, onError: events.add, onDone: done.complete);
          await done.future;
          expect(events.whereType<StateError>().length, equals(1));
          expect(events.whereType<int>().last, equals(30));
        },
      );
    });

    group('race', () {
      test('the first stream to emit wins, is mirrored in full, and losers '
          'are cancelled', () async {
        var loserEvents = 0;
        final fast = timed([(40, 'fast-1'), (90, 'fast-2')], 130);
        final slow = timed([(200, 'slow')], 240).map((v) {
          loserEvents++;
          return v;
        });
        final out = await FxEvents.race([slow, fast]).toList();
        expect(out, equals(['fast-1', 'fast-2']));
        await Future<void>.delayed(const Duration(milliseconds: 250));
        expect(loserEvents, equals(0));
      });

      test('an error can win the race', () async {
        final failing = timed([
          (30, 'x'),
        ], 60).asyncMap((_) => Future<String>.error(StateError('lost mirror')));
        final slow = timed([(200, 'slow')], 240);
        await expectLater(
          FxEvents.race([failing, slow]).toList(),
          throwsStateError,
        );
      });

      test('all candidates closing empty closes the result', () async {
        expect(
          await FxEvents.race<int>([timed([], 30), timed([], 50)]).toList(),
          equals([]),
        );
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
      final out = await fxEvents(
        Stream.fromIterable([1, 2, 3, 4, 5]),
      ).pull().filter((v) => v.isOdd).map((v) => v * 2).toList();
      expect(out, equals([2, 6, 10]));
    });
  });

  group('LiveValue', () {
    test(
      'seeded value is replayed to a late subscriber before updates',
      () async {
        final live = LiveValue.seeded(21.0);
        final seen = <double>[];
        live.stream.listen(seen.add);
        live.add(21.5);
        await Future<void>.delayed(Duration.zero);
        expect(seen, equals([21.0, 21.5]));
      },
    );

    test(
      'a subscriber arriving after updates gets the latest then the rest',
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
      },
    );

    test('value and hasValue report the current state', () {
      final live = LiveValue<int>();
      expect(live.hasValue, isFalse);
      expect(() => live.value, throwsStateError);
      live.add(7);
      expect(live.hasValue, isTrue);
      expect(live.value, equals(7));
    });

    test(
      'add after close throws; late subscriber still gets the replay',
      () async {
        final live = LiveValue.seeded('last');
        await live.close();
        expect(live.isClosed, isTrue);
        expect(() => live.add('more'), throwsStateError);
        expect(await live.stream.toList(), equals(['last']));
      },
    );

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

    test(
      'from feeds the value hot, and the source closing closes it',
      () async {
        final c = StreamController<int>();
        final live = LiveValue.from(c.stream);
        expect(live.hasValue, isFalse);

        c.add(1);
        await Future<void>.delayed(Duration.zero);
        expect(live.value, 1, reason: 'updated with nobody listening');

        final seen = <int>[];
        final sub = live.stream.listen(seen.add);
        await Future<void>.delayed(Duration.zero);
        c.add(2);
        await Future<void>.delayed(Duration.zero);
        expect(seen, equals([1, 2]));

        await c.close();
        await Future<void>.delayed(Duration.zero);
        expect(live.isClosed, isTrue);
        await sub.cancel();
      },
    );

    test('from forwards source errors to subscribers', () async {
      final c = StreamController<int>();
      final live = LiveValue.from(c.stream);
      final seen = <Object>[];
      final sub = live.stream.listen(seen.add, onError: seen.add);
      await Future<void>.delayed(Duration.zero);
      c.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await sub.cancel();
      await live.close();
      await c.close();
    });

    test('seededFrom holds the seed until the source speaks, and close '
        'cancels the source', () async {
      final c = StreamController<int>();
      final live = LiveValue.seededFrom(0, c.stream);
      expect(live.value, 0);

      c.add(7);
      await Future<void>.delayed(Duration.zero);
      expect(live.value, 7);

      await live.close();
      expect(live.isClosed, isTrue);
      c.add(8);
      await Future<void>.delayed(Duration.zero);
      expect(live.value, 7, reason: 'source was cancelled by close');
      await c.close();
    });
  });

  group('gating', () {
    test('stopOn mirrors until the trigger fires', () async {
      final source = StreamController<int>();
      final stop = StreamController<void>();
      final out = fxEvents(source.stream).stopOn(stop.stream).toList();

      source.add(1);
      await Future<void>.delayed(Duration.zero);
      source.add(2);
      await Future<void>.delayed(Duration.zero);
      stop.add(null);
      await Future<void>.delayed(Duration.zero);
      source.add(3);

      expect(await out, equals([1, 2]));
      await source.close();
      await stop.close();
    });

    test(
      'stopOn closes with the source when the trigger never fires',
      () async {
        final stop = StreamController<void>();
        expect(
          await fxEvents(
            Stream.fromIterable([1, 2]),
          ).stopOn(stop.stream).toList(),
          equals([1, 2]),
        );
        await stop.close();
      },
    );

    test('stopOn forwards trigger errors and supports cancel', () async {
      final source = StreamController<int>();
      final stop = StreamController<void>();
      final seen = <Object>[];
      final sub = fxEvents(
        source.stream,
      ).stopOn(stop.stream).listen(seen.add, onError: seen.add);
      stop.addError(StateError('trigger blew up'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await sub.cancel();
      await source.close();
      await stop.close();
    });

    test('startOn drops events until the trigger fires', () async {
      final source = StreamController<int>();
      final start = StreamController<void>();
      final out = fxEvents(source.stream).startOn(start.stream).toList();

      source.add(1);
      await Future<void>.delayed(Duration.zero);
      start.add(null);
      await Future<void>.delayed(Duration.zero);
      source.add(2);
      await Future<void>.delayed(Duration.zero);
      source.add(3);
      await Future<void>.delayed(Duration.zero);
      await source.close();

      expect(await out, equals([2, 3]));
      await start.close();
    });

    test('startOn emits nothing when the source closes first', () async {
      final start = StreamController<void>();
      expect(
        await fxEvents(
          Stream.fromIterable([1, 2]),
        ).startOn(start.stream).toList(),
        hasLength(0),
      );
      await start.close();
    });

    test('startOn forwards trigger errors and supports cancel', () async {
      final source = StreamController<int>();
      final start = StreamController<void>();
      final seen = <Object>[];
      final sub = fxEvents(
        source.stream,
      ).startOn(start.stream).listen(seen.add, onError: seen.add);
      start.addError(StateError('trigger blew up'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await sub.cancel();
      await source.close();
      await start.close();
    });
  });

  group('time', () {
    test('sample emits the newest value on its own clock', () async {
      final out = await fxEvents(
        timed([(0, 'a'), (60, 'b'), (300, 'c')], 640),
      ).sample(const Duration(milliseconds: 200)).toList();
      expect(
        out,
        equals(['b', 'c']),
        reason: 'the 600ms tick has nothing new to report',
      );
    });

    test('delay shifts every event without dropping any', () async {
      final watch = Stopwatch()..start();
      final out = await fxEvents(
        Stream.fromIterable([1, 2, 3]),
      ).delay(const Duration(milliseconds: 200)).toList();
      watch.stop();
      expect(out, equals([1, 2, 3]));
      expect(watch.elapsedMilliseconds, greaterThanOrEqualTo(150));
    });

    test(
      'delay forwards errors immediately and cancels pending timers',
      () async {
        final c = StreamController<int>();
        final seen = <Object>[];
        final sub = fxEvents(c.stream)
            .delay(const Duration(milliseconds: 300))
            .listen(seen.add, onError: seen.add);
        c
          ..addError(StateError('boom'))
          ..add(1);
        await Future<void>.delayed(const Duration(milliseconds: 40));
        expect(
          seen.single,
          isA<StateError>(),
          reason: 'data is still in flight',
        );
        await sub.cancel();
        await Future<void>.delayed(const Duration(milliseconds: 350));
        expect(seen.length, 1, reason: 'the pending timer was cancelled');
        await c.close();
      },
    );

    test('spaceBy stretches a burst out instead of dropping it', () async {
      final watch = Stopwatch()..start();
      final out = await fxEvents(
        Stream.fromIterable([1, 2, 3]),
      ).spaceBy(const Duration(milliseconds: 150)).toList();
      watch.stop();
      expect(out, equals([1, 2, 3]), reason: 'lossless, unlike throttle');
      expect(watch.elapsedMilliseconds, greaterThanOrEqualTo(300));
    });

    test('spaceBy supports cancel mid-queue', () async {
      final c = StreamController<int>();
      final seen = <int>[];
      final sub = fxEvents(
        c.stream,
      ).spaceBy(const Duration(milliseconds: 300)).listen(seen.add);
      c
        ..add(1)
        ..add(2);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      await sub.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 350));
      expect(seen, hasLength(0));
      await c.close();
    });
  });

  group('batching', () {
    test('chunk groups by count and flushes a short final batch', () async {
      expect(
        await fxEvents(Stream.fromIterable([1, 2, 3, 4, 5])).chunk(2).toList(),
        equals([
          [1, 2],
          [3, 4],
          [5],
        ]),
      );
    });

    test('chunk emits nothing extra when the count divides evenly', () async {
      expect(
        await fxEvents(Stream.fromIterable([1, 2, 3, 4])).chunk(2).toList(),
        equals([
          [1, 2],
          [3, 4],
        ]),
      );
    });

    test('chunk rejects a count below 1', () {
      expect(() => fxEvents(Stream<int>.empty()).chunk(0), throwsArgumentError);
    });

    test('chunk forwards errors, pauses and cancels', () async {
      final c = StreamController<int>();
      final seen = <Object>[];
      final sub = fxEvents(
        c.stream,
      ).chunk(2).listen(seen.add, onError: seen.add);
      c.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      sub.pause();
      c
        ..add(1)
        ..add(2);
      await Future<void>.delayed(Duration.zero);
      expect(seen.length, 1);
      sub.resume();
      await Future<void>.delayed(Duration.zero);
      expect(seen.last, equals([1, 2]));
      await sub.cancel();
      await c.close();
    });

    test(
      'chunkOn batches on the trigger and stays silent when empty',
      () async {
        final source = StreamController<int>();
        final tick = StreamController<void>();
        final out = fxEvents(source.stream).chunkOn(tick.stream).toList();

        source
          ..add(1)
          ..add(2);
        await Future<void>.delayed(Duration.zero);
        tick.add(null);
        await Future<void>.delayed(Duration.zero);
        tick.add(null); // buffer is empty — no batch
        await Future<void>.delayed(Duration.zero);
        source.add(3);
        await Future<void>.delayed(Duration.zero);
        await source.close();

        expect(
          await out,
          equals([
            [1, 2],
            [3],
          ]),
          reason: 'the tail is flushed on close',
        );
        await tick.close();
      },
    );

    test('chunkOn forwards trigger errors and supports cancel', () async {
      final source = StreamController<int>();
      final tick = StreamController<void>();
      final seen = <Object>[];
      final sub = fxEvents(
        source.stream,
      ).chunkOn(tick.stream).listen(seen.add, onError: seen.add);
      tick.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await sub.cancel();
      await source.close();
      await tick.close();
    });

    test('chunkEvery batches per window', () async {
      final out = await fxEvents(
        timed([(0, 1), (30, 2), (60, 3), (250, 4), (280, 5)], 520),
      ).chunkEvery(const Duration(milliseconds: 200)).toList();
      expect(
        out,
        equals([
          [1, 2, 3],
          [4, 5],
        ]),
      );
    });

    test('chunkEvery forwards errors, pauses and cancels', () async {
      final c = StreamController<int>();
      final seen = <Object>[];
      final sub = fxEvents(c.stream)
          .chunkEvery(const Duration(milliseconds: 60))
          .listen(seen.add, onError: seen.add);
      c.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      sub.pause();
      c.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(seen.length, 1);
      sub.resume();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(seen.last, equals([1]));
      await sub.cancel();
      await c.close();
    });
  });

  group('multi-source', () {
    test('concat plays the sources one after another', () async {
      expect(
        await FxEvents.concat([
          Stream.fromIterable([1, 2]),
          Stream.fromIterable([3]),
        ]).toList(),
        equals([1, 2, 3]),
      );
    });

    test('concat ends the chain on a source error', () async {
      expect(
        FxEvents.concat([
          Stream<int>.error(StateError('boom')),
          Stream.fromIterable([1]),
        ]).toList(),
        throwsStateError,
      );
    });

    test('followedBy is the two-source form', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1]),
        ).followedBy(Stream.fromIterable([2])).toList(),
        equals([1, 2]),
      );
    });

    test('zip pairs sources by index and stops at the shortest', () async {
      final out = await FxEvents.zip<int, String>([
        timed([(0, 1), (60, 2), (120, 3)], 400),
        timed([(30, 10), (90, 20)], 500),
      ], (v) => v.join('+')).toList();
      expect(out, equals(['1+10', '2+20']));
    });

    test('zip closes immediately with no sources', () async {
      expect(
        await FxEvents.zip<int, int>([], (v) => v.first).toList(),
        hasLength(0),
      );
    });

    test('zip forwards errors and supports cancel', () async {
      final a = StreamController<int>();
      final b = StreamController<int>();
      final seen = <Object>[];
      final sub = FxEvents.zip<int, int>([
        a.stream,
        b.stream,
      ], (v) => v.first).listen(seen.add, onError: seen.add);
      a.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await sub.cancel();
      await a.close();
      await b.close();
    });

    test('zipWith pairs two differently typed streams', () async {
      final out = await fxEvents(timed([(0, 1), (60, 2), (120, 3)], 400))
          .zipWith<String, String>(
            timed([(30, 'a'), (90, 'b')], 500),
            (n, s) => '$n$s',
          )
          .toList();
      expect(out, equals(['1a', '2b']));
    });

    test('zipWith forwards errors and supports cancel', () async {
      final a = StreamController<int>();
      final b = StreamController<int>();
      final seen = <Object>[];
      final sub = fxEvents(a.stream)
          .zipWith<int, int>(b.stream, (x, y) => x + y)
          .listen(seen.add, onError: seen.add);
      b.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await sub.cancel();
      await a.close();
      await b.close();
    });

    test('mergeWith interleaves, raceWith keeps the first to speak', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1]),
        ).mergeWith(Stream.fromIterable([2])).toList(),
        unorderedEquals([1, 2]),
      );
      expect(
        await fxEvents(
          timed([(0, 'fast')], 100),
        ).raceWith(timed([(200, 'slow')], 300)).toList(),
        equals(['fast']),
      );
    });

    test('combineLatestAll emits the latest of every source', () async {
      final a = StreamController<int>();
      final b = StreamController<int>();
      final out = FxEvents.combineLatestAll([a.stream, b.stream]).toList();

      a.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(a.hasListener, isTrue);
      b.add(10);
      await Future<void>.delayed(Duration.zero);
      a.add(2); // second event from a — already 'seen'
      await Future<void>.delayed(Duration.zero);
      await a.close();
      await b.close();

      expect(
        await out,
        equals([
          [1, 10],
          [2, 10],
        ]),
      );
    });

    test('combineLatestAll closes immediately with no sources', () async {
      expect(await FxEvents.combineLatestAll<int>([]).toList(), hasLength(0));
    });

    test('combineLatestAll forwards errors and supports cancel', () async {
      final a = StreamController<int>();
      final seen = <Object>[];
      final sub = FxEvents.combineLatestAll([
        a.stream,
      ]).listen(seen.add, onError: seen.add);
      a.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await sub.cancel();
      await a.close();
    });

    test('waitAll emits every last value once all have closed', () async {
      expect(
        await FxEvents.waitAll([
          Stream.fromIterable([1, 2]),
          Stream.fromIterable([10, 20, 30]),
        ]).toList(),
        equals([
          [2, 30],
        ]),
      );
    });

    test('waitAll emits nothing when a source never speaks', () async {
      expect(
        await FxEvents.waitAll([
          Stream.fromIterable([1]),
          Stream<int>.empty(),
        ]).toList(),
        hasLength(0),
      );
    });

    test('waitAll emits an empty list for no sources', () async {
      expect(await FxEvents.waitAll<int>([]).toList(), equals([<int>[]]));
    });

    test('waitAll forwards errors and supports cancel', () async {
      final a = StreamController<int>();
      final seen = <Object>[];
      final sub = FxEvents.waitAll([
        a.stream,
      ]).listen(seen.add, onError: seen.add);
      a.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.single, isA<StateError>());
      await sub.cancel();
      await a.close();
    });
  });

  group('higher-order mapping', () {
    test('mergeMap runs every inner stream at once', () async {
      final out = await fxEvents(
        Stream.fromIterable([1, 2]),
      ).mergeMap((n) => timed([(30 * n, n * 10)], 30 * n + 30)).toList();
      expect(out, equals([10, 20]));
    });

    test('mergeMap with concurrent queues the extra sources', () async {
      final running = <int>[];
      final peak = <int>[];
      final out = await fxEvents(Stream.fromIterable([1, 2, 3, 4])).mergeMap((
        n,
      ) {
        running.add(n);
        peak.add(running.length);
        return timed([(60, n)], 90).map((v) => v).asBroadcastStream().map((v) {
          running.remove(n);
          return v;
        });
      }, concurrent: 2).toList();
      expect(out, unorderedEquals([1, 2, 3, 4]));
      expect(peak.reduce((a, b) => a > b ? a : b), lessThanOrEqualTo(2));
    });

    test('mergeMap rejects a concurrent below 1', () {
      expect(
        () => fxEvents(
          Stream<int>.empty(),
        ).mergeMap((n) => Stream.value(n), concurrent: 0),
        throwsArgumentError,
      );
    });

    test('mergeMap forwards a mapper throw and still closes', () async {
      final seen = <Object>[];
      final done = Completer<void>();
      fxEvents(Stream.fromIterable([1]))
          .mergeMap<int>((_) => throw StateError('boom'))
          .listen(seen.add, onError: seen.add, onDone: done.complete);
      await done.future;
      expect(seen.single, isA<StateError>());
    });

    test(
      'mergeMap forwards source and inner errors, and supports cancel',
      () async {
        final c = StreamController<int>();
        final seen = <Object>[];
        final sub = fxEvents(c.stream)
            .mergeMap((n) => Stream<int>.error(StateError('inner $n')))
            .listen(seen.add, onError: seen.add);
        c.addError(StateError('outer'));
        c.add(1);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(seen.length, 2);
        await sub.cancel();
        await c.close();
      },
    );

    test('concatMap plays inner streams strictly in order', () async {
      final out = await fxEvents(
        Stream.fromIterable([1, 2]),
      ).concatMap((n) => Stream.fromIterable([n, n * 10])).toList();
      expect(out, equals([1, 10, 2, 20]));
    });

    test('exhaustMap ignores events while an inner stream runs', () async {
      final out = await fxEvents(
        timed([(0, 1), (30, 2), (200, 3)], 400),
      ).exhaustMap((n) => timed([(100, n)], 120)).toList();
      expect(out, equals([1, 3]), reason: '2 arrived while 1 was in flight');
    });

    test(
      'exhaustMap waits for an inner stream still running at close',
      () async {
        final out = await fxEvents(
          timed([(0, 1)], 30),
        ).exhaustMap((n) => timed([(150, n * 10)], 200)).toList();
        expect(
          out,
          equals([10]),
          reason: 'the source closed first, the inner stream finished later',
        );
      },
    );

    test('exhaustMap forwards a mapper throw', () async {
      final seen = <Object>[];
      final done = Completer<void>();
      fxEvents(Stream.fromIterable([1]))
          .exhaustMap<int>((_) => throw StateError('boom'))
          .listen(seen.add, onError: seen.add, onDone: done.complete);
      await done.future;
      expect(seen.single, isA<StateError>());
    });

    test('exhaustMap forwards source errors and supports cancel', () async {
      final c = StreamController<int>();
      final seen = <Object>[];
      final sub = fxEvents(c.stream)
          .exhaustMap((n) => timed([(200, n)], 300))
          .listen(seen.add, onError: seen.add);
      c.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
      c.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await sub.cancel();
      expect(seen.single, isA<StateError>());
      await c.close();
    });
  });

  group('errors', () {
    test('onErrorReturn substitutes a value for every error', () async {
      final c = StreamController<int>();
      final out = fxEvents(c.stream).onErrorReturn(-1).toList();
      c
        ..add(1)
        ..addError(StateError('a'))
        ..add(2)
        ..addError(StateError('b'));
      await c.close();
      expect(await out, equals([1, -1, 2, -1]));
    });

    test('onErrorReturn pauses and cancels', () async {
      final c = StreamController<int>();
      final seen = <int>[];
      final sub = fxEvents(c.stream).onErrorReturn(-1).listen(seen.add);
      sub.pause();
      c.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(seen, hasLength(0));
      sub.resume();
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([1]));
      await sub.cancel();
      await c.close();
    });

    test('onErrorResume abandons the source for the fallback', () async {
      final c = StreamController<int>();
      final out = fxEvents(c.stream)
          .onErrorResume((e, _) => Stream.fromIterable(['$e'.length, 99]))
          .toList();
      c
        ..add(1)
        ..addError(StateError('boom'))
        ..add(2);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await c.close();
      final result = await out;
      expect(result.first, 1);
      expect(result.last, 99);
      expect(result, hasLength(3), reason: 'the post-error 2 never arrives');
    });

    test('onErrorResume passes a clean source straight through', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1, 2]),
        ).onErrorResume((e, _) => Stream.value(-1)).toList(),
        equals([1, 2]),
      );
    });

    test('onErrorResume forwards a throw from the builder', () async {
      expect(
        fxEvents(
          Stream<int>.error(StateError('boom')),
        ).onErrorResume((e, st) => throw ArgumentError('builder')).toList(),
        throwsArgumentError,
      );
    });

    test(
      'onErrorResume forwards fallback errors and supports cancel',
      () async {
        final c = StreamController<int>();
        final seen = <Object>[];
        final sub = fxEvents(c.stream)
            .onErrorResume((e, _) => Stream<int>.error(ArgumentError('again')))
            .listen(seen.add, onError: seen.add);
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        await c.close();
        expect(seen, hasLength(0));
      },
    );

    test('retry resubscribes until the factory succeeds', () async {
      var attempts = 0;
      final out = await FxEvents.retry<int>(() {
        attempts++;
        return attempts < 3
            ? Stream<int>.error(StateError('attempt $attempts'))
            : Stream.fromIterable([1, 2]);
      }).toList();
      expect(out, equals([1, 2]));
      expect(attempts, 3);
    });

    test(
      'retry gives up after count retries and forwards the last error',
      () async {
        var attempts = 0;
        final seen = <Object>[];
        final done = Completer<void>();
        FxEvents.retry<int>(() {
          attempts++;
          return Stream<int>.error(StateError('attempt $attempts'));
        }, 2).listen(seen.add, onError: seen.add, onDone: done.complete);
        await done.future;
        expect(attempts, 3, reason: 'one attempt plus two retries');
        expect(seen.single, isA<StateError>());
      },
    );

    test('retry forwards a throw from the factory', () async {
      expect(
        FxEvents.retry<int>(() => throw StateError('boom')).toList(),
        throwsStateError,
      );
    });

    test('retry supports cancel mid-attempt', () async {
      final c = StreamController<int>();
      final seen = <int>[];
      final sub = FxEvents.retry<int>(() => c.stream).listen(seen.add);
      c.add(1);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(seen, equals([1]));
      await c.close();
    });
  });

  group('stateful', () {
    test('scan emits the seed before any event', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1, 2, 3]),
        ).scan<int>((acc, a) => acc + a, 10).toList(),
        equals([10, 11, 13, 16]),
      );
    });

    test('scan on an empty source emits the seed alone', () async {
      expect(
        await fxEvents(
          const Stream<int>.empty(),
        ).scan<int>((acc, a) => acc + a, 7).toList(),
        equals([7]),
      );
    });

    test('scan turns a throwing fold into an error event and carries on',
        () async {
      final seen = <Object>[];
      final done = Completer<void>();
      fxEvents(Stream.fromIterable([1, 2, 3]))
          .scan<int>(
            (acc, a) => a == 2 ? throw StateError('boom') : acc + a,
            0,
          )
          .listen(seen.add, onError: seen.add, onDone: done.complete);
      await done.future;
      expect(seen.first, equals(0));
      expect(seen.any((e) => e is StateError), isTrue);
      expect(seen.last, equals(4));
    });

    test('uniqAdjacent drops runs but keeps a later repeat', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1, 1, 2, 2, 2, 1]),
        ).uniqAdjacent().toList(),
        equals([1, 2, 1]),
      );
    });

    test('uniqAdjacentBy compares the key, not the value', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([1, 11, 21, 2, 1]),
        ).uniqAdjacentBy((a) => a % 10).toList(),
        equals([1, 2, 1]),
      );
    });

    test('pairwise pairs each event with its successor', () async {
      expect(
        await fxEvents(Stream.fromIterable([1, 2, 3, 4])).pairwise().toList(),
        equals([(1, 2), (2, 3), (3, 4)]),
      );
    });

    test('pairwise stays silent when only one event arrives', () async {
      expect(
        await fxEvents(Stream.fromIterable([1])).pairwise().toList(),
        hasLength(0),
      );
    });

    test('uniqAdjacentBy reports a throwing key and keeps the last one it '
        'computed', () async {
      final seen = <Object>[];
      final done = Completer<void>();
      fxEvents(Stream.fromIterable([1, 2, 11, 3]))
          .uniqAdjacentBy((a) => a == 2 ? throw StateError('boom') : a % 10)
          .listen(seen.add, onError: seen.add, onDone: done.complete);
      await done.future;
      // 2 fails, so the key stays 1 and the following 11 is dropped as a
      // repeat of it.
      expect(seen.whereType<int>().toList(), equals([1, 3]));
      expect(seen.any((e) => e is StateError), isTrue);
    });

    test('scan forwards pause, resume and cancel to the source', () async {
      final c = StreamController<int>();
      final seen = <int>[];
      final sub = fxEvents(c.stream).scan<int>((acc, a) => acc + a, 0).listen(
        seen.add,
      );
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([0]));
      sub.pause();
      c
        ..add(1)
        ..add(2);
      await Future<void>.delayed(Duration.zero);
      expect(c.isPaused, isTrue);
      expect(seen, equals([0]));
      sub.resume();
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([0, 1, 3]));
      await sub.cancel();
      expect(c.hasListener, isFalse);
      await c.close();
    });

    test('drop forwards pause, resume and cancel to the source', () async {
      final c = StreamController<int>();
      final seen = <int>[];
      final sub = fxEvents(c.stream).drop(1).listen(seen.add);
      await Future<void>.delayed(Duration.zero);
      sub.pause();
      c
        ..add(1)
        ..add(2);
      await Future<void>.delayed(Duration.zero);
      expect(c.isPaused, isTrue);
      expect(seen, hasLength(0));
      sub.resume();
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals([2]));
      await sub.cancel();
      expect(c.hasListener, isFalse);
      await c.close();
    });

    test('uniqAdjacentBy, pairwise and take forward pause and cancel',
        () async {
      for (final build in <FxEvents<int> Function(Stream<int>)>[
        (s) => fxEvents(s).uniqAdjacentBy((a) => a),
        (s) => fxEvents(s).pairwise().map((p) => p.$1),
        (s) => fxEvents(s).take(9),
      ]) {
        final c = StreamController<int>();
        final seen = <int>[];
        final sub = build(c.stream).listen(seen.add);
        await Future<void>.delayed(Duration.zero);
        sub.pause();
        c
          ..add(1)
          ..add(2);
        await Future<void>.delayed(Duration.zero);
        expect(c.isPaused, isTrue);
        expect(seen, hasLength(0));
        sub.resume();
        await Future<void>.delayed(Duration.zero);
        expect(seen, isNotEmpty);
        await sub.cancel();
        expect(c.hasListener, isFalse);
        await c.close();
      }
    });

    test('scan, uniqAdjacentBy and pairwise forward a source error in place',
        () async {
      for (final build in <FxEvents<Object> Function(Stream<int>)>[
        (s) => fxEvents(s).scan<int>((acc, a) => acc + a, 0).map((a) => a),
        (s) => fxEvents(s).uniqAdjacentBy((a) => a).map((a) => a),
        (s) => fxEvents(s).pairwise().map((p) => p.$2),
      ]) {
        final c = StreamController<int>();
        final seen = <Object>[];
        final done = Completer<void>();
        build(c.stream).listen(
          seen.add,
          onError: seen.add,
          onDone: done.complete,
        );
        c
          ..add(1)
          ..add(2)
          ..addError(StateError('boom'))
          ..add(3);
        await c.close();
        await done.future;
        // The error keeps its place in the sequence: whatever the operator
        // emitted for `2` comes before it, whatever it emits for `3` after.
        final at = seen.indexWhere((e) => e is StateError);
        expect(at, greaterThan(0));
        expect(at, lessThan(seen.length - 1));
      }
    });

    test('the controller operators answer single-subscription, broadcast '
        'source or not', () async {
      final broadcast = StreamController<int>.broadcast().stream;
      expect(broadcast.isBroadcast, isTrue);
      final built = <FxEvents<Object>>[
        fxEvents(broadcast).scan<int>((acc, a) => acc + a, 0),
        fxEvents(broadcast).uniqAdjacentBy((a) => a),
        fxEvents(broadcast).pairwise(),
      ];
      for (final e in built) {
        // Documented on each operator: a controller stage does not carry the
        // source's broadcast-ness through. `take`/`drop` do, because they
        // delegate to the SDK — the asymmetry is deliberate and pinned here
        // so a later change to either side is a visible decision.
        expect(e.stream.isBroadcast, isFalse);
      }
    });
  });

  group('limiting', () {
    test('take stops at the count', () async {
      expect(
        await fxEvents(Stream.fromIterable([1, 2, 3, 4, 5])).take(2).toList(),
        equals([1, 2]),
      );
    });

    test('take cancels the source once the count is met', () async {
      var cancelled = false;
      final c = StreamController<int>(onCancel: () => cancelled = true);
      final collected = fxEvents(c.stream).take(2).toList();
      c
        ..add(1)
        ..add(2)
        ..add(3);
      expect(await collected, equals([1, 2]));
      await Future<void>.delayed(Duration.zero);
      expect(cancelled, isTrue);
    });

    test('take below 1 closes without subscribing', () async {
      for (final count in [0, -1]) {
        var listened = false;
        final c = StreamController<int>(onListen: () => listened = true);
        expect(await fxEvents(c.stream).take(count).toList(), hasLength(0));
        expect(listened, isFalse);
        // Nobody subscribed, so `close()` would never complete — the done
        // event has no listener to reach.
        unawaited(c.close());
      }
    });

    test('take keeps the source subscription multiplicity at every count',
        () async {
      final single = StreamController<int>().stream;
      final broadcast = StreamController<int>.broadcast().stream;
      for (final count in [0, 1]) {
        expect(fxEvents(single).take(count).stream.isBroadcast, isFalse);
        expect(fxEvents(broadcast).take(count).stream.isBroadcast, isTrue);
      }
    });

    test('drop skips the leading events', () async {
      expect(
        await fxEvents(Stream.fromIterable([1, 2, 3, 4, 5])).drop(2).toList(),
        equals([3, 4, 5]),
      );
    });

    test('drop past the end yields nothing', () async {
      expect(
        await fxEvents(Stream.fromIterable([1, 2])).drop(5).toList(),
        hasLength(0),
      );
    });

    test('skip is the same operator as drop', () async {
      expect(
        await fxEvents(Stream.fromIterable([1, 2, 3])).skip(1).toList(),
        equals([2, 3]),
      );
    });

    test('drop below 1 skips nothing, where Stream.skip would throw', () async {
      expect(
        await fxEvents(Stream.fromIterable([1, 2])).drop(-1).toList(),
        equals([1, 2]),
      );
      expect(
        await fxEvents(Stream.fromIterable([1, 2])).drop(0).toList(),
        equals([1, 2]),
      );
    });
  });

  group('head', () {
    test('answers the first event', () async {
      expect(
        await fxEvents(Stream.fromIterable([7, 8, 9])).head(),
        equals(7),
      );
    });

    test('answers null on a stream that closes empty', () async {
      expect(await fxEvents(const Stream<int>.empty()).head(), equals(null));
    });

    test('the source is already cancelled when it answers', () async {
      var cancelled = false;
      final c = StreamController<int>(onCancel: () => cancelled = true);
      final value = fxEvents(c.stream).head();
      c
        ..add(1)
        ..add(2);
      expect(await value, equals(1));
      // No settling delay: the future waits for the teardown itself.
      expect(cancelled, isTrue);
    });

    // `Stream.first` answers with what the stream delivered and lets a
    // throwing disposer surface as a zone error instead. These two pin the
    // same split, because the tempting `then(onError:)` spelling would let
    // the teardown failure replace the answer.
    test('a failing teardown does not replace the delivered value', () async {
      final zoneErrors = <Object>[];
      await runZonedGuarded(() async {
        final c = StreamController<int>(
          onCancel: () => throw StateError('cancel-boom'),
        );
        final value = fxEvents(c.stream).head();
        c.add(1);
        expect(await value, equals(1));
      }, (e, _) => zoneErrors.add(e));
      await Future<void>.delayed(Duration.zero);
      expect(zoneErrors.single, isStateError);
    });

    test('a source error survives a failing teardown', () async {
      final zoneErrors = <Object>[];
      await runZonedGuarded(() async {
        final c = StreamController<int>(
          onCancel: () => throw StateError('cancel-boom'),
        );
        final value = fxEvents(c.stream).head();
        c.addError(ArgumentError('source-boom'));
        await expectLater(value, throwsArgumentError);
      }, (e, _) => zoneErrors.add(e));
      await Future<void>.delayed(Duration.zero);
      expect(zoneErrors.single, isStateError);
    });

    test('answers from a broadcast source', () async {
      final c = StreamController<int>.broadcast();
      final value = fxEvents(c.stream).head();
      await Future<void>.delayed(Duration.zero);
      c.add(5);
      expect(await value, equals(5));
      await c.close();
    });

    test('forwards an error instead of answering', () async {
      await expectLater(
        fxEvents(Stream<int>.error(StateError('boom'))).head(),
        throwsStateError,
      );
    });

    test('answers the value when the source errors after it', () async {
      final c = StreamController<int>();
      final value = fxEvents(c.stream).head();
      c.add(1);
      expect(await value, equals(1));
      c.addError(StateError('late'));
      await c.close();
    });

    test('firstOrNull is the same terminal', () async {
      expect(
        await fxEvents(Stream.fromIterable([7, 8])).firstOrNull(),
        equals(7),
      );
      expect(
        await fxEvents(const Stream<int>.empty()).firstOrNull(),
        equals(null),
      );
    });
  });
}
