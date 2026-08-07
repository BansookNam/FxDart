import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('foldRight', () {
    group('sync', () {
      test('visits the elements from last to first', () {
        final seen = <int>[];
        foldRight(0, (acc, int a) {
          seen.add(a);
          return acc;
        }, [1, 2, 3]);
        expect(seen, equals([3, 2, 1]));
      });

      test('nests from the right where fold nests from the left', () {
        // 1 - (2 - (3 - 0)) == 2, but ((0 - 1) - 2) - 3 == -6.
        expect(foldRight(0, (acc, int a) => a - acc, [1, 2, 3]), equals(2));
        expect(fold(0, (acc, int a) => acc - a, [1, 2, 3]), equals(-6));
      });

      test('returns the seed for an empty source', () {
        expect(foldRight(42, (acc, int a) => acc + a, <int>[]), equals(42));
      });

      test('agrees with fold over a reversed source', () {
        final source = [3, 1, 4, 1, 5];
        expect(foldRight('', (acc, int a) => '$acc$a', source),
            equals(fold('', (acc, int a) => '$acc$a', reverse(source))));
      });

      test('works on a lazy, non-List source', () {
        final source = fx([1, 2, 3]).map((a) => a * 10);
        expect(foldRight(<int>[], (acc, int a) => acc..add(a), source),
            equals([30, 20, 10]));
      });

      test('can build a right-nested structure', () {
        final res = foldRight('nil', (acc, String a) => '($a . $acc)',
            ['a', 'b', 'c']);
        expect(res, equals('(a . (b . (c . nil)))'));
      });

      test('is available as an fx chain method', () {
        expect(fx([1, 2, 3]).foldRight(0, (acc, a) => a - acc), equals(2));
      });
    });

    group('async', () {
      test('visits the values from last to first', () async {
        final seen = <int>[];
        await foldRightAsync(0, (acc, int a) {
          seen.add(a);
          return acc;
        }, toAsync([1, 2, 3]));
        expect(seen, equals([3, 2, 1]));
      });

      test('nests from the right', () async {
        expect(await foldRightAsync(0, (acc, int a) => a - acc, toAsync([1, 2, 3])),
            equals(2));
      });

      test('accepts an async seed and accumulator', () async {
        final res = await foldRightAsync(Future.value(0),
            (acc, int a) async => a - acc, toAsync([1, 2, 3]));
        expect(res, equals(2));
      });

      test('returns the seed for an empty source', () async {
        expect(await foldRightAsync(42, (acc, int a) => acc + a, toAsync(<int>[])),
            equals(42));
      });

      test('agrees with the sync form over the same values', () async {
        final source = [3, 1, 4, 1, 5];
        expect(await foldRightAsync('', (acc, int a) => '$acc$a', toAsync(source)),
            equals(foldRight('', (acc, int a) => '$acc$a', source)));
      });

      test('is available as an fxAsync chain method', () async {
        final res =
            await fxAsync(toAsync([1, 2, 3])).foldRight(0, (acc, a) => a - acc);
        expect(res, equals(2));
      });
    });
  });

  group('foldRightWithIndex', () {
    group('sync', () {
      test('reports the source position, counting down', () {
        final seen = <(String, int)>[];
        foldRightWithIndex(0, (acc, String a, i) {
          seen.add((a, i));
          return acc;
        }, ['a', 'b', 'c']);
        expect(seen, equals([('c', 2), ('b', 1), ('a', 0)]));
      });

      test('the index agrees with foldWithIndex for the same element', () {
        final source = ['a', 'b', 'c'];
        final left = <String, int>{};
        final right = <String, int>{};
        foldWithIndex(0, (acc, String a, i) {
          left[a] = i;
          return acc;
        }, source);
        foldRightWithIndex(0, (acc, String a, i) {
          right[a] = i;
          return acc;
        }, source);
        expect(right, equals(left));
      });

      test('returns the seed for an empty source', () {
        expect(foldRightWithIndex(42, (acc, int a, i) => acc + i, <int>[]),
            equals(42));
      });

      test('works on a lazy, non-List source', () {
        final source = fx([1, 2, 3]).map((a) => a * 10);
        final res =
            foldRightWithIndex(<(int, int)>[], (acc, int a, i) => acc..add((i, a)),
                source);
        expect(res, equals([(2, 30), (1, 20), (0, 10)]));
      });

      test('is available as an fx chain method', () {
        expect(fx([1, 2, 3]).foldRightWithIndex(0, (acc, a, i) => acc + a * i),
            equals(8));
      });
    });

    group('async', () {
      test('reports the source position, counting down', () async {
        final seen = <(String, int)>[];
        await foldRightWithIndexAsync(0, (acc, String a, i) {
          seen.add((a, i));
          return acc;
        }, toAsync(['a', 'b', 'c']));
        expect(seen, equals([('c', 2), ('b', 1), ('a', 0)]));
      });

      test('accepts an async seed and accumulator', () async {
        final res = await foldRightWithIndexAsync(Future.value(0),
            (acc, int a, i) async => acc + a * i, toAsync([1, 2, 3]));
        expect(res, equals(8));
      });

      test('returns the seed for an empty source', () async {
        final res = await foldRightWithIndexAsync(
            42, (acc, int a, i) => acc + i, toAsync(<int>[]));
        expect(res, equals(42));
      });

      test('is available as an fxAsync chain method', () async {
        final res = await fxAsync(toAsync([1, 2, 3]))
            .foldRightWithIndex(0, (acc, a, i) => acc + a * i);
        expect(res, equals(8));
      });
    });
  });
}
