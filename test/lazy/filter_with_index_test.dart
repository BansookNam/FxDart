import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('filterWithIndex', () {
    group('sync', () {
      test('keeps the elements the predicate holds for', () {
        expect(
          toList(filterWithIndex((a, i) => i.isEven, ['a', 'b', 'c'])),
          equals(['a', 'c']),
        );
      });

      test(
        'the index counts the input — dropped elements still advance it',
        () {
          final seen = <(String, int)>[];
          toList(
            filterWithIndex((String a, int i) {
              seen.add((a, i));
              return false;
            }, ['a', 'b', 'c']),
          );
          expect(seen, equals([('a', 0), ('b', 1), ('c', 2)]));
        },
      );

      test('is empty for an empty source', () {
        expect(
          toList(filterWithIndex((a, i) => true, <int>[])),
          equals(<int>[]),
        );
      });

      test('stays lazy', () {
        var calls = 0;
        final it = filterWithIndex((int a, int i) {
          calls++;
          return true;
        }, [1, 2, 3]);
        expect(calls, equals(0));
        expect(it.take(1).toList(), equals([1]));
        expect(calls, equals(1));
      });

      test('restarts the index on every iteration', () {
        final it = filterWithIndex((a, i) => i < 2, ['a', 'b', 'c']);
        expect(it.toList(), equals(['a', 'b']));
        expect(it.toList(), equals(['a', 'b']));
      });

      test('combines the value and the index', () {
        final res = fx([
          10,
          20,
          30,
          40,
        ]).filterWithIndex((a, i) => i.isOdd && a > 20).toList();
        expect(res, equals([40]));
      });

      test('is available as an fx chain method', () {
        expect(
          fx(range(0, 6)).filterWithIndex((a, i) => i % 3 == 0).toList(),
          equals([0, 3]),
        );
      });
    });

    group('async', () {
      test('keeps the elements the predicate holds for', () async {
        final res = await toListAsync(
          filterWithIndexAsync((a, i) => i.isEven, toAsync(['a', 'b', 'c'])),
        );
        expect(res, equals(['a', 'c']));
      });

      test('accepts an async predicate', () async {
        final res = await toListAsync(
          filterWithIndexAsync((a, i) async => i.isEven, toAsync([1, 2, 3])),
        );
        expect(res, equals([1, 3]));
      });

      test('the index counts the input', () async {
        final seen = <(String, int)>[];
        await toListAsync(
          filterWithIndexAsync((String a, int i) {
            seen.add((a, i));
            return false;
          }, toAsync(['a', 'b', 'c'])),
        );
        expect(seen, equals([('a', 0), ('b', 1), ('c', 2)]));
      });

      test('restarts the index on every iteration', () async {
        final it = filterWithIndexAsync(
          (a, i) => i < 2,
          toAsync(['a', 'b', 'c']),
        );
        expect(await toListAsync(it), equals(['a', 'b']));
        expect(await toListAsync(it), equals(['a', 'b']));
      });

      test('numbers in source order under concurrency', () async {
        final res = await fxAsync(toAsync([5, 4, 3, 2, 1]))
            .map((a) => delay(Duration(milliseconds: a * 20), a))
            .filterWithIndex((a, i) => i.isEven)
            .concurrent(5)
            .toList();
        expect(res, equals([5, 3, 1]));
      });

      test('is available as an fxAsync chain method', () async {
        final res = await fxAsync(
          toAsync(range(0, 6)),
        ).filterWithIndex((a, i) => i % 3 == 0).toList();
        expect(res, equals([0, 3]));
      });
    });
  });
}
