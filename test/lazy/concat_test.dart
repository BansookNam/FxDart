import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

import 'concurrent_mock.dart';

void main() {
  group('concat', () {
    group('sync', () {
      test("should be concatenated given two 'Iterable'", () {
        expect(
          fxToList(fxConcat([1, 2, 3], [4, 5, 6])),
          equals([1, 2, 3, 4, 5, 6]),
        );
      });

      test('should be able to be used in the pipeline', () {
        final res = fx([1, 2, 3]).concat([4, 5, 6]).toList();
        expect(res, equals([1, 2, 3, 4, 5, 6]));
      });
    });

    group('async', () {
      test("should be concatenated given two 'AsyncIterable'", () async {
        final a = fxMapAsync(
          (int x) => fxDelay(const Duration(milliseconds: 50), x),
          fxToAsync([1, 2]),
        );
        final b = fxMapAsync(
          (int x) => fxDelay(const Duration(milliseconds: 50), x),
          fxToAsync([3, 4]),
        );
        final res = await fxToListAsync(fxConcatAsync(a, b));
        expect(res, equals([1, 2, 3, 4]));
      });

      test(
        "should be concatenated given two 'AsyncIterable' concurrently",
        () async {
          final a = fxMapAsync(
            (int x) => fxDelay(const Duration(milliseconds: 100), x),
            fxToAsync([1, 2, 3]),
          );
          final b = fxMapAsync(
            (int x) => fxDelay(const Duration(milliseconds: 100), x),
            fxToAsync([4, 5, 6]),
          );
          final sw = Stopwatch()..start();
          final res = await fxToListAsync(
            fxConcurrentAsync(2, fxConcatAsync(a, b)),
          );
          expect(res, equals([1, 2, 3, 4, 5, 6]));
          // sequential is ~600ms; concurrent(2) should be ~300ms
          expect(sw.elapsedMilliseconds, lessThan(500));
        },
      );

      test(
        "should be concatenated given 'Iterable' and 'AsyncIterable'",
        () async {
          final res1 = await fxToListAsync(
            fxConcatAsync(fxToAsync([1, 2, 3]), fxToAsync([4, 5, 6])),
          );
          expect(res1, equals([1, 2, 3, 4, 5, 6]));

          final res2 = await fx([
            1,
            2,
            3,
          ]).toAsync().concat(fxToAsync([4, 5, 6])).toList();
          expect(res2, equals([1, 2, 3, 4, 5, 6]));
        },
      );

      test(
        'should be passed concurrent object when job works concurrently',
        () async {
          final mock = ConcurrentMock<int>();
          final it = fxConcatAsync(mock, fxToAsync([1, 2, 3])).iterator;
          final concurrent = Concurrent.of(2);
          await it.next(concurrent);
          expect(mock.received, same(concurrent));
        },
      );
    });
  });
}
