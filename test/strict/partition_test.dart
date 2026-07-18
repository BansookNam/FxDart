import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/partition.spec.ts. The AsyncFunctionException test
// is JS-specific (Dart's typed predicates cannot return a Future here).
void main() {
  group('partition', () {
    group('sync', () {
      test("should be split in two parts by the callback", () {
        final res = partition((int a) => a % 2 == 0, [1, 2, 3, 4, 5, 6]);
        expect(res.$1, equals([2, 4, 6]));
        expect(res.$2, equals([1, 3, 5]));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe([
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
          (Iterable<int> a) => map((int n) => n + 1, a),
          (Iterable<int> a) => partition((int n) => n % 2 == 0, a),
        ]) as (List<int>, List<int>);

        expect(res.$1, equals([2, 4, 6, 8, 10]));
        expect(res.$2, equals([3, 5, 7, 9]));
      });

      test('should be able to be used as a chaining method in the `fx`', () {
        final res = fx([1, 2, 3, 4, 5, 6, 7, 8, 9])
            .map((a) => a + 1)
            .partition((a) => a % 2 == 0);

        expect(res.$1, equals([2, 4, 6, 8, 10]));
        expect(res.$2, equals([3, 5, 7, 9]));
      });
    });

    group('async', () {
      test("should be split in two parts by the callback", () async {
        final res = await partitionAsync(
            (int a) => a % 2 == 0, toAsync([1, 2, 3, 4, 5, 6]));
        expect(res.$1, equals([2, 4, 6]));
        expect(res.$2, equals([1, 3, 5]));
      });

      test('should work well when the given function is asynchronous',
          () async {
        final res = await partitionAsync(
            (int a) => Future.value(a % 2 == 0), toAsync([1, 2, 3, 4, 5, 6]));
        expect(res.$1, equals([2, 4, 6]));
        expect(res.$2, equals([1, 3, 5]));
      });

      test('should be able to be used as a chaining method in the `fx`',
          () async {
        final res = await fxAsync(toAsync([1, 2, 3, 4, 5, 6, 7, 8, 9]))
            .map((a) => a + 1)
            .partition((a) => a % 2 == 0);

        expect(res.$1, equals([2, 4, 6, 8, 10]));
        expect(res.$2, equals([3, 5, 7, 9]));
      });
    });
  });
}
