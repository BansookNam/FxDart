import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('take', () {
    group('sync', () {
      test('should be able to take the element', () {
        final res = <int>[];
        for (final item in take(1, [1, 2, 3, 4])) {
          res.add(item);
        }
        expect(res, equals([1]));

        expect(toList(take(1, [1, 2, 3, 4])), equals([1]));
        expect(toList(take(2, [1, 2, 3, 4])), equals([1, 2]));
        expect(toList(take(4, [1, 2, 3, 4])), equals([1, 2, 3, 4]));
        expect(toList(take(5, [1, 2, 3, 4])), equals([1, 2, 3, 4]));
        expect(toList(take(-1, [1, 2, 3, 4])), equals([]));
      });

      test('should be able to be used in the pipeline', () {
        final res1 = pipe([
          1,
          2,
          3,
          4
        ], [
          (v) => map((int a) => a + 10, v),
          (v) => filter((int a) => a % 2 == 0, v),
          (v) => take(2, v),
          (v) => toList(v),
        ]);

        expect(res1, equals([12, 14]));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res1 = fx([1, 2, 3, 4])
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .take(2)
            .toList();

        expect(res1, equals([12, 14]));
      });

      test('should be able to take the rest element', () {
        final it = take(5, range(1, 11)).iterator;
        it.moveNext();
        it.moveNext();
        var sum = 0;
        while (it.moveNext()) {
          sum += it.current;
        }
        expect(sum, equals(3 + 4 + 5));
      });
    });

    group('async', () {
      test('should be able to take the element', () async {
        final res = <int>[];
        final it = takeAsync(1, toAsync([1, 2, 3, 4])).iterator;
        while (true) {
          final r = await it.next();
          if (r.done) break;
          res.add(r.value);
        }
        expect(res, equals([1]));

        expect(await toListAsync(takeAsync(1, toAsync([1, 2, 3, 4]))),
            equals([1]));
        expect(await toListAsync(takeAsync(2, toAsync([1, 2, 3, 4]))),
            equals([1, 2]));
        expect(await toListAsync(takeAsync(4, toAsync([1, 2, 3, 4]))),
            equals([1, 2, 3, 4]));
        expect(await toListAsync(takeAsync(5, toAsync([1, 2, 3, 4]))),
            equals([1, 2, 3, 4]));
        expect(await toListAsync(takeAsync(-1, toAsync([1, 2, 3, 4]))),
            equals([]));
      });

      test('should be able to be used in the pipeline', () async {
        final res1 = await fxAsync(toAsync([1, 2, 3, 4]))
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .take(2)
            .toList();

        expect(res1, equals([12, 14]));
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        final res1 = await fxAsync(toAsync([1, 2, 3, 4]))
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .take(2)
            .toList();

        expect(res1, equals([12, 14]));
      });

      test('should be able to take the element concurrently', () async {
        Iterable<Future<int>> source() sync* {
          yield delay(const Duration(milliseconds: 100), 1);
          yield delay(const Duration(milliseconds: 100), 2);
          yield delay(const Duration(milliseconds: 100), 3);
          yield delay(const Duration(milliseconds: 100), 4);
          yield delay(const Duration(milliseconds: 100), 5);
        }

        final it = takeAsync(3, toAsync(source())).iterator;
        final sw = Stopwatch()..start();
        final values = await Future.wait([
          it.next().then((r) => r.value),
          it.next().then((r) => r.value),
          it.next().then((r) => r.value),
        ]);
        sw.stop();

        expect(values[0] + values[1] + values[2], equals(1 + 2 + 3));
        // Sequential would take ~300ms; overlapping pulls should be ~100ms.
        expect(sw.elapsedMilliseconds, lessThan(250));
      });
    });
  });
}
