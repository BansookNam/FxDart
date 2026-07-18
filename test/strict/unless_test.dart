import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/unless.spec.ts.
void main() {
  group('unless', () {
    test('do process function if predicate returns false', () {
      var count = 0;
      final result = unless<Object>(isNumber, (input) {
        count += 1;
        return int.parse(input as String);
      }, '0');
      expect(result, equals(0));
      expect(count, equals(1));
    });

    test('skip process function if predicate returns true', () {
      var count = 0;
      final result = unless<Object>(isNumber, (input) {
        count += 1;
        return input;
      }, 0);
      expect(result, equals(0));
      expect(count, equals(0));
    });
  });
}
