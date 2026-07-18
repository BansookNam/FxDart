import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/some.spec.ts. The AsyncFunctionException test is
// JS-specific (Dart's typed predicates cannot return a Future here).
void main() {
  group('some', () {
    group('sync', () {
      test("should return 'false' if given iterable is an empty array", () {
        expect(some((bool a) => a, <bool>[]), equals(false));
      });

      final cases = <(bool Function(int), List<int>, bool)>[
        ((a) => a % 2 == 0, [2, 4, 6, 8, 10], true),
        ((a) => a % 2 == 0, [1, 4, 6, 8, 10], true),
        ((a) => a % 2 == 0, [2, 4, 7, 8, 10], true),
        ((a) => a % 2 == 0, [2, 4, 7, 8, 11], true),
        ((a) => a % 2 == 1, [2, 4, 6, 8, 10], false),
      ];

      for (final (f, iterable, result) in cases) {
        test('should return $result for $iterable', () {
          expect(some(f, iterable), equals(result));
        });
      }

      test('should be able to be used in the pipeline', () {
        final res1 = pipe([
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
          9
        ], [
          (Iterable<int> a) => filter((int n) => n % 2 == 0, a),
          (Iterable<int> a) => some((int n) => n % 2 == 0, a),
        ]);
        expect(res1, equals(true));

        final res2 = pipe([
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
          9
        ], [
          (Iterable<int> a) => map((int n) => n + 10, a),
          (Iterable<int> a) => some((int n) => n > 10, a),
        ]);
        expect(res2, equals(true));

        final res3 = pipe([
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
          9
        ], [
          (Iterable<int> a) => map((int n) => n + 10, a),
          (Iterable<int> a) => some((int n) => n < 10, a),
        ]);
        expect(res3, equals(false));

        final res4 = pipe([
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
          9
        ], [
          (Iterable<int> a) => map((int n) => n + 10, a),
          (Iterable<int> a) => some((int n) => n < 15, a),
        ]);
        expect(res4, equals(true));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res1 = fx([1, 2, 3, 4, 5, 6, 7, 8, 9])
            .filter((a) => a % 2 == 0)
            .some((a) => a % 2 == 0);
        expect(res1, equals(true));

        final res2 = fx([1, 2, 3, 4, 5, 6, 7, 8, 9])
            .map((a) => a + 10)
            .some((a) => a > 10);
        expect(res2, equals(true));

        final res3 = fx([1, 2, 3, 4, 5, 6, 7, 8, 9])
            .map((a) => a + 10)
            .some((a) => a < 10);
        expect(res3, equals(false));

        final res4 = fx([1, 2, 3, 4, 5, 6, 7, 8, 9])
            .map((a) => a + 10)
            .some((a) => a < 15);
        expect(res4, equals(true));
      });
    });

    group('async', () {
      final syncCases = <(bool Function(int), List<int>, bool)>[
        ((a) => a % 2 == 0, [2, 4, 6, 8, 10], true),
        ((a) => a % 2 == 0, [1, 4, 6, 8, 10], true),
        ((a) => a % 2 == 0, [2, 4, 7, 8, 10], true),
        ((a) => a % 2 == 0, [2, 4, 7, 8, 11], true),
        ((a) => a % 2 == 1, [2, 4, 6, 8, 10], false),
      ];

      for (final (f, iterable, result) in syncCases) {
        test('should return $result for $iterable with a synchronous predicate',
            () async {
          expect(await someAsync(f, toAsync(iterable)), equals(result));
        });
      }

      final asyncCases = <(Future<bool> Function(int), List<int>, bool)>[
        ((a) => Future.value(a % 2 == 0), [2, 4, 6, 8, 10], true),
        ((a) => Future.value(a % 2 == 0), [1, 4, 6, 8, 10], true),
        ((a) => Future.value(a % 2 == 0), [2, 4, 7, 8, 10], true),
        ((a) => Future.value(a % 2 == 0), [2, 4, 7, 8, 11], true),
        ((a) => Future.value(a % 2 == 1), [2, 4, 6, 8, 10], false),
      ];

      for (final (f, iterable, result) in asyncCases) {
        test(
            'should return $result for $iterable with an asynchronous predicate',
            () async {
          expect(await someAsync(f, toAsync(iterable)), equals(result));
        });
      }

      test('should be able to be used in the pipeline', () async {
        final res1 = await pipe(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9]), [
          (FxAsyncIterable<int> a) => filterAsync((int n) => n % 2 == 0, a),
          (FxAsyncIterable<int> a) => someAsync((int n) => n % 2 == 0, a),
        ]);
        expect(res1, equals(true));

        final res2 = await pipe(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9]), [
          (FxAsyncIterable<int> a) => mapAsync((int n) => n + 10, a),
          (FxAsyncIterable<int> a) => someAsync((int n) => n > 10, a),
        ]);
        expect(res2, equals(true));

        final res3 = await pipe(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9]), [
          (FxAsyncIterable<int> a) => mapAsync((int n) => n + 10, a),
          (FxAsyncIterable<int> a) =>
              someAsync((int n) => Future.value(n < 10), a),
        ]);
        expect(res3, equals(false));

        final res4 = await pipe(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9]), [
          (FxAsyncIterable<int> a) => mapAsync((int n) => n + 10, a),
          (FxAsyncIterable<int> a) =>
              someAsync((int n) => Future.value(n < 15), a),
        ]);
        expect(res4, equals(true));
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        final res1 = await fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9]))
            .filter((a) => a % 2 == 0)
            .some((a) => a % 2 == 0);
        expect(res1, equals(true));

        final res2 = await fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9]))
            .map((a) => a + 10)
            .some((a) => a > 10);
        expect(res2, equals(true));

        final res3 = await fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9]))
            .map((a) => a + 10)
            .some((a) => Future.value(a < 10));
        expect(res3, equals(false));

        final res4 = await fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9]))
            .map((a) => a + 10)
            .some((a) => Future.value(a < 15));
        expect(res4, equals(true));
      });
    });
  });
}
