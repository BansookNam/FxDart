import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/last.spec.ts.
void main() {
  group('last', () {
    group('sync', () {
      test("should return last item of the given 'Iterable'", () {
        expect(fxLast(fxRange(5)), equals(4));
      });

      test("should return last item of the given 'Iterable' - array", () {
        expect(fxLast([1, 2, 3, 4]), equals(4));
      });

      test("should return last item of the given 'Iterable' - string", () {
        expect(fxLast('marpple'.split('')), equals('e'));
      });

      test('should be able to be used in the pipeline', () {
        final result = pipe(
          [1, 2, 3, 4],
          [
            (Iterable<int> a) => fxMap((int n) => n + 10, a),
            (Iterable<int> a) => fxFilter((int n) => n % 2 == 0, a),
            (Iterable<int> a) => fxLast(a),
          ],
        );
        expect(result, equals(14));
      });
    });

    group('async', () {
      test("should return last item of the given 'AsyncIterable'", () async {
        expect(await fxLastAsync(fxToAsync(fxRange(5))), equals(4));
      });

      test('should be able to be used in the pipeline', () async {
        final result = await pipe(fxToAsync([1, 2, 3, 4]), [
          (FxAsyncIterable<int> a) => fxMapAsync((int n) => n + 10, a),
          (FxAsyncIterable<int> a) => fxFilterAsync((int n) => n % 2 == 0, a),
          (FxAsyncIterable<int> a) => fxLastAsync(a),
        ]);
        expect(result, equals(14));
      });
    });
  });
}
