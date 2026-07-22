import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

int add2(int a, int b) => a + b;
int add3(int a, int b, int c) => a + b + c;
int add4(int a, int b, int c, int d) => a + b + c + d;
int add5(int a, int b, int c, int d, int e) => a + b + c + d + e;

void main() {
  group('curried', () {
    test('should curry a binary function', () {
      expect(add2.curried(1)(2), equals(3));
    });

    test('should curry arities 3 through 5', () {
      expect(add3.curried(1)(2)(3), equals(6));
      expect(add4.curried(1)(2)(3)(4), equals(10));
      expect(add5.curried(1)(2)(3)(4)(5), equals(15));
    });

    test('should keep full static types', () {
      String describe(String name, int age) => '$name is $age';
      final String Function(int) Function(String) curried = describe.curried;
      final String Function(int) forAlice = curried('Alice');
      expect(forAlice(30), equals('Alice is 30'));
    });

    test('partial application should be usable within a pipeline', () {
      int multiply(int a, int b) => a * b;
      final res = fx([1, 2, 3]).map(multiply.curried(10)).toList();
      expect(res, equals([10, 20, 30]));
    });

    test('should work on function expressions via a typed variable', () {
      // ignore: prefer_function_declarations_over_variables
      final concat = (String a, String b) => a + b;
      expect(concat.curried('foo')('bar'), equals('foobar'));
    });
  });

  group('uncurried', () {
    test('should uncurry a 2-level chain', () {
      final curried = add2.curried;
      expect(curried.uncurried(1, 2), equals(3));
    });

    test('should uncurry 3- through 5-level chains', () {
      expect(add3.curried.uncurried(1, 2, 3), equals(6));
      expect(add4.curried.uncurried(1, 2, 3, 4), equals(10));
      expect(add5.curried.uncurried(1, 2, 3, 4, 5), equals(15));
    });

    test('should uncurry hand-written closures', () {
      // ignore: prefer_function_declarations_over_variables
      final greet = (String greeting) => (String name) => '$greeting, $name!';
      expect(greet.uncurried('Hello', 'FxDart'), equals('Hello, FxDart!'));
    });

    test('explicit extension application flattens fewer levels', () {
      final curried = add3.curried; // A => B => C => int
      final partial = Uncurry2(curried).uncurried; // (A, B) => C => int
      expect(partial(1, 2)(3), equals(6));
    });
  });
}
