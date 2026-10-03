import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/props.spec.ts. The Dart port operates on Maps only
// (no arrays / null targets — those are JS-specific).
void main() {
  group('props', () {
    final obj = {
      'a': 'v1',
      'b': 'v2',
      'c': 'v3',
      'd': 'v4',
      'e': 'v5',
      'f': 'v6',
    };

    test('should return empty array if no properties requested', () {
      expect(fxProps(<String>[], obj), equals(<String?>[]));
    });

    test('should return values for requested properties', () {
      expect(fxProps(['a', 'e'], obj), equals(['v1', 'v5']));
    });

    test('should preserve order', () {
      expect(fxProps(['f', 'c', 'e'], obj), equals(['v6', 'v3', 'v5']));
    });

    test('should return null for nonexistent properties', () {
      expect(fxProps(['a', 'nonexistent'], obj), equals(['v1', null]));
    });

    test('should be able to be used in the pipeline', () async {
      final syncRes = pipe(obj, [
        (Map<String, String> m) => fxProps(['a', 'b'], m),
        (List<String?> vs) => fxToList(vs),
      ]);
      expect(syncRes, equals(['v1', 'v2']));

      final asyncRes = await pipe(Future.value(obj), [
        (Map<String, String> m) => fxProps(['a', 'b'], m),
      ]);
      expect(asyncRes, equals(['v1', 'v2']));
    });
  });
}
