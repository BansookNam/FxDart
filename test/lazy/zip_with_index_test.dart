import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

import 'concurrent_mock.dart';

void main() {
  group('zipWithIndex', () {
    group('sync', () {
      test('should be returned as a tuple (index, value)', () {
        final items = ['a', 'b', 'c', 'd'];
        var i = -1;
        for (final item in zipWithIndex(items)) {
          i++;
          expect(item.$1, equals(i));
          expect(item.$2, equals(items[i]));
        }
        expect(i, equals(3));
      });
    });

    group('async', () {
      test('should be returned as a tuple (index, value)', () async {
        final items = ['a', 'b', 'c', 'd'];
        final res = await toListAsync(zipWithIndexAsync(toAsync(items)));
        expect(res, equals([(0, 'a'), (1, 'b'), (2, 'c'), (3, 'd')]));
      });

      test('should be returned as a tuple (index, value) concurrently',
          () async {
        final items = ['a', 'b', 'c', 'd'];
        final length = items.length;
        final it = concurrentAsync(
            4,
            zipWithIndexAsync(toAsync(items.asMap().entries.map((e) => delay(
                Duration(milliseconds: (length - e.key) * 50),
                e.value))))).iterator;

        final r1 = (await it.next()).value;
        final r2 = (await it.next()).value;
        final r3 = (await it.next()).value;
        final r4 = (await it.next()).value;
        expect(r1.$2 + r2.$2 + r3.$2 + r4.$2, equals('abcd'));
        expect([r1.$1, r2.$1, r3.$1, r4.$1], equals([0, 1, 2, 3]));
      });

      test('should be passed concurrent object when job works concurrently',
          () async {
        final mock = ConcurrentMock<int>();
        final it = zipWithIndexAsync(mock).iterator;
        await it.next(Concurrent.of(2));
        expect(mock.received?.length, equals(2));
      });
    });
  });
}
