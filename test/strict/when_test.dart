import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart' hide isEmpty, isNull, isNotNull, isList, isMap;

// Ported from FxTS test/when.spec.ts.
void main() {
  group('when', () {
    group('with a general predicate', () {
      Object testFn(Object value) => when<Object>(
            (v) => v == 100,
            (v) {
              expect(v, equals(100));
              return 'value is 100';
            },
            value,
          );

      Object withPipe(Object value) => pipe(value, [
            testFn,
            (Object v) => when<Object>(isString, (_) => 'Hello fxts', v),
          ]) as Object;

      test(
          'If the input value is a number 100, the callback is executed and returns its result.',
          () {
        expect(testFn(100), equals('value is 100'));
      });

      test(
          'If the input value does not match predicate, it returns the original value.',
          () {
        expect(testFn('Hello World'), equals('Hello World'));
      });

      test("If nothing matches, all 'when' functions will be passed.", () {
        final input = [1, 2, 3, 4];
        expect(testFn(input), equals(input));
        expect(withPipe(input), equals(input));
      });
    });

    group('with a type-checking predicate', () {
      final circle = {'type': 'circle', 'radius': 10};
      final square = {'type': 'square', 'side': 5};

      bool isCircle(Object shape) => shape is Map && shape['type'] == 'circle';

      test(
          'should return the result of the callback when the predicate is true',
          () {
        final result = when<Object>(
          isCircle,
          (shape) => 'A circle with radius ${(shape as Map)['radius']}',
          circle,
        );
        expect(result, equals('A circle with radius 10'));
      });

      test('should return the original value when the predicate is false', () {
        final result = when<Object>(
          isCircle,
          (shape) => 'A circle with radius ${(shape as Map)['radius']}',
          square,
        );
        expect(result, equals(square));
      });

      test('should work correctly with pipe', () {
        Object shapeHandler(Object shape) => when<Object>(
              isCircle,
              (s) => 'A circle with radius ${(s as Map)['radius']}',
              shape,
            );

        expect(pipe(circle, [shapeHandler]), equals('A circle with radius 10'));
        expect(pipe(square, [shapeHandler]), equals(square));
      });
    });
  });
}
