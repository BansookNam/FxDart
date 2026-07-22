import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/omit.spec.ts. The Dart port has no async-keys
// variant (keys are a plain Iterable), so the async section is not portable.
void main() {
  group('omit', () {
    group('sync', () {
      test('should be omitted properties as given keys', () {
        final obj = {'a': 1, 'b': 2, 'c': '3'};
        expect(omit(['a', 'c'], obj), equals({'b': 2}));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe({
          'a': 1,
          'b': '2',
          'c': true
        }, [
          (Map<String, Object> m) => omit(['a', 'b'], m),
          (Map<String, Object> m) => toList(entries(m)),
        ]);
        expect(res, equals([('c', true)]));
      });
    });
  });
}
