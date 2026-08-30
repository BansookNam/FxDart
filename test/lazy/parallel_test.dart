@TestOn('vm')
library;

import 'dart:async';
import 'dart:isolate';

import 'package:fxdart/fxdart.dart';
import 'package:fxdart/src/async_iterable.dart' show StreamPullCancel;
import 'package:test/test.dart';

int doubleIt(int x) => x * 2;

int throwsOnThree(int x) {
  if (x == 3) throw StateError('three');
  return x;
}

int busy(int x) {
  var acc = 0;
  for (var i = 0; i < 2000000; i++) {
    acc += i & 7;
  }
  return x + (acc & 1);
}

void main() {
  group('parallel', () {
    test('yields every element, in order', () async {
      expect(
        await fx([1, 2, 3, 4]).parallel(2, doubleIt).toList(),
        equals([2, 4, 6, 8]),
      );
    });

    test('workers == 1 still runs off-isolate and keeps order', () async {
      expect(
        await fx([1, 2, 3]).parallel(1, doubleIt).toList(),
        equals([2, 4, 6]),
      );
    });

    test('an empty source completes empty', () async {
      expect(await fx(<int>[]).parallel(2, doubleIt).toList(), equals(<int>[]));
    });

    test('a single element', () async {
      expect(await fx([7]).parallel(4, doubleIt).toList(), equals([14]));
    });

    test('workers < 1 throws', () {
      expect(() => parallel(0, doubleIt, [1]), throwsRangeError);
    });

    test('propagates a worker error as itself', () async {
      try {
        await fx([1, 2, 3, 4, 5, 6]).parallel(3, throwsOnThree).toList();
        fail('expected throw');
      } on StateError catch (e) {
        expect(e.message, 'three');
      }
    });

    test('a worker error does not leak unhandled async errors', () async {
      var unhandled = 0;
      await runZonedGuarded(
        () async {
          try {
            await fx([1, 2, 3, 4, 5, 6]).parallel(3, throwsOnThree).toList();
          } catch (_) {}
          await Future<void>.delayed(Duration.zero);
        },
        (e, st) {
          unhandled++;
        },
      );
      expect(unhandled, 0);
    });

    test('take shuts the pool', () async {
      expect(
        await fx([
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
        ]).parallel(4, doubleIt).take(2).toList(),
        equals([2, 4]),
      );
    });

    test('cancel on the iterator ends further pulls', () async {
      final it = parallel(4, doubleIt, [1, 2, 3, 4, 5, 6, 7, 8]).iterator;
      expect((await it.next()).value, 2);
      await (it as StreamPullCancel).cancel();
      expect((await it.next()).done, isTrue);
    });

    test('head shuts the pool', () async {
      expect(await fx([1, 2, 3, 4]).parallel(2, doubleIt).head(), 2);
    });

    test('overlapping next() keeps source order', () async {
      final it = parallel(2, doubleIt, [1, 2, 3, 4, 5, 6]).iterator;
      final marker = Concurrent.of(3);
      final results = await Future.wait([
        it.next(marker),
        it.next(marker),
        it.next(marker),
      ]);
      expect(
        results.map((r) => r.done ? 'done' : r.value).toList(),
        equals([2, 4, 6]),
      );
    });

    test('parallel then concurrent does not crash and keeps order', () async {
      expect(
        await fx([
          1,
          2,
          3,
          4,
          5,
          6,
        ]).parallel(2, doubleIt).concurrent(3).toList(),
        equals([2, 4, 6, 8, 10, 12]),
      );
    });

    test('a capturing closure of a sendable int runs', () async {
      const factor = 3;
      expect(
        await fx([1, 2, 3]).parallel(2, (int x) => x * factor).toList(),
        equals([3, 6, 9]),
      );
    });

    test('a closure that captures a ReceivePort throws at spawn', () async {
      final port = ReceivePort();
      try {
        expect(
          fx([1, 2, 3]).parallel(2, (x) {
            port.toString();
            return x;
          }).toList(),
          throwsA(isA<ArgumentError>()),
        );
      } finally {
        port.close();
      }
    });

    test(
      'two workers finish four busy items faster than serial would',
      () async {
        final serial = Stopwatch()..start();
        await fx([1, 2, 3, 4]).parallel(1, busy).toList();
        final serialMs = serial.elapsedMilliseconds;

        final paired = Stopwatch()..start();
        final out = await fx([1, 2, 3, 4]).parallel(2, busy).toList();
        final pairedMs = paired.elapsedMilliseconds;

        expect(out.length, 4);
        expect(pairedMs, lessThan(serialMs * 0.85));
      },
    );

    test('async source via parallelAsync', () async {
      expect(
        await fx([1, 2, 3]).toAsync().parallel(2, doubleIt).toList(),
        equals([2, 4, 6]),
      );
    });
  });
}
