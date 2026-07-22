import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/pick.spec.ts. The Dart port has no async-keys
// variant (keys are a plain Iterable), so the async section is not portable.
void main() {
  group('pick', () {
    group('sync', () {
      test('should be picked properties as given keys', () {
        final obj = {'a': 1, 'b': 2, 'c': '3'};
        expect(pick(['a', 'c'], obj), equals({'a': 1, 'c': '3'}));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe({
          'a': 1,
          'b': '2',
          'c': true
        }, [
          (Map<String, Object> m) => pick(['a', 'b'], m),
          (Map<String, Object> m) => toList(entries(m)),
        ]);
        expect(res, equals([('a', 1), ('b', '2')]));
      });
    });
  });
}
