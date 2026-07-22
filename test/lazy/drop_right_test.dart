import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('dropRight', () {
    group('sync', () {
      test('should be discarded elements by length', () {
        final acc = <int>[];
        for (final a in dropRight(2, [1, 2, 3, 4, 5])) {
          acc.add(a);
        }
        expect(acc, equals([1, 2, 3]));

        expect(toList(dropRight(0, [1, 2, 3, 4, 5])), equals([1, 2, 3, 4, 5]));
      });

      test('should be discarded string by length', () {
        final acc = <String>[];
        for (final a in dropRight(2, 'abcde'.split(''))) {
          acc.add(a);
        }
        expect(acc, equals(['a', 'b', 'c']));
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
          (v) => dropRight(2, v),
          (v) => toList(v),
        ]);

        expect(res, equals([12, 14]));
      });
    });

    group('async', () {
      test('should be discarded elements by length', () async {
        final acc = <int>[];
        final it = dropRightAsync(2, toAsync([1, 2, 3, 4, 5])).iterator;
        while (true) {
          final r = await it.next();
          if (r.done) break;
          acc.add(r.value);
        }
        expect(acc, equals([1, 2, 3]));

        expect(await toListAsync(dropRightAsync(0, toAsync([1, 2, 3, 4, 5]))),
            equals([1, 2, 3, 4, 5]));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8]))
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .dropRight(2)
            .toList();

        expect(res, equals([12, 14]));
      });

      test('should be discarded elements by length concurrently', () async {
        final sw = Stopwatch()..start();
        final res = await fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]))
            .map((a) => delay(const Duration(milliseconds: 100), a))
            .filter((a) => a % 2 == 0)
            .dropRight(2)
            .concurrent(3)
            .toList();
        sw.stop();

        expect(res, equals([2, 4, 6]));
        // Sequential would be ~1000ms; concurrent(3) should be ~400ms.
        expect(sw.elapsedMilliseconds, lessThan(800));
      });

      test('should be able to handle an error when asynchronous', () async {
        await expectLater(
          fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]))
              .filter((a) => throw Exception('err'))
              .dropRight(2)
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
              .dropRight(2)
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
              .dropRight(2)
              .concurrent(3)
              .toList(),
          throwsException,
        );
      });
    });
  });
}
