import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

import 'concurrent_mock.dart';

void main() {
  group('difference', () {
    group('sync', () {
      test('should return all elements in iterable2 not contained in iterable1',
          () {
        expect(toArray(difference([1, 2, 3, 4], [3, 4, 5, 6, 5, 3])),
            equals([5, 6]));
        expect(toArray(difference('abcd'.split(''), 'cdefg'.split(''))),
            equals(['e', 'f', 'g']));
      });

      test('should be able to be used in the pipeline', () {
        final res = toArray(difference([2, 4, 5, 6], [1, 2, 3, 4]));
        expect(res, equals([1, 3]));
      });
    });

    group('async', () {
      test('should return all elements in iterable2 not contained in iterable1',
          () async {
        expect(
            await toArrayAsync(differenceAsync(
                toAsync([1, 2, 3, 4]), toAsync([3, 4, 5, 6, 5, 3]))),
            equals([5, 6]));
        expect(
            await toArrayAsync(differenceAsync(
                toAsync('abcd'.split('')), toAsync('cdefg'.split('')))),
            equals(['e', 'f', 'g']));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await toArrayAsync(
            differenceAsync(toAsync([2, 4, 5, 6]), toAsync([1, 2, 3, 4])));
        expect(res, equals([1, 3]));
      });

      test('should be handled concurrently', () async {
        final sw = Stopwatch()..start();
        final res = await toArrayAsync(concurrentAsync(
            3,
            differenceAsync(
                toAsync([3, 4, 5]),
                mapAsync((int a) => delay(const Duration(milliseconds: 100), a),
                    toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9])))));

        expect(res, equals([1, 2, 6, 7, 8, 9]));
        // sequential is ~900ms; concurrent(3) is ~300ms
        expect(sw.elapsedMilliseconds, lessThan(700));
      });

      test('should be passed concurrent object when job works concurrently',
          () async {
        final mock1 = ConcurrentMock<int>();
        final mock2 = ConcurrentMock<int>();
        final it = differenceAsync(mock1, mock2).iterator;
        await it.next(Concurrent.of(2));
        // Only iterable2 is evaluated concurrently, as in FxTS.
        expect(mock2.received?.length, equals(2));
        expect(mock1.received, equals(null));
      });
    });
  });
}
