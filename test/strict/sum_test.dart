import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/sum.spec.ts.
void main() {
  group('sum', () {
    group('sync', () {
      test('should sum all elements [1, 2, 3]', () {
        expect(fxSum([1, 2, 3]), equals(6));
      });

      test('should switch to double accumulation at the first double', () {
        expect(fxSum([1, 2, 2.5]), equals(5.5));
        expect(fxSum([1, 2.5, 3]), equals(6.5));
      });

      test('should sum all elements []', () {
        expect(fxSum(<num>[]), equals(0));
      });

      test('should be able to be used in the pipeline', () {
        final res1 = pipe([1, 2, 3], [fxSum]);
        expect(res1, equals(6));
        final res2 = pipe(<num>[], [fxSum]);
        expect(res2, equals(0));
      });
    });

    group('async', () {
      test('should sum all elements [1, 2, 3]', () async {
        expect(await fxSumAsync(fxToAsync(<num>[1, 2, 3])), equals(6));
      });

      test('should sum all elements []', () async {
        expect(await fxSumAsync(fxToAsync(<num>[])), equals(0));
      });

      test('should be able to be used in the pipeline', () async {
        final res1 = await pipe(
          <num>[1, 2, 3],
          [
            (List<num> a) => fxToAsync(a),
            (FxAsyncIterable<num> a) => fxSumAsync(a),
          ],
        );
        expect(res1, equals(6));
        final res2 = await pipe(<num>[], [
          (List<num> a) => fxToAsync(a),
          (FxAsyncIterable<num> a) => fxSumAsync(a),
        ]);
        expect(res2, equals(0));
      });
    });
  });
}
