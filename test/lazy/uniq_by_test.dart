import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

import 'concurrent_mock.dart';

void main() {
  group('uniqBy', () {
    group('sync', () {
      test('should be removed duplicate values by the callback', () {
        final res1 = uniqBy((String a) => a, 'marpple'.split(''));
        expect(res1.toList(), equals(['m', 'a', 'r', 'p', 'l', 'e']));

        final res2 = uniqBy((Map<String, int> a) => a['age'], [
          {'age': 21},
          {'age': 22},
          {'age': 21},
          {'age': 23},
          {'age': 22},
        ]);
        expect(
          res2.toList(),
          equals([
            {'age': 21},
            {'age': 22},
            {'age': 23},
          ]),
        );

        final res3 = uniqBy((int a) => a, [1, 2, 3, 4]);
        expect(res3.toList(), equals([1, 2, 3, 4]));
      });

      test('should dedup a non-List source, which toList cannot index', () {
        Iterable<int> generated() sync* {
          yield 11;
          yield 22;
          yield 31;
          yield 42;
        }

        // Keyed on the last digit, so the 3rd and 4th elements are dropped.
        expect(
          uniqBy((int a) => a % 10, generated()).toList(),
          equals([11, 22]),
        );
        expect(
          uniqBy((int a) => a % 10, generated()).toList(growable: false),
          equals([11, 22]),
        );
      });

      test('should be able to be used in the pipeline', () {
        final res = fx([1, 2, 3, 4, 4, 2])
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .uniqBy((a) => a)
            .toList();
        expect(res, equals([12, 14]));
      });
    });

    group('async', () {
      test('should be removed duplicate values by the callback', () async {
        final res1 = await toListAsync(
          uniqByAsync((String a) => a, toAsync('marpple'.split(''))),
        );
        expect(res1, equals(['m', 'a', 'r', 'p', 'l', 'e']));

        final res2 = await toListAsync(
          uniqByAsync(
            (Map<String, int> a) => a['age'],
            toAsync([
              {'age': 21},
              {'age': 22},
              {'age': 21},
              {'age': 23},
              {'age': 22},
            ]),
          ),
        );
        expect(
          res2,
          equals([
            {'age': 21},
            {'age': 22},
            {'age': 23},
          ]),
        );

        final res3 = await toListAsync(
          uniqByAsync((int a) => a, toAsync([1, 2, 3, 4])),
        );
        expect(res3, equals([1, 2, 3, 4]));
      });

      test('should await a key callback that returns a Future', () async {
        final res = await toListAsync(
          uniqByAsync((int a) async => a % 3, toAsync([1, 2, 3, 4, 5, 6, 7])),
        );
        expect(res, equals([1, 2, 3]));
      });

      test('should handle a key callback that is sometimes async', () async {
        final res = await toListAsync(
          uniqByAsync(
            (int a) => a.isEven ? Future.value(a % 3) : a % 3,
            toAsync([1, 2, 3, 4, 5, 6]),
          ),
        );
        expect(res, equals([1, 2, 3]));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await fx([1, 2, 3, 4, 4, 2])
            .toAsync()
            .map((a) => a + 10)
            .filter((a) => a % 2 == 0)
            .uniqBy((a) => a)
            .toList();
        expect(res, equals([12, 14]));
      });

      test(
        'should be passed concurrent object when job works concurrently',
        () async {
          final mock = ConcurrentMock<int>();
          final it = uniqByAsync((int a) => a, mock).iterator;
          await it.next(Concurrent.of(2));
          expect(mock.received?.length, equals(2));
        },
      );
    });
  });
}
