import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('mapWithIndex', () {
    group('sync', () {
      test('passes the 0-based position alongside the value', () {
        expect(toList(mapWithIndex((a, i) => '$i:$a', ['a', 'b', 'c'])),
            equals(['0:a', '1:b', '2:c']));
      });

      test('is empty for an empty source', () {
        expect(toList(mapWithIndex((a, i) => a, <int>[])), equals(<int>[]));
      });

      test('stays lazy', () {
        var calls = 0;
        final it = mapWithIndex((int a, int i) {
          calls++;
          return a;
        }, [1, 2, 3]);
        expect(calls, equals(0));
        expect(it.take(1).toList(), equals([1]));
        expect(calls, equals(1));
      });

      test('restarts the index on every iteration', () {
        final it = mapWithIndex((a, i) => i, ['a', 'b']);
        expect(it.toList(), equals([0, 1]));
        expect(it.toList(), equals([0, 1]));
      });

      test('counts what reaches it, not the original source', () {
        final res = fx([1, 2, 3, 4, 5])
            .filter((a) => a.isOdd)
            .mapWithIndex((a, i) => (i, a))
            .toList();
        expect(res, equals([(0, 1), (1, 3), (2, 5)]));
      });

      test('the List fast path agrees with the iterator path', () {
        final list = [10, 20, 30];
        expect(mapWithIndex((a, i) => a + i, list).toList(),
            equals(toList(mapWithIndex((a, i) => a + i, list.where((_) => true)))));
      });

      test('a non-growable toList still holds every element', () {
        final res = mapWithIndex((a, i) => a + i, [10, 20, 30])
            .toList(growable: false);
        expect(res, equals([10, 21, 32]));
      });

      test('matches zipWithIndex + map, without the record', () {
        final viaIndex = fx([10, 20, 30]).mapWithIndex((a, i) => a * i).toList();
        final viaZip =
            fx([10, 20, 30]).zipWithIndex().map((p) => p.$2 * p.$1).toList();
        expect(viaIndex, equals(viaZip));
      });

      test('is available as an fx chain method', () {
        expect(fx(range(1, 4)).mapWithIndex((a, i) => a * i).toList(),
            equals([0, 2, 6]));
      });
    });

    group('async', () {
      test('passes the 0-based position alongside the value', () async {
        final res = await toListAsync(
            mapWithIndexAsync((a, i) => '$i:$a', toAsync(['a', 'b', 'c'])));
        expect(res, equals(['0:a', '1:b', '2:c']));
      });

      test('accepts an async callback', () async {
        final res = await toListAsync(
            mapWithIndexAsync((a, i) async => a * i, toAsync([1, 2, 3])));
        expect(res, equals([0, 2, 6]));
      });

      test('restarts the index on every iteration', () async {
        final it = mapWithIndexAsync((a, i) => i, toAsync(['a', 'b']));
        expect(await toListAsync(it), equals([0, 1]));
        expect(await toListAsync(it), equals([0, 1]));
      });

      test('numbers in source order under concurrency', () async {
        final res = await fxAsync(toAsync([5, 4, 3, 2, 1]))
            .map((a) => delay(Duration(milliseconds: a * 20), a))
            .mapWithIndex((a, i) => (i, a))
            .concurrent(5)
            .toList();
        expect(res, equals([(0, 5), (1, 4), (2, 3), (3, 2), (4, 1)]));
      });

      test('is available as an fxAsync chain method', () async {
        final res = await fxAsync(toAsync(range(1, 4)))
            .mapWithIndex((a, i) => a * i)
            .toList();
        expect(res, equals([0, 2, 6]));
      });
    });
  });
}
