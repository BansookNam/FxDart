import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/compactObject.spec.ts (`undefined` becomes `null`).
void main() {
  group('compactObject', () {
    test('should return identity map if there is no null property', () {
      final obj = <String, Object?>{'a': 1, 'b': 'b'};
      expect(compactObject(obj), equals(obj));
    });

    test('should return a map with null properties removed', () {
      final obj = <String, Object?>{'a': 1, 'b': 'b', 'c': null, 'd': null};
      expect(compactObject(obj), equals({'a': 1, 'b': 'b'}));
    });

    test('should not remove any falsy values other than null', () {
      final obj = <String, Object?>{'a': 0, 'b': '', 'd': null, 'e': false};
      expect(compactObject(obj), equals({'a': 0, 'b': '', 'e': false}));
    });
  });
}
