import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/pickBy.spec.ts. The predicate receives a
// `(key, value)` record; the Dart port has no async-predicate variant.
void main() {
  group('pickBy', () {
    group('sync', () {
      final obj = <String, Object>{'a': 1, 'b': '2', 'c': true};

      test('should be picked properties by given predicate function', () {
        expect(pickBy((e) => e.$1 == 'b' || e.$2 is bool, obj),
            equals({'b': '2', 'c': true}));
      });

      test('should be picked properties matching by value type', () {
        expect(pickBy((e) => e.$2 is String || e.$2 is bool, obj),
            equals({'b': '2', 'c': true}));
      });

      test('should be able to be used in the pipeline', () {
        final res = pipe({
          'a': 1,
          'b': '2',
          'c': true
        }, [
          (Map<String, Object> m) =>
              pickBy((e) => e.$1 == 'b' || e.$2 is bool, m),
        ]);
        expect(res, equals({'b': '2', 'c': true}));
      });
    });
  });
}
