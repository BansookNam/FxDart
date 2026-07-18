import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/nth.spec.ts. In the Dart port a negative index
// returns null (documented behavior) instead of throwing.
void main() {
  group('nth', () {
    group('sync', () {
      test('should return nth element', () {
        expect(nth(2, 'marpple'.split('')), equals('r'));
        expect(nth(10, 'marpple'.split('')), equals(null));
        expect(nth(-1, 'marpple'.split('')), equals(null));

        expect(nth(1, [1, 2, 3, 4]), equals(2));
        expect(nth(5, [1, 2, 3, 4]), equals(null));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe([
          1,
          2,
          3,
          4
        ], [
          (Iterable<int> a) => map((int n) => n + 10, a),
          (Iterable<int> a) => filter((int n) => n % 2 == 0, a),
          (Iterable<int> a) => nth(1, a),
        ]);
        expect(res, equals(14));
      });
    });

    group('async', () {
      test('should return nth element', () async {
        expect(await nthAsync(2, toAsync('marpple'.split(''))), equals('r'));
        expect(await nthAsync(10, toAsync('marpple'.split(''))), equals(null));

        expect(await nthAsync(1, toAsync([1, 2, 3, 4])), equals(2));
        expect(await nthAsync(5, toAsync([1, 2, 3, 4])), equals(null));
      });

      test('should be able to be used in the pipeline', () async {
        final res = await pipe(toAsync([1, 2, 3, 4]), [
          (FxAsyncIterable<int> a) => mapAsync((int n) => n + 10, a),
          (FxAsyncIterable<int> a) => filterAsync((int n) => n % 2 == 0, a),
          (FxAsyncIterable<int> a) => nthAsync(1, a),
        ]);
        expect(res, equals(14));
      });
    });
  });
}
