import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/last.spec.ts.
void main() {
  group('last', () {
    group('sync', () {
      test("should return last item of the given 'Iterable'", () {
        expect(last(range(5)), equals(4));
      });

      test("should return last item of the given 'Iterable' - array", () {
        expect(last([1, 2, 3, 4]), equals(4));
      });

      test("should return last item of the given 'Iterable' - string", () {
        expect(last('marpple'.split('')), equals('e'));
      });

      test('should be able to be used in the pipeline', () {
        final result = pipe([
          1,
          2,
          3,
          4
        ], [
          (Iterable<int> a) => map((int n) => n + 10, a),
          (Iterable<int> a) => filter((int n) => n % 2 == 0, a),
          (Iterable<int> a) => last(a),
        ]);
        expect(result, equals(14));
      });
    });

    group('async', () {
      test("should return last item of the given 'AsyncIterable'", () async {
        expect(await lastAsync(toAsync(range(5))), equals(4));
      });

      test('should be able to be used in the pipeline', () async {
        final result = await pipe(toAsync([1, 2, 3, 4]), [
          (FxAsyncIterable<int> a) => mapAsync((int n) => n + 10, a),
          (FxAsyncIterable<int> a) => filterAsync((int n) => n % 2 == 0, a),
          (FxAsyncIterable<int> a) => lastAsync(a),
        ]);
        expect(result, equals(14));
      });
    });
  });
}
