import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

void main() {
  group('not', () {
    test('should negate the boolean', () {
      expect(fxNot(true), isFalse);
      expect(fxNot(false), isTrue);
    });

    test('should be able to be used in the pipeline', () {
      expect(pipe(true, [fxNot]), isFalse);
    });
  });

  group('sleep', () {
    test('should complete after the given duration', () async {
      final start = DateTime.now();
      await fxSleep(const Duration(milliseconds: 30));
      expect(
        DateTime.now().difference(start).inMilliseconds,
        greaterThanOrEqualTo(20),
      );
    });
  });

  group('comparison operators', () {
    test('should throw when the values are not Comparable', () {
      expect(() => fxGt(Object(), Object()), throwsArgumentError);
      expect(() => fxLt(Object(), Object()), throwsArgumentError);
      expect(() => fxGte(Object(), Object()), throwsArgumentError);
      expect(() => fxLte(Object(), Object()), throwsArgumentError);
    });

    test('should throw when only one side is not Comparable', () {
      expect(() => fxGt(1, Object()), throwsArgumentError);
      expect(() => fxGt(Object(), 1), throwsArgumentError);
    });
  });
}
