import 'package:fxdart/fxdart.dart' hide fxIsNull;
import 'package:test/test.dart';

void main() {
  group('always', () {
    test('should always return the specified value', () {
      final returnValue = {'key': 'value'};
      expect(fxAlways(returnValue)(), same(returnValue));
      expect(fxAlways(returnValue)(''), same(returnValue));
      expect(fxAlways(returnValue)(1), same(returnValue));

      expect(fxAlways(null)(), isNull);
      expect(fxAlways(null)(''), isNull);
      expect(fxAlways(null)(1), isNull);
    });
  });
}
