import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

import 'concurrent_mock.dart';

void main() {
  group('cycle', () {
    group('sync', () {
      test('should repeat given elements (numbers)', () {
        expect(take(8, cycle([1, 2, 3, 4, 5])).toList(),
            equals([1, 2, 3, 4, 5, 1, 2, 3]));
      });

      test('should repeat given elements (string chars)', () {
        expect(take(8, cycle('abcde'.split(''))).toList(),
            equals(['a', 'b', 'c', 'd', 'e', 'a', 'b', 'c']));
      });

      test('should be able to be used in the pipeline', () {
        final res = fx([1, 2, 3, 4]).cycle().map((a) => '$a').take(5).toList();
        expect(res, equals(['1', '2', '3', '4', '1']));
      });
    });

    group('async', () {
      test('should repeat given elements (numbers)', () async {
        final it = cycleAsync(toAsync([1, 2, 3, 4, 5])).iterator;
        for (final expected in [1, 2, 3, 4, 5, 1, 2, 3]) {
          expect((await it.next()).value, equals(expected));
        }
      });

      test('should repeat given elements (string chars)', () async {
        final it = cycleAsync(toAsync('abcde'.split(''))).iterator;
        for (final expected in ['a', 'b', 'c', 'd', 'e', 'a', 'b', 'c']) {
          expect((await it.next()).value, equals(expected));
        }
      });

      test('should be able to be used in the pipeline', () async {
        final res = await fx([1, 2, 3, 4])
            .toAsync()
            .cycle()
            .map((a) => '$a')
            .take(5)
            .toList();
        expect(res, equals(['1', '2', '3', '4', '1']));
      });

      test('should be repeated concurrently', () async {
        final sw = Stopwatch()..start();
        final res = await fxAsync(cycleAsync(toAsync(() sync* {
          for (var i = 1; i <= 6; i++) {
            yield delay(const Duration(milliseconds: 100), i);
          }
        }())))
            .concurrent(2)
            .take(6)
            .toList();
        expect(res, equals([1, 2, 3, 4, 5, 6]));
        // sequential would be ~600ms; concurrent(2) is ~300ms
        expect(sw.elapsedMilliseconds, lessThan(500));
      });

      test('should be passed concurrent object when job works concurrently',
          () async {
        final mock = ConcurrentMock<int>();
        final it = cycleAsync(mock).iterator;
        await it.next(Concurrent.of(2));
        expect(mock.received?.length, equals(2));
      });
    });
  });
}
