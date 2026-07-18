import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/prop.spec.ts. The Dart port operates on Maps only
// (no arrays / null targets — those are JS-specific).
void main() {
  group('prop', () {
    test('should return the value for the given map property', () {
      final obj = <String, Object>{'a': 1, 'b': '2'};

      expect(prop('a', obj), equals(1));
      expect(prop('b', obj), equals('2'));
      expect(prop('c', obj), equals(null));
    });

    test('should be able to be used in the pipeline', () async {
      final data = {'content': ''};
      final obj = <String, Object>{'label': 'value', 'data': data};

      final syncRes = pipe(obj, [
        (Map<String, Object> m) => prop('data', m),
      ]);
      expect(identical(syncRes, data), isTrue);

      final asyncRes = await pipe(Future.value(obj), [
        (Map<String, Object> m) => prop('data', m),
      ]);
      expect(identical(asyncRes, data), isTrue);
    });
  });
}
