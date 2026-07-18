import 'package:fxdart/fxdart.dart' hide isNull;
import 'package:test/test.dart';

void main() {
  group('always', () {
    test('should always return the specified value', () {
      final returnValue = {'key': 'value'};
      expect(always(returnValue)(), same(returnValue));
      expect(always(returnValue)(''), same(returnValue));
      expect(always(returnValue)(1), same(returnValue));

      expect(always(null)(), isNull);
      expect(always(null)(''), isNull);
      expect(always(null)(1), isNull);
    });
  });
}
