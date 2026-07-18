import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('entries', () {
    test('should return an iterable that iterates entries of the given map',
        () {
      final map = <String, Object?>{
        'a': 1,
        'b': '2',
        'c': true,
        'd': null,
      };
      final res = entries(map).toList();
      expect(res, equals([('a', 1), ('b', '2'), ('c', true), ('d', null)]));
    });

    test('should return entries lazily', () {
      final it = entries({'a': 1, 'b': 2, 'c': 3}).iterator;
      expect(it.moveNext(), isTrue);
      expect(it.current, equals(('a', 1)));
      final rest = <(String, int)>[];
      while (it.moveNext()) {
        rest.add(it.current);
      }
      expect(rest, equals([('b', 2), ('c', 3)]));
    });

    test('should handle empty Map', () {
      expect(entries(<String, int>{}).toList(), equals(<(String, int)>[]));
    });

    test('should preserve Map key types', () {
      final res = entries(<int, String>{1: 'a', 2: 'b'}).toList();
      expect(res, equals([(1, 'a'), (2, 'b')]));
    });
  });
}
