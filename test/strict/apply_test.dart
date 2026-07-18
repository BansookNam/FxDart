import 'dart:math' as math;

import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

num max5(num a, num b, num c, num d, num e) => [a, b, c, d, e].reduce(math.max);

void main() {
  group('apply', () {
    test('should apply given list to the function', () {
      final res = apply<num>(max5, [1, 2, 3, 4, 5]);
      expect(res, equals(5));
    });

    test('should be able to be used in the pipeline', () {
      final args = fx(range(1, 6)).toArray();
      final res = apply<num>(max5, args);
      expect(res, equals(5));
    });
  });
}
