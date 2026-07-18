import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('keys', () {
    test('should return an iterable that iterates keys of the given map', () {
      final map = <String, Object?>{
        'a': 1,
        'b': '2',
        'c': true,
        'f': null,
      };
      expect(keys(map).toList(), equals(['a', 'b', 'c', 'f']));
    });

    test('should handle empty Map', () {
      expect(keys(<String, int>{}).toList(), equals(<String>[]));
    });

    test('should preserve Map key types', () {
      expect(keys(<int, String>{1: 'a', 2: 'b'}).toList(), equals([1, 2]));
    });
  });
}
