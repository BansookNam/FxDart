import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/negate.spec.ts. Dart has no `undefined` or `Symbol`;
// `fxIsUndefined` is an alias of `fxIsNull` (deprecated), `fxIsArray` of `fxIsList`.
void main() {
  group('negate', () {
    group('negate isUndefined', () {
      // ignore: deprecated_member_use
      final isDefined = fxNegate(fxIsUndefined);

      for (final a in <Object>[2, true, <String, int>{}, <int>[], 'a']) {
        test('given non-null ($a) then should be true', () {
          expect(isDefined(a), equals(true));
        });
      }

      test('given null then should be false', () {
        expect(isDefined(null), equals(false));
      });
    });

    group('negate isArray', () {
      // ignore: deprecated_member_use
      final isNotArray = fxNegate(fxIsArray);

      for (final s in <Object?>[null, true, 1, 'a', () => null]) {
        test('given non array ($s) then should return true', () {
          expect(isNotArray(s), equals(true));
        });
      }

      test('given array then should return false', () {
        expect(isNotArray([1, 2, 3]), equals(false));
      });
    });

    group('negate isEmpty', () {
      final isNotEmpty = fxNegate(fxIsEmpty);

      final testParameters = <(Object?, bool)>[
        (1, false),
        (0, false),
        (false, false),
        (true, false),
        (DateTime.now(), false),
        (null, true),
        (<String, int>{}, true),
        ({'a': 1}, false),
        (<int>[], true),
        ([1], false),
        ('', true),
        ('a', false),
        (() {}, false),
      ];

      for (final (input, expected) in testParameters) {
        test('should return `${!expected}` for $input', () {
          expect(isNotEmpty(input), equals(!expected));
        });
      }
    });

    group('negate isNil', () {
      final isNotNil = fxNegate(fxIsNil);

      test('given null then should return false', () {
        expect(isNotNil(null), equals(false));
      });

      for (final value in <Object>[3, '3', <String, int>{}, false]) {
        test('given non-null ($value) then should return true', () {
          expect(isNotNil(value), equals(true));
        });
      }
    });
  });
}
