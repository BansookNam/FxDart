import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

import 'concurrent_mock.dart';

void main() {
  group('reverse', () {
    group('sync', () {
      test('should return the given elements in reverse order (numbers)', () {
        expect(toArray(reverse([1, 2, 3, 4])), equals([4, 3, 2, 1]));
      });

      test('should return the given elements in reverse order (string chars)',
          () {
        expect(
            toArray(reverse('abcd'.split(''))), equals(['d', 'c', 'b', 'a']));
      });

      test('should be able to be used in the pipeline', () {
        final res = fx([1, 2, 3, 4]).reverse().toArray();
        expect(res, equals([4, 3, 2, 1]));
      });
    });

    group('async', () {
      test('should return the given elements in reverse order (numbers)',
          () async {
        expect(await toArrayAsync(reverseAsync(toAsync([1, 2, 3, 4]))),
            equals([4, 3, 2, 1]));
      });

      test('should return the given elements in reverse order (string chars)',
          () async {
        expect(await toArrayAsync(reverseAsync(toAsync('abcd'.split('')))),
            equals(['d', 'c', 'b', 'a']));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await fx([1, 2, 3, 4]).toAsync().reverse().toArray();
        expect(res, equals([4, 3, 2, 1]));
      });

      test('should be reversed elements concurrently', () async {
        final sw = Stopwatch()..start();
        final res = await fx([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
            .toAsync()
            .map((a) => delay(const Duration(milliseconds: 100), a))
            .filter((a) => a % 2 == 0)
            .reverse()
            .concurrent(3)
            .toArray();
        expect(res, equals([10, 8, 6, 4, 2]));
        // sequential is ~1000ms; concurrent(3) is ~400ms
        expect(sw.elapsedMilliseconds, lessThan(800));
      });

      test('should be passed concurrent object when job works concurrently',
          () async {
        final mock = ConcurrentMock<int>();
        final it = reverseAsync(mock).iterator;
        await it.next(Concurrent.of(2));
        expect(mock.received?.length, equals(2));
      });
    });
  });
}
