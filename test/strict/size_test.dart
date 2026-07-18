import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/size.spec.ts.
void main() {
  group('size', () {
    group('sync', () {
      test('should return the size of elements (list)', () {
        expect(size([1, 2, 3, 4, 5]), equals(5));
      });

      test('should return the size of elements (string chars)', () {
        expect(size('abcdef'.split('')), equals(6));
      });
    });

    group('async', () {
      test('should return the size of elements (list)', () async {
        expect(await sizeAsync(toAsync([1, 2, 3, 4, 5])), equals(5));
      });

      test('should return the size of elements (string chars)', () async {
        expect(await sizeAsync(toAsync('abcdef'.split(''))), equals(6));
      });
    });
  });
}
