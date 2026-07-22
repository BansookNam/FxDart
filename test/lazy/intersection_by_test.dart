import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

import 'concurrent_mock.dart';

void main() {
  group('intersectionBy', () {
    group('sync', () {
      test('should return all elements in iterable2 contained in iterable1',
          () {
        final iter = intersectionBy((Map<String, int> a) => a['x'], [
          {'x': 1},
          {'x': 4},
        ], [
          {'x': 1},
          {'x': 2},
          {'x': 3},
        ]);
        expect(
            toList(iter),
            equals([
              {'x': 1},
            ]));

        expect(
            toList(intersectionBy(
                (String a) => a, 'abcd'.split(''), 'cdefgc'.split(''))),
            equals(['c', 'd']));
      });
    });

    group('async', () {
      test('should return all elements in iterable2 contained in iterable1',
          () async {
        final res = await toListAsync(intersectionByAsync(
            (Map<String, int> a) => a['x'],
            toAsync([
              {'x': 1},
              {'x': 4},
            ]),
            toAsync([
              {'x': 1},
              {'x': 2},
              {'x': 3},
            ])));
        expect(
            res,
            equals([
              {'x': 1},
            ]));

        expect(
            await toListAsync(intersectionByAsync((String a) => a,
                toAsync('abcd'.split('')), toAsync('cdefgc'.split('')))),
            equals(['c', 'd']));
      });

      test('should support an async callback', () async {
        final res = await toListAsync(intersectionByAsync(
            (int a) async => a % 10, toAsync([1, 2]), toAsync([11, 13, 21])));
        expect(res, equals([11, 21]));
      });

      test('should be passed concurrent object when job works concurrently',
          () async {
        final mock1 = ConcurrentMock<int>();
        final mock2 = ConcurrentMock<int>();
        final it = intersectionByAsync((int a) => a, mock1, mock2).iterator;
        await it.next(Concurrent.of(2));
        // Only iterable2 is evaluated concurrently, as in FxTS.
        expect(mock2.received?.length, equals(2));
        expect(mock1.received, equals(null));
      });
    });
  });
}
