import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/size.spec.ts.
void main() {
  group('size', () {
    group('sync', () {
      test('should return the size of elements (list)', () {
        expect(fxSize([1, 2, 3, 4, 5]), equals(5));
      });

      test('should return the size of elements (string chars)', () {
        expect(fxSize('abcdef'.split('')), equals(6));
      });
    });

    group('async', () {
      test('should return the size of elements (list)', () async {
        expect(await fxSizeAsync(fxToAsync([1, 2, 3, 4, 5])), equals(5));
      });

      test('should return the size of elements (string chars)', () async {
        expect(await fxSizeAsync(fxToAsync('abcdef'.split(''))), equals(6));
      });
    });
  });
}
