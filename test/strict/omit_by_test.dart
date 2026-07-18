import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/omitBy.spec.ts. The predicate receives a
// `(key, value)` record; the Dart port has no async-predicate variant.
void main() {
  group('omitBy', () {
    group('sync', () {
      final obj = <String, Object>{'a': 1, 'b': '2', 'c': true};

      test('should be omitted properties by given predicate function', () {
        expect(
            omitBy((e) => e.$1 == 'b' || e.$2 is bool, obj), equals({'a': 1}));
      });

      test('should be omitted properties matching by value type', () {
        expect(omitBy((e) => e.$2 is String || e.$2 is bool, obj),
            equals({'a': 1}));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe({
          'a': 1,
          'b': '2',
          'c': true
        }, [
          (Map<String, Object> m) =>
              omitBy((e) => e.$1 == 'b' || e.$2 is bool, m),
        ]);
        expect(res, equals({'a': 1}));
      });
    });
  });
}
