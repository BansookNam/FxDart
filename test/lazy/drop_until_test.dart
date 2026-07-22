import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('dropUntil', () {
    group('sync', () {
      test(
          'should be dropped elements until the value applied to callback returns truly',
          () {
        final arr = [1, 2, 3, 4, 5, 1, 2];
        final acc = <int>[];
        for (final a in dropUntil((a) => a > 3, arr)) {
          acc.add(a);
        }
        expect(acc, equals([5, 1, 2]));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe([
          1,
          2,
          3,
          4,
          5,
          1,
          2
        ], [
          (v) => map((int a) => a + 10, v),
          (v) => filter((int a) => a % 2 == 1, v),
          (v) => dropUntil((int a) => a > 13, v),
          (v) => toList(v),
        ]);

        expect(res, equals([11]));
      });
    });

    group('async', () {
      test(
          'should be dropped elements until the value applied to callback returns truly',
          () async {
        final arr = [1, 2, 3, 4, 5, 1, 2];
        final acc = <int>[];
        final it = dropUntilAsync((a) => a > 3, toAsync(arr)).iterator;
        while (true) {
          final r = await it.next();
          if (r.done) break;
          acc.add(r.value);
        }
        expect(acc, equals([5, 1, 2]));
      });

      test(
          'should be dropped elements until the value applied to async callback returns truly',
          () async {
        final arr = [1, 2, 3, 4, 5, 1, 2];
        final acc = await toListAsync(
            dropUntilAsync((a) async => a > 3, toAsync(arr)));
        expect(acc, equals([5, 1, 2]));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await fxAsync(toAsync([1, 2, 3, 4, 5, 1, 2]))
            .map((a) => a + 10)
            .filter((a) => a % 2 == 1)
            .dropUntil((a) => a > 13)
            .toList();

        expect(res, equals([11]));
      });

      test('should be able to handle an error when asynchronous', () async {
        await expectLater(
          fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])).dropUntil((a) {
            if (a > 5) throw Exception('err');
            return false;
          }).toList(),
          throwsException,
        );
      });

      test('should be dropped elements concurrently', () async {
        final sw = Stopwatch()..start();
        final res = await fxAsync(toAsync([1, 2, 3, 4, 5, 1, 2]))
            .map((a) => delay(const Duration(milliseconds: 100), a + 10))
            .filter((a) => a % 2 == 1)
            .dropUntil((a) => a > 13)
            .concurrent(3)
            .toList();
        sw.stop();

        expect(res, equals([11]));
        // Sequential would be ~700ms; concurrent(3) should be ~300ms.
        expect(sw.elapsedMilliseconds, lessThan(600));
      });

      test('should be controlled the order when concurrency', () async {
        Iterable<Future<int>> source() sync* {
          yield delay(const Duration(milliseconds: 100), 1);
          yield delay(const Duration(milliseconds: 90), 2);
          yield delay(const Duration(milliseconds: 80), 3);
          yield delay(const Duration(milliseconds: 70), 4);
          yield delay(const Duration(milliseconds: 60), 5);
          yield delay(const Duration(milliseconds: 100), 11);
          yield delay(const Duration(milliseconds: 90), 12);
          yield delay(const Duration(milliseconds: 80), 13);
          yield delay(const Duration(milliseconds: 70), 8);
          yield delay(const Duration(milliseconds: 60), 9);
        }

        final res = await fxAsync(toAsync(source()))
            .dropUntil((a) => a > 12)
            .concurrent(5)
            .toList();
        expect(res, equals([8, 9]));
      });

      test('should be able to handle an error when working concurrent',
          () async {
        await expectLater(
          fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]))
              .dropUntil((a) {
                if (a > 5) throw Exception('err');
                return false;
              })
              .concurrent(3)
              .toList(),
          throwsException,
        );
      });

      test(
          'should be able to handle an error when working concurrent - Future.error',
          () async {
        await expectLater(
          fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]))
              .dropUntil((a) {
                if (a > 5) return Future<bool>.error(Exception('err'));
                return false;
              })
              .concurrent(3)
              .toList(),
          throwsException,
        );
      });
    });
  });
}
