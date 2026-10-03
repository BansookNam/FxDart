import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('flatMapWithIndex', () {
    group('sync', () {
      test('flattens what the callback returns', () {
        expect(
          fxToList(flatMapWithIndex((a, i) => [i, a], [10, 20])),
          equals([0, 10, 1, 20]),
        );
      });

      test('the index counts source elements, not emitted ones', () {
        final seen = <int>[];
        fxToList(
          flatMapWithIndex((int a, int i) {
            seen.add(i);
            return List.filled(a, a);
          }, [3, 2, 1]),
        );
        expect(seen, equals([0, 1, 2]));
      });

      test('an empty inner iterable emits nothing but advances the index', () {
        expect(
          fxToList(
            flatMapWithIndex((a, i) => i.isEven ? [a] : <String>[], [
              'a',
              'b',
              'c',
            ]),
          ),
          equals(['a', 'c']),
        );
      });

      test('is empty for an empty source', () {
        expect(
          fxToList(flatMapWithIndex((a, i) => [a], <int>[])),
          equals(<int>[]),
        );
      });

      test('stays lazy', () {
        var calls = 0;
        final it = flatMapWithIndex((int a, int i) {
          calls++;
          return [a];
        }, [1, 2, 3]);
        expect(calls, equals(0));
        expect(it.take(1).toList(), equals([1]));
        expect(calls, equals(1));
      });

      test('restarts the index on every iteration', () {
        final it = flatMapWithIndex((a, i) => [i], ['a', 'b']);
        expect(it.toList(), equals([0, 1]));
        expect(it.toList(), equals([0, 1]));
      });

      test('is available as an fx chain method', () {
        final res = fx([
          'a',
          'b',
        ]).flatMapWithIndex((a, i) => List.filled(i + 1, a)).toList();
        expect(res, equals(['a', 'b', 'b']));
      });
    });

    group('async', () {
      test('flattens what the callback returns', () async {
        final res = await fxToListAsync(
          flatMapWithIndexAsync((a, i) => [i, a], fxToAsync([10, 20])),
        );
        expect(res, equals([0, 10, 1, 20]));
      });

      test('accepts an async callback', () async {
        final res = await fxToListAsync(
          flatMapWithIndexAsync((a, i) async => [a * i], fxToAsync([1, 2, 3])),
        );
        expect(res, equals([0, 2, 6]));
      });

      test('the index counts source elements', () async {
        final seen = <int>[];
        await fxToListAsync(
          flatMapWithIndexAsync((int a, int i) {
            seen.add(i);
            return List.filled(a, a);
          }, fxToAsync([3, 2, 1])),
        );
        expect(seen, equals([0, 1, 2]));
      });

      test('restarts the index on every iteration', () async {
        final it = flatMapWithIndexAsync((a, i) => [i], fxToAsync(['a', 'b']));
        expect(await fxToListAsync(it), equals([0, 1]));
        expect(await fxToListAsync(it), equals([0, 1]));
      });

      test('is available as an fxAsync chain method', () async {
        final res = await fxAsync(
          fxToAsync(['a', 'b']),
        ).flatMapWithIndex((a, i) => List.filled(i + 1, a)).toList();
        expect(res, equals(['a', 'b', 'b']));
      });
    });
  });
}
