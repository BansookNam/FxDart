import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

import 'concurrent_mock.dart';

void main() {
  group('intersectionBy', () {
    group('sync', () {
      test(
        'should return all elements in iterable2 contained in iterable1',
        () {
          final iter = fxIntersectionBy(
            (Map<String, int> a) => a['x'],
            [
              {'x': 1},
              {'x': 4},
            ],
            [
              {'x': 1},
              {'x': 2},
              {'x': 3},
            ],
          );
          expect(
            fxToList(iter),
            equals([
              {'x': 1},
            ]),
          );

          expect(
            fxToList(
              fxIntersectionBy(
                (String a) => a,
                'abcd'.split(''),
                'cdefgc'.split(''),
              ),
            ),
            equals(['c', 'd']),
          );
        },
      );
    });

    group('async', () {
      test(
        'should return all elements in iterable2 contained in iterable1',
        () async {
          final res = await fxToListAsync(
            fxIntersectionByAsync(
              (Map<String, int> a) => a['x'],
              fxToAsync([
                {'x': 1},
                {'x': 4},
              ]),
              fxToAsync([
                {'x': 1},
                {'x': 2},
                {'x': 3},
              ]),
            ),
          );
          expect(
            res,
            equals([
              {'x': 1},
            ]),
          );

          expect(
            await fxToListAsync(
              fxIntersectionByAsync(
                (String a) => a,
                fxToAsync('abcd'.split('')),
                fxToAsync('cdefgc'.split('')),
              ),
            ),
            equals(['c', 'd']),
          );
        },
      );

      test('should support an async callback', () async {
        final res = await fxToListAsync(
          fxIntersectionByAsync(
            (int a) async => a % 10,
            fxToAsync([1, 2]),
            fxToAsync([11, 13, 21]),
          ),
        );
        expect(res, equals([11, 21]));
      });

      test(
        'should be passed concurrent object when job works concurrently',
        () async {
          final mock1 = ConcurrentMock<int>();
          final mock2 = ConcurrentMock<int>();
          final it = fxIntersectionByAsync((int a) => a, mock1, mock2).iterator;
          await it.next(Concurrent.of(2));
          // Only iterable2 is evaluated concurrently, as in FxTS.
          expect(mock2.received?.length, equals(2));
          expect(mock1.received, equals(null));
        },
      );
    });
  });
}
