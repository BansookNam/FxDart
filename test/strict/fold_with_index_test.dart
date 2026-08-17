import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('foldWithIndex', () {
    group('sync', () {
      test('passes the 0-based position to the accumulator', () {
        expect(
          foldWithIndex(0, (acc, int a, i) => acc + a * i, [1, 2, 3]),
          equals(8),
        );
      });

      test('returns the seed for an empty source', () {
        expect(
          foldWithIndex(42, (acc, int a, i) => acc + a, <int>[]),
          equals(42),
        );
      });

      test('visits every element once, in order', () {
        final seen = <(int, int)>[];
        foldWithIndex(0, (acc, int a, i) {
          seen.add((a, i));
          return acc;
        }, [10, 20, 30]);
        expect(seen, equals([(10, 0), (20, 1), (30, 2)]));
      });

      test('can build a map keyed by position', () {
        final res = foldWithIndex(<int, String>{}, (acc, String a, i) {
          acc[i] = a;
          return acc;
        }, ['a', 'b']);
        expect(res, equals({0: 'a', 1: 'b'}));
      });

      test('matches fold over zipWithIndex', () {
        final source = [3, 1, 4, 1, 5];
        final viaIndex = foldWithIndex(
          0,
          (acc, int a, i) => acc + a * i,
          source,
        );
        final viaZip = fold(
          0,
          (acc, (int, int) p) => acc + p.$2 * p.$1,
          zipWithIndex(source),
        );
        expect(viaIndex, equals(viaZip));
      });

      test('restarts the index on every call', () {
        final source = [1, 2, 3];
        final first = foldWithIndex(0, (acc, int a, i) => acc + i, source);
        final second = foldWithIndex(0, (acc, int a, i) => acc + i, source);
        expect(first, equals(3));
        expect(second, equals(3));
      });

      test('is available as an fx chain method', () {
        expect(
          fx([1, 2, 3]).foldWithIndex(0, (acc, a, i) => acc + a * i),
          equals(8),
        );
      });
    });

    group('async', () {
      test('passes the 0-based position to the accumulator', () async {
        final res = await foldWithIndexAsync(
          0,
          (acc, int a, i) => acc + a * i,
          toAsync([1, 2, 3]),
        );
        expect(res, equals(8));
      });

      test('accepts an async seed and accumulator', () async {
        final res = await foldWithIndexAsync(
          Future.value(0),
          (acc, int a, i) async => acc + a * i,
          toAsync([1, 2, 3]),
        );
        expect(res, equals(8));
      });

      test('returns the seed for an empty source', () async {
        final res = await foldWithIndexAsync(
          42,
          (acc, int a, i) => acc + a,
          toAsync(<int>[]),
        );
        expect(res, equals(42));
      });

      test('numbers in source order under concurrency', () async {
        final res = await fxAsync(toAsync([5, 4, 3, 2, 1]))
            .map((a) => delay(Duration(milliseconds: a * 20), a))
            .concurrent(5)
            .foldWithIndex(<(int, int)>[], (acc, a, i) => acc..add((i, a)));
        expect(res, equals([(0, 5), (1, 4), (2, 3), (3, 2), (4, 1)]));
      });

      test('restarts the index on every call', () async {
        final source = toAsync([1, 2, 3]);
        expect(
          await foldWithIndexAsync(0, (acc, int a, i) => acc + i, source),
          equals(3),
        );
        expect(
          await foldWithIndexAsync(0, (acc, int a, i) => acc + i, source),
          equals(3),
        );
      });

      test('is available as an fxAsync chain method', () async {
        final res = await fxAsync(
          toAsync([1, 2, 3]),
        ).foldWithIndex(0, (acc, a, i) => acc + a * i);
        expect(res, equals(8));
      });
    });
  });
}
