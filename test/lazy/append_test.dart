import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

import 'concurrent_mock.dart';

void main() {
  group('append', () {
    group('sync', () {
      test('should be contained the contents of the given element', () {
        expect(toArray(append('c', ['a', 'b'])), equals(['a', 'b', 'c']));
      });

      test('should be contained the contents of the given element - string',
          () {
        expect(toArray(append('c', 'ab'.split(''))), equals(['a', 'b', 'c']));
      });

      test('should be able to be used in the pipeline', () {
        final res = fx(range(1, 4)).append(4).append(5).append(6).toArray();
        expect(res, equals([1, 2, 3, 4, 5, 6]));
      });

      test('should be able to be used chaining method in the `fx`', () {
        final res = fx(range(1, 4)).append(4).append(5).toArray();
        expect(res, equals([1, 2, 3, 4, 5]));
      });
    });

    group('async', () {
      test('should be contained the contents of the given element', () async {
        final res = await toArrayAsync(appendAsync('c', toAsync(['a', 'b'])));
        expect(res, equals(['a', 'b', 'c']));
      });

      test('should be able to append a Future element', () async {
        final res = await toArrayAsync(appendAsync(
            delay(const Duration(milliseconds: 100), 4), toAsync([1, 2, 3])));
        expect(res, equals([1, 2, 3, 4]));
      });

      test('should be able to be used chaining method in the `fx`', () async {
        final res =
            await fx(range(1, 4)).toAsync().append(4).append(5).toArray();
        expect(res, equals([1, 2, 3, 4, 5]));
      });

      test('should be appended sequentially', () async {
        Future<void> chained = Future.value();
        Future<int> chain(int v) {
          final next =
              chained.then((_) => delay(const Duration(milliseconds: 50), v));
          chained = next;
          return next;
        }

        var it = toAsync(range(1, 4));
        it = appendAsync(chain(4), it);
        it = appendAsync(chain(5), it);
        it = appendAsync(chain(6), it);
        expect(await toArrayAsync(it), equals([1, 2, 3, 4, 5, 6]));
      });

      test('should be appended concurrently', () async {
        final sw = Stopwatch()..start();
        final res = await fx([1, 2, 3])
            .toAsync()
            .map((a) => delay(const Duration(milliseconds: 100), a))
            .append(4)
            .append(Future.value(5))
            .append(6)
            .concurrent(3)
            .toArray();
        expect(res, equals([1, 2, 3, 4, 5, 6]));
        // sequential would be ~300ms; concurrent(3) is ~100ms
        expect(sw.elapsedMilliseconds, lessThan(250));
      });

      test('should be passed concurrent object when job works concurrently',
          () async {
        final mock = ConcurrentMock<int>();
        final it = appendAsync(1, mock).iterator;
        await it.next(Concurrent.of(2));
        expect(mock.received?.length, equals(2));
      });
    });
  });
}
