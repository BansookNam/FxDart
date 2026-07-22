import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('takeWhile', () {
    group('sync', () {
      test(
          'should be able to take the element while the callback result is truthy',
          () {
        final res = <int>[];
        for (final item in takeWhile((a) => a < 3, [1, 2, 3, 4])) {
          res.add(item);
        }
        expect(res, equals([1, 2]));

        final res1 = toList(takeWhile((a) => a > 10, [1, 2, 3, 4]));
        expect(res1, equals([]));

        final res2 = toList(takeWhile((a) => a > 0, [1, 2, 3, 4]));
        expect(res2, equals([1, 2, 3, 4]));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe(range(1, 20), [
          (v) => map((int a) => a + 10, v),
          (v) => filter((int a) => a % 2 == 0, v),
          (v) => takeWhile((int a) => a < 20, v),
          (v) => toList(v),
        ]);

        expect(res, equals([12, 14, 16, 18]));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res = fx(range(1, 20))
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .takeWhile((a) => a < 20)
            .toList();

        expect(res, equals([12, 14, 16, 18]));
      });
    });

    group('async', () {
      test(
          'should be able to take the element while the callback result is truthy',
          () async {
        final res = <int>[];
        final it = takeWhileAsync((a) => a < 3, toAsync([1, 2, 3, 4])).iterator;
        while (true) {
          final r = await it.next();
          if (r.done) break;
          res.add(r.value);
        }
        expect(res, equals([1, 2]));

        final res1 = await toListAsync(
            takeWhileAsync((a) => a > 10, toAsync([1, 2, 3, 4])));
        expect(res1, equals([]));

        final res2 = await toListAsync(
            takeWhileAsync((a) => a > 0, toAsync([1, 2, 3, 4])));
        expect(res2, equals([1, 2, 3, 4]));
      });

      test(
          'should be able to take the element while the async callback result is truthy',
          () async {
        final res = await toListAsync(
            takeWhileAsync((a) async => a < 3, toAsync([1, 2, 3, 4])));
        expect(res, equals([1, 2]));

        final res1 = await toListAsync(
            takeWhileAsync((a) async => a > 10, toAsync([1, 2, 3, 4])));
        expect(res1, equals([]));

        final res2 = await toListAsync(
            takeWhileAsync((a) async => a > 0, toAsync([1, 2, 3, 4])));
        expect(res2, equals([1, 2, 3, 4]));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await fxAsync(toAsync(range(1, 20)))
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .takeWhile((a) => a < 20)
            .toList();

        expect(res, equals([12, 14, 16, 18]));
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        final res = await fx(range(1, 20))
            .toAsync()
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .takeWhile((a) => a < 20)
            .toList();

        expect(res, equals([12, 14, 16, 18]));
      });

      test(
          "should be consumed 'AsyncIterable' as many times as called with 'next'",
          () async {
        final res = fxAsync(toAsync(range(1, 500)))
            .map((a) => delay(const Duration(milliseconds: 50), a + 10))
            .takeWhile((a) => a < 16)
            .concurrent(2);

        final it = res.iterator;
        final r1 = await it.next();
        final r2 = await it.next();
        final r3 = await it.next();
        final r4 = await it.next();
        final r5 = await it.next();
        final r6 = await it.next();
        final r7 = await it.next();

        expect(r1.value + r2.value + r3.value + r4.value + r5.value,
            equals(11 + 12 + 13 + 14 + 15));
        expect(r6.done, isTrue);
        expect(r7.done, isTrue);
      });

      test('should be able to take the element concurrently', () async {
        final sw = Stopwatch()..start();
        final res = await fxAsync(toAsync(range(1, 500)))
            .map((a) => delay(const Duration(milliseconds: 50), a + 10))
            .filter((a) => a % 2 == 0)
            .takeWhile((a) => a < 22)
            .concurrent(2)
            .toList();
        sw.stop();

        expect(res, equals([12, 14, 16, 18, 20]));
        // Sequential over ~12 pulls would be ~600ms; concurrent(2) ~300ms.
        expect(sw.elapsedMilliseconds, lessThan(500));
      });
    });
  });
}
