import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('dropWhile', () {
    group('sync', () {
      test(
          'should be dropped elements until the value applied to callback returns falsey',
          () {
        final acc = <int>[];
        for (final a in dropWhile((a) => a < 3, [1, 2, 3, 1, 5])) {
          acc.add(a);
        }
        expect(acc, equals([3, 1, 5]));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe([
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8
        ], [
          (v) => map((int a) => a + 10, v),
          (v) => filter((int a) => a % 2 == 0, v),
          (v) => dropWhile((int a) => a < 16, v),
          (v) => toArray(v),
        ]);

        expect(res, equals([16, 18]));
      });
    });

    group('async', () {
      test(
          'should be dropped elements until the value applied to callback returns falsey',
          () async {
        final acc = <int>[];
        final it =
            dropWhileAsync((a) => a < 3, toAsync([1, 2, 3, 1, 5])).iterator;
        while (true) {
          final r = await it.next();
          if (r.done) break;
          acc.add(r.value);
        }
        expect(acc, equals([3, 1, 5]));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8]))
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .dropWhile((a) => a < 16)
            .toArray();

        expect(res, equals([16, 18]));
      });

      test('should be able to handle an error when asynchronous', () async {
        await expectLater(
          fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])).dropWhile((a) {
            if (a > 5) throw Exception('err');
            return true;
          }).toArray(),
          throwsException,
        );
      });

      test('should be dropped elements concurrently', () async {
        final sw = Stopwatch()..start();
        final res = await fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]))
            .map((a) => delay(const Duration(milliseconds: 100), a))
            .filter((a) => a % 2 == 0)
            .dropWhile((a) => a < 6)
            .concurrent(3)
            .toArray();
        sw.stop();

        expect(res, equals([6, 8, 10]));
        // Sequential would be ~1000ms; concurrent(3) should be ~400ms.
        expect(sw.elapsedMilliseconds, lessThan(800));
      });

      test('should be controlled the order when concurrency', () async {
        Iterable<Future<int>> source() sync* {
          yield delay(const Duration(milliseconds: 100), 1);
          yield delay(const Duration(milliseconds: 90), 2);
          yield delay(const Duration(milliseconds: 80), 3);
          yield delay(const Duration(milliseconds: 70), 4);
          yield delay(const Duration(milliseconds: 60), 5);
          yield delay(const Duration(milliseconds: 100), 6);
          yield delay(const Duration(milliseconds: 90), 7);
          yield delay(const Duration(milliseconds: 80), 8);
          yield delay(const Duration(milliseconds: 70), 1);
          yield delay(const Duration(milliseconds: 60), 10);
        }

        final res = await fxAsync(toAsync(source()))
            .dropWhile((a) => a < 7)
            .concurrent(5)
            .toArray();
        expect(res, equals([7, 8, 1, 10]));
      });

      test('should be able to handle an error when working concurrent',
          () async {
        await expectLater(
          fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]))
              .dropWhile((a) {
                if (a > 5) throw Exception('err');
                return true;
              })
              .concurrent(3)
              .toArray(),
          throwsException,
        );
      });

      test(
          'should be able to handle an error when working concurrent - Future.error',
          () async {
        await expectLater(
          fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]))
              .dropWhile((a) {
                if (a > 5) return Future<bool>.error(Exception('err'));
                return true;
              })
              .concurrent(3)
              .toArray(),
          throwsException,
        );
      });
    });
  });
}
