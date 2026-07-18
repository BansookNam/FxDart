import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/throwIf.spec.ts. The Dart port always takes an
// explicit `toError` (FxTS's default of throwing the value itself is not
// typable in Dart).
void main() {
  group('throwIf', () {
    test('if return of predicate is true', () {
      const input = 'input is string';
      expect(
        () => throwIf<Object>(isString, (v) => Exception('$v'), input),
        throwsA(isA<Exception>()),
      );
    });

    test('if return of predicate is false', () {
      const input = 10;
      expect(
          throwIf<Object>(isString, (v) => Exception('$v'), input), equals(10));
    });
  });
}
