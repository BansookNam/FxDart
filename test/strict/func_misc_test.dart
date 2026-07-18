import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

void main() {
  group('not', () {
    test('should negate the boolean', () {
      expect(not(true), isFalse);
      expect(not(false), isTrue);
    });

    test('should be able to be used in the pipeline', () {
      expect(pipe(true, [not]), isFalse);
    });
  });

  group('sleep', () {
    test('should complete after the given duration', () async {
      final start = DateTime.now();
      await sleep(const Duration(milliseconds: 30));
      expect(DateTime.now().difference(start).inMilliseconds,
          greaterThanOrEqualTo(20));
    });
  });

  group('comparison operators', () {
    test('should throw when the values are not Comparable', () {
      expect(() => gt(Object(), Object()), throwsArgumentError);
      expect(() => lt(Object(), Object()), throwsArgumentError);
      expect(() => gte(Object(), Object()), throwsArgumentError);
      expect(() => lte(Object(), Object()), throwsArgumentError);
    });

    test('should throw when only one side is not Comparable', () {
      expect(() => gt(1, Object()), throwsArgumentError);
      expect(() => gt(Object(), 1), throwsArgumentError);
    });
  });
}
