import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

void main() {
  group('sumByDouble', () {
    test('sums as double', () {
      final double r = sumByDouble((({double v}) x) => x.v, [
        (v: 1.5),
        (v: 2.25),
      ]);
      expect(r, 3.75);
      expect(sumByDouble((int x) => x / 2, fxRange(4)), 3.0);
    });

    test('empty is 0.0', () {
      final r = sumByDouble((double x) => x, <double>[]);
      expect(r, 0.0);
      expect(r, isA<double>());
    });

    test('same rounding as fxSumBy (left to right)', () {
      final xs = [0.1, 0.2, 0.3, 1e16, -1e16];
      expect(sumByDouble((double x) => x, xs), fxSumBy((double x) => x, xs));
    });

    test('chain and async', () async {
      final double c = fx([1, 2, 3]).sumByDouble((x) => x * 0.5);
      expect(c, 3.0);
      final double a = await fxAsync(
        fxToAsync([1, 2]),
      ).sumByDouble((x) async => x * 1.0);
      expect(a, 3.0);
      expect(
        await sumByDoubleAsync((double x) => x, fxToAsync(<double>[])),
        0.0,
      );
    });
  });
}
