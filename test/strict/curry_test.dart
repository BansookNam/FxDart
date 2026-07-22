import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('curry (deprecated 2-arity stub)', () {
    test('should curry a binary function', () {
      // ignore: deprecated_member_use
      final curried = curry((int a, int b) => a + b);
      expect(curried(1)(2), equals(3));
    });

    test('should work with strings', () {
      // ignore: deprecated_member_use
      final curried = curry((String a, String b) => a + b);
      expect(curried('foo')('bar'), equals('foobar'));
    });

    test('curried function should be usable within a pipeline', () {
      // ignore: deprecated_member_use
      final multiply = curry((int a, int b) => a * b);
      final res = fx([1, 2, 3]).map((a) => multiply(10)(a) as int).toList();
      expect(res, equals([10, 20, 30]));
    });
  });
}
