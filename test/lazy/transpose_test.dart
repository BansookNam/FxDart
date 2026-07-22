import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

import 'concurrent_mock.dart';

void main() {
  group('transpose', () {
    group('sync', () {
      test(
          "should be merged values of each 'Iterable' with value at the corresponding position",
          () {
        final res = toList(transpose<Object>([
          [1, 'a'],
          [2, 'b'],
          [3, 'c'],
          [4, 'd'],
        ]));

        expect(
            res,
            equals([
              [1, 2, 3, 4],
              ['a', 'b', 'c', 'd'],
            ]));
        expect(
            toList(transpose(res)),
            equals([
              [1, 'a'],
              [2, 'b'],
              [3, 'c'],
              [4, 'd'],
            ]));
      });

      test('should be transposed if the iterables have different size', () {
        final res = toList(transpose([
          [1, 2],
          [3],
          <int>[],
          [4, 5, 6],
          [7],
          [8, 9],
        ]));

        expect(
            res,
            equals([
              [1, 3, 4, 7, 8],
              [2, 5, 9],
              [6]
            ]));
      });

      test('should be able to be used in the pipeline', () {
        final res = fx(transpose([
          [1, 5],
          [2, 6],
          [3, 7],
          [4, 8, 9],
        ])).take(2).map((row) => sum(row)).toList();

        expect(res, equals([10, 26]));
      });

      test("should be transposed each 'Iterable' having a different type", () {
        final res = fx(transpose<Object>([
          ['a', 1],
          ['b', 2],
          ['c', 3],
        ])).map((value) => join('-', value)).toList();

        expect(res, equals(['a-b-c', '1-2-3']));
      });

      test('should transpose two rows into pairs', () {
        final res = toList(transpose([
          [1, 2, 3, 4],
          [5, 6, 7, 8],
        ]));

        expect(
            res,
            equals([
              [1, 5],
              [2, 6],
              [3, 7],
              [4, 8],
            ]));
      });
    });

    group('async', () {
      test(
          "should be merged values of each 'AsyncIterable' with value at the corresponding position",
          () async {
        final res = await toListAsync(transposeAsync([
          toAsync([1, 5]),
          toAsync([2, 6]),
          toAsync([3, 7]),
          toAsync([4, 8]),
        ]));

        expect(
            res,
            equals([
              [1, 2, 3, 4],
              [5, 6, 7, 8],
            ]));
      });

      test('should be transposed if the iterables have different size',
          () async {
        final res = await toListAsync(transposeAsync([
          toAsync([1, 2]),
          toAsync([3]),
          toAsync(<int>[]),
          toAsync([4, 5, 6]),
          toAsync([7]),
          toAsync([8, 9]),
        ]));

        expect(
            res,
            equals([
              [1, 3, 4, 7, 8],
              [2, 5, 9],
              [6]
            ]));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await toListAsync(transposeAsync([
          toAsync([1, 2, 3, 4]),
          toAsync([5, 6, 7, 8]),
        ]));

        expect(
            res,
            equals([
              [1, 5],
              [2, 6],
              [3, 7],
              [4, 8],
            ]));
      });

      test('should be transposed sequentially', () async {
        final res = await toListAsync(transposeAsync([
          toAsync([1, 2, 3, 4]),
          mapAsync((int a) => delay(const Duration(milliseconds: 50), a),
              toAsync([5, 6, 7, 8])),
        ]));

        expect(
            res,
            equals([
              [1, 5],
              [2, 6],
              [3, 7],
              [4, 8],
            ]));
      });

      test('should be transposed concurrently: transpose - map', () async {
        final sw = Stopwatch()..start();
        final res = await fxAsync(transposeAsync<Object>([
          toAsync<Object>([1, 2, 3, 4]),
          toAsync<Object>([5, 6, 7, 8]),
        ]))
            .map((l) => delay(const Duration(milliseconds: 100), l))
            .concurrent(4)
            .toList();

        expect(
            res,
            equals([
              [1, 5],
              [2, 6],
              [3, 7],
              [4, 8],
            ]));
        // sequential is ~400ms; concurrent(4) is ~100ms
        expect(sw.elapsedMilliseconds, lessThan(300));
      });

      test('should be passed concurrent object when job works concurrently',
          () async {
        final mock = ConcurrentMock<int>();
        final it = transposeAsync([
          toAsync([1, 2, 3]),
          mock
        ]).iterator;
        final concurrent = Concurrent.of(2);
        await it.next(concurrent);
        expect(mock.received, same(concurrent));
      });
    });
  });
}
