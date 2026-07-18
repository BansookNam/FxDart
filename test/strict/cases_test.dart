import 'package:fxdart/fxdart.dart';
import 'package:test/test.dart';

void main() {
  group('cases', () {
    test('should work in pipe', () {
      final res = fx([10, 20, 30])
          .map(cases<int, int>([
            ((n) => gt(15, n), (n) => n + 20),
            ((n) => gt(25, n), (n) => n + 10),
          ]))
          .toArray();
      expect(res, equals([30, 30, 30]));
    });

    test('should work with type-narrowing predicates', () {
      final res = fx([
        {'a': 'A', 'b': 'B'},
        {'a': 'A'},
      ])
          .map(cases<Map<String, String>, String>([
            ((n) => n.containsKey('b'), (n) => n['b']!),
          ], orElse: (n) => n['a']!))
          .toArray();
      expect(res, equals(['B', 'A']));

      final upper = cases<Object, String>([
        (isString, (s) => (s as String).toUpperCase()),
      ], orElse: (_) => 'not string');
      expect(upper('hello'), equals('HELLO'));
      expect(upper(123), equals('not string'));
    });

    test('should match first predicate', () {
      final res = fx([5, -5])
          .map(cases<int, Object>([
            ((n) => lt(0, n), always('positive')),
          ]))
          .toArray();
      expect(res, equals(['positive', -5]));
    });

    test('should throw when no case matches, no orElse, and value is not R',
        () {
      final f = cases<int, String>([
        ((n) => n < 0, (n) => 'negative'),
      ]);
      expect(() => f(1), throwsStateError);
    });
  });
}
