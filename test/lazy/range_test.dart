import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('range', () {
    test('start', () {
      expect(range(5).toList(), equals([0, 1, 2, 3, 4]));
    });

    test('start end', () {
      expect(range(1, 5).toList(), equals([1, 2, 3, 4]));
    });

    test('start end step', () {
      expect(range(1, 10, 2).toList(), equals([1, 3, 5, 7, 9]));
    });

    test('negative step', () {
      expect(range(1, 10, -2).toList(), equals(<int>[]));
      expect(range(10, 1, -2).toList(), equals([10, 8, 6, 4, 2]));
    });
  });
}
