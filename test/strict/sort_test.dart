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
        expect(sort(sortFn, <Object?>[]), equals(<Object?>[]));
      });

      test('should sort the elements (numbers)', () {
        expect(sort(sortFn, [3, 4, 1, 2, 5, 2]), equals([1, 2, 2, 3, 4, 5]));
      });

      test('should sort the elements (string chars)', () {
        expect(sort(sortFn, 'bcdaef'.split('')),
            equals(['a', 'b', 'c', 'd', 'e', 'f']));
      });

      test('should not mutate the original list', () {
        final original = [3, 4, 1, 2, 5, 2];
        final result = sort(sortFn, original);
        expect(identical(original, result), isFalse);
        expect(original, equals([3, 4, 1, 2, 5, 2]));
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
          (Iterable<int> a) => sort(sortFn, a),
        ]);
        expect(res, equals([1, 3, 5]));
      });
    });

    group('async', () {
      test('should sort the elements (empty)', () async {
        expect(
            await sortAsync(sortFn, toAsync(<Object?>[])), equals(<Object?>[]));
      });

      test('should sort the elements (numbers)', () async {
        expect(await sortAsync(sortFn, toAsync([3, 4, 1, 2, 5, 2])),
            equals([1, 2, 2, 3, 4, 5]));
      });

      test('should sort the elements (string chars)', () async {
        expect(await sortAsync(sortFn, toAsync('bcdaef'.split(''))),
            equals(['a', 'b', 'c', 'd', 'e', 'f']));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await pipe([
          3,
          4,
          1,
          2,
          5,
          2
        ], [
          (List<int> a) => toAsync(a),
          (FxAsyncIterable<int> a) => filterAsync((int n) => n % 2 != 0, a),
          (FxAsyncIterable<int> a) => sortAsync(sortFn, a),
        ]);
        expect(res, equals([1, 3, 5]));
      });
    });
  });
}
