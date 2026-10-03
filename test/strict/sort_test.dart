import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/sort.spec.ts. The Dart `sort` always returns a new
// list and never mutates its input.
int sortFn(Object? a, Object? b) =>
    Comparable.compare(a as Comparable<Object?>, b as Comparable<Object?>);

void main() {
  group('sort', () {
    group('sync', () {
      test('should sort the elements (empty)', () {
        expect(fxSort(sortFn, <Object?>[]), equals(<Object?>[]));
      });

      test('should sort the elements (numbers)', () {
        expect(fxSort(sortFn, [3, 4, 1, 2, 5, 2]), equals([1, 2, 2, 3, 4, 5]));
      });

      test('should sort the elements (string chars)', () {
        expect(
          fxSort(sortFn, 'bcdaef'.split('')),
          equals(['a', 'b', 'c', 'd', 'e', 'f']),
        );
      });

      test('should not mutate the original list', () {
        final original = [3, 4, 1, 2, 5, 2];
        final result = fxSort(sortFn, original);
        expect(identical(original, result), isFalse);
        expect(original, equals([3, 4, 1, 2, 5, 2]));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe(
          [3, 4, 1, 2, 5, 2],
          [
            (Iterable<int> a) => fxFilter((int n) => n % 2 != 0, a),
            (Iterable<int> a) => fxSort(sortFn, a),
          ],
        );
        expect(res, equals([1, 3, 5]));
      });
    });

    group('async', () {
      test('should sort the elements (empty)', () async {
        expect(
          await fxSortAsync(sortFn, fxToAsync(<Object?>[])),
          equals(<Object?>[]),
        );
      });

      test('should sort the elements (numbers)', () async {
        expect(
          await fxSortAsync(sortFn, fxToAsync([3, 4, 1, 2, 5, 2])),
          equals([1, 2, 2, 3, 4, 5]),
        );
      });

      test('should sort the elements (string chars)', () async {
        expect(
          await fxSortAsync(sortFn, fxToAsync('bcdaef'.split(''))),
          equals(['a', 'b', 'c', 'd', 'e', 'f']),
        );
      });

      test('should be able to be used in the pipeline', () async {
        final res = await pipe(
          [3, 4, 1, 2, 5, 2],
          [
            (List<int> a) => fxToAsync(a),
            (FxAsyncIterable<int> a) => fxFilterAsync((int n) => n % 2 != 0, a),
            (FxAsyncIterable<int> a) => fxSortAsync(sortFn, a),
          ],
        );
        expect(res, equals([1, 3, 5]));
      });
    });
  });
}
