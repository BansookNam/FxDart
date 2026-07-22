import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

import 'concurrent_mock.dart';

void main() {
  group('intersection', () {
    group('sync', () {
      test('should return all elements in iterable2 contained in iterable1',
          () {
        expect(toList(intersection([1, 2, 3, 4], [3, 4, 4, 5, 6])),
            equals([3, 4]));
        expect(toList(intersection('abcd'.split(''), 'cdefgc'.split(''))),
            equals(['c', 'd']));
      });

      test('should be able to be used in the pipeline', () {
        final res = toList(intersection([2, 4, 5, 6], [1, 2, 3, 4]));
        expect(res, equals([2, 4]));
      });
    });

    group('async', () {
      test('should return all elements in iterable2 contained in iterable1',
          () async {
        expect(
            await toListAsync(intersectionAsync(
                toAsync([1, 2, 3, 4]), toAsync([3, 4, 4, 5, 6, 3]))),
            equals([3, 4]));
        expect(
            await toListAsync(intersectionAsync(
                toAsync('abcd'.split('')), toAsync('cdefg'.split('')))),
            equals(['c', 'd']));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await toListAsync(
            intersectionAsync(toAsync([2, 4, 5, 6]), toAsync([1, 2, 3, 4])));
        expect(res, equals([2, 4]));
      });

      test('should be handled concurrently', () async {
        final sw = Stopwatch()..start();
        final res = await toListAsync(concurrentAsync(
            3,
            intersectionAsync(
                toAsync([3, 4, 5]),
                mapAsync((int a) => delay(const Duration(milliseconds: 100), a),
                    toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9])))));

        expect(res, equals([3, 4, 5]));
        // sequential is ~900ms; concurrent(3) is ~300ms
        expect(sw.elapsedMilliseconds, lessThan(700));
      });

      test('should be passed concurrent object when job works concurrently',
          () async {
        final mock1 = ConcurrentMock<int>();
        final mock2 = ConcurrentMock<int>();
        final it = intersectionAsync(mock1, mock2).iterator;
        await it.next(Concurrent.of(2));
        // Only iterable2 is evaluated concurrently, as in FxTS.
        expect(mock2.received?.length, equals(2));
        expect(mock1.received, equals(null));
      });
    });
  });
}
