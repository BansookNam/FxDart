import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('drop', () {
    group('sync', () {
      test('should be discarded elements by length', () {
        final acc = <int>[];
        for (final a in drop(2, [1, 2, 3, 4, 5])) {
          acc.add(a);
        }
        expect(acc, equals([3, 4, 5]));
        expect(toList(drop(0, [1, 2, 3, 4, 5])), equals([1, 2, 3, 4, 5]));
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
          (v) => drop(2, v),
          (v) => toList(v),
        ]);

        expect(res, equals([16, 18]));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res = fx([1, 2, 3, 4, 5, 6, 7, 8])
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .drop(2)
            .toList();

        expect(res, equals([16, 18]));
      });
    });

    group('async', () {
      test('should be discarded elements by length', () async {
        final acc = <int>[];
        final it = dropAsync(2, toAsync([1, 2, 3, 4, 5])).iterator;
        while (true) {
          final r = await it.next();
          if (r.done) break;
          acc.add(r.value);
        }
        expect(acc, equals([3, 4, 5]));

        expect(await toListAsync(dropAsync(0, toAsync([1, 2, 3, 4, 5]))),
            equals([1, 2, 3, 4, 5]));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8]))
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .drop(2)
            .toList();

        expect(res, equals([16, 18]));
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        final res = await fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8]))
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .drop(2)
            .toList();

        expect(res, equals([16, 18]));
      });

      test('should be discarded elements by length concurrently', () async {
        final sw = Stopwatch()..start();
        final res = await fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]))
            .map((a) => delay(const Duration(milliseconds: 100), a))
            .filter((a) => a % 2 == 0)
            .drop(2)
            .concurrent(3)
            .toList();
        sw.stop();

        expect(res, equals([6, 8, 10]));
        // Sequential would be ~1000ms; concurrent(3) should be ~400ms.
        expect(sw.elapsedMilliseconds, lessThan(800));
      });

      test('should be able to handle an error when asynchronous', () async {
        await expectLater(
          fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]))
              .filter((a) => throw Exception('err'))
              .drop(2)
              .toList(),
          throwsException,
        );
      });

      test('should be able to handle an error when working concurrent',
          () async {
        await expectLater(
          fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]))
              .filter((a) {
                if (a == 1) throw Exception('err');
                return true;
              })
              .drop(2)
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
              .map((a) {
                if (a < 3) return Future<int>.error(Exception('err'));
                return a;
              })
              .drop(2)
              .concurrent(3)
              .toList(),
          throwsException,
        );
      });
    });
  });
}
