import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/sortBy.spec.ts.
void main() {
  group('sortBy', () {
    group('sync', () {
      test("should sort the elements by 'f' (identity, empty)", () {
        expect(fxSortBy(fxIdentity, <Object?>[]), equals(<Object?>[]));
      });

      test("should sort the elements by 'f' (identity, numbers)", () {
        expect(
          fxSortBy(fxIdentity, [3, 4, 1, 2, 5, 2]),
          equals([1, 2, 2, 3, 4, 5]),
        );
      });

      test("should sort the elements by 'f' (identity, string chars)", () {
        expect(
          fxSortBy(fxIdentity, 'bcdae'.split('')),
          equals(['a', 'b', 'c', 'd', 'e']),
        );
      });

      test('should sort all-double keys (unboxed path)', () {
        expect(
          fxSortBy((double d) => d, [2.5, 0.5, 1.5]),
          equals([0.5, 1.5, 2.5]),
        );
      });

      test('should sort generic Comparable keys (DateTime)', () {
        final dates = [DateTime(2026, 3, 1), DateTime(2026, 1, 2)];
        expect(
          fxSortBy((DateTime d) => d, dates),
          equals([DateTime(2026, 1, 2), DateTime(2026, 3, 1)]),
        );
      });

      test('should not mutate the original list', () {
        // `_sortByImpl` copies via `iterable.toList()` before any merge
        // buffer is allocated, so the caller's list cannot be aliased.
        // The new `List.filled` workspaces only ever see that copy.
        final original = [3, 4, 1, 2, 5, 2];
        final result = fxSortBy(fxIdentity, original);
        expect(identical(original, result), isFalse);
        expect(original, equals([3, 4, 1, 2, 5, 2]));
      });

      test('should not mutate the original list (double keys, merge path)', () {
        final original = [2.5, 0.5, 1.5, 4.0, 3.0];
        final result = fxSortBy((double d) => d, original);
        expect(identical(original, result), isFalse);
        expect(original, equals([2.5, 0.5, 1.5, 4.0, 3.0]));
        expect(result, equals([0.5, 1.5, 2.5, 3.0, 4.0]));
      });

      test("should sort the elements by 'f' (key extractor)", () {
        final res = fxSortBy((Map<String, Object> a) => a['id'], [
          {'id': 4, 'name': 'foo'},
          {'id': 2, 'name': 'bar'},
          {'id': 3, 'name': 'lee'},
        ]);
        expect(
          res,
          equals([
            {'id': 2, 'name': 'bar'},
            {'id': 3, 'name': 'lee'},
            {'id': 4, 'name': 'foo'},
          ]),
        );
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe(
          [3, 4, 1, 2, 5, 2],
          [
            (Iterable<int> a) => fxFilter((int n) => n % 2 != 0, a),
            (Iterable<int> a) => fxSortBy(fxIdentity, a),
          ],
        );
        expect(res, equals([1, 3, 5]));
      });
    });

    group('async', () {
      test("should sort the elements by 'f' (identity, empty)", () async {
        expect(
          await fxSortByAsync(fxIdentity, fxToAsync(<Object?>[])),
          equals(<Object?>[]),
        );
      });

      test("should sort the elements by 'f' (identity, numbers)", () async {
        expect(
          await fxSortByAsync(fxIdentity, fxToAsync([3, 4, 1, 2, 5, 2])),
          equals([1, 2, 2, 3, 4, 5]),
        );
      });

      test(
        "should sort the elements by 'f' (identity, string chars)",
        () async {
          expect(
            await fxSortByAsync(fxIdentity, fxToAsync('bcdae'.split(''))),
            equals(['a', 'b', 'c', 'd', 'e']),
          );
        },
      );

      test("should sort the elements by 'f' (key extractor)", () async {
        final res = await fxSortByAsync(
          (Map<String, Object> a) => a['id'],
          fxToAsync([
            {'id': 4, 'name': 'foo'},
            {'id': 2, 'name': 'bar'},
            {'id': 3, 'name': 'lee'},
          ]),
        );
        expect(
          res,
          equals([
            {'id': 2, 'name': 'bar'},
            {'id': 3, 'name': 'lee'},
            {'id': 4, 'name': 'foo'},
          ]),
        );
      });

      test('should be able to be used in the pipeline', () async {
        final res = await pipe(
          [3, 4, 1, 2, 5, 2],
          [
            (List<int> a) => fxToAsync(a),
            (FxAsyncIterable<int> a) => fxFilterAsync((int n) => n % 2 != 0, a),
            (FxAsyncIterable<int> a) => fxSortByAsync(fxIdentity, a),
          ],
        );
        expect(res, equals([1, 3, 5]));
      });
    });
  });
}
