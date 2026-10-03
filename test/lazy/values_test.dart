import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('values', () {
    test(
      "should return an iterable that iterates values of the given map's properties",
      () {
        final map = <String, Object?>{'a': 1, 'b': '2', 'c': true, 'd': null};
        expect(fxValues(map).toList(), equals([1, '2', true, null]));
      },
    );

    test('should handle empty Map', () {
      expect(fxValues(<String, int>{}).toList(), equals(<int>[]));
    });

    test('should preserve Map value types', () {
      expect(fxValues(<String, int>{'a': 1, 'b': 2}).toList(), equals([1, 2]));
    });
  });
}
