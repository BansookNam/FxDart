import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/resolveProps.spec.ts.
void main() {
  group('resolveProps', () {
    test('should resolve a map of futures to a future of a map', () async {
      final obj = <String, Object>{
        'a': Future.value(1),
        'b': Future.value('2'),
        'c': Future.value(true),
        'd': 'non-future value',
      };

      final result = await resolveProps(obj);
      expect(
          result,
          equals({
            'a': 1,
            'b': '2',
            'c': true,
            'd': 'non-future value',
          }));
    });
  });
}
