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
  group('mergeScan', () {
    test('emits accumulations without the seed', () async {
      expect(
        await fxEvents(Stream.fromIterable([1, 2, 3]))
            .mergeScan<int>(
              10,
              (acc, v) => Stream.value(acc + v),
              concurrent: 1,
            )
            .toList(),
        equals([11, 13, 16]),
      );
      expect(
        await fxEvents(
          const Stream<int>.empty(),
        ).mergeScan<int>(7, (acc, v) => Stream.value(acc + v)).toList(),
        equals([]),
        reason: 'unlike FxEvents.scan, the seed is not emitted',
      );
    });

    test('concurrent: 2 queues extra sources and shares state', () async {
      final source = StreamController<int>();
      final inners = <int, StreamController<int>>{};
      final started = <int>[];
      final seen = <int>[];
      final done = Completer<void>();

      fxEvents(source.stream)
          .mergeScan<int>(0, (acc, v) {
            started.add(v);
            final c = StreamController<int>();
            inners[v] = c;
            return c.stream;
          }, concurrent: 2)
          .listen(seen.add, onDone: done.complete);

      source
        ..add(1)
        ..add(2)
        ..add(3);
      await Future<void>.delayed(Duration.zero);
      expect(started, equals([1, 2]), reason: '3 is queued at the cap');

      inners[1]!.add(10);
      await inners[1]!.close();
      await Future<void>.delayed(Duration.zero);
      expect(started, equals([1, 2, 3]), reason: 'a free slot starts 3');

      inners[2]!.add(20);
      await inners[2]!.close();
      inners[3]!.add(30);
      await inners[3]!.close();
      await source.close();
      await done.future;
      expect(seen, equals([10, 20, 30]));
    });

    test('rejects a concurrent below 1', () {
      expect(
        () => fxEvents(
          Stream<int>.empty(),
        ).mergeScan<int>(0, (acc, v) => Stream.value(v), concurrent: 0),
        throwsArgumentError,
      );
    });

    test('waits for inners still running after the source closes', () async {
      final out = await fxEvents(
        timed([(0, 1)], 20),
      ).mergeScan<int>(0, (acc, v) => timed([(80, acc + v)], 100)).toList();
      expect(out, equals([1]));
    });

    test(
      'a throwing accumulator is an error; queued values still start',
      () async {
        final source = StreamController<int>();
        final first = StreamController<int>();
        final seen = <Object>[];
        final done = Completer<void>();
        fxEvents(source.stream)
            .mergeScan<int>(0, (acc, v) {
              if (v == 2) throw StateError('bad');
              if (v == 1) return first.stream;
              return Stream.value(acc + v);
            }, concurrent: 1)
            .listen(seen.add, onError: seen.add, onDone: done.complete);

        source.add(1);
        await Future<void>.delayed(Duration.zero);
        source.add(2);
        source.add(3);
        await Future<void>.delayed(Duration.zero);
        first.add(10);
        await first.close();
        await source.close();
        await done.future;
        expect(seen.whereType<StateError>().length, equals(1));
        expect(seen.whereType<int>().toList(), equals([10, 13]));
      },
    );

    test('a throwing accumulator on the last value still closes', () async {
      final seen = <Object>[];
      final done = Completer<void>();
      fxEvents(Stream.fromIterable([1]))
          .mergeScan<int>(0, (acc, v) => throw StateError('boom'))
          .listen(seen.add, onError: seen.add, onDone: done.complete);
      await done.future;
      expect(seen.single, isA<StateError>());
    });

    test('forwards source and inner errors, and supports cancel', () async {
      final c = StreamController<int>();
      final inner = StreamController<int>();
      final seen = <Object>[];
      final sub = fxEvents(c.stream)
          .mergeScan<int>(0, (acc, v) => inner.stream)
          .listen(seen.add, onError: seen.add);
      c.addError(StateError('outer'));
      c.add(1);
      await Future<void>.delayed(Duration.zero);
      inner.addError(StateError('inner'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.whereType<StateError>().length, equals(2));
      await sub.cancel();
      inner.add(99);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(seen.whereType<int>(), equals([]));
      await inner.close();
      await c.close();
    });

    test('unlimited concurrent runs every inner at once', () async {
      final out = await fxEvents(Stream.fromIterable([1, 2]))
          .mergeScan<int>(0, (acc, v) => timed([(30 * v, v * 10)], 30 * v + 30))
          .toList();
      expect(out, unorderedEquals([10, 20]));
    });
  });

  group('switchScan', () {
    test('a newer event cancels the previous inner', () async {
      final started = <int>[];
      final out = await fxEvents(timed([(0, 1), (60, 2)], 400)).switchScan<int>(
        10,
        (acc, v) {
          started.add(v);
          return timed([(150, acc + v)], 200);
        },
      ).toList();
      expect(started, equals([1, 2]));
      expect(
        out,
        equals([12]),
        reason: '1 was cancelled before 10+1 could emit; 2 used seed 10',
      );
    });

    test('hands the latest inner emission to the next accumulator', () async {
      final accs = <int>[];
      final source = StreamController<int>();
      final first = StreamController<int>();
      final second = StreamController<int>();
      final seen = <int>[];
      final done = Completer<void>();
      fxEvents(source.stream)
          .switchScan<int>(10, (acc, v) {
            accs.add(acc);
            return v == 1 ? first.stream : second.stream;
          })
          .listen(seen.add, onDone: done.complete);

      source.add(1);
      await Future<void>.delayed(Duration.zero);
      first.add(11);
      await Future<void>.delayed(Duration.zero);
      source.add(2);
      await Future<void>.delayed(Duration.zero);
      expect(first.hasListener, isFalse, reason: 'switched away from first');
      await source.close();
      expect(seen, equals([11]), reason: 'still waiting on the current inner');
      second.add(13);
      await second.close();
      await done.future;
      expect(accs, equals([10, 11]));
      expect(seen, equals([11, 13]));
    });

    test('does not emit the seed; empty source closes empty', () async {
      expect(
        await fxEvents(
          const Stream<int>.empty(),
        ).switchScan<int>(7, (acc, v) => Stream.value(acc + v)).toList(),
        equals([]),
      );
    });

    test('waits for the current inner after the source closes', () async {
      final out = await fxEvents(timed([(0, 1)], 20))
          .switchScan<int>(0, (acc, v) => timed([(80, acc + v * 10)], 100))
          .toList();
      expect(out, equals([10]));
    });

    test(
      'a throwing accumulator is an error event, source continues',
      () async {
        final seen = <Object>[];
        final done = Completer<void>();
        fxEvents(timed([(0, 1), (40, 2), (80, 3)], 200))
            .switchScan<int>(
              0,
              (acc, v) =>
                  v == 2 ? throw StateError('bad') : Stream.value(acc + v),
            )
            .listen(seen.add, onError: seen.add, onDone: done.complete);
        await done.future;
        expect(seen.whereType<StateError>().length, equals(1));
        expect(seen.whereType<int>().toList(), equals([1, 4]));
      },
    );

    test('forwards inner and source errors, and supports cancel', () async {
      final c = StreamController<int>();
      final inner = StreamController<int>();
      final seen = <Object>[];
      final sub = fxEvents(c.stream)
          .switchScan<int>(0, (acc, v) => inner.stream)
          .listen(seen.add, onError: seen.add);
      c.addError(StateError('outer'));
      c.add(1);
      await Future<void>.delayed(Duration.zero);
      inner.addError(StateError('inner'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.whereType<StateError>().length, equals(2));
      await sub.cancel();
      inner.add(99);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(seen.whereType<int>(), equals([]));
      await inner.close();
      await c.close();
    });
  });

  group('expandEach', () {
    test('recursively flattens a finite tree', () async {
      expect(
        await fxEvents(Stream.value(0))
            .expandEach(
              (n) => n >= 2 ? Stream<int>.empty() : Stream.value(n + 1),
            )
            .toList(),
        equals([0, 1, 2]),
      );
    });

    test('concurrent caps in-flight project streams', () async {
      final source = StreamController<String>();
      final inners = <String, StreamController<String>>{
        'first': StreamController<String>(),
        'second': StreamController<String>(),
        'third': StreamController<String>(),
      };
      final seen = <String>[];
      final done = Completer<void>();
      fxEvents(source.stream)
          .expandEach(
            (v) => inners[v]?.stream ?? Stream<String>.empty(),
            concurrent: 2,
          )
          .listen(seen.add, onDone: done.complete);

      source
        ..add('first')
        ..add('second')
        ..add('third');
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals(['first', 'second']));
      expect(inners['third']!.hasListener, isFalse);

      inners['second']!.add('second-child');
      await inners['first']!.close();
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals(['first', 'second', 'third']));
      expect(inners['third']!.hasListener, isTrue);

      await inners['third']!.close();
      await Future<void>.delayed(Duration.zero);
      expect(seen, equals(['first', 'second', 'third', 'second-child']));
      await inners['second']!.close();
      await source.close();
      await done.future;
    });

    test('rejects a concurrent below 1', () {
      expect(
        () => fxEvents(
          Stream<int>.empty(),
        ).expandEach((n) => Stream.value(n), concurrent: 0),
        throwsArgumentError,
      );
    });

    test('an empty source closes empty', () async {
      expect(
        await fxEvents(
          const Stream<int>.empty(),
        ).expandEach((n) => Stream.value(n + 1)).toList(),
        equals([]),
      );
    });

    test('a throwing project is an error; siblings still expand', () async {
      final seen = <Object>[];
      final done = Completer<void>();
      fxEvents(Stream.value(0))
          .expandEach((n) {
            if (n == 1) throw StateError('bad');
            return n >= 2
                ? Stream<int>.empty()
                : Stream.fromIterable([n + 1, n + 2]);
          })
          .listen(seen.add, onError: seen.add, onDone: done.complete);
      await done.future;
      expect(seen.whereType<StateError>().length, equals(1));
      expect(seen.whereType<int>().contains(0), isTrue);
      expect(seen.whereType<int>().contains(2), isTrue);
    });

    test('forwards source and inner errors, and supports cancel', () async {
      final c = StreamController<int>();
      final inner = StreamController<int>();
      final seen = <Object>[];
      final sub = fxEvents(c.stream)
          .expandEach((n) => n == 1 ? inner.stream : Stream<int>.empty())
          .listen(seen.add, onError: seen.add);
      c.addError(StateError('outer'));
      c.add(1);
      await Future<void>.delayed(Duration.zero);
      expect(seen.whereType<int>(), equals([1]));
      inner.addError(StateError('inner'));
      await Future<void>.delayed(Duration.zero);
      expect(seen.whereType<StateError>().length, equals(2));
      await sub.cancel();
      inner.add(99);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(seen.whereType<int>(), equals([1]));
      await inner.close();
      await c.close();
    });

    test('waits for projected values after the source closes', () async {
      final out = await fxEvents(timed([(0, 1)], 20))
          .expandEach(
            (n) => n >= 2 ? Stream<int>.empty() : timed([(60, n + 1)], 80),
          )
          .toList();
      expect(out, equals([1, 2]));
    });

    test('unlimited concurrent projects every queued value', () async {
      expect(
        await fxEvents(
          Stream.fromIterable([10, 20]),
        ).expandEach((n) => Stream<int>.empty()).toList(),
        equals([10, 20]),
      );
    });
  });
}
