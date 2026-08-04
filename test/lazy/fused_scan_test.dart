import 'dart:async';

import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

/// `scanAsync` fuses into the same stage run as map/filter/takeWhile, and the
/// all-consuming terminals drive that run directly. Both are invisible from
/// the outside — these pin the observable behaviour of the combinations.
void main() {
  group('fused scan', () {
    test('scan then map: the seed flows through the later stages', () async {
      final res = await fx([1, 2, 3])
          .toAsync()
          .scan<int>((acc, a) => acc + a, 10)
          .map((a) => 'v$a')
          .toList();
      expect(res, equals(['v10', 'v11', 'v13', 'v16']));
    });

    test('map then scan: the earlier stage does not see the seed', () async {
      final res = await fx([1, 2, 3])
          .toAsync()
          .map((a) => a * 2)
          .scan<int>((acc, a) => acc + a, 100)
          .toList();
      expect(res, equals([100, 102, 106, 112]));
    });

    test('async accumulator and async map in one run', () async {
      final res = await fx(['b', 'c'])
          .toAsync()
          .scan<String>((acc, a) async => acc + a, 'a')
          .map((a) async => a.toUpperCase())
          .toList();
      expect(res, equals(['A', 'AB', 'ABC']));
    });

    test('a filter after the scan can drop the seed', () async {
      final res = await fx([1, 2, 3])
          .toAsync()
          .scan<int>((acc, a) => acc + a, 0)
          .filter((a) => a.isOdd)
          .toList();
      expect(res, equals([1, 3]));
    });

    test('a filter before the scan skips elements, not accumulations',
        () async {
      final res = await fx([1, 2, 3, 4])
          .toAsync()
          .filter((a) => a.isEven)
          .scan<int>((acc, a) => acc + a, 0)
          .toList();
      expect(res, equals([0, 2, 6]));
    });

    test('takeWhile after the scan ends the run', () async {
      final res = await fx([1, 2, 3, 4])
          .toAsync()
          .scan<int>((acc, a) => acc + a, 1)
          .takeWhile((a) => a < 7)
          .toList();
      expect(res, equals([1, 2, 4]));
    });

    test('takeWhile rejecting the seed yields nothing', () async {
      final res = await fx([1, 2])
          .toAsync()
          .scan<int>((acc, a) => acc + a, 99)
          .takeWhile((a) => a < 10)
          .toList();
      expect(res, equals(<int>[]));
    });

    test('a second scan starts a new run over the first', () async {
      final res = await fx([1, 2])
          .toAsync()
          .scan<int>((acc, a) => acc + a, 1) // 1, 2, 4
          .scan<int>((acc, a) => acc * a, 2) // 2, 2, 4, 16
          .toList();
      expect(res, equals([2, 2, 4, 16]));
    });

    test('a Future seed is awaited before the first value', () async {
      final res = await fx([1, 2])
          .toAsync()
          .scan<int>((acc, a) => acc + a, Future.value(5))
          .map((a) => a * 10)
          .toList();
      expect(res, equals([50, 60, 80]));
    });

    test('an empty source still emits the seed', () async {
      final res =
          await fx(<int>[]).toAsync().scan<int>((acc, a) => acc + a, 7).toList();
      expect(res, equals([7]));
    });

    test('a throwing accumulator fails the terminal', () async {
      final future = fx([1, 2, 3])
          .toAsync()
          .scan<int>((acc, a) {
            if (a == 2) throw StateError('boom');
            return acc + a;
          }, 0)
          .map((a) => a)
          .toList();
      await expectLater(future, throwsStateError);
    });

    test('an async accumulator error fails the terminal', () async {
      final future = fx([1, 2, 3])
          .toAsync()
          .scan<int>((acc, a) async {
            if (a == 2) throw StateError('boom');
            return acc + a;
          }, 0)
          .toList();
      await expectLater(future, throwsStateError);
    });

    test('concurrent falls back to the unfused layering', () async {
      final sw = Stopwatch()..start();
      final res = await fx([1, 2, 3, 4, 5, 6])
          .toAsync()
          .map((a) => delay(const Duration(milliseconds: 100), a))
          .scan<int>((acc, a) => acc + a, 0)
          .concurrent(3)
          .toList();
      expect(res, equals([0, 1, 3, 6, 10, 15, 21]));
      expect(sw.elapsedMilliseconds, lessThan(500));
    });

    test('a stream source keeps the pull path when a scan is fused', () async {
      final res = await fxStream(Stream.fromIterable([1, 2, 3]))
          .scan<int>((acc, a) => acc + a, 0)
          .map((a) => a * 2)
          .toList();
      expect(res, equals([0, 2, 6, 12]));
    });

    test('each and fold see the same elements as toList', () async {
      FxAsync<int> chain() => fx([1, 2, 3])
          .toAsync()
          .scan<int>((acc, a) => acc + a, 0)
          .filter((a) => a != 3);
      final seen = <int>[];
      await chain().each(seen.add);
      expect(seen, equals([0, 1, 6]));
      expect(await chain().fold<int>(0, (acc, a) => acc + a), equals(7));
    });

    test('an async emit holds the pipeline in order', () async {
      final seen = <int>[];
      await fx([1, 2, 3])
          .toAsync()
          .scan<int>((acc, a) => acc + a, 0)
          .each((a) async {
        await Future<void>.delayed(Duration.zero);
        seen.add(a);
      });
      expect(seen, equals([0, 1, 3, 6]));
    });

    test('a Future element in the source is awaited', () async {
      final res = await toListAsync(scanAsync<int, int>((acc, a) => acc + a, 0,
          toAsync(<FutureOr<int>>[1, Future.value(2), 3])));
      expect(res, equals([0, 1, 3, 6]));
    });


    test('a sync stage throwing after an async one fails the terminal',
        () async {
      final future = fx([1, 2, 3])
          .toAsync()
          .scan<int>((acc, a) async => acc + a, 0)
          .map((a) {
            if (a == 3) throw StateError('late');
            return a;
          })
          .toList();
      await expectLater(future, throwsStateError);
    });

    test('a sync filter throwing after an async stage fails the terminal',
        () async {
      final future = fx([1, 2, 3])
          .toAsync()
          .map((a) async => a * 2)
          .filter((a) {
            if (a == 4) throw StateError('late-filter');
            return true;
          })
          .toList();
      await expectLater(future, throwsStateError);
    });

    test('a throwing emit fails the terminal', () async {
      final future = fx([1, 2, 3]).toAsync().map((a) async => a).each((a) {
        if (a == 2) throw StateError('emit');
      });
      await expectLater(future, throwsStateError);
    });

    test('a throwing source iterable fails the terminal', () async {
      Iterable<int> boom() sync* {
        yield 1;
        throw StateError('src');
      }

      final future = fx(boom())
          .toAsync()
          .scan<int>((acc, a) => acc + a, 0)
          .toList();
      await expectLater(future, throwsStateError);
    });
  });
}
