import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('dropWhile', () {
    group('sync', () {
      test(
        'should be dropped elements until the value applied to callback returns falsey',
        () {
          final acc = <int>[];
          for (final a in fxDropWhile((a) => a < 3, [1, 2, 3, 1, 5])) {
            acc.add(a);
          }
          expect(acc, equals([3, 1, 5]));
        },
      );

      test('should be able to be used in the pipeline', () {
        final res = pipe(
          [1, 2, 3, 4, 5, 6, 7, 8],
          [
            (v) => fxMap((int a) => a + 10, v),
            (v) => fxFilter((int a) => a % 2 == 0, v),
            (v) => fxDropWhile((int a) => a < 16, v),
            (v) => fxToList(v),
          ],
        );

        expect(res, equals([16, 18]));
      });
    });

    group('async', () {
      test(
        'should be dropped elements until the value applied to callback returns falsey',
        () async {
          final acc = <int>[];
          final it = fxDropWhileAsync(
            (a) => a < 3,
            fxToAsync([1, 2, 3, 1, 5]),
          ).iterator;
          while (true) {
            final r = await it.next();
            if (r.done) break;
            acc.add(r.value);
          }
          expect(acc, equals([3, 1, 5]));
        },
      );

      test('should be able to be used in the pipeline', () async {
        final res = await fxAsync(fxToAsync([1, 2, 3, 4, 5, 6, 7, 8]))
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .dropWhile((a) => a < 16)
            .toList();

        expect(res, equals([16, 18]));
      });

      test('should be able to handle an error when asynchronous', () async {
        await expectLater(
          fxAsync(fxToAsync([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])).dropWhile((a) {
            if (a > 5) throw Exception('err');
            return true;
          }).toList(),
          throwsException,
        );
      });

      test('should be dropped elements concurrently', () async {
        final sw = Stopwatch()..start();
        final res = await fxAsync(fxToAsync([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]))
            .map((a) => fxDelay(const Duration(milliseconds: 100), a))
            .filter((a) => a % 2 == 0)
            .dropWhile((a) => a < 6)
            .concurrent(3)
            .toList();
        sw.stop();

        expect(res, equals([6, 8, 10]));
        // Sequential would be ~1000ms; concurrent(3) should be ~400ms.
        expect(sw.elapsedMilliseconds, lessThan(800));
      });

      test('should be controlled the order when concurrency', () async {
        Iterable<Future<int>> source() sync* {
          yield fxDelay(const Duration(milliseconds: 100), 1);
          yield fxDelay(const Duration(milliseconds: 90), 2);
          yield fxDelay(const Duration(milliseconds: 80), 3);
          yield fxDelay(const Duration(milliseconds: 70), 4);
          yield fxDelay(const Duration(milliseconds: 60), 5);
          yield fxDelay(const Duration(milliseconds: 100), 6);
          yield fxDelay(const Duration(milliseconds: 90), 7);
          yield fxDelay(const Duration(milliseconds: 80), 8);
          yield fxDelay(const Duration(milliseconds: 70), 1);
          yield fxDelay(const Duration(milliseconds: 60), 10);
        }

        final res = await fxAsync(
          fxToAsync(source()),
        ).dropWhile((a) => a < 7).concurrent(5).toList();
        expect(res, equals([7, 8, 1, 10]));
      });

      test(
        'should be able to handle an error when working concurrent',
        () async {
          await expectLater(
            fxAsync(fxToAsync([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]))
                .dropWhile((a) {
                  if (a > 5) throw Exception('err');
                  return true;
                })
                .concurrent(3)
                .toList(),
            throwsException,
          );
        },
      );

      test(
        'should be able to handle an error when working concurrent - Future.error',
        () async {
          await expectLater(
            fxAsync(fxToAsync([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]))
                .dropWhile((a) {
                  if (a > 5) return Future<bool>.error(Exception('err'));
                  return true;
                })
                .concurrent(3)
                .toList(),
            throwsException,
          );
        },
      );
    });
  });
}
