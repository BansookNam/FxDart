import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/toSorted.spec.ts. In Dart, `toSorted` is an alias of
// `sort` (both are non-mutating); the async section uses `sortAsync` since
// only the sync alias exists.
int sortFn(Object? a, Object? b) =>
    Comparable.compare(a as Comparable<Object?>, b as Comparable<Object?>);

void main() {
  group('toSorted', () {
    group('sync', () {
      test('should sort the elements (empty)', () {
        expect(toSorted(sortFn, <Object?>[]), equals(<Object?>[]));
      });

      test('should sort the elements (numbers)', () {
        expect(
            toSorted(sortFn, [3, 4, 1, 2, 5, 2]), equals([1, 2, 2, 3, 4, 5]));
      });

      test('should sort the elements (string chars)', () {
        expect(toSorted(sortFn, 'bcdaef'.split('')),
            equals(['a', 'b', 'c', 'd', 'e', 'f']));
      });

      test('should handle single element', () {
        expect(toSorted(sortFn, [42]), equals([42]));
      });

      test('should handle array with identical elements', () {
        expect(toSorted(sortFn, [5, 5, 5, 5]), equals([5, 5, 5, 5]));
      });

      test('should be immutable - original array should not be changed', () {
        final original = [3, 4, 1, 2, 5, 2];
        final result = toSorted(sortFn, original);
        expect(identical(original, result), isFalse);
        expect(original, equals([3, 4, 1, 2, 5, 2]));
      });

      test('should return the same result as sort (both non-mutating in Dart)',
          () {
        final arr1 = [3, 4, 1, 2, 5, 2];
        final arr2 = [3, 4, 1, 2, 5, 2];
        final sortedResult = sort(sortFn, arr1);
        final toSortedResult = toSorted(sortFn, arr2);

        expect(toSortedResult, equals(sortedResult));
        // Unlike JS, the Dart port's sort never mutates either.
        expect(arr1, equals([3, 4, 1, 2, 5, 2]));
        expect(arr2, equals([3, 4, 1, 2, 5, 2]));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe([
          3,
          4,
          1,
          2,
          5,
          2
        ], [
          (Iterable<int> a) => filter((int n) => n % 2 != 0, a),
          (Iterable<int> a) => toSorted(sortFn, a),
        ]);
        expect(res, equals([1, 3, 5]));
      });

      test('should work with other functions in pipeline', () {
        final res = pipe([
          3,
          4,
          1,
          2,
          5,
          2
        ], [
          (Iterable<int> a) => map((int n) => n * 2, a),
          (Iterable<int> a) => filter((int n) => n > 4, a),
          (Iterable<int> a) => toSorted(sortFn, a),
        ]);
        expect(res, equals([6, 8, 10]));
      });

      test('should preserve immutability in pipeline', () {
        final original = [3, 4, 1, 2, 5, 2];
        final originalCopy = [...original];
        final res = pipe(original, [
          (Iterable<int> a) => toSorted(sortFn, a),
        ]);
        expect(original, equals(originalCopy));
        expect(res, equals([1, 2, 2, 3, 4, 5]));
      });
    });

    group('async (via sortAsync — no async toSorted alias)', () {
      test('should sort the elements (numbers)', () async {
        expect(await sortAsync(sortFn, toAsync([3, 4, 1, 2, 5, 2])),
            equals([1, 2, 2, 3, 4, 5]));
      });

      test('should work with other functions in async pipeline', () async {
        final res = await pipe([
          3,
          4,
          1,
          2,
          5,
          2
        ], [
          (List<int> a) => toAsync(a),
          (FxAsyncIterable<int> a) => mapAsync((int n) => n * 2, a),
          (FxAsyncIterable<int> a) => filterAsync((int n) => n > 4, a),
          (FxAsyncIterable<int> a) => sortAsync(sortFn, a),
        ]);
        expect(res, equals([6, 8, 10]));
      });
    });
  });
}
