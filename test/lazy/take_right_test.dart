import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('takeRight', () {
    group('sync', () {
      test('should be able to take the element', () {
        final res = <int>[];
        for (final item in takeRight(1, [1, 2, 3, 4])) {
          res.add(item);
        }
        expect(res, equals([4]));

        expect(toArray(takeRight(0, [1, 2, 3, 4])), equals([]));
        expect(toArray(takeRight(1, [1, 2, 3, 4])), equals([4]));
        expect(toArray(takeRight(2, [1, 2, 3, 4])), equals([3, 4]));
        expect(toArray(takeRight(3, [1, 2, 3, 4])), equals([2, 3, 4]));
        expect(toArray(takeRight(4, [1, 2, 3, 4])), equals([1, 2, 3, 4]));
        expect(toArray(takeRight(5, [1, 2, 3, 4])), equals([1, 2, 3, 4]));
      });

      test('should be able to be used in the pipeline', () {
        final res1 = pipe([
          1,
          2,
          3,
          4,
          5,
          6
        ], [
          (v) => map((int a) => a + 10, v),
          (v) => filter((int a) => a % 2 == 0, v),
          (v) => takeRight(2, v),
          (v) => toArray(v),
        ]);

        expect(res1, equals([14, 16]));
      });

      test('should be able to take the rest element', () {
        final it = takeRight(5, range(1, 11)).iterator;
        it.moveNext();
        it.moveNext();
        var sum = 0;
        while (it.moveNext()) {
          sum += it.current;
        }
        expect(sum, equals(8 + 9 + 10));
      });
    });

    group('async', () {
      test('should be able to take the element', () async {
        final res = <int>[];
        final it = takeRightAsync(1, toAsync([1, 2, 3, 4])).iterator;
        while (true) {
          final r = await it.next();
          if (r.done) break;
          res.add(r.value);
        }
        expect(res, equals([4]));

        expect(await toArrayAsync(takeRightAsync(0, toAsync([1, 2, 3, 4]))),
            equals([]));
        expect(await toArrayAsync(takeRightAsync(1, toAsync([1, 2, 3, 4]))),
            equals([4]));
        expect(await toArrayAsync(takeRightAsync(2, toAsync([1, 2, 3, 4]))),
            equals([3, 4]));
        expect(await toArrayAsync(takeRightAsync(3, toAsync([1, 2, 3, 4]))),
            equals([2, 3, 4]));
        expect(await toArrayAsync(takeRightAsync(4, toAsync([1, 2, 3, 4]))),
            equals([1, 2, 3, 4]));
        expect(await toArrayAsync(takeRightAsync(5, toAsync([1, 2, 3, 4]))),
            equals([1, 2, 3, 4]));
      });

      test('should be able to be used in the pipeline', () async {
        final res1 = await fxAsync(toAsync([1, 2, 3, 4, 5, 6]))
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .takeRight(2)
            .toArray();

        expect(res1, equals([14, 16]));
      });

      test('should be able to take the element concurrently', () async {
        final sw = Stopwatch()..start();
        final res = await fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]))
            .map((a) => delay(const Duration(milliseconds: 100), a))
            .filter((a) => a % 2 == 0)
            .takeRight(3)
            .concurrent(3)
            .toArray();
        sw.stop();

        expect(res, equals([6, 8, 10]));
        // Sequential would be ~1000ms; concurrent(3) should be ~400ms.
        expect(sw.elapsedMilliseconds, lessThan(800));
      });
    });
  });
}
