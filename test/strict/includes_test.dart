import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('includes', () {
    group('sync', () {
      test('should check if the specified value is equal.', () {
        expect(fxIncludes('r', 'marpple'.split('')), isTrue);
        expect(fxIncludes('b', 'marpple'.split('')), isFalse);

        expect(fxIncludes(1, [1, 2, 3, 4]), isTrue);
        expect(fxIncludes(5, [1, 2, 3, 4]), isFalse);
      });

      test('should be able to be used in the pipeline', () {
        final res1 = fxIncludes(
          14,
          fx([1, 2, 3, 4]).map((a) => a + 10).filter((a) => a % 2 == 0),
        );
        expect(res1, isTrue);
      });
    });

    group('async', () {
      test('should check if the specified value is equal.', () async {
        expect(
          await fxIncludesAsync('r', fxToAsync('marpple'.split(''))),
          isTrue,
        );
        expect(
          await fxIncludesAsync('b', fxToAsync('marpple'.split(''))),
          isFalse,
        );

        expect(await fxIncludesAsync(1, fxToAsync([1, 2, 3, 4])), isTrue);
        expect(await fxIncludesAsync(5, fxToAsync([1, 2, 3, 4])), isFalse);
      });

      test('should be able to be used in the pipeline', () async {
        final res1 = await fxIncludesAsync(
          14,
          fxFilterAsync(
            (int a) => a % 2 == 0,
            fxMapAsync((int a) => a + 10, fxToAsync([1, 2, 3, 4])),
          ),
        );
        expect(res1, isTrue);
      });
    });
  });
}
