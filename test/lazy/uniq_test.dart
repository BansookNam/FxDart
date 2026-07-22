import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

import 'concurrent_mock.dart';

void main() {
  group('uniq', () {
    group('sync', () {
      test('should be removed duplicate values', () {
        final res1 = uniq('marpple'.split(''));
        expect(res1.toList(), equals(['m', 'a', 'r', 'p', 'l', 'e']));

        final res2 = uniq([1, 2, 3, 4]);
        expect(res2.toList(), equals([1, 2, 3, 4]));
      });

      test('should keep distinct (identity-unequal) map objects', () {
        final res = toList(uniq([
          {'v': 1},
          {'v': 1},
          {'v': 1},
          {'v': 1},
          {'v': 1},
        ]));
        expect(
            res,
            equals([
              {'v': 1},
              {'v': 1},
              {'v': 1},
              {'v': 1},
              {'v': 1},
            ]));
      });

      test('should be able to be used in the pipeline', () {
        final res = fx([1, 2, 3, 4, 4, 2])
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .uniq()
            .toList();
        expect(res, equals([12, 14]));
      });
    });

    group('async', () {
      test('should be removed duplicate values', () async {
        final res1 =
            await toListAsync(uniqAsync(toAsync('marpple'.split(''))));
        expect(res1, equals(['m', 'a', 'r', 'p', 'l', 'e']));

        final res2 = await toListAsync(uniqAsync(toAsync([1, 2, 3, 4])));
        expect(res2, equals([1, 2, 3, 4]));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await fx([1, 2, 3, 4, 4, 2])
            .toAsync()
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .uniq()
            .toList();
        expect(res, equals([12, 14]));
      });

      test('should be passed concurrent object when job works concurrently',
          () async {
        final mock = ConcurrentMock<int>();
        final it = uniqAsync(mock).iterator;
        await it.next(Concurrent.of(2));
        expect(mock.received?.length, equals(2));
      });
    });
  });
}
