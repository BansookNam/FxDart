@TestOn('vm')
library;

import 'dart:isolate';

import 'package:fxdart/fxdart.dart';
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

    test('propagates a worker error', () {
      expect(
        fx([3]).parallel(1, throwsOnThree).toList(),
        throwsA(isA<StateError>()),
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
