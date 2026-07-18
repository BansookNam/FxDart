import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

import 'util.dart';

bool mod(int a) => a % 2 == 0;
Future<bool> modAsync(int a) async => a % 2 == 0;

void main() {
  group('filter', () {
    group('sync', () {
      test('should be filtered by the callback', () {
        final res = [...filter(mod, range(1, 10))];
        expect(res, equals([2, 4, 6, 8]));
      });

      test('should be able to handle an error', () {
        expect(
          () => toArray(filter<int>((a) => throw 'err', range(1, 10))),
          throwsA(equals('err')),
        );
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe([
          1,
          2,
          3,
          4
        ], [
          (v) => filter((int a) => a % 2 == 0, v),
          (v) => toArray(v),
        ]);

        expect(res, equals([2, 4]));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res = fx([1, 2, 3, 4]).filter((a) => a % 2 == 0).toArray();

        expect(res, equals([2, 4]));
      });
    });

    group('async', () {
      test('should be filtered by the callback', () async {
        final res = <int>[];
        final it = filterAsync(modAsync, toAsync(range(1, 10))).iterator;
        while (true) {
          final r = await it.next();
          if (r.done) break;
          res.add(r.value);
        }
        expect(res, equals([2, 4, 6, 8]));
      });

      test('should be able to handle an error', () async {
        await expectLater(
          toArrayAsync(
              filterAsync<int>((a) => throw 'err', toAsync(range(1, 10)))),
          throwsA(equals('err')),
        );
      });

      test(
          'should be able to handle an error when the callback is asynchronous',
          () async {
        await expectLater(
          toArrayAsync(filterAsync<int>(
              (a) => Future<bool>.error(Exception('err')),
              toAsync(range(1, 10)))),
          throwsException,
        );
      });

      test('should be able to handle an error when working concurrent',
          () async {
        await expectLater(
          fxAsync(toAsync(range(1, 51)))
              .filter((a) {
                if (a == 7) throw 'err';
                return a % 2 == 0;
              })
              .concurrent(5)
              .toArray(),
          throwsA(equals('err')),
        );
      });

      test('should be filtered by callback concurrently', () async {
        final sw = Stopwatch()..start();
        final res = await fxAsync(toAsync(range(1, 21)))
            .filter((a) => delay(const Duration(milliseconds: 100), a % 2 == 0))
            .concurrent(10)
            .toArray();
        sw.stop();

        expect(res, equals([2, 4, 6, 8, 10, 12, 14, 16, 18, 20]));
        // Sequential would take ~2000ms; concurrent(10) should be ~200ms.
        expect(sw.elapsedMilliseconds, lessThan(1200));
      });

      test("should be able to call with 'next'", () async {
        final res = fxAsync(toAsync(range(1, 20)))
            .map((a) => delay(const Duration(milliseconds: 50), a))
            .filter((a) => a % 2 == 0 || a % 3 == 0)
            .concurrent(2);

        final it = res.iterator;
        final v1 = (await it.next()).value;
        final v2 = (await it.next()).value;
        final v3 = (await it.next()).value;
        final v4 = (await it.next()).value;
        final v5 = (await it.next()).value;

        expect(v1 + v2 + v3 + v4 + v5, equals(2 + 3 + 4 + 6 + 8));
      });

      test('should be empty when all elements are filtered', () async {
        final res = await fxAsync(toAsync(range(1, 20)))
            .filter((a) => delay(const Duration(milliseconds: 20), false))
            .concurrent(2)
            .toArray();
        expect(res, equals([]));
      });

      test('should be having all elements when all elements are not filtered',
          () async {
        final res = await fxAsync(toAsync(range(1, 20)))
            .filter((a) => delay(const Duration(milliseconds: 20), true))
            .concurrent(2)
            .toArray();

        expect(
            res,
            equals([
              1,
              2,
              3,
              4,
              5,
              6,
              7,
              8,
              9,
              10,
              11,
              12,
              13,
              14,
              15,
              16,
              17,
              18,
              19
            ]));
      });

      test(
          "should be filtered by the callback 'take' - 'filter' - 'concurrent'",
          () async {
        final res = await fxAsync(toAsync(range(1, 21)))
            .take(10)
            .filter((a) => delay(const Duration(milliseconds: 50), a % 2 == 0))
            .concurrent(5)
            .toArray();

        expect(res, equals([2, 4, 6, 8, 10]));
      });

      test(
          "should be filtered by the callback 'filter' - 'take' - 'concurrent'",
          () async {
        final res = await fxAsync(toAsync(range(1, 51)))
            .filter((a) => delay(const Duration(milliseconds: 50), a % 2 == 0))
            .take(10)
            .concurrent(10)
            .toArray();

        expect(res, equals([2, 4, 6, 8, 10, 12, 14, 16, 18, 20]));
      });

      test("should be filtered by the callback 'map' - 'filter' - 'concurrent'",
          () async {
        final res = await fxAsync(toAsync(range(1, 21)))
            .map((a) => delay(const Duration(milliseconds: 50), a + 10))
            .filter((a) => a % 2 == 0)
            .concurrent(10)
            .toArray();

        expect(res, equals([12, 14, 16, 18, 20, 22, 24, 26, 28, 30]));
      });

      test(
          "should be filtered by the callback 'map' - 'filter' - 'concurrent' - 'take'",
          () async {
        final res = await fxAsync(toAsync(range(1, 10)))
            .map((a) => delay(const Duration(milliseconds: 50), a))
            .filter((a) => a > 0)
            .concurrent(5)
            .take(8)
            .toArray();

        expect(res, equals([...range(1, 9)]));
      });

      test(
          'should be able to handle an error when the callback is asynchronous',
          () async {
        await expectLater(
          fxAsync(toAsync(range(1, 1000)))
              .map((a) => delay(const Duration(milliseconds: 50), a + 10))
              .filter((a) {
                if (a == 14) throw Exception('err');
                return a > 20;
              })
              .concurrent(2)
              .toArray(),
          throwsException,
        );
      });

      test('should be able to handle errors when the callback is asynchronous',
          () async {
        await expectLater(
          fxAsync(toAsync(range(1, 1000)))
              .map<int>((a) async {
                await delay(const Duration(milliseconds: 50), a);
                throw Exception('err');
              })
              .filter((a) => a % 2 == 0)
              .concurrent(4)
              .toArray(),
          throwsException,
        );
      });

      test('should be able to be used in the pipeline', () async {
        final res = await toArrayAsync(
            filterAsync((a) => a % 2 == 0, toAsync([1, 2, 3, 4])));

        expect(res, equals([2, 4]));
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        final res = await fxAsync(toAsync([1, 2, 3, 4]))
            .filter((a) => a % 2 == 0)
            .toArray();

        expect(res, equals([2, 4]));
      });

      test(
          "should be consumed 'AsyncIterable' as many times as called with 'next'",
          () async {
        final source = SharedAsyncIterable(toAsync(range(1, 21)));
        final res = fxAsync(source)
            .map((a) => delay(const Duration(milliseconds: 50), a))
            .filter((a) => a % 2 == 0)
            .concurrent(3);

        final it = res.iterator;
        final v1 = (await it.next()).value;
        final v2 = (await it.next()).value;
        final v3 = (await it.next()).value;
        final v4 = (await it.next()).value;
        final v5 = (await it.next()).value;
        expect(v1, equals(2));
        expect(v2, equals(4));
        expect(v3, equals(6));
        expect(v4, equals(8));
        expect(v5, equals(10));
      });
    });
  });
}
