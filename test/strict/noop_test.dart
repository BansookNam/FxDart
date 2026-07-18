import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/noop.spec.ts (`undefined` return becomes "returns
// normally and produces nothing" in Dart).
void main() {
  group('noop', () {
    test('should do nothing and return normally', () {
      expect(() => noop(), returnsNormally);
    });
  });
}
