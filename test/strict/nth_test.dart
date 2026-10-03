import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/nth.spec.ts. In the Dart port a negative index
// returns null (documented behavior) instead of throwing.
void main() {
  group('nth', () {
    group('sync', () {
      test('should return nth element', () {
        expect(fxNth(2, 'marpple'.split('')), equals('r'));
        expect(fxNth(10, 'marpple'.split('')), equals(null));
        expect(fxNth(-1, 'marpple'.split('')), equals(null));

        expect(fxNth(1, [1, 2, 3, 4]), equals(2));
        expect(fxNth(5, [1, 2, 3, 4]), equals(null));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe(
          [1, 2, 3, 4],
          [
            (Iterable<int> a) => fxMap((int n) => n + 10, a),
            (Iterable<int> a) => fxFilter((int n) => n % 2 == 0, a),
            (Iterable<int> a) => fxNth(1, a),
          ],
        );
        expect(res, equals(14));
      });
    });

    group('async', () {
      test('should return nth element', () async {
        expect(
          await fxNthAsync(2, fxToAsync('marpple'.split(''))),
          equals('r'),
        );
        expect(
          await fxNthAsync(10, fxToAsync('marpple'.split(''))),
          equals(null),
        );

        expect(await fxNthAsync(1, fxToAsync([1, 2, 3, 4])), equals(2));
        expect(await fxNthAsync(5, fxToAsync([1, 2, 3, 4])), equals(null));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await pipe(fxToAsync([1, 2, 3, 4]), [
          (FxAsyncIterable<int> a) => fxMapAsync((int n) => n + 10, a),
          (FxAsyncIterable<int> a) => fxFilterAsync((int n) => n % 2 == 0, a),
          (FxAsyncIterable<int> a) => fxNthAsync(1, a),
        ]);
        expect(res, equals(14));
      });
    });
  });
}
