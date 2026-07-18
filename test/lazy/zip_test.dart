import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

import 'concurrent_mock.dart';

void main() {
  group('zip', () {
    group('sync', () {
      test(
          "should be merged values of each 'Iterable' with value at the corresponding position",
          () {
        final res = toArray(zip([1, 2, 3, 4], [5, 6, 7, 8]));
        expect(res, equals([(1, 5), (2, 6), (3, 7), (4, 8)]));
      });

      test('should be zipped if the iterables have different size', () {
        final res1 = toArray(zip([1, 2, 3, 4], [5, 6, 7, 8, 9]));
        expect(res1, equals([(1, 5), (2, 6), (3, 7), (4, 8)]));

        final res2 = toArray(zip([1, 2, 3, 4, 5], [6, 7, 8, 9]));
        expect(res2, equals([(1, 6), (2, 7), (3, 8), (4, 9)]));
      });

      test('should be able to be used in the pipeline', () {
        final res = fx([1, 2, 3, 4])
            .zip([5, 6, 7, 8])
            .map((r) => [r.$1 + r.$2])
            .toArray();
        expect(
            res,
            equals([
              [6],
              [8],
              [10],
              [12]
            ]));
      });

      test("should be zipped each 'Iterable' having a different type", () {
        final res = fx(['a', 'b', 'c', 'd'])
            .zip([1, 2, 3, 4])
            .map((r) => {r.$1: r.$2})
            .toArray();
        expect(
            res,
            equals([
              {'a': 1},
              {'b': 2},
              {'c': 3},
              {'d': 4}
            ]));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res1 = fx([1, 2, 3]).zip(['5', '6', '7', '8']).toArray();
        expect(res1, equals([(1, '5'), (2, '6'), (3, '7')]));

        final res2 = fx([1, 2, 3, 4]).zip(['5', '6', '7']).toArray();
        expect(res2, equals([(1, '5'), (2, '6'), (3, '7')]));
      });
    });

    group('async', () {
      test(
          "should be merged values of each 'AsyncIterable' with value at the corresponding position",
          () async {
        final res = await toArrayAsync(
            zipAsync(toAsync([1, 2, 3, 4]), toAsync([5, 6, 7, 8])));
        expect(res, equals([(1, 5), (2, 6), (3, 7), (4, 8)]));
      });

      test('should be zipped if the iterables have different size', () async {
        final res1 = await toArrayAsync(
            zipAsync(toAsync([1, 2, 3, 4]), toAsync([5, 6, 7, 8, 9])));
        expect(res1, equals([(1, 5), (2, 6), (3, 7), (4, 8)]));

        final res2 = await toArrayAsync(
            zipAsync(toAsync([1, 2, 3, 4, 5]), toAsync([6, 7, 8, 9])));
        expect(res2, equals([(1, 6), (2, 7), (3, 8), (4, 9)]));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await fx([1, 2, 3, 4])
            .toAsync()
            .zip(toAsync([5, 6, 7, 8]))
            .map((r) => [r.$1 + r.$2])
            .toArray();
        expect(
            res,
            equals([
              [6],
              [8],
              [10],
              [12]
            ]));
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        final res1 = await fx([1, 2, 3])
            .toAsync()
            .zip(toAsync(['5', '6', '7', '8']))
            .toArray();
        expect(res1, equals([(1, '5'), (2, '6'), (3, '7')]));

        final res2 = await fx([1, 2, 3, 4])
            .toAsync()
            .zip(toAsync(['5', '6', '7']))
            .toArray();
        expect(res2, equals([(1, '5'), (2, '6'), (3, '7')]));
      });

      test("should be zipped each 'AsyncIterable' having a different type",
          () async {
        final res = await fx(['a', 'b', 'c', 'd'])
            .toAsync()
            .zip(toAsync([1, 2, 3, 4]))
            .map((r) => {r.$1: r.$2})
            .toArray();
        expect(
            res,
            equals([
              {'a': 1},
              {'b': 2},
              {'c': 3},
              {'d': 4}
            ]));
      });

      test('should be zipped sequentially', () async {
        final res = await fxAsync(mapAsync(
            (int a) => delay(const Duration(milliseconds: 50), a),
            toAsync([5, 6, 7, 8]))).zip(toAsync([1, 2, 3, 4])).toArray();
        expect(res, equals([(5, 1), (6, 2), (7, 3), (8, 4)]));
      });

      test('should be zipped concurrently: zip - map', () async {
        final sw = Stopwatch()..start();
        final res = await fx([5, 6, 7, 8])
            .toAsync()
            .zip(toAsync([1, 2, 3, 4]))
            .map((r) => delay(const Duration(milliseconds: 100), r))
            .concurrent(4)
            .toArray();
        expect(res, equals([(5, 1), (6, 2), (7, 3), (8, 4)]));
        // sequential is ~400ms; concurrent(4) is ~100ms
        expect(sw.elapsedMilliseconds, lessThan(300));
      });

      test('should be zipped concurrently: map - zip', () async {
        final sw = Stopwatch()..start();
        final res = await fxAsync(mapAsync(
                (int a) => delay(const Duration(milliseconds: 100), a),
                toAsync([5, 6, 7, 8])))
            .zip(toAsync([1, 2, 3, 4]))
            .concurrent(4)
            .toArray();
        expect(res, equals([(5, 1), (6, 2), (7, 3), (8, 4)]));
        // sequential is ~400ms; concurrent(4) should be ~100ms
        expect(sw.elapsedMilliseconds, lessThan(300));
      });

      test('should be passed concurrent object when job works concurrently',
          () async {
        final mock = ConcurrentMock<int>();
        final it = zipAsync(toAsync([1, 2, 3]), mock).iterator;
        final concurrent = Concurrent.of(2);
        await it.next(concurrent);
        expect(mock.received, same(concurrent));
      });
    });
  });
}
