import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/toSorted.spec.ts. In Dart, `fxToSorted` is an alias of
// `sort` (both are non-mutating); the async section uses `fxSortAsync` since
// only the sync alias exists.
int sortFn(Object? a, Object? b) =>
    Comparable.compare(a as Comparable<Object?>, b as Comparable<Object?>);

void main() {
  group('toSorted', () {
    group('sync', () {
      test('should sort the elements (empty)', () {
        expect(fxToSorted(sortFn, <Object?>[]), equals(<Object?>[]));
      });

      test('should sort the elements (numbers)', () {
        expect(
          fxToSorted(sortFn, [3, 4, 1, 2, 5, 2]),
          equals([1, 2, 2, 3, 4, 5]),
        );
      });

      test('should sort the elements (string chars)', () {
        expect(
          fxToSorted(sortFn, 'bcdaef'.split('')),
          equals(['a', 'b', 'c', 'd', 'e', 'f']),
        );
      });

      test('should handle single element', () {
        expect(fxToSorted(sortFn, [42]), equals([42]));
      });

      test('should handle array with identical elements', () {
        expect(fxToSorted(sortFn, [5, 5, 5, 5]), equals([5, 5, 5, 5]));
      });

      test('should be immutable - original array should not be changed', () {
        final original = [3, 4, 1, 2, 5, 2];
        final result = fxToSorted(sortFn, original);
        expect(identical(original, result), isFalse);
        expect(original, equals([3, 4, 1, 2, 5, 2]));
      });

      test(
        'should return the same result as sort (both non-mutating in Dart)',
        () {
          final arr1 = [3, 4, 1, 2, 5, 2];
          final arr2 = [3, 4, 1, 2, 5, 2];
          final sortedResult = fxSort(sortFn, arr1);
          final toSortedResult = fxToSorted(sortFn, arr2);

          expect(toSortedResult, equals(sortedResult));
          // Unlike JS, the Dart port's sort never mutates either.
          expect(arr1, equals([3, 4, 1, 2, 5, 2]));
          expect(arr2, equals([3, 4, 1, 2, 5, 2]));
        },
      );

      test('should be able to be used in the pipeline', () {
        final res = pipe(
          [3, 4, 1, 2, 5, 2],
          [
            (Iterable<int> a) => fxFilter((int n) => n % 2 != 0, a),
            (Iterable<int> a) => fxToSorted(sortFn, a),
          ],
        );
        expect(res, equals([1, 3, 5]));
      });

      test('should work with other functions in pipeline', () {
        final res = pipe(
          [3, 4, 1, 2, 5, 2],
          [
            (Iterable<int> a) => fxMap((int n) => n * 2, a),
            (Iterable<int> a) => fxFilter((int n) => n > 4, a),
            (Iterable<int> a) => fxToSorted(sortFn, a),
          ],
        );
        expect(res, equals([6, 8, 10]));
      });

      test('should preserve immutability in pipeline', () {
        final original = [3, 4, 1, 2, 5, 2];
        final originalCopy = [...original];
        final res = pipe(original, [
          (Iterable<int> a) => fxToSorted(sortFn, a),
        ]);
        expect(original, equals(originalCopy));
        expect(res, equals([1, 2, 2, 3, 4, 5]));
      });
    });

    group('async (via sortAsync — no async toSorted alias)', () {
      test('should sort the elements (numbers)', () async {
        expect(
          await fxSortAsync(sortFn, fxToAsync([3, 4, 1, 2, 5, 2])),
          equals([1, 2, 2, 3, 4, 5]),
        );
      });

      test('should work with other functions in async pipeline', () async {
        final res = await pipe(
          [3, 4, 1, 2, 5, 2],
          [
            (List<int> a) => fxToAsync(a),
            (FxAsyncIterable<int> a) => fxMapAsync((int n) => n * 2, a),
            (FxAsyncIterable<int> a) => fxFilterAsync((int n) => n > 4, a),
            (FxAsyncIterable<int> a) => fxSortAsync(sortFn, a),
          ],
        );
        expect(res, equals([6, 8, 10]));
      });
    });
  });
}
