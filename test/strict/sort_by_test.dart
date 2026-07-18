import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/sortBy.spec.ts.
void main() {
  group('sortBy', () {
    group('sync', () {
      test("should sort the elements by 'f' (identity, empty)", () {
        expect(sortBy(identity, <Object?>[]), equals(<Object?>[]));
      });

      test("should sort the elements by 'f' (identity, numbers)", () {
        expect(
            sortBy(identity, [3, 4, 1, 2, 5, 2]), equals([1, 2, 2, 3, 4, 5]));
      });

      test("should sort the elements by 'f' (identity, string chars)", () {
        expect(sortBy(identity, 'bcdae'.split('')),
            equals(['a', 'b', 'c', 'd', 'e']));
      });

      test("should sort the elements by 'f' (key extractor)", () {
        final res = sortBy((Map<String, Object> a) => a['id'], [
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
            ]));
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
          (Iterable<int> a) => sortBy(identity, a),
        ]);
        expect(res, equals([1, 3, 5]));
      });
    });

    group('async', () {
      test("should sort the elements by 'f' (identity, empty)", () async {
        expect(await sortByAsync(identity, toAsync(<Object?>[])),
            equals(<Object?>[]));
      });

      test("should sort the elements by 'f' (identity, numbers)", () async {
        expect(await sortByAsync(identity, toAsync([3, 4, 1, 2, 5, 2])),
            equals([1, 2, 2, 3, 4, 5]));
      });

      test("should sort the elements by 'f' (identity, string chars)",
          () async {
        expect(await sortByAsync(identity, toAsync('bcdae'.split(''))),
            equals(['a', 'b', 'c', 'd', 'e']));
      });

      test("should sort the elements by 'f' (key extractor)", () async {
        final res = await sortByAsync(
            (Map<String, Object> a) => a['id'],
            toAsync([
              {'id': 4, 'name': 'foo'},
              {'id': 2, 'name': 'bar'},
              {'id': 3, 'name': 'lee'},
            ]));
        expect(
            res,
            equals([
              {'id': 2, 'name': 'bar'},
              {'id': 3, 'name': 'lee'},
              {'id': 4, 'name': 'foo'},
            ]));
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
          (FxAsyncIterable<int> a) => sortByAsync(identity, a),
        ]);
        expect(res, equals([1, 3, 5]));
      });
    });
  });
}
