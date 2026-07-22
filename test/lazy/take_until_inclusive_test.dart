import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('takeUntilInclusive', () {
    group('sync', () {
      test(
          'should be able to take the element until the callback result is truthy',
          () {
        final res = <int>[];
        for (final item
            in takeUntilInclusive((a) => a % 2 == 0, [1, 2, 3, 4])) {
          res.add(item);
        }
        expect(res, equals([1, 2]));

        final res1 =
            toList(takeUntilInclusive((a) => a % 2 == 0, [1, 2, 3, 4]));
        expect(res1, equals([1, 2]));

        final res2 = toList(takeUntilInclusive((a) => a > 5, [1, 2, 3, 4]));
        expect(res2, equals([1, 2, 3, 4]));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe([
          1,
          2,
          3,
          4
        ], [
          (v) => map((int a) => a + 10, v),
          (v) => filter((int a) => a % 2 == 0, v),
          (v) => takeUntilInclusive((int a) => a > 12, v),
          (v) => toList(v),
        ]);

        expect(res, equals([12, 14]));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res = fx([1, 2, 3, 4])
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .takeUntilInclusive((a) => a > 12)
            .toList();

        expect(res, equals([12, 14]));
      });
    });

    group('async', () {
      test(
          'should be able to take the element until the callback result is truthy',
          () async {
        final res = <int>[];
        final it =
            takeUntilInclusiveAsync((a) => a % 2 == 0, toAsync([1, 2, 3, 4]))
                .iterator;
        while (true) {
          final r = await it.next();
          if (r.done) break;
          res.add(r.value);
        }
        expect(res, equals([1, 2]));

        final res1 = await toListAsync(
            takeUntilInclusiveAsync((a) => a % 2 == 0, toAsync([1, 2, 3, 4])));
        expect(res1, equals([1, 2]));

        final res2 = await toListAsync(
            takeUntilInclusiveAsync((a) => a > 5, toAsync([1, 2, 3, 4])));
        expect(res2, equals([1, 2, 3, 4]));
      });

      test(
          'should be able to take the element until the async callback result is truthy',
          () async {
        final res1 = await toListAsync(takeUntilInclusiveAsync(
            (a) async => a % 2 == 0, toAsync([1, 2, 3, 4])));
        expect(res1, equals([1, 2]));

        final res2 = await toListAsync(
            takeUntilInclusiveAsync((a) async => a > 5, toAsync([1, 2, 3, 4])));
        expect(res2, equals([1, 2, 3, 4]));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await fxAsync(toAsync([1, 2, 3, 4]))
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .takeUntilInclusive((a) => a > 12)
            .toList();

        expect(res, equals([12, 14]));
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        final res = await fxAsync(toAsync([1, 2, 3, 4]))
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .takeUntilInclusive((a) => a > 12)
            .toList();

        expect(res, equals([12, 14]));
      });

      test('should be able to take the element (lazily pulls the source)',
          () async {
        var peeked = 0;
        final res = await fxAsync(toAsync([3, 3, 1, 0, 0]))
            .peek((a) => peeked++)
            .map((a) => delay(const Duration(milliseconds: 50), a))
            .takeUntilInclusive((a) => a < 3)
            .toList();

        expect(peeked, equals(3));
        expect(res, equals([3, 3, 1]));
      });

      test(
          'should be able to take the element until the callback result is truthy concurrently',
          () async {
        final res = await fxAsync(toAsync(range(1, 20)))
            .takeUntilInclusive((a) => a > 12)
            .concurrent(4)
            .toList();

        expect(res, equals([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]));
      });

      test(
          "should be consumed 'AsyncIterable' as many times as called with 'next'",
          () async {
        final res = fxAsync(toAsync(range(1, 500)))
            .map((a) => delay(const Duration(milliseconds: 50), a + 10))
            .takeUntilInclusive((a) => a > 14)
            .concurrent(2);

        final it = res.iterator;
        final r1 = await it.next();
        final r2 = await it.next();
        final r3 = await it.next();
        final r4 = await it.next();
        final r5 = await it.next();
        final r6 = await it.next();

        expect(r1.value + r2.value + r3.value + r4.value + r5.value,
            equals(11 + 12 + 13 + 14 + 15));
        expect(r6.done, isTrue);
      });

      test('should be consumed concurrently', () async {
        final res = await fxAsync(toAsync(range(1, 500)))
            .map((a) => delay(const Duration(milliseconds: 50), a + 10))
            .filter((a) => a % 2 == 0)
            .takeUntilInclusive((a) => a > 20)
            .concurrent(2)
            .toList();
        expect(res, equals([12, 14, 16, 18, 20, 22]));
      });

      test('should be able to handle an error when asynchronous', () async {
        await expectLater(
          fxAsync(toAsync(naturals()))
              .map((a) => delay(const Duration(milliseconds: 20), a + 10))
              .filter((a) => a % 2 == 0)
              .takeUntilInclusive((a) {
                if (a > 15) throw Exception('err');
                return false;
              })
              .concurrent(5)
              .toList(),
          throwsException,
        );
      });

      test('should be controlled the order when concurrency', () async {
        Iterable<Future<int>> source() sync* {
          yield delay(const Duration(milliseconds: 100), 1);
          yield delay(const Duration(milliseconds: 80), 2);
          yield delay(const Duration(milliseconds: 60), 3);
          yield delay(const Duration(milliseconds: 40), 4);
          yield delay(const Duration(milliseconds: 20), 5);
          yield delay(const Duration(milliseconds: 100), 6);
          yield delay(const Duration(milliseconds: 80), 7);
          yield delay(const Duration(milliseconds: 60), 8);
          yield delay(const Duration(milliseconds: 40), 9);
        }

        final res = await fxAsync(toAsync(source()))
            .takeUntilInclusive((a) => a > 8)
            .concurrent(5)
            .toList();
        expect(res, equals([1, 2, 3, 4, 5, 6, 7, 8, 9]));
      });
    });
  });
}
